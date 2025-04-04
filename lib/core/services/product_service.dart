import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final SupabaseClient supabaseClient;
  final supabase = Supabase.instance.client;

  ProductService(this.supabaseClient);

  /// Muestra todos los productos disponibles
  Future<List<Product>> fetchAllProducts() async {
    try {
      final response = await supabase
          .from('productos')
          .select()
          .order('created_at', ascending: false);
      return response.map((data) => Product.fromMap(data)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Registra un nuevo producto
  Future<bool> registerProduct(Product product) async {
    try {
      final response =
          await supabaseClient.from('productos').insert(product.toMap());
      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene los detalles de un producto por ID
  Future<Product?> fetchProductDetails(int productId) async {
    try {
      final response = await supabaseClient
          .from('productos')
          .select('*')
          .eq('idProducto', productId)
          .single();

      return Product.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  /// Actualiza los detalles de un producto
  Future<bool> updateProductDetails(
      int productId, Map<String, dynamic> updates) async {
    try {
      final response = await supabaseClient
          .from('productos')
          .update(updates)
          .eq('idProducto', productId)
          .select();

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Elimina un producto dado su ID
  Future<bool> deleteProduct(int productId) async {
    try {
      final response = await supabaseClient
          .from('productos')
          .delete()
          .eq('idProducto', productId)
          .select();

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si el producto pertenece al usuario actual
  Future<bool> isProductOwner(int productId) async {
    try {
      final authUser = supabaseClient.auth.currentUser;
      if (authUser == null) {
        return false;
      }

      // Obtener `idPropietario` del producto
      final productoResponse = await supabaseClient
          .from('productos')
          .select('idPropietario')
          .eq('idProducto', productId)
          .single();

      if (productoResponse.isEmpty) {
        return false;
      }

      final String idUsuarioProducto = productoResponse['idPropietario'];

      return idUsuarioProducto == authUser.id; // Comparar como String
    } catch (e) {
      return false;
    }
  }

  /// Obtiene todos los productos que pertenecen al productor autenticado
  Future<List<Product>> fetchProductsByProducer() async {
    try {
      final authUser = supabaseClient.auth.currentUser;
      if (authUser == null) {
        throw Exception('Usuario no autenticado.');
      }

      final productosResponse = await supabaseClient
          .from('productos')
          .select('*')
          .eq('idPropietario', authUser.id); // Usar `authUser.id` directamente

      return productosResponse
          .map<Product>((data) => Product.fromMap(data))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Actualiza la cantidad de un producto (puede restar o sumar)
  Future<void> updateProductQuantity(int productId, int changeAmount) async {
    try {
      final product = await fetchProductDetails(productId);
      if (product == null) return;

      final newQuantity = product.cantidad + changeAmount;

      await supabaseClient
          .from('productos')
          .update({'cantidad': newQuantity}).eq('idProducto', productId);
    } catch (e) {
      return;
    }
  }
}
