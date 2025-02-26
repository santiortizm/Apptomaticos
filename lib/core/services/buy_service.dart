import 'package:apptomaticos/core/models/buy_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Registra la compra y maneja la eliminación o actualización del producto en stock.
  Future<bool> createPurchase(BuyModel purchase) async {
    try {
      //  Obtener detalles del producto antes de la compra
      final response = await _supabase
          .from('productos')
          .select(
              'idProducto, nombreProducto, precio, cantidad, idPropietario, idImagen')
          .eq('idProducto', purchase.idProducto)
          .maybeSingle();
      if (response == null) {
        print(' Error: Producto no encontrado.');
        return false;
      }

      final int cantidadActual = response['cantidad'];
      final double precio = (response['precio'] as num).toDouble();
      final String nombreProducto = response['nombreProducto'];
      final String idPropietario = response['idPropietario'];
      final String? idImagen = response['idImagen'];

      //  Verificar si hay stock suficiente
      if (cantidadActual < purchase.cantidad) {
        print(' Error: Stock insuficiente.');
        return false;
      }

      //  Insertar la compra en la tabla "compras"
      final insertResponse = await _supabase.from('compras').insert({
        'idProducto': purchase.idProducto,
        'nombreProducto': nombreProducto,
        'cantidad': purchase.cantidad,
        'total': purchase.cantidad * precio,
        'alternativaPago': purchase.alternativaPago,
        'idComprador': purchase.idComprador,
        'idPropietario': idPropietario,
        'imagenProducto': idImagen ?? '',
        'fecha': purchase.fecha.toIso8601String(),
      }).select(); // 🔹 Para verificar la inserción

      if (insertResponse.isEmpty) {
        print(' Error al registrar la compra.');
        return false;
      }

      // Calcular la nueva cantidad de stock después de la compra
      final nuevaCantidad = cantidadActual - purchase.cantidad;

      if (nuevaCantidad <= 0) {
        //  Eliminar el producto si la cantidad llega a 0
        await _supabase
            .from('productos')
            .delete()
            .eq('idProducto', purchase.idProducto);

        print('Producto eliminado porque la cantidad llegó a 0.');
      } else {
        // 6️⃣ Actualizar la cantidad restante del producto
        await _supabase.from('productos').update(
            {'cantidad': nuevaCantidad}).eq('idProducto', purchase.idProducto);
      }

      print('Compra registrada exitosamente.');
      return true;
    } catch (e) {
      print(' Error inesperado en la compra: $e');
      return false;
    }
  }
}
