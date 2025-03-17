import 'package:App_Tomaticos/core/models/product_model.dart';
import 'package:App_Tomaticos/core/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:App_Tomaticos/core/models/counter_offer_model.dart';
import 'package:App_Tomaticos/core/services/counter_offer_service.dart';

void main() {
  late SupabaseClient supabaseClient;
  late CounterOfferService counterOfferService;
  late ProductService productService;
  int createdCounterOfferId = 999;
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
    counterOfferService =
        CounterOfferService(supabaseClient, ProductService(supabaseClient));
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

  test('✅ Crear una contraoferta y validar los datos', () async {
    final newCounterOffer = CounterOffer(
      idContraOferta: createdCounterOfferId,
      createdAt: DateTime.now(),
      cantidad: 10,
      valorOferta: 12000,
      estadoOferta: 'Pendiente',
      estadoPago: null,
      imagenProducto: 'https://example.com/product.jpg',
      nombreProducto: 'Tomate Cherry',
      idProducto: createdProductId,
      idComprador: 'd51f845f-86c2-4cd8-a483-05e2a8e576e7',
      idPropietario: 'c5de83d8-4805-4831-8a11-068020004369',
    );

    final insertResponse = await supabaseClient
        .from('contra_oferta')
        .insert(newCounterOffer.toMap())
        .select()
        .single();
    createdCounterOfferId = insertResponse['idContraOferta'];

    // Validar que los datos insertados sean correctos
    expect(createdCounterOfferId, isNotNull);
    expect(createdCounterOfferId, isA<int>());
    expect(insertResponse['cantidad'], equals(newCounterOffer.cantidad));
    expect(insertResponse['valorOferta'], equals(newCounterOffer.valorOferta));
    expect(
        insertResponse['estadoOferta'], equals(newCounterOffer.estadoOferta));
  });

  test('✅ Actualizar una contraoferta', () async {
    expect(createdCounterOfferId, isNotNull,
        reason: 'El ID de la contraoferta no puede ser nulo.');

    final updatedData = {'estadoOferta': 'Aceptada', 'valorOferta': 120.0};

    final updateResponse = await supabaseClient
        .from('contra_oferta')
        .update(updatedData)
        .eq('idContraOferta', createdCounterOfferId)
        .select()
        .single();

    expect(updateResponse['estadoOferta'], equals('Aceptada'));
    expect(updateResponse['valorOferta'], equals(120.0));
    print('🟢 Contraoferta actualizada correctamente.');
  });

  test('❌ Manejo de error al crear una contraoferta con datos inválidos',
      () async {
    try {
      final invalidCounterOffer = CounterOffer(
        createdAt: DateTime.now(),
        cantidad: -5, // Valor inválido
        valorOferta: -100.0, // Valor inválido
        estadoOferta: '',
        estadoPago: null,
        imagenProducto: 'https://example.com/product.jpg',
        nombreProducto: '',
        idProducto: 9999, // ID de producto que no existe
        idComprador: '',
        idPropietario: '',
      );

      await supabaseClient
          .from('contra_oferta')
          .insert(invalidCounterOffer.toMap());
      fail('❌ Se esperaba un error al insertar datos inválidos.');
    } catch (error) {
      print('🟢 Error capturado correctamente al insertar datos inválidos.');
      expect(error, isNotNull);
    }
  });
  test('Eliminación de datos', () async {
    await productService.deleteProduct(createdProductId);
    await counterOfferService.deleteCounterOffer(createdCounterOfferId);
    print('🟢 Contraoferta y producto eliminados después del test.');
  });
}
