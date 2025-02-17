import {createClient} from "npm:@supabase/supabase-js@2";
import {JWT} from "npm:google-auth-library@9";
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

interface WebhookPlayload{
  type: 'INSERT'
  table: string
  record: Order
  schema: 'public'
  old_record: null | Order
}

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_ANON_KEY')!
)

Deno.serve(async (req) => {
  const payload: WebhookPlayload = await req.json()
  const {data} = await supabase.from('usuarios').select('fcm_token').eq('idUsuario',payload.record.idPropietario).single()

  const fcmToken = data!.fcm_token as string

  const accessToken = await getAccessToken({
    clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key,
  })

  
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
            title: `Public Product Confirmation`,
            body: `${payload.record.nombreProducto} purchased for \$${payload.record.precio}.`
          }
        }
      }) 
    }
  )

  const resData = await res.json()
  if(res.status < 200 || 299 < res.status) {
    throw resData
    
  }
  return new Response(
    JSON.stringify(resData),
    { headers: { "Content-Type": "application/json" } },
  )
})

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