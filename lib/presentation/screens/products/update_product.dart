import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/widgets/avatar_product.dart';
import 'package:App_Tomaticos/core/widgets/text_form_field_widget.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class UpdateProduct extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final VoidCallback onPressedDecline;
  final VoidCallback onPressedAccept;
  final String? imageUrl;
  final void Function(String imageUrl) onUpLoad;
  final int productId;

  const UpdateProduct({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.priceController,
    required this.quantityController,
    required this.onPressedDecline,
    required this.onPressedAccept,
    required this.imageUrl,
    required this.onUpLoad,
    required this.productId,
  });

  @override
  State<UpdateProduct> createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 12,
          children: [
            AutoSizeText(
              'Actualizar Producto',
              maxLines: 1,
              maxFontSize: 22,
              minFontSize: 4,
              style: temaApp.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            AutoSizeText(
              'Foto Producto',
              maxLines: 1,
              maxFontSize: 18,
              minFontSize: 4,
              style: temaApp.textTheme.titleSmall!.copyWith(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            AvatarProduct(
              imageUrl: widget.imageUrl,
              onUpLoad: widget.onUpLoad,
              productId: widget.productId,
            ),
            TextFormFieldWidget(
              labelText: 'Titulo',
              controller: widget.titleController,
              icon: Icons.shopping_basket,
              keyboardType: TextInputType.text,
            ),
            TextFormFieldWidget(
              labelText: 'Descripción',
              controller: widget.descriptionController,
              icon: Icons.description_sharp,
              keyboardType: TextInputType.text,
            ),
            TextFormFieldWidget(
              labelText: 'Precio',
              controller: widget.priceController,
              icon: Icons.price_change,
              keyboardType: TextInputType.number,
            ),
            TextFormFieldWidget(
              labelText: 'Cantidad',
              controller: widget.quantityController,
              icon: Icons.shopping_cart,
              keyboardType: TextInputType.number,
            ),
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 110,
                  child: TextButton(
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: redApp, width: 2),
                        ),
                      ),
                      // backgroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: widget.onPressedDecline,
                    child: AutoSizeText(
                      'CANCELAR',
                      maxLines: 1,
                      maxFontSize: 14,
                      minFontSize: 8,
                      style: temaApp.textTheme.titleSmall!.copyWith(
                          color: redApp,
                          fontWeight: FontWeight.w600,
                          fontSize: 30),
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: TextButton(
                    style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                        backgroundColor: WidgetStatePropertyAll(buttonGreen)),
                    onPressed: widget.onPressedAccept,
                    child: AutoSizeText(
                      'MODIFICAR',
                      maxLines: 1,
                      maxFontSize: 14,
                      minFontSize: 8,
                      style: temaApp.textTheme.titleSmall!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 30),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
