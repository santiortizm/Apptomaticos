import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";
import serviceAccount from '../service-account.json' with { type: 'json' };

interface CounterOffer {
  idContraOferta: number;
  cantidad: number;
  valorOferta: number;
  estadoOferta: string;
  imagenProducto: string;
  nombreProducto: string;
  idProducto: number;
  idComprador: string;
  idPropietario: string;
}

interface Product {
  idProducto: string;
  nombreProducto: string;
  cantidad: number;
  descripcion: string;
  maduracion: string;
  fertilizantes: string;
  fechaCosecha: string;
  fechaCaducidad: string;
  precio: number;
  idImagen: string;
  idPropietario: string;
}

interface WebhookPayload {
  type: 'UPDATE';
  table: 'contra_oferta';
  record: CounterOffer;
  schema: 'public';
  old_record: CounterOffer | null;
}

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_ANON_KEY')!
);

//  Handler de la Edge Function
Deno.serve(async (req) => {
  try {
    //  Leer el cuerpo de la solicitud (evento del WebHook)
    const payload: WebhookPayload = await req.json();
    const { idComprador, estadoOferta, cantidad, idProducto } = payload.record;

    console.log(`📢 Cambio detectado en contra_oferta: ${JSON.stringify(payload.record)}`);

    //  Obtener el token FCM del comprador
    const { data, error } = await supabase
      .from('usuarios')
      .select('fcm_token')
      .eq('idUsuario', idComprador)
      .single();

    if (error || !data?.fcm_token) {
      console.error('⚠️ Error obteniendo token FCM del comprador:', error);
      return new Response(JSON.stringify({ error: 'No se encontró el token FCM' }), { status: 400 });
    }

    const fcmToken = data.fcm_token as string;

    //  Preparar el mensaje de la notificación
    let mensaje = '';
    if (estadoOferta === 'Aceptado') {
      mensaje = '🎉 Tu contra oferta ha sido ACEPTADA.';
    } else if (estadoOferta === 'Rechazado') {
      mensaje = ' Tu contra oferta ha sido RECHAZADA. La cantidad ofertada ha sido devuelta.';

      //   Si la oferta fue rechazada, devolver la cantidad al producto
      const { data: producto, error: productoError } = await supabase
        .from('productos')
        .select('cantidad')
        .eq('idProducto', idProducto)
        .single();

      if (productoError || !producto) {
        console.error('⚠️ Error obteniendo producto:', productoError);
        return new Response(JSON.stringify({ error: 'No se pudo obtener el producto' }), { status: 400 });
      }

      const nuevaCantidad = producto.cantidad + cantidad;

      const { error: updateError } = await supabase
        .from('productos')
        .update({ cantidad: nuevaCantidad })
        .eq('idProducto', idProducto);

      if (updateError) {
        console.error('⚠️ Error actualizando cantidad del producto:', updateError);
        return new Response(JSON.stringify({ error: 'No se pudo actualizar el producto' }), { status: 400 });
      }
    }

    //  Obtener el Access Token para Firebase Cloud Messaging (FCM)
    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key,
    });

    //  Enviar la notificación con FCM
    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: fcmToken,
            notification: {
              title: 'Actualización de Contra Oferta',
              body: mensaje,
            },
          },
        }),
      }
    );

    const resData = await res.json();

    if (res.status < 200 || res.status > 299) {
      console.error('⚠️ Error enviando notificación:', resData);

      //  Si el error es "UNREGISTERED", eliminar el token de la base de datos
      if (resData.error?.details?.some((d: any) => d.errorCode === 'UNREGISTERED')) {
        console.log('Token FCM inválido, eliminándolo de la base de datos...');

        await supabase
          .from('usuarios')
          .update({ fcm_token: null })
          .eq('idUsuario', idComprador);
      }

      return new Response(JSON.stringify(resData), { status: 400 });
    }

    console.log(' Notificación enviada con éxito:', mensaje);
    return new Response(
      JSON.stringify({ message: 'Notificación enviada' }),
      { headers: { "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error(' Error en la Edge Function:', error);
    return new Response(JSON.stringify({ error: 'Error en la función' }), { status: 500 });
  }
});

//  Función para obtener el Access Token de Firebase
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
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
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
