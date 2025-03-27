import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/models/counter_offer_model.dart';
import 'package:App_Tomaticos/core/services/counter_offer_service.dart';
import 'package:App_Tomaticos/core/services/product_service.dart';
import 'package:App_Tomaticos/core/widgets/custom_button.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OffertPage extends StatefulWidget {
  final int productId;
  final double price;
  final String imageUrl;
  final int availableQuantity;
  final int cantidad;
  final String productName;
  final String ownerId;
  const OffertPage({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.price,
    required this.availableQuantity,
    required this.productName,
    required this.ownerId,
    required this.cantidad,
  });

  @override
  State<OffertPage> createState() => _OffertPageState();
}

class _OffertPageState extends State<OffertPage> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _offerPriceController = TextEditingController();
  double _totalPrice = 0;

  void _updateTotalPrice() {
    final int quantity = int.tryParse(_quantityController.text) ?? 0;
    final double offerPrice =
        double.tryParse(_offerPriceController.text) ?? widget.price;

    setState(() {
      _totalPrice = quantity * offerPrice;
    });
  }

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_updateTotalPrice);
    _offerPriceController.addListener(_updateTotalPrice);
  }

  String formatPrice(num price) {
    final formatter =
        NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0);
    return formatter.format(price);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_updateTotalPrice);
    _offerPriceController.removeListener(_updateTotalPrice);
    _quantityController.dispose();
    _offerPriceController.dispose();
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
                  image: AssetImage('assets/images/fondo_2.jpg'),
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
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Column(
                    spacing: 18,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: size.height * 0.025),
                        alignment: Alignment.centerLeft,
                        width: size.width,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            children: [
                              const Icon(
                                size: 24,
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                              SizedBox(width: size.width * 0.02),
                              AutoSizeText(
                                'Atrás',
                                maxLines: 1,
                                minFontSize: 16,
                                maxFontSize: 18,
                                style: temaApp.textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                  fontSize: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      textWidget(context, 'Ofertar', 28),
                      Container(
                        width: size.width,
                        height: size.height * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          image: DecorationImage(
                            image: NetworkImage(widget.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      containerPrice(context, 'Precio Actual',
                          '\$${formatPrice(widget.price)}', 16),
                      textWidget(context, 'Cantidad a Ofertar:', 18),
                      textWidget(context,
                          '(Cantidad Disponible: ${widget.cantidad})', 14),
                      SizedBox(
                        width: size.width * 0.6,
                        child: textFormField(context, 'Cantidad en Canastas',
                            TextInputType.number, _quantityController),
                      ),
                      textWidget(context, 'Precio a Ofertar (Por Canasta)', 18),
                      SizedBox(
                        width: size.width * 0.6,
                        child: textFormField(context, 'Precio a Ofertar',
                            TextInputType.number, _offerPriceController),
                      ),
                      containerPrice(context, 'Total a Pagar:',
                          formatPrice(_totalPrice), 16),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: size.height * 0.025),
                        child: Row(
                          spacing: 20,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 115,
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
                              width: 115,
                              child: CustomButton(
                                onPressed: () async {
                                  final quantity =
                                      int.tryParse(_quantityController.text) ??
                                          0;
                                  final offerPrice = double.tryParse(
                                          _offerPriceController.text) ??
                                      widget.price;

                                  if (quantity <= 0 ||
                                      quantity > widget.availableQuantity ||
                                      offerPrice <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Oferta no válida')),
                                    );
                                    return;
                                  }

                                  final supabase = Supabase.instance.client;
                                  final userId = supabase.auth.currentUser
                                      ?.id; // ID del usuario autenticado

                                  if (userId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Usuario no autenticado')),
                                    );
                                    return;
                                  }

                                  final CounterOffer nuevaOferta = CounterOffer(
                                    idContraOferta:
                                        DateTime.now().millisecondsSinceEpoch,
                                    idProducto: widget.productId,
                                    cantidad: quantity,
                                    valorOferta: offerPrice,
                                    estadoOferta: 'En Espera',
                                    createdAt: DateTime.now(),
                                    imagenProducto: widget.imageUrl,
                                    nombreProducto: widget.productName,
                                    idComprador: userId,
                                    idPropietario: widget.ownerId,
                                  );

                                  final productService =
                                      ProductService(supabase);
                                  final counterOfferService =
                                      CounterOfferService(
                                          supabase, productService);

                                  bool success = await counterOfferService
                                      .createContraOferta(nuevaOferta);

                                  if (success) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Oferta enviada con éxito')),
                                    );
                                    // ignore: use_build_context_synchronously
                                    context.pop();
                                  } else {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Error al enviar la oferta')),
                                    );
                                  }
                                },
                                color: buttonGreen,
                                colorBorder: buttonGreen,
                                border: 12,
                                width: 0.35,
                                height: 0.07,
                                elevation: 1,
                                sizeBorder: 0,
                                child: AutoSizeText(
                                  'OFERTAR',
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
      width: size.width,
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
      width: size.width,
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
        ],
      ),
    );
  }

  Widget textFormField(BuildContext context, String label,
      TextInputType keyboardType, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
}
