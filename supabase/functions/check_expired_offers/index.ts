import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";
import serviceAccount from "../service-account.json" with { type: "json" };

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_ANON_KEY")!
);

Deno.serve(async (req) => {
  try {
    const now = new Date(); // ⏳ Hora actual en UTC
    console.log(`🕒 Ejecutando Edge Function a las: ${now.toISOString()} (UTC)`);

    // 🔹 Buscar todas las ofertas que están "En Espera"
    const { data: ofertasPendientes, error: ofertasError } = await supabase
      .from("contra_oferta")
      .select("idContraOferta, idProducto, cantidad, created_at")
      .eq("estadoOferta", "En Espera");

    if (ofertasError) throw ofertasError;

    if (!ofertasPendientes || ofertasPendientes.length === 0) {
      console.log("✅ No hay ofertas pendientes.");
      return new Response("No hay ofertas expiradas.", { status: 200 });
    }

    let ofertasExpiradas = 0;

    for (const oferta of ofertasPendientes) {
      const { idProducto, cantidad, idContraOferta, created_at } = oferta;

      if (!created_at) {
        console.error(`❌ Error: La oferta ${idContraOferta} no tiene created_at.`);
        continue;
      }

      // 🔹 Convertir `created_at` de Colombia (UTC-5) a UTC
      const createdAtColombia = new Date(created_at); // Hora local
      createdAtColombia.setHours(createdAtColombia.getHours() + 5); // ✅ Ajustar a UTC

      const tiempoExpiracion = new Date(createdAtColombia.getTime() + 30 * 60 * 1000); // ✅ Sumar 30 minutos

      console.log(`🕒 Hora actual del servidor: ${now.toISOString()} (UTC)`);
      console.log(`⏳ Oferta ${idContraOferta}: Creada a las ${createdAtColombia.toISOString()} (UTC), Expira a las ${tiempoExpiracion.toISOString()} (UTC)`);
      console.log(`🔍 Comparación: ${now.toISOString()} >= ${tiempoExpiracion.toISOString()} --> ${now >= tiempoExpiracion}`);

      if (now >= tiempoExpiracion) {
        console.log(`⏳ Oferta ${idContraOferta} ha expirado. Procesando...`);

        // 🔹 Obtener la cantidad actual del producto
        const { data: producto, error: productoError } = await supabase
          .from("productos")
          .select("cantidad")
          .eq("idProducto", idProducto)
          .single();

        if (productoError || !producto) {
          console.error("❌ Error obteniendo producto:", productoError);
          continue;
        }

        const cantidadActual = producto.cantidad;
        const nuevaCantidad = cantidadActual + cantidad; // ✅ Sumar en lugar de reemplazar

        // 🔹 Actualizar la cantidad del producto
        const { error: updateError } = await supabase
          .from("productos")
          .update({ cantidad: nuevaCantidad })
          .eq("idProducto", idProducto);

        if (updateError) {
          console.error("❌ Error actualizando cantidad del producto:", updateError);
          continue;
        }

        // 🔹 Cambiar el estado de la oferta a "Rechazado"
        const { error: updateOfferError } = await supabase
          .from("contra_oferta")
          .update({ estadoOferta: "Rechazado" })
          .eq("idContraOferta", idContraOferta);

        if (updateOfferError) {
          console.error("❌ Error cambiando estado de oferta:", updateOfferError);
          continue;
        }

        console.log(`✅ Oferta ${idContraOferta} rechazada y cantidad restaurada.`);
        ofertasExpiradas++;
      }
    }

    return new Response(`✅ Se procesaron ${ofertasExpiradas} ofertas expiradas.`, {
      status: 200,
    });
  } catch (error) {
    console.error("❌ Error en la Edge Function:", error);
    return new Response("Error interno en la Edge Function.", {
      status: 500,
    });
  }
});
