import 'dart:async';

import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/data/repositories/product_repository.dart';
import 'package:apptomaticos/core/widgets/custom_card_products.dart';
import 'package:apptomaticos/presentation/screens/products/add_product_widget.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomListview extends StatefulWidget {
  const CustomListview({super.key});

  @override
  State<CustomListview> createState() => _CustomListviewState();
}

class _CustomListviewState extends State<CustomListview> {
  String? userRole;
  final supabase = Supabase.instance.client;
  final ProductRepository productRepository = ProductRepository();
  late Future<List> productsFuture;
  late List products = [];

  @override
  void initState() {
    productsFuture = productRepository.readData();
    _fetchUserRole();
    _loadProducts();
    super.initState();
  }

  /// Carga inicial de productos
  Future<void> _loadProducts() async {
    try {
      final data = await productRepository.readData();
      setState(() {
        products = data;
      });
    } catch (e) {
      print('Error cargando productos: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> _productsStream() {
    return supabase.from('productos').stream(primaryKey: ['idProducto']).map(
        (event) => event.map((e) => e).toList());
  }

  Future<void> _fetchUserRole() async {
    try {
      final user = supabase.auth.currentUser;

      if (user != null) {
        final response = await supabase
            .from('usuarios')
            .select('rol')
            .eq('idAuth', user.id)
            .single();

        setState(() {
          userRole = response['rol'];
        });
      }
    } catch (e) {
      print('Error al obtener el rol del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20)),
      width: size.width * 1,
      height: size.height * 1,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _productsStream(), // Escucha los cambios en la tabla productos
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Stack(
                children: [
                  const Center(
                    child: Text('Datos no disponibles'),
                  ),
                  if (userRole == null)
                    const CircularProgressIndicator()
                  else if (userRole == 'Productor') ...[
                    Center(
                      child: Container(
                        width: size.width * 0.4,
                        alignment: const Alignment(0.0, 0.95),
                        child: CustomButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AddProductWidget())),
                          color: buttonGreen,
                          border: 18,
                          width: 0.4,
                          height: 0.07,
                          elevation: 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sell,
                                color: redApp,
                                size: 26,
                              ),
                              AutoSizeText(
                                'Vender',
                                maxFontSize: 32,
                                minFontSize: 14,
                                maxLines: 1,
                                style: temaApp.textTheme.titleSmall!.copyWith(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              );
            }
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    // Llama al método para recargar los datos
                    await _loadProducts();
                    // Vuelve a establecer los productos en el estado
                    setState(() {
                      productsFuture = productRepository.readData();
                    });
                  },
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, int index) {
                      var data = snapshot.data![index];
                      return CustomCardProducts(
                        productId: data['idProducto'].toString(),
                        title: data['nombreProducto'],
                        state: data['maduracion'],
                        price: data['precio'].toString(),
                        imageUrl: data['idImagen'] ??
                            'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp',
                      );
                    },
                  ),
                ),
                if (userRole == null)
                  const CircularProgressIndicator()
                else if (userRole == 'Productor') ...[
                  Center(
                    child: Container(
                      width: size.width * 0.4,
                      alignment: const Alignment(0.0, 0.95),
                      child: CustomButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AddProductWidget())),
                        color: buttonGreen,
                        border: 18,
                        width: 0.4,
                        height: 0.07,
                        elevation: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sell,
                              color: redApp,
                              size: 26,
                            ),
                            AutoSizeText(
                              'Vender',
                              maxFontSize: 32,
                              minFontSize: 14,
                              maxLines: 1,
                              style: temaApp.textTheme.titleSmall!.copyWith(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
