import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List> readData() async {
    final result = await _supabase.from('productos').select();
    return result;
  }
}
