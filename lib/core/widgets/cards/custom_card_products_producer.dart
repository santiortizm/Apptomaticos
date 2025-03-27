import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/models/product_model.dart';
import 'package:App_Tomaticos/core/services/product_service.dart';
import 'package:App_Tomaticos/core/widgets/custom_alert_dialog.dart';
import 'package:App_Tomaticos/presentation/screens/products/buy_product_page.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class CustomCardProductsProducer extends StatefulWidget {
  final int productId;
  final String title;
  final String date;
  final String imageUrl;
  final VoidCallback isDelete;

  const CustomCardProductsProducer({
    super.key,
    required this.productId,
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.isDelete,
  });

  @override
  State<CustomCardProductsProducer> createState() =>
      _CustomCardProductsProducerState();
}

class _CustomCardProductsProducerState
    extends State<CustomCardProductsProducer> {
  late final ProductService productService =
      ProductService(Supabase.instance.client);
  late Future<List<Product>> productDetails;
  final dataProduct = ProductService(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    productDetails = dataProduct.fetchProductsByProducer();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BuyProductPage(productId: widget.productId),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
        height: size.height * 0.15,
        width: size.width * .1,
        margin: EdgeInsets.only(
            bottom: size.height * 0.015, top: size.height * 0.01),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: size.width * .3,
              height: size.height * 0.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Row(
              spacing: 8,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: size.width * 0.27,
                      height: 40,
                      child: AutoSizeText(
                        widget.title,
                        maxFontSize: 18,
                        minFontSize: 4,
                        maxLines: 2,
                        style: temaApp.textTheme.titleSmall!.copyWith(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                          child: AutoSizeText(
                            'Publicado',
                            maxFontSize: 14,
                            minFontSize: 4,
                            maxLines: 1,
                            style: temaApp.textTheme.titleSmall!.copyWith(
                                fontSize: 14, color: buttoGreenSelected),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                          child: AutoSizeText(
                            DateFormat('dd/MM/yyyy').format(DateTime.parse(
                                widget.date)), // Formato día/mes/año
                            maxFontSize: 14,
                            minFontSize: 4,
                            maxLines: 1,
                            style: temaApp.textTheme.titleSmall!.copyWith(
                                fontSize: 14, color: buttoGreenSelected),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    _dialog(context);
                  },
                  child: Icon(
                    Icons.delete,
                    color: redApp,
                    size: 26,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dialog(BuildContext parentContext) {
    return showDialog<void>(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return CustomAlertDialog(
          width: 220,
          height: 270,
          assetImage: './assets/images/alert.gif',
          title: 'Alerta',
          content: Container(
            width: 200,
            alignment: Alignment.center,
            child: AutoSizeText(
              '¿Estás seguro de eliminar este producto?',
              maxLines: 2,
              minFontSize: 4,
              maxFontSize: 18,
              textAlign: TextAlign.center,
              style: temaApp.textTheme.titleSmall!
                  .copyWith(color: Colors.black, fontSize: 18),
            ),
          ),
          onPressedAcept: () async {
            Navigator.of(context).pop();
            final success =
                await productService.deleteProduct(widget.productId);

            if (success) {
              setState(
                () {
                  productDetails = productService.fetchProductsByProducer();
                  Navigator.of(context).pop();
                },
              );
            } else {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    backgroundColor: redApp,
                    content: Text('Error al eliminar el producto')),
              );
            }
          },
          onPressedCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
