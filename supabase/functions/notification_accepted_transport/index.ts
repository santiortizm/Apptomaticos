import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";
import serviceAccount from '../service-account.json' with { type: 'json' }

interface Transport {
  idTransporte: number
  fechaCargue: string
  fechaEntrega: number
  estado: string
  pesoCarga: string
  valorTransporte: string
  idCompra: string
  idTransportador: string
}

interface WebhookPayload {
  type: 'INSERT'
  table: string
  record: Transport
  schema: 'public'
  old_record: null | Transport
}

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_ANON_KEY')!
)

Deno.serve(async (req) => {
  const payload: WebhookPayload = await req.json();
  const idCompra = payload.record.idCompra;

  // 🔹 Obtener idComprador y idPropietario de la compra
  const { data: compra, error: compraError } = await supabase
    .from('compras')
    .select('idComprador, idPropietario')
    .eq('id', idCompra)
    .maybeSingle();

  if (compraError || !compra) {
    console.error('Error al obtener datos de la compra:', compraError);
    return new Response(
      JSON.stringify({ error: 'No se pudo obtener los datos de la compra' }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }

  // 🔹 Obtener tokens de FCM para comprador y propietario
  const { data: usuarios, error: usuarioError } = await supabase
    .from('usuarios')
    .select('idUsuario, fcm_token')
    .in('idUsuario', [compra.idComprador, compra.idPropietario])
    .not('fcm_token', 'is', null)
    .neq('fcm_token', '');

  if (usuarioError) {
    console.error('Error al obtener tokens de FCM:', usuarioError);
    return new Response(
      JSON.stringify({ error: 'No se pudo obtener los tokens de FCM' }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }

  if (!usuarios || usuarios.length === 0) {
    console.log("No hay usuarios con token de FCM para notificar.");
    return new Response(
      JSON.stringify({ message: "No hay usuarios para notificar." }),
      { headers: { "Content-Type": "application/json" } }
    );
  }

  // 🔥 Obtener token de acceso de Firebase
  const accessToken = await getAccessToken({
    clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key,
  });

  // 🔹 Enviar notificación personalizada a comprador y propietario
  const notifications = usuarios.map(async (usuario) => {
    const fcmToken = usuario.fcm_token as string;
    const isComprador = usuario.idUsuario === compra.idComprador;

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
              title: "Notificación de Transporte",
              body: isComprador
                ? "El transporte de tu compra está confirmado. Se notificará cuando esté en camino."
                : "El transportador va en camino para realizar el cargue del producto.",
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
    return new Response(
      JSON.stringify({ error: "Algunas notificaciones fallaron" }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }

  return new Response(
    JSON.stringify({ message: "Notificaciones enviadas con éxito" }),
    { headers: { "Content-Type": "application/json" } }
  );
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
}
