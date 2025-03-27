import 'package:App_Tomaticos/core/models/buy_model.dart';
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
          .not('estado', 'eq', 'Finalizado')
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createTransport(Transport transport) async {
    try {
      final hasActive = await hasActiveTransport(transport.idTransportador);
      if (hasActive) {
        return false;
      }

      await supabase.from('transportes').insert(transport.toMap());
      return true;
    } catch (e) {
      print('Error al crear el transporte: $e');
      return false;
    }
  }

  //Obtiene los transportes que estan listos para transportar
  Future<List<Buy>> fetchAllTransports() async {
    try {
      final response = await supabase
          .from('compras')
          .select('*')
          .order('created_at', ascending: false);

      return response.map((data) => Buy.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtiene todos los productos que pertenecen al productor autenticado
  Future<List<Transport>> fetchTransportsByTrucker(String idUsuario) async {
    try {
      final response = await supabase
          .from('transportes')
          .select('*')
          .eq('idTransportador', idUsuario);

      return response
          .map<Transport>((data) => Transport.fromMap(data))
          .toList();
    } catch (e) {
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
          .inFilter('idCompra', idsCompras);

      return transportes
          .map<Transport>((data) => Transport.fromMap(data))
          .toList();
    } catch (e) {
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
      return;
    }
  }
}
