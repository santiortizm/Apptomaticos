import 'package:apptomaticos/core/models/transport_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransportService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// 🔹 Verifica si el transportador ya tiene un transporte "En Curso"
  Future<bool> hasActiveTransport(String idUsuario) async {
    try {
      final response = await supabase
          .from('transportes')
          .select('idTransporte')
          .eq('idTransportador', idUsuario)
          .eq('estado', 'En Curso')
          .maybeSingle();

      return response !=
          null; // Retorna `true` si ya tiene un transporte activo
    } catch (e) {
      print('Error al verificar transporte activo: $e');
      return false;
    }
  }

  /// 🔹 Crea un nuevo transporte SOLO si no hay uno "En Curso"
  Future<bool> createTransport(Transport transport) async {
    try {
      // ❗ Verificar si el transportador ya tiene un transporte en curso
      final hasActive = await hasActiveTransport(transport.idTransportador);
      if (hasActive) {
        return false; // ❌ No permite registrar otro transporte
      }

      await supabase.from('transportes').insert(transport.toMap());
      return true;
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
}
