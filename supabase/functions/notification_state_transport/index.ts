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
  type: 'UPDATE'
  table: string
  record: Transport
  schema: 'public'
  old_record: null | Transport
}

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_ANON_KEY')!
);

Deno.serve(async (req) => {
  const payload: WebhookPayload = await req.json();
  const idCompra = payload.record.idCompra;

  // 🔹 Obtener idComprador de la compra
  const { data: compra, error: compraError } = await supabase
    .from('compras')
    .select('idComprador')
    .eq('id', idCompra)
    .maybeSingle();

  if (compraError || !compra?.idComprador) {
    console.error('⚠️ Error obteniendo idComprador:', compraError);
    return new Response(
      JSON.stringify({ error: 'No se pudo obtener el comprador' }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }

  // 🔹 Obtener token de FCM del comprador
  const { data: comprador, error: usuarioError } = await supabase
    .from('usuarios')
    .select('fcm_token')
    .eq('idUsuario', compra.idComprador)
    .maybeSingle();

  if (usuarioError || !comprador?.fcm_token) {
    console.log("⚠️ Comprador no tiene token de FCM.");
    return new Response(
      JSON.stringify({ message: "No hay comprador para notificar." }),
      { headers: { "Content-Type": "application/json" } }
    );
  }

  // 🔥 Obtener token de acceso de Firebase
  const accessToken = await getAccessToken({
    clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key,
  });

  // 🔹 Enviar notificación al comprador
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
          token: comprador.fcm_token,
          notification: {
            title: "Estado de Transporte",
            body: `El transporte ahora está ${payload.record.estado}.`,
          },
        },
      }),
    }
  );

  if (!response.ok) {
    console.error("⚠️ Error enviando notificación:", await response.text());
    return new Response(
      JSON.stringify({ error: "Error enviando la notificación" }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }

  return new Response(
    JSON.stringify({ message: "Notificación enviada con éxito" }),
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
