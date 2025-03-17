import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  State<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> salesData = [];
  List<Map<String, dynamic>> tableData = [];

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    try {
      final response = await supabase
          .from('compras')
          .select('nombreProducto, total, cantidad')
          .order('fecha', ascending: true);

      final Map<String, Map<String, double>> productPrices = {};

      for (var sale in response) {
        final String productName =
            (sale['nombreProducto'] as String).toLowerCase();
        final double total = (sale['total'] as num).toDouble();
        final int cantidad = (sale['cantidad'] as num).toInt();

        if (cantidad == 0) continue;

        final double pricePerUnit = total / cantidad;

        if (!productPrices.containsKey(productName)) {
          productPrices[productName] = {
            'min': pricePerUnit,
            'max': pricePerUnit,
          };
        } else {
          productPrices[productName]!['min'] =
              pricePerUnit < productPrices[productName]!['min']!
                  ? pricePerUnit
                  : productPrices[productName]!['min']!;
          productPrices[productName]!['max'] =
              pricePerUnit > productPrices[productName]!['max']!
                  ? pricePerUnit
                  : productPrices[productName]!['max']!;
        }
      }

      setState(() {
        // 📊 Datos para la gráfica (Solo los máximos)
        salesData = productPrices.entries
            .map((entry) => {
                  'nombreProducto': entry.key,
                  'precio': entry.value['max'],
                })
            .toList();

        // 📋 Datos para la tabla (Mínimo y Máximo)
        tableData = productPrices.entries
            .map((entry) => {
                  'nombreProducto': entry.key,
                  'min': entry.value['min'],
                  'max': entry.value['max'],
                })
            .toList();
      });
    } catch (e) {
      print('❌ Error al obtener datos de ventas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: AutoSizeText(
        textAlign: TextAlign.center,
        'Precios de Productos Vendidos',
        maxLines: 2,
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 📊 Gráfica de precios unitarios máximos
            Expanded(
              flex: 1,
              child: salesData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Chart(
                      data: salesData,
                      variables: {
                        'nombreProducto': Variable(
                          accessor: (Map map) =>
                              map['nombreProducto'] as String,
                          scale: OrdinalScale(),
                        ),
                        'precio': Variable(
                          scale: LinearScale(
                              max: 20000, min: 1000, title: 'Valor'),
                          accessor: (Map map) => map['precio'] as double,
                        ),
                      },
                      marks: [
                        IntervalMark(
                          position: Varset('nombreProducto') * Varset('precio'),
                          color: ColorEncode(value: buttonGreen),
                          shape: ShapeEncode(value: RectShape()),
                        ),
                      ],
                      axes: [
                        Defaults.horizontalAxis,
                        Defaults.verticalAxis,
                      ],
                      selections: {
                        'tap': PointSelection(dim: Dim.x),
                      },
                    ),
            ),
            const SizedBox(height: 20),

            // 📋 Tabla de Precios Unitarios (Mínimo y Máximo)
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateColor.resolveWith(
                      (states) => Colors.grey[200]!),
                  columns: const [
                    DataColumn(label: Text('Nombre Producto')),
                    DataColumn(label: Text('Precio Mínimo')),
                    DataColumn(label: Text('Precio Máximo')),
                  ],
                  rows: tableData.map((data) {
                    return DataRow(cells: [
                      DataCell(Text(data['nombreProducto'])),
                      DataCell(
                          Text('\$${data['min']?.toStringAsFixed(0) ?? "0"}')),
                      DataCell(
                          Text('\$${data['max']?.toStringAsFixed(0) ?? "0"}')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
