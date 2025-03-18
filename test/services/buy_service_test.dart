import 'package:App_Tomaticos/core/models/product_model.dart';
import 'package:App_Tomaticos/core/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:App_Tomaticos/core/models/buy_model.dart';
import 'package:App_Tomaticos/core/services/buy_service.dart';

void main() {
  late SupabaseClient supabaseClient;
  late BuyService buyService;
  late ProductService productService;

  int createdBuyId = 999;
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
    buyService = BuyService(ProductService(supabaseClient));
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
  test('✅ Crear una compra y validar los datos', () async {
    final newBuy = Buy(
      id: createdBuyId,
      createdAt: DateTime.now(),
      alternativaPago: 'Contra Entrega',
      nombreProducto: 'Tomate Cherry',
      cantidad: 5,
      total: 60000,
      fecha: DateTime.now(),
      idProducto: createdProductId,
      idComprador: 'd51f845f-86c2-4cd8-a483-05e2a8e576e7',
      idPropietario: 'c5de83d8-4805-4831-8a11-068020004369',
      imagenProducto: 'https://example.com/product.jpg',
      estadoCompra: 'Pendiente',
    );

    final registerPurchase = await supabaseClient
        .from('compras')
        .insert(newBuy.toMap())
        .select()
        .single();
    createdBuyId = registerPurchase['id'];

    // Validar que los datos insertados sean correctos
    expect(createdBuyId, isNotNull);
    expect(createdBuyId, isA<int>());
    expect(registerPurchase['cantidad'], equals(newBuy.cantidad));
    expect(registerPurchase['total'], equals(newBuy.total));
    expect(registerPurchase['estadoCompra'], equals(newBuy.estadoCompra));
  });

  test('✅ Actualizar una compra', () async {
    expect(createdBuyId, isNotNull,
        reason: 'El ID de la compra no puede ser nulo.');

    final updatePurchase = {'estadoCompra': 'Completada', 'total': 60.0};

    final updateResponse = await supabaseClient
        .from('compras')
        .update(updatePurchase)
        .eq('id', createdBuyId)
        .select()
        .single();

    expect(updateResponse['estadoCompra'], equals('Completada'));
    expect(updateResponse['total'], equals(60.0));
    print('🟢 Compra actualizada correctamente.');
  });

  test('❌ Manejo de error al crear una compra con datos inválidos', () async {
    try {
      final invalidBuy = Buy(
        createdAt: DateTime.now(),
        alternativaPago: '',
        nombreProducto: '',
        cantidad: -10, // Valor inválido
        total: -20.0, // Valor inválido
        fecha: DateTime.now(),
        idProducto: 9999, // ID de producto que no existe
        idComprador: '',
        idPropietario: '',
        imagenProducto: 'https://example.com/product.jpg',
        estadoCompra: '',
      );

      await supabaseClient.from('compras').insert(invalidBuy.toMap());
      fail('❌ Se esperaba un error al insertar datos inválidos.');
    } catch (error) {
      print('🟢 Error capturado correctamente al insertar datos inválidos.');
      expect(error, isNotNull);
    }
  });

  test('Eliminación de datos', () async {
    await productService.deleteProduct(createdProductId);
    await buyService.deleteBuy(createdBuyId);
    print('🟢 Compra y producto eliminados después del test.');
  });
}
