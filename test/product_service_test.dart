import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apptomaticos/core/models/product_model.dart';
import 'package:apptomaticos/core/services/product_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  late ProductService productService;
  late SupabaseClient supabaseClient;
  int createdProductId = 0; // Se usará después de la creación
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({}); // Inicializar valores mock
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_KEY'];
    if (url == null || anonKey == null) {
      throw Exception(
          'Las credenciales de Supabase no están definidas en .env');
    }
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    supabaseClient = Supabase.instance.client;
    productService = ProductService(supabaseClient);
  });
  group('ProductService Tests', () {
    test('✅ Crear un producto', () async {
      final newProduct = Product(
        idProducto: createdProductId, // Supabase generará el ID automáticamente
        createdAt: DateTime.now(),
        nombreProducto: 'Producto de prueba',
        cantidad: 10,
        descripcion: 'Descripción de prueba',
        maduracion: 'Maduro',
        fertilizantes: 'Orgánico',
        fechaCosecha: '2024-02-20',
        fechaCaducidad: '2024-03-20',
        precio: 20.5,
        imagen: 'https://example.com/producto.jpg',
        idPropietario:
            'c5de83d8-4805-4831-8a11-068020004369', // ID de prueba válido
      );
      final insertResponse = await supabaseClient
          .from('productos')
          .insert(newProduct.toMap())
          .select()
          .single();
      createdProductId = insertResponse['idProducto']; // Guardar el ID generado
      expect(createdProductId, isNotNull);
      expect(createdProductId, isA<int>());
      // ignore: avoid_print
      print('🟢 Producto creado con ID: $createdProductId');
    });
    test('✅ Obtener detalles del producto', () async {
      expect(createdProductId, isNotNull,
          reason: 'El producto no fue creado correctamente.');
      final product =
          await productService.fetchProductDetails(createdProductId);
      expect(product, isNotNull);
      expect(product!.idProducto, equals(createdProductId));
      expect(product.nombreProducto, equals('Producto de prueba'));
      // ignore: avoid_print
      print('🟢 Producto obtenido correctamente.');
    });
    test('✅ Eliminar un producto', () async {
      expect(createdProductId, isNotNull,
          reason: 'El producto no fue creado correctamente.');

      final success = await productService.deleteProduct(createdProductId);
      expect(success, isTrue);
      // ignore: avoid_print
      print('🟢 Producto eliminado correctamente.');

      final deletedProduct =
          await productService.fetchProductDetails(createdProductId);
      expect(deletedProduct, isNull);
      // ignore: avoid_print
      print('🟢 Producto ya no existe en la base de datos.');
    });
  });
}
