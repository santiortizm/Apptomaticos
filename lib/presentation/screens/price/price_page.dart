import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
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
        salesData = productPrices.entries
            .map((entry) => {
                  'nombreProducto': entry.key,
                  'precio': entry.value['max'],
                })
            .toList();

        tableData = productPrices.entries
            .map((entry) => {
                  'nombreProducto': entry.key,
                  'min': entry.value['min'],
                  'max': entry.value['max'],
                })
            .toList();
      });
    } catch (e) {
      print(' Error al obtener datos de ventas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withValues(alpha: 0.8)),
      width: size.width * 1,
      height: size.width * 1,
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            Container(
              width: 300,
              height: 70,
              alignment: Alignment.center,
              child: AutoSizeText(
                'Precios de venta\nde Tomate de Carne',
                maxLines: 2,
                maxFontSize: 22,
                minFontSize: 8,
                textAlign: TextAlign.center,
                style: temaApp.textTheme.titleSmall!.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            //  Gráfica de precios unitarios máximos
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(6),
                width: 400,
                height: 300,
                child: salesData.isEmpty
                    ? Text('No hay ventas aun realizadas')
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
                                max: 15000, min: 1000, title: 'Valor'),
                            accessor: (Map map) => map['precio'] as double,
                          ),
                        },
                        marks: [
                          IntervalMark(
                            position:
                                Varset('nombreProducto') * Varset('precio'),
                            color: ColorEncode(
                                value: const Color.fromARGB(255, 164, 39, 39)),
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
                      )),

            //  Tabla de Precios Unitarios (Mínimo y Máximo)
            SizedBox(
              width: 400,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateColor.resolveWith(
                      (states) => const Color.fromARGB(204, 227, 159, 159)),
                  columns: const [
                    DataColumn(label: Text('Nombre Producto')),
                    DataColumn(label: Text('Mín')),
                    DataColumn(label: Text('Máx')),
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
