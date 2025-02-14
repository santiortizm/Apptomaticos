import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apptomaticos/core/services/product_service.dart';

/// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseAuth extends Mock implements GoTrueClient {}

class MockSupabaseTable extends Mock implements SupabaseQueryBuilder {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockSupabaseTable mockProductsTable;
  late ProductService productService;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockProductsTable = MockSupabaseTable();
    productService = ProductService(mockSupabase);
    // Registrar tipos nulos en mocktail para evitar errores
    registerFallbackValue(<String, dynamic>{});
  });

  group('Registro de producto', () {
    test('Debe registrar un producto correctamente y retornar true', () async {
      // Simular la tabla 'productos'
      when(() => mockSupabase.from('productos')).thenReturn(mockProductsTable);
      // Simulación de respuesta exitosa de Supabase
      when(() => mockProductsTable.insert(any()))
          .thenReturn(PostgrestFilterBuilder(mockProductsTable));

      // Datos del producto a registrar
      final productData = {
        'nombreProducto': 'Tomate',
        'cantidad': 10,
        'descripcion': 'Tomate fresco',
        'maduracion': 'Verde',
        'fertilizantes': 'Orgánico',
        'fechaCosecha': '2024-02-10',
        'fechaCaducidad': '2024-03-10',
        'precio': 1500.0,
        'idUsuario': 1,
      };

      // Ejecutar la función
      final result = await productService.registerProduct(productData);

      // Verificaciones
      expect(result, true);
      verify(() => mockProductsTable.insert(productData)).called(1);
    });

    test('Debe retornar false si la inserción falla', () async {
      // Simular la tabla 'productos'
      when(() => mockSupabase.from('productos')).thenReturn(mockProductsTable);

      // Simulación de error en Supabase
      when(() => mockProductsTable.insert(any()))
          .thenThrow(Exception('Error en la inserción'));

      // Datos del producto a registrar
      final productData = {
        'nombreProducto': 'Manzana',
        'cantidad': 10,
        'descripcion': 'Manzanas rojas frescas',
        'maduracion': 'Verde',
        'fertilizantes': 'Orgánico',
        'fechaCosecha': '2024-02-10',
        'fechaCaducidad': '2024-03-10',
        'precio': 15.0,
        'idUsuario': 1,
      };

      // Ejecutar la función
      final result = await productService.registerProduct(productData);

      // Verificaciones
      expect(result, false);
      verify(() => mockProductsTable.insert(productData)).called(1);
    });
  });
}
