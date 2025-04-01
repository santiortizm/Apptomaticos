import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/widgets/button/custom_button.dart';
import 'package:App_Tomaticos/core/widgets/dialogs/custom_notification.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PurchasePage extends StatefulWidget {
  final int productId;
  final double price;
  final String imageUrl;
  final int cantidad;
  final int availableQuantify;
  const PurchasePage(
      {super.key,
      required this.productId,
      required this.imageUrl,
      required this.price,
      required this.availableQuantify,
      required this.cantidad});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final TextEditingController _quantityController = TextEditingController();
  double _totalPrice = 0;
  void _updateTotalPrice() {
    final int quantity = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _totalPrice = quantity * widget.price;
    });
  }

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_updateTotalPrice);
  }

  String formatPrice(num price) {
    final formatter =
        NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0);
    return formatter.format(price);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_updateTotalPrice);
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: size.width,
              height: size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background/fondo_2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05, vertical: size.height * 0.03),
              child: Container(
                width: size.width * 1,
                height: size.height * 1,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 16,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.025),
                        alignment: Alignment.centerLeft,
                        width: size.width * 1,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            spacing: size.width * 0.02,
                            children: [
                              const Icon(
                                size: 24,
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                              AutoSizeText(
                                'Atrás',
                                maxLines: 1,
                                minFontSize: 16,
                                maxFontSize: 18,
                                style: temaApp.textTheme.titleSmall!.copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                    fontSize: 28),
                              ),
                            ],
                          ),
                        ),
                      ),
                      textWidget(context, 'Comprar', 28),
                      Container(
                        width: size.width * 1,
                        height: size.height * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          image: DecorationImage(
                            image: NetworkImage(widget.imageUrl),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      containerPrice(context, 'Precio Canasta',
                          formatPrice(widget.price), 16),
                      Column(
                        spacing: 4,
                        children: [
                          textWidget(context, 'Cantidad a Comprar:', 18),
                          textWidget(context,
                              '(Cantidad Disponible: ${widget.cantidad})', 14),
                        ],
                      ),
                      SizedBox(
                        width: size.width * 0.6,
                        child: textFormField(context, 'Cantidad en Canastas',
                            TextInputType.number, _quantityController),
                      ),
                      containerPrice(context, 'Total a Pagar:',
                          formatPrice(_totalPrice), 16),
                      Container(
                        alignment: Alignment.center,
                        margin:
                            EdgeInsets.symmetric(vertical: size.height * 0.025),
                        child: Row(
                          spacing: 15,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              child: CustomButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                color: Colors.white,
                                colorBorder: redApp,
                                border: 12,
                                width: 0.35,
                                height: 0.07,
                                elevation: 2,
                                sizeBorder: 2.5,
                                child: AutoSizeText(
                                  'CANCELAR',
                                  maxLines: 1,
                                  maxFontSize: 18,
                                  minFontSize: 4,
                                  style: temaApp.textTheme.titleSmall!.copyWith(
                                      color: redApp,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 30),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: CustomButton(
                                onPressed: () {
                                  if (_quantityController.text.isEmpty) {
                                    _errorCampos(context);
                                  }
                                  final quantity =
                                      int.tryParse(_quantityController.text) ??
                                          0;
                                  if (quantity <= 0 ||
                                      quantity > widget.availableQuantify) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Cantidad no válida')),
                                    );
                                    return;
                                  }

                                  // Navegar a la pantalla de métodos de pago con los datos de la compra
                                  context.push(
                                    '/paymentAlternatives',
                                    extra: {
                                      'productId': widget.productId,
                                      'quantity': quantity,
                                      'totalPrice': _totalPrice,
                                      'imageProduct': widget.imageUrl,
                                    },
                                  );
                                },
                                color: buttonGreen,
                                colorBorder: buttonGreen,
                                border: 12,
                                width: 0.35,
                                height: 0.07,
                                elevation: 1,
                                sizeBorder: 0,
                                child: AutoSizeText(
                                  'COMPRAR',
                                  maxLines: 1,
                                  maxFontSize: 20,
                                  minFontSize: 4,
                                  style: temaApp.textTheme.titleSmall!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textWidget(BuildContext context, String text, double maxFontSize) {
    final size = MediaQuery.of(context).size;

    return Container(
      alignment: Alignment.center,
      width: size.width * 1,
      child: AutoSizeText(
        text,
        minFontSize: 4,
        maxFontSize: maxFontSize,
        maxLines: 1,
        style: temaApp.textTheme.titleSmall!.copyWith(
          fontSize: 100,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget containerPrice(
      BuildContext context, String text1, String text2, double maxFontSize) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 1,
      height: size.height * 0.07,
      decoration: BoxDecoration(
        color: const Color(0xfff1f4f8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            width: size.width * 0.4,
            child: AutoSizeText(
              text1,
              minFontSize: 4,
              maxFontSize: maxFontSize,
              maxLines: 1,
              style: temaApp.textTheme.titleSmall!.copyWith(
                fontSize: 100,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            width: size.width * 0.3,
            child: AutoSizeText(
              text2,
              minFontSize: 4,
              maxFontSize: maxFontSize,
              maxLines: 1,
              style: temaApp.textTheme.titleSmall!.copyWith(
                fontSize: 100,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            width: size.width * 0.1,
            alignment: Alignment.center,
            child: Icon(
              Icons.attach_money_sharp,
              color: redApp,
              size: 24,
            ),
          )
        ],
      ),
    );
  }

  Widget textFormField(BuildContext context, String label,
      TextInputType keynoardType, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: keynoardType,
      decoration: InputDecoration(
        focusColor: redApp,
        label: Text(label),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xffAFAFAF),
          ),
        ),
      ),
    );
  }

  Future<void> _errorCampos(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomNotification(
            width: 300,
            height: 300,
            assetImage: './assets/gifts/error.gif',
            title: 'Error',
            content: Container(
              alignment: Alignment.center,
              width: 250,
              child: AutoSizeText(
                'Debes llenar todos los campos para realizar',
                maxLines: 2,
                maxFontSize: 26,
                minFontSize: 4,
                style: temaApp.textTheme.titleSmall!.copyWith(fontSize: 100),
              ),
            ),
            button: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(buttonGreen),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Container(
                      alignment: Alignment.center,
                      width: 80,
                      height: 28,
                      child: AutoSizeText('Aceptar',
                          maxLines: 1,
                          maxFontSize: 14,
                          minFontSize: 4,
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
