import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apptomaticos/core/models/sale_model.dart';

class SaleService {
  final SupabaseClient supabase = Supabase.instance.client;

  ///  **Crear una nueva venta**
  Future<bool> createSale(Sale sale) async {
    try {
      final response =
          await supabase.from('ventas').insert(sale.toMap()).select();

      if (response.isEmpty) {
        print(' Error al registrar la venta.');
        return false;
      }

      print(' Venta registrada con éxito.');
      return true;
    } catch (e) {
      print(' Error al crear la venta: $e');
      return false;
    }
  }

  ///  **Actualizar el estado de una venta**
  Future<bool> updateSaleStatus(int idVenta, String nuevoEstado) async {
    try {
      final response = await supabase
          .from('ventas')
          .update({'estadoVenta': nuevoEstado})
          .eq('idVenta', idVenta)
          .select();

      if (response.isEmpty) {
        print(' Error al actualizar el estado de la venta.');
        return false;
      }

      print(' Estado de la venta actualizado a: $nuevoEstado');
      return true;
    } catch (e) {
      print(' Error al actualizar la venta: $e');
      return false;
    }
  }
}
