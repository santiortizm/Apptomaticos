import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient supabaseClient;

  UserService(this.supabaseClient);

  /// Obtiene el rol del usuario autenticado
  Future<String?> getUserRole() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      final response = await supabaseClient
          .from('usuarios')
          .select('rol')
          .eq('idUsuario', user.id)
          .single();

      return response['rol'];
    } catch (e) {
      print('Error obteniendo rol del usuario: $e');
      return null;
    }
  }
}
