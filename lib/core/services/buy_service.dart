import 'package:apptomaticos/core/models/buy_model.dart';
import 'package:apptomaticos/core/services/product_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ProductService productService;

  BuyService(this.productService);

  /// Registra la compra y actualiza el stock del producto.
  Future<bool> createPurchase(Buy purchase) async {
    try {
      final response = await _supabase
          .from('productos')
          .select(
              'idProducto, nombreProducto, precio, cantidad, idPropietario, imagen')
          .eq('idProducto', purchase.idProducto)
          .maybeSingle();

      if (response == null) {
        return false;
      }

      final int cantidadActual = response['cantidad'];
      final double precio = (response['precio'] as num).toDouble();
      final String nombreProducto = response['nombreProducto'];
      final String idPropietario = response['idPropietario'];
      final String? imagen = response['imagen'];

      if (cantidadActual < purchase.cantidad) {
        return false;
      }

      final insertResponse = await _supabase.from('compras').insert({
        'idProducto': purchase.idProducto,
        'nombreProducto': nombreProducto,
        'cantidad': purchase.cantidad,
        'total': purchase.cantidad * precio,
        'alternativaPago': purchase.alternativaPago,
        'idComprador': purchase.idComprador,
        'idPropietario': idPropietario,
        'imagenProducto': imagen ?? '',
        'fecha': purchase.fecha.toIso8601String(),
        'estadoCompra': purchase.estadoCompra,
      }).select();

      if (insertResponse.isEmpty) {
        return false;
      }

      await productService.updateProductQuantity(
          purchase.idProducto, -purchase.cantidad);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene todas las compras realizadas por el usuario autenticado
  Future<List<Buy>> fetchPurchasesByUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return [];
      }

      final response = await _supabase
          .from('compras')
          .select()
          .eq('idComprador', user.id)
          .order('fecha', ascending: false);

      return response.map((json) => Buy.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Buy>> fetchPurchase() async {
    try {
      final response = await _supabase.from('compras').select('*');

      return response.map((data) => Buy.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }
}
