import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";
import serviceAccount from "../service-account.json" with { type: "json" };

interface Purchase {
  id: number;
  alternativaPago: string;
  nombreProducto: string;
  cantidad: string;
  total: string;
  fecha: string;
  imagenProducto: string;
  estadoCompra: string;
  idPropietario: string;
  idProducto: number;
  idComprador: string;
}

interface WebhookPayload {
  type: "INSERT";
  table: "compras";
  record: Purchase;
  schema: "public";
  old_record: null | Purchase;
}

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_ANON_KEY")!
);

Deno.serve(async (req) => {
  try {
    const payload: WebhookPayload = await req.json();

    //  Verificar que el evento es un INSERT en la tabla compras
    if (payload.table !== "compras" || payload.type !== "INSERT") {
      return new Response("No es un nuevo registro de compra.", { status: 200 });
    }

    console.log(`🛒 Nueva compra registrada con ID: ${payload.record.id}`);

    const idPropietario = payload.record.idPropietario;

    // Obtener el fcm_token del propietario del producto
    const { data: propietario, error: propietarioError } = await supabase
      .from("usuarios")
      .select("fcm_token")
      .eq("idUsuario", idPropietario)
      .maybeSingle();

    if (propietarioError || !propietario?.fcm_token) {
      console.error("⚠️ Error obteniendo fcm_token del propietario:", propietarioError);
      return new Response("Propietario no tiene token FCM.", { status: 200 });
    }

    console.log(`📲 Enviando notificación a propietario ${idPropietario}...`);

    //  Obtener token de acceso de Firebase
    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key,
    });

    //  Enviar notificación al propietario
    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: propietario.fcm_token,
            notification: {
              title: "Nueva Venta Realizada",
              body: `Has vendido ${payload.record.cantidad} unidades de ${payload.record.nombreProducto} por \$${payload.record.total}.`,
            },
          },
        }),
      }
    );

    if (!response.ok) {
      console.error("❌ Error enviando notificación:", await response.text());
      return new Response("Error al enviar la notificación.", { status: 500 });
    }

    console.log("✅ Notificación enviada con éxito.");
    return new Response("Notificación enviada correctamente.", { status: 200 });

  } catch (error) {
    console.error("❌ Error en la Edge Function:", error);
    return new Response("Error interno en la Edge Function.", { status: 500 });
  }
});

// Función para obtener el token de acceso de Firebase
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
