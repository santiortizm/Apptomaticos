import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";
import serviceAccount from '../service-account.json' with { type: 'json' }

interface Buy {
  idProducto: number
  alternativaPago: string
  nombreProducto: string
  cantidad: number
  total: number
  fecha: string
  idPropietario: string
  idComprador: string
  idProducto: number
  imagenProducto: string
  idPropietario: string
  estadoCompra: string
}

interface WebhookPayload {
  type: 'INSERT'
  table: string
  record: Buy
  schema: 'public'
  old_record: null | Buy
}

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_ANON_KEY')!
)

Deno.serve(async (req) => {
  const payload: WebhookPayload = await req.json();

  //  Obtener SOLO los transportadores con fcm_token válido
  const { data: merchants, error } = await supabase
    .from('usuarios')
    .select('fcm_token')
    .eq('rol', 'Transportador')  //  Filtra SOLO transportadores
    .not('fcm_token', 'is', null)  //  Excluye usuarios sin token
    .neq('fcm_token', '')  //  Excluye tokens vacíos

  if (error) {
    console.error('Error al obtener transportadores:', error);
    return new Response(
      JSON.stringify({ error: 'No se pudo obtener transportadores' }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }

  if (!merchants || merchants.length === 0) {
    console.log("No hay transportadores registrados con token FCM.");
    return new Response(
      JSON.stringify({ message: "No hay transportadores para notificar." }),
      { headers: { "Content-Type": "application/json" } }
    );
  }

  //  Obtener token de acceso a Firebase
  const accessToken = await getAccessToken({
    clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key,
  });

  //  Enviar notificación a CADA comerciante
  const notifications = merchants.map(async (merchant) => {
    const fcmToken = merchant.fcm_token as string;

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
              title: "Transporte Disponible 🚚",
              body: `${payload.record.nombreProducto} carga de ${payload.record.cantidad} canastas.`,
            },
          },
        }),
      }
    );
  });

  //  Ejecutar todas las notificaciones en paralelo
  const results = await Promise.allSettled(notifications);

  //  Filtrar errores
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


//  **Función para obtener el token de acceso de Firebase**
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
