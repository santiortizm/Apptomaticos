import 'package:apptomaticos/core/models/buy_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> createPurchase(BuyModel purchase) async {
    try {
      // Iniciar transacción
      final response = await _supabase.rpc('buy_product', params: {
        'id_producto': purchase.idProducto,
        'cantidad_comprada': purchase.cantidad,
        'id_comprador': purchase.idComprador,
        'alternativa_pago': purchase.alternativaPago,
        'total': purchase.total,
        'fecha': purchase.fecha.toIso8601String(),
      });

      if (response != null) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error en la compra: $e');
      return false;
    }
  }
}
