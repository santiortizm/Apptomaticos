import 'package:App_Tomaticos/core/models/transport_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransportService {
  final SupabaseClient supabase = Supabase.instance.client;
  Future<bool> hasActiveTransport(String idUsuario) async {
    try {
      final response = await supabase
          .from('transportes')
          .select('idTransporte, estado')
          .eq('idTransportador', idUsuario)
          .not('estado', 'eq',
              'Finalizado') // ❌ Filtra todos los que NO están "Finalizado"
          .maybeSingle();

      return response !=
          null; // Si encuentra al menos uno, tiene transporte activo
    } catch (e) {
      print('Error al verificar transporte activo: $e');
      return false;
    }
  }

  Future<bool> createTransport(Transport transport) async {
    try {
      final hasActive = await hasActiveTransport(transport.idTransportador);
      if (hasActive) {
        return false; // ❌ No permite crear si hay transportes NO finalizados
      }

      await supabase.from('transportes').insert(transport.toMap());
      return true; // ✅ Transporte creado
    } catch (e) {
      print('Error al crear el transporte: $e');
      return false;
    }
  }

  /// Obtiene todos los productos que pertenecen al productor autenticado
  Future<List<Transport>> fetchTransportsByTrucker(String idUsuario) async {
    try {
      final response = await supabase.from('transportes').select('*').eq(
          'idTransportador', idUsuario); // 🔥 Filtrar por ID del transportador

      return response
          .map<Transport>((data) => Transport.fromMap(data))
          .toList();
    } catch (e) {
      print('Error al obtener transportes: $e');
      return [];
    }
  }

  Future<List<Transport>> fetchTransportsByBuyer(String idComprador) async {
    try {
      final compras = await supabase
          .from('compras')
          .select('id')
          .eq('idComprador', idComprador);

      if (compras.isEmpty) return [];

      final idsCompras = compras.map<int>((c) => c['id'] as int).toList();

      final transportes = await supabase
          .from('transportes')
          .select('*')
          .inFilter('idCompra',
              idsCompras); // 🔥 Solo transportes con idCompra del comprador

      return transportes
          .map<Transport>((data) => Transport.fromMap(data))
          .toList();
    } catch (e) {
      print('Error al obtener transportes del comprador: $e');
      return [];
    }
  }

  Future<void> deleteTransport(int idTransporte) async {
    try {
      await supabase
          .from('transportes')
          .delete()
          .eq('idTransporte', idTransporte);
    } catch (e) {
      print('Error al eliminar transporte: $e');
    }
  }
}
