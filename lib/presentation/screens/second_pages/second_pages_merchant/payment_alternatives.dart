import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/models/buy_model.dart';
import 'package:apptomaticos/core/services/buy_service.dart';
import 'package:apptomaticos/core/services/product_service.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class PaymentAlternatives extends StatefulWidget {
  final int productId;
  final int quantity;
  final double totalPrice;

  const PaymentAlternatives({
    super.key,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
  });

  @override
  State<PaymentAlternatives> createState() => _PaymentAlternativesState();
}

class _PaymentAlternativesState extends State<PaymentAlternatives> {
  final supabase = Supabase.instance.client;
  final BuyService buyService =
      BuyService(ProductService(Supabase.instance.client));

  Future<void> _handleCashOnDelivery() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe iniciar sesión')),
        );
        return;
      }

      final now = DateTime.now();

      // Obtener detalles del producto antes de la compra
      final productResponse = await supabase
          .from('productos')
          .select('idPropietario, imagen, nombreProducto')
          .eq('idProducto', widget.productId)
          .maybeSingle(); // 🔹 Evita errores si no encuentra el producto

      if (productResponse == null) {
        return;
      }

      final String nombreProducto = productResponse['nombreProducto'];
      final String idPropietario = productResponse['idPropietario'];
      final String? idImagen = productResponse['imagen'];

      // Crear el modelo de compra con todos los parámetros
      final Buy compra = Buy(
        idProducto: widget.productId,
        createdAt: DateTime.now(),
        cantidad: widget.quantity,
        alternativaPago: 'PAGO CONTRA ENTREGA',
        idComprador: userId,
        fecha: now,
        nombreProducto: nombreProducto,
        total: widget.totalPrice,
        idPropietario: idPropietario,
        imagenProducto: idImagen ?? '',
      );

      // Usar el servicio de compra
      bool success = await buyService.createPurchase(compra);

      if (success) {
        if (!mounted) return; // 🔹 Verificamos que el widget sigue activo

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compra realizada con éxito')),
        );
        context.pushReplacement('/menu');
      } else {
        throw Exception('No se pudo completar la compra.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
                  child: Column(
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
                                    fontSize: 28),
                              ),
                            ],
                          ),
                        ),
                      ),
                      texTitletWidget(context, 'Alternativas de Pago', 28),
                      textWidget(
                          context,
                          'Ofrecemos dos opciones para tu comodidad:\n\nPago Contra Entrega: Realiza el pago al recibir tus tomates, asegurando la calidad del producto antes de pagar.\n\nPago Inmediato: Paga al momento de hacer tu pedido y disfruta de un proceso de compra rápido y sencillo.',
                          16),
                      SizedBox(height: size.height * 0.03),
                      CustomButton(
                        onPressed: () {},
                        color: buttonGreen,
                        colorBorder: buttonGreen,
                        border: 12,
                        width: 0.4,
                        height: 0.07,
                        elevation: 2,
                        sizeBorder: 0,
                        child: AutoSizeText(
                          'PAGO INMEDIATO',
                          maxLines: 1,
                          maxFontSize: 18,
                          minFontSize: 16,
                          style: temaApp.textTheme.titleSmall!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 30),
                        ),
                      ),
                      CustomButton(
                        onPressed: _handleCashOnDelivery,
                        color: Colors.white,
                        colorBorder: buttonGreen,
                        border: 12,
                        width: 0.4,
                        height: 0.07,
                        elevation: 2,
                        sizeBorder: 2.5,
                        child: AutoSizeText(
                          'PAGO CONTRA ENTREGA',
                          maxLines: 1,
                          maxFontSize: 18,
                          minFontSize: 16,
                          style: temaApp.textTheme.titleSmall!.copyWith(
                              color: buttonGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 30),
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

  Widget texTitletWidget(
      BuildContext context, String text, double maxFontSize) {
    final size = MediaQuery.of(context).size;

    return Container(
      alignment: Alignment.center,
      width: size.width * .6,
      child: AutoSizeText(
        textAlign: TextAlign.center,
        text,
        minFontSize: 14,
        maxFontSize: maxFontSize,
        maxLines: 2,
        style: temaApp.textTheme.titleSmall!.copyWith(
          fontSize: 100,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget textWidget(BuildContext context, String text, double maxFontSize) {
    final size = MediaQuery.of(context).size;

    return Container(
      alignment: Alignment.center,
      width: size.width * .75,
      child: AutoSizeText(
        textAlign: TextAlign.justify,
        text,
        minFontSize: 14,
        maxFontSize: maxFontSize,
        maxLines: 16,
        style: temaApp.textTheme.titleSmall!.copyWith(
          fontSize: 100,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
    );
  }
}
