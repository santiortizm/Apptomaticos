import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:App_Tomaticos/core/models/product_model.dart';
import 'package:App_Tomaticos/core/services/product_service.dart';

void main() {
  late SupabaseClient supabaseClient;
  late ProductService productService;
  int createdProductId = 999;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_KEY'];
    if (url == null || anonKey == null) {
      throw Exception(
          'Las credenciales de Supabase no están definidas en .env');
    }
    await Supabase.initialize(url: url, anonKey: anonKey);
    supabaseClient = Supabase.instance.client;
    productService = ProductService(supabaseClient);
  });

  test('✅ Crear un producto y validar los datos', () async {
    final newProduct = Product(
      idProducto: createdProductId,
      createdAt: DateTime.now(),
      nombreProducto: 'Tomates Cherry',
      cantidad: 100,
      descripcion: 'Tomates cherry frescos y orgánicos.',
      maduracion: 'Maduro',
      fertilizantes: 'Sin Etileno',
      fechaCosecha: '2024-04-10',
      fechaCaducidad: '2024-05-10',
      precio: 12500,
      imagen: 'https://example.com/tomates.jpg',
      idPropietario: 'c5de83d8-4805-4831-8a11-068020004369',
    );

    final registerProduct = await supabaseClient
        .from('productos')
        .insert(newProduct.toMap())
        .select()
        .single();

    createdProductId = registerProduct['idProducto'];

    // Validaciones del producto insertado
    expect(createdProductId, isNotNull);
    expect(createdProductId, isA<int>());
    expect(
        registerProduct['nombreProducto'], equals(newProduct.nombreProducto));
    expect(registerProduct['precio'], equals(newProduct.precio));
    print('🟢 Producto creado correctamente.');
  });

  test('✅ Obtener detalles del producto', () async {
    expect(createdProductId, isNotNull,
        reason: 'El producto no fue creado correctamente.');
    print('🔍 ID del producto creado: $createdProductId');

    final product = await productService.fetchProductDetails(createdProductId);

    expect(product, isNotNull);
    expect(product!.idProducto, equals(createdProductId));
    expect(product.nombreProducto, equals('Tomates Cherry'));
    expect(product.precio, equals(12500));
    print('🟢 Producto obtenido correctamente.');
  });

  test('✅ Actualizar precio del producto', () async {
    expect(createdProductId, isNotNull,
        reason: 'El producto no fue creado correctamente.');

    final updatedData = {'precio': 29.99};

    final updateResponse = await supabaseClient
        .from('productos')
        .update(updatedData)
        .eq('idProducto', createdProductId)
        .select()
        .single();

    expect(updateResponse['precio'], equals(29.99));
    print('🟢 Precio del producto actualizado correctamente.');
  });

  test('✅ Eliminar un producto', () async {
    expect(createdProductId, isNotNull,
        reason: 'El producto no fue creado correctamente.');

    final success = await productService.deleteProduct(createdProductId);
    expect(success, isTrue);
    print('🟢 Producto eliminado correctamente.');

    final deletedProduct =
        await productService.fetchProductDetails(createdProductId);
    expect(deletedProduct, isNull);
    print('🟢 Producto ya no existe en la base de datos.');
  });

  test('❌ Manejo de error al crear un producto con datos inválidos', () async {
    try {
      final invalidProduct = Product(
        idProducto: createdProductId,
        createdAt: DateTime.now(),
        nombreProducto: '',
        cantidad: -5, // Cantidad inválida
        descripcion: '',
        maduracion: '',
        fertilizantes: '',
        fechaCosecha: '',
        fechaCaducidad: '',
        precio: -10.0, // Precio inválido
        imagen: '',
        idPropietario: '',
      );

      await supabaseClient.from('productos').insert(invalidProduct.toMap());
      fail('❌ Se esperaba un error al insertar datos inválidos.');
    } catch (error) {
      print('🟢 Error capturado correctamente al insertar datos inválidos.');
      expect(error, isNotNull);
    }
  });
}
