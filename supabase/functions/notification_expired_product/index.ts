import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";
import serviceAccount from "../service-account.json" with { type: "json" };

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_ANON_KEY")!
);

Deno.serve(async (req) => {
  try {
    const now = new Date(); // 📌 Obtener fecha actual en UTC
    console.log(`🕒 Ejecutando limpieza de productos caducados: ${now.toISOString()} (UTC)`);

    // 🔹 Buscar productos caducados
    const { data: productosCaducados, error: fetchError } = await supabase
      .from("productos")
      .select("idProducto, nombreProducto, fechaCaducidad, idPropietario")
      .lte("fechaCaducidad", now.toISOString());

    if (fetchError) throw fetchError;

    if (!productosCaducados || productosCaducados.length === 0) {
      console.log("✅ No hay productos caducados.");
      return new Response("No se encontraron productos caducados.", { status: 200 });
    }

    console.log(`⚠️ Se encontraron ${productosCaducados.length} productos caducados.`);

    let productosEliminados = 0;
    let propietariosNotificados = new Set();

    for (const producto of productosCaducados) {
      console.log(`🗑 Eliminando producto: ${producto.nombreProducto} (ID: ${producto.idProducto})`);

      // 🔥 Eliminar el producto
      const { error: deleteError } = await supabase
        .from("productos")
        .delete()
        .eq("idProducto", producto.idProducto);

      if (deleteError) {
        console.error(`❌ Error eliminando ${producto.nombreProducto}:`, deleteError);
        continue;
      }

      console.log(`✅ Producto ${producto.nombreProducto} eliminado con éxito.`);
      productosEliminados++;

      // 🔥 Guardar el propietario para notificarlo después
      propietariosNotificados.add(producto.idPropietario);
    }

    // 🔹 Obtener tokens de FCM de los propietarios
    const { data: propietarios, error: propietariosError } = await supabase
      .from("usuarios")
      .select("idUsuario, fcm_token")
      .in("idUsuario", Array.from(propietariosNotificados))
      .not("fcm_token", "is", null)
      .neq("fcm_token", "");

    if (propietariosError) {
      console.error("Error al obtener tokens de FCM de los propietarios:", propietariosError);
    }

    if (propietarios && propietarios.length > 0) {
      console.log(`🔔 Se enviarán notificaciones a ${propietarios.length} propietarios.`);

      // 🔥 Obtener token de acceso de Firebase
      const accessToken = await getAccessToken({
        clientEmail: serviceAccount.client_email,
        privateKey: serviceAccount.private_key,
      });

      // 🔹 Enviar notificación a cada propietario
      const notifications = propietarios.map(async (propietario) => {
        const fcmToken = propietario.fcm_token as string;

        return fetch(
          `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${accessToken}`,
            },
            body: JSON.stringify({
              message: {
                token: fcmToken,
                notification: {
                  title: "Producto Eliminado",
                  body: "Uno de sus productos ha sido eliminado debido a su fecha de caducidad.",
                },
              },
            }),
          }
        );
      });

      // 🔹 Ejecutar notificaciones en paralelo
      const results = await Promise.allSettled(notifications);
      const failed = results.filter((result) => result.status === "rejected");

      if (failed.length > 0) {
        console.error("Error enviando notificaciones:", failed);
      }
    }

    return new Response(`Se eliminaron ${productosEliminados} productos caducados y se notificó a los propietarios.`, {
      status: 200,
    });

  } catch (error) {
    console.error("❌ Error en la Edge Function:", error);
    return new Response("Error interno en la Edge Function.", { status: 500 });
  }
});

// ✅ **Función para obtener el token de acceso de Firebase**
const getAccessToken = ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string
  privateKey: string
}): Promise<string> => {
  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err)
        return
      }
      resolve(tokens!.access_token!)
    })
  })
};
