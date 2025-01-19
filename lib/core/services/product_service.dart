import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final SupabaseClient supabaseClient;
  ProductService(this.supabaseClient);
  Future<Map<String, dynamic>> fetchProductDetails(String productId) async {
    final response = await supabaseClient
        .from('productos')
        .select('*')
        .eq('idProducto', productId)
        .single();
    return response;
  }
}
