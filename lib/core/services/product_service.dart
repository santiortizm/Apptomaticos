import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final SupabaseClient supabaseClient;

  ProductService(this.supabaseClient);

  /// Obtiene los detalles de un producto por ID
  Future<Map<String, dynamic>> fetchProductDetails(String productId) async {
    final response = await supabaseClient
        .from('productos')
        .select('*')
        .eq('idProducto', productId)
        .single();
    return response;
  }

  /// Actualiza los detalles de un producto
  Future<bool> updateProductDetails(
      String productId, Map<String, dynamic> updates) async {
    try {
      final response = await supabaseClient
          .from('productos')
          .update(updates)
          .eq('idProducto', productId)
          .select();

      return response.isNotEmpty;
    } catch (e) {
      print('Error actualizando los detalles del producto: $e');
      return false;
    }
  }

  /// Verifica si el producto pertenece al usuario actual
  Future<bool> isProductOwner(String productId) async {
    try {
      final authUser = supabaseClient.auth.currentUser;
      if (authUser == null) {
        return false;
      }
      // Obtener el idUsuario correspondiente al authUser.id desde la tabla 'usuarios'
      final usuarioResponse = await supabaseClient
          .from('usuarios')
          .select('idUsuario')
          .eq('idAuth', authUser.id)
          .single();
      if (usuarioResponse['idUsuario'] == null) {
        return false; // Si no se encuentra el usuario en la tabla 'usuarios'
      }
      final int idUsuario = usuarioResponse['idUsuario'];
      // Consulta para verificar si el producto pertenece al usuario autenticado
      final productoResponse = await supabaseClient
          .from('productos')
          .select('idUsuario')
          .eq('idProducto', productId)
          .single();

      if (productoResponse['idUsuario'] == null) {
        return false;
      }

      return productoResponse['idUsuario'] == idUsuario;
    } catch (e) {
      print('Error verificando propiedad del producto: $e');
      return false;
    }
  }
}
