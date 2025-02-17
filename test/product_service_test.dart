import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apptomaticos/core/models/product_model.dart';
import 'package:apptomaticos/core/services/product_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Mock para simular SharedPreferences
class MockService extends Mock implements ProductService {}

void main() {
  late ProductService productService;
  late SupabaseClient supabaseClient;
  late int createdProductId = 111;

  setUpAll(() async {
    // Simular SharedPreferences vacío
    SharedPreferences.setMockInitialValues({});
    // Cargar variables de entorno
    await dotenv.load(fileName: ".env");

    // Verificar que las credenciales no sean null
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (url == null || anonKey == null) {
      throw Exception(
          'Las credenciales de Supabase no están definidas en .env.test');
    }

    // Inicializar Supabase
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );

    supabaseClient = Supabase.instance.client;
    productService = ProductService(supabaseClient);
  });
  group('Load Service', () {
    test('Load Service', () async {
      SharedPreferences.setMockInitialValues({});
      await dotenv.load(fileName: ".env");
      final url = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
      if (url == null || anonKey == null) {
        throw Exception(
            'Las credenciales de Supabase no están definidas en .env.test');
      }
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
    });
  });
  group('addProduct', () {
    test('Crear un producto', () async {
      final product = Product(
        idProducto: 111, // Supabase generará el ID automáticamente
        createdAt: DateTime.now(),
        nombreProducto: 'Producto de prueba',
        cantidad: 10,
        descripcion: 'Descripción de prueba',
        maduracion: 'Maduro',
        fertilizantes: 'Orgánico',
        fechaCosecha: '2024-02-20',
        fechaCaducidad: '2024-03-20',
        precio: 20.5,
        idImagen: '289015df-c556-4e31-a251-e5cde2c0b56c',
        idPropietario:
            'c5de83d8-4805-4831-8a11-068020004369', // Asegúrate de usar un ID válido
      );
    });

    test('Visualizar los detalles del producto', () async {
      final product =
          await productService.fetchProductDetails(createdProductId);
      expect(product, isNotNull);
      expect(product!.idProducto, equals(createdProductId));
      expect(product.nombreProducto, equals('Producto de prueba'));
    });

    test('Eliminar un producto', () async {
      final success = await productService.deleteProduct(createdProductId);
      expect(success, isTrue);

      final deletedProduct =
          await productService.fetchProductDetails(createdProductId);
      expect(deletedProduct, isNull);
    });
  });
}
