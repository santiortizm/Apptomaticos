import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";
import serviceAccount from "../service-account.json" with { type: "json" };

interface CounterOffer {
  idContraOferta: string;
  nombreProducto: string;
  cantidad: number;
  valorOferta: number;
  estadoOferta: string;
  imagenProducto: string;
  idProducto: string;
  idComprador: string;
  idPropietario: string;
}

interface WebhookPayload {
  type: "INSERT";
  table: "contra_oferta";
  record: CounterOffer;
  schema: "public";
  old_record: null | CounterOffer;
}

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_ANON_KEY")!
);

Deno.serve(async (req) => {
  try {
    const payload: WebhookPayload = await req.json();
    const { idProducto, idComprador, cantidad, valorOferta, idPropietario, nombreProducto, imagenProducto } = payload.record;

    console.log(` Nueva contraoferta recibida para el producto ${idProducto}`);

    //  Obtener el `fcm_token` del propietario
    const { data: propietario, error: ownerError } = await supabase
      .from("usuarios")
      .select("fcm_token")
      .eq("idUsuario", idPropietario)
      .single();

    if (ownerError || !propietario || !propietario.fcm_token) {
      console.error(" Error obteniendo token del propietario:", ownerError);
      return new Response("No se pudo obtener token del propietario", { status: 500 });
    }

    const fcmToken = propietario.fcm_token as string;

    //  Obtener token de acceso a Firebase
    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key,
    });

    //  Enviar notificación SOLO al propietario
    const notificationResponse = await fetch(
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
              title: "📩 Nueva Oferta Recibida 📩",
              body: `Tienes una nueva oferta de ${cantidad} unidades por \$${valorOferta} en ${nombreProducto}.`,
              image: imagenProducto,
            },
          },
        }),
      }
    );

    if (!notificationResponse.ok) {
      console.error(" Error enviando notificación:", await notificationResponse.text());
      return new Response("Error enviando notificación", { status: 500 });
    }

    console.log(` Notificación enviada al propietario ${idPropietario}`);
    return new Response("Notificación enviada con éxito", { status: 200 });

  } catch (error) {
    console.error(" Error en la Edge Function:", error);
    return new Response("Error interno en la Edge Function", { status: 500 });
  }
});

// 🔹 **Función para obtener el token de acceso de Firebase**
const getAccessToken = ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string;
  privateKey: string;
}): Promise<string> => {
  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
    });
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(tokens!.access_token!);
    });
  });
};
