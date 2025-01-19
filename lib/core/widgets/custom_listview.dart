import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/data/repositories/product_repository.dart';
import 'package:apptomaticos/core/widgets/custom_card_products.dart';
import 'package:apptomaticos/presentation/screens/products/add_product_widget.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomListview extends StatefulWidget {
  const CustomListview({super.key});

  @override
  State<CustomListview> createState() => _CustomListviewState();
}

class _CustomListviewState extends State<CustomListview> {
  String? userRole;

  final ProductRepository productRepository = ProductRepository();
  late Future<List> productsFuture;

  @override
  void initState() {
    productsFuture = productRepository.readData();
    super.initState();
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
      child: FutureBuilder(
        future: productsFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Dialog(
              child: SizedBox(
                width: size.width * 0.4,
                height: size.height * 0.3,
                child: const Text('Error'),
              ),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return const Center(
                child: Text('Datos no disponibles'),
              );
            }
            return Stack(
              children: [
                ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, int index) {
                    var data = snapshot.data[index];
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
                Center(
                  child: Container(
                    width: size.width * 0.4,
                    alignment: const Alignment(0.0, 0.95),
                    child: CustomButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddProductWidget())),
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
