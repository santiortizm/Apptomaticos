import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";
import serviceAccount from '../service-account.json' with { type: 'json' }

interface Product {
  idProducto: string
  nombreProducto: string
  cantidad: number
  descripcion: string
  maduracion: string
  fertilizantes: string
  fechaCosecha: string
  fechaCaducidad: string
  precio: number
  idImagen: string
  idPropietario: string
}

interface WebhookPayload {
  type: 'INSERT'
  table: string
  record: Product
  schema: 'public'
  old_record: null | Product
}

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_ANON_KEY')!
)

Deno.serve(async (req) => {
  const payload: WebhookPayload = await req.json();

  // ✅ Obtener SOLO los comerciantes con fcm_token válido
  const { data: merchants, error } = await supabase
    .from('usuarios')
    .select('fcm_token')
    .eq('rol', 'Comerciante')  // 🔹 Filtra SOLO comerciantes
    .not('fcm_token', 'is', null)  // 🔹 Excluye usuarios sin token
    .neq('fcm_token', '')  // 🔹 Excluye tokens vacíos

  if (error) {
    console.error('Error al obtener comerciantes:', error);
    return new Response(
      JSON.stringify({ error: 'No se pudo obtener comerciantes' }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }

  if (!merchants || merchants.length === 0) {
    console.log("No hay comerciantes registrados con token FCM.");
    return new Response(
      JSON.stringify({ message: "No hay comerciantes para notificar." }),
      { headers: { "Content-Type": "application/json" } }
    );
  }

  // ✅ Obtener token de acceso a Firebase
  const accessToken = await getAccessToken({
    clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key,
  });

  // ✅ Enviar notificación a CADA comerciante
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
              title: "Nuevo Producto Disponible",
              body: `${payload.record.nombreProducto} en venta por \$${payload.record.precio}.`,
            },
          },
        }),
      }
    );
  });

  // ✅ Ejecutar todas las notificaciones en paralelo
  const results = await Promise.allSettled(notifications);

  // ✅ Filtrar errores
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


// 🔹 **Función para obtener el token de acceso de Firebase**
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
