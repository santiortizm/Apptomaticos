import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/models/product_model.dart';
import 'package:apptomaticos/core/services/product_service.dart';
import 'package:apptomaticos/presentation/screens/products/buy_product_page.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
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
          spacing: 2,
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: size.width * 0.3,
                  child: AutoSizeText(
                    widget.title,
                    maxFontSize: 22,
                    minFontSize: 12,
                    maxLines: 2,
                    style: temaApp.textTheme.titleSmall!
                        .copyWith(fontSize: 22, color: Colors.black),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      'Publicado',
                      maxFontSize: 14,
                      minFontSize: 12,
                      maxLines: 1,
                      style: temaApp.textTheme.titleSmall!
                          .copyWith(fontSize: 14, color: buttoGreenSelected),
                    ),
                    AutoSizeText(
                      DateFormat('dd/MM/yyyy').format(
                          DateTime.parse(widget.date)), // Formato día/mes/año
                      maxFontSize: 14,
                      minFontSize: 12,
                      maxLines: 1,
                      style: temaApp.textTheme.titleSmall!
                          .copyWith(fontSize: 14, color: buttoGreenSelected),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () async {
                _dialog(context);
              },
              icon: Icon(
                Icons.delete,
                color: redApp,
                size: 26,
              ),
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
        return AlertDialog(
          title: const Text('Advertencia'),
          content: const Text('¿Estás seguro de eliminar el producto?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success =
                    await productService.deleteProduct(widget.productId);

                if (success) {
                  setState(() {
                    productDetails = productService.fetchProductsByProducer();
                  });

                  widget.isDelete();

                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Producto eliminado exitosamente'),
                    ),
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar el producto'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
