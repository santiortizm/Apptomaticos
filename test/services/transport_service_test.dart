import 'package:App_Tomaticos/core/models/buy_model.dart';
import 'package:App_Tomaticos/core/models/product_model.dart';
import 'package:App_Tomaticos/core/services/buy_service.dart';
import 'package:App_Tomaticos/core/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:App_Tomaticos/core/models/transport_model.dart';
import 'package:App_Tomaticos/core/services/transport_service.dart';

void main() {
  late SupabaseClient supabaseClient;
  late TransportService transportService;
  late BuyService buyService;
  late ProductService productService;
  int createdTransportId = 999;
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
    transportService = TransportService();
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

    final insertResponse = await supabaseClient
        .from('compras')
        .insert(newBuy.toMap())
        .select()
        .single();
    createdBuyId = insertResponse['id'];

    // Validar que los datos insertados sean correctos
    expect(createdBuyId, isNotNull);
    expect(createdBuyId, isA<int>());
    expect(insertResponse['cantidad'], equals(newBuy.cantidad));
    expect(insertResponse['total'], equals(newBuy.total));
    expect(insertResponse['estadoCompra'], equals(newBuy.estadoCompra));
  });
  test('✅ Crear un transporte y validar los datos', () async {
    final newTransport = Transport(
      idTransporte: createdTransportId,
      createdAt: DateTime.now(),
      fechaCargue: '2024-03-10',
      fechaEntrega: '2024-03-11',
      estado: 'Pendiente',
      pesoCarga: 200.5,
      valorTransporte: 1500,
      idCompra: createdBuyId,
      idTransportador:
          '093b55d0-ac41-41f0-81bd-234a5ba16293', // ID de transportador
    );

    final insertResponse = await supabaseClient
        .from('transportes')
        .insert(newTransport.toMap())
        .select()
        .single();
    createdTransportId = insertResponse['idTransporte'];

    // Validar que los datos insertados sean correctos
    expect(createdTransportId, isNotNull);
    expect(createdTransportId, isA<int>());
    expect(insertResponse['estado'], equals(newTransport.estado));
    expect(insertResponse['pesoCarga'], equals(newTransport.pesoCarga));
  });

  test('✅ Actualizar estado del transporte', () async {
    expect(createdTransportId, isNotNull,
        reason: 'El ID del transporte no puede ser nulo.');

    final updatedData = {'estado': 'En camino', 'valorTransporte': 1600};

    final updateResponse = await supabaseClient
        .from('transportes')
        .update(updatedData)
        .eq('idTransporte', createdTransportId)
        .select()
        .single();

    expect(updateResponse['estado'], equals('En camino'));
    expect(updateResponse['valorTransporte'], equals(1600));
    print('🟢 Estado del transporte actualizado correctamente.');
  });

  test('❌ Manejo de error al crear un transporte con datos inválidos',
      () async {
    try {
      final invalidTransport = Transport(
        idTransporte: 1002,
        createdAt: DateTime.now(),
        fechaCargue: '',
        fechaEntrega: '',
        estado: '',
        pesoCarga: -50, // Valor inválido
        valorTransporte: -100, // Valor inválido
        idCompra: 9999, // ID de compra que no existe
        idTransportador: '',
      );

      await supabaseClient.from('transportes').insert(invalidTransport.toMap());
      fail('❌ Se esperaba un error al insertar datos inválidos.');
    } catch (error) {
      print('🟢 Error capturado correctamente al insertar datos inválidos.');
      expect(error, isNotNull);
    }
  });
  test('Eliminación de datos', () async {
    await productService.deleteProduct(createdProductId);
    await buyService.deleteBuy(createdBuyId);
    await transportService.deleteTransport(createdTransportId);

    print('🟢 Transporte, compra y producto eliminados después del test.');
  });
}
