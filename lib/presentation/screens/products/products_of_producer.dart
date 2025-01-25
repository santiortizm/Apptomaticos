import 'package:apptomaticos/core/services/product_service.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/core/widgets/custom_card_products_producer.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsOfProducer extends StatefulWidget {
  const ProductsOfProducer({super.key});

  @override
  State<ProductsOfProducer> createState() => _ProductsOfProducerState();
}

class _ProductsOfProducerState extends State<ProductsOfProducer> {
  late Future<List<Map<String, dynamic>>> producerProductsFuture;
  final ProductService productService =
      ProductService(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    producerProductsFuture = productService.fetchProductsByProducer();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      producerProductsFuture = productService.fetchProductsByProducer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              width: size.width * 1,
              height: size.height * 1,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/fondo_2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05, vertical: 0.05),
              child: Center(
                child: Container(
                  width: size.width,
                  height: size.height * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: const Alignment(-0.9, 0),
                        child: SizedBox(
                          width: size.width * 0.35,
                          child: CustomButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            color: Colors.white.withValues(alpha: 0.1),
                            border: 20,
                            width: 0.2,
                            height: 0.1,
                            elevation: 0,
                            child: Row(
                              spacing: size.width * 0.02,
                              children: [
                                const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                                AutoSizeText(
                                  'Atrás',
                                  maxFontSize: 18,
                                  minFontSize: 14,
                                  maxLines: 1,
                                  style: temaApp.textTheme.titleSmall!.copyWith(
                                      fontSize: 18, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AutoSizeText(
                        'Mis productos',
                        maxFontSize: 26,
                        minFontSize: 18,
                        maxLines: 1,
                        style: temaApp.textTheme.titleSmall!.copyWith(
                            fontSize: 26,
                            color: Colors.black,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: size.height * 0.7,
                        width: size.width * 1,
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: producerProductsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            if (snapshot.data == null ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text('No tienes productos disponibles.'),
                              );
                            }
                            final productos = snapshot.data!;
                            return RefreshIndicator(
                              onRefresh: _refreshProducts,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.05),
                                itemCount: productos.length,
                                itemBuilder: (context, index) {
                                  final producto = productos[index];
                                  return CustomCardProductsProducer(
                                    productId:
                                        producto['idProducto'].toString(),
                                    title: producto['nombreProducto'],
                                    date: producto['created_at'],
                                    imageUrl: producto['idImagen'] ??
                                        'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp', // Imagen por defecto
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
