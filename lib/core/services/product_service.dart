import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final SupabaseClient supabaseClient;
  final supabase = Supabase.instance.client;

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

  /// Elimina un producto dado su ID
  Future<bool> deleteProduct(String productId) async {
    try {
      final response = await supabaseClient
          .from('productos')
          .delete()
          .eq('idProducto', productId)
          .select();

      if (response.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error al eliminar el producto: $e');
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
      final usuarioResponse = await supabaseClient
          .from('usuarios')
          .select('idUsuario')
          .eq('idAuth', authUser.id)
          .single();
      if (usuarioResponse['idUsuario'] == null) {
        return false;
      }
      final int idUsuario = usuarioResponse['idUsuario'];
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

  /// Obtiene todos los productos que pertenecen al productor autenticado
  Future<List<Map<String, dynamic>>> fetchProductsByProducer() async {
    try {
      final authUser = supabaseClient.auth.currentUser;

      if (authUser == null) {
        throw Exception('Usuario no autenticado.');
      }
      final usuarioResponse = await supabaseClient
          .from('usuarios')
          .select('idUsuario')
          .eq('idAuth', authUser.id)
          .single();

      final int idUsuario = usuarioResponse['idUsuario'];

      final productosResponse = await supabaseClient
          .from('productos')
          .select('*')
          .eq('idUsuario', idUsuario);

      return List<Map<String, dynamic>>.from(productosResponse);
    } catch (e) {
      print('Error al obtener los productos del productor: $e');
      return [];
    }
  }
}
