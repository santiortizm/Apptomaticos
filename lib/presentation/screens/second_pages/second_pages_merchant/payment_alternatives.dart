import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/models/buy_model.dart';
import 'package:App_Tomaticos/core/services/buy_service.dart';
import 'package:App_Tomaticos/core/services/product_service.dart';
import 'package:App_Tomaticos/core/widgets/button/custom_button.dart';
import 'package:App_Tomaticos/core/widgets/dialogs/custom_notification.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class PaymentAlternatives extends StatefulWidget {
  final int productId;
  final int quantity;
  final double totalPrice;
  final String imageProduct;
  const PaymentAlternatives({
    super.key,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.imageProduct,
  });

  @override
  State<PaymentAlternatives> createState() => _PaymentAlternativesState();
}

class _PaymentAlternativesState extends State<PaymentAlternatives> {
  final supabase = Supabase.instance.client;
  final BuyService buyService =
      BuyService(ProductService(Supabase.instance.client));
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
                padding: EdgeInsets.only(bottom: size.height * 0.025),
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
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
                                    fontSize: 28),
                              ),
                            ],
                          ),
                        ),
                      ),
                      texTitletWidget(context, 'Alternativas\nde Pago', 28),
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
                        onPressed: () async {
                          try {
                            final userId = supabase.auth.currentUser?.id;
                            if (userId == null) {
                              _error(context);
                              return;
                            }

                            final now = DateTime.now();

                            // Obtener detalles del producto antes de la compra
                            final productResponse = await supabase
                                .from('productos')
                                .select('idPropietario, imagen, nombreProducto')
                                .eq('idProducto', widget.productId)
                                .maybeSingle();

                            if (productResponse == null) {
                              // ignore: use_build_context_synchronously
                              _error(context);
                              return;
                            }

                            final String nombreProducto =
                                productResponse['nombreProducto'];
                            final String idPropietario =
                                productResponse['idPropietario'];

                            // Crear el modelo de compra
                            final Buy compra = Buy(
                              id: DateTime.now().millisecondsSinceEpoch,
                              idProducto: widget.productId,
                              createdAt: now,
                              cantidad: widget.quantity,
                              alternativaPago: 'PAGO CONTRA ENTREGA',
                              idComprador: userId,
                              fecha: now,
                              nombreProducto: nombreProducto,
                              total: widget.totalPrice,
                              idPropietario: idPropietario,
                              imagenProducto: widget.imageProduct,
                              estadoCompra: 'En Curso',
                            );

                            // Registrar la compra
                            final bool success =
                                await buyService.createPurchase(compra);
                            if (success) {
                              // ignore: use_build_context_synchronously
                              _alertConfirmPurchase(context);
                            } else {
                              _error(context);
                            }
                          } catch (e) {
                            print('Error al procesar el pago: $e');
                            // ignore: use_build_context_synchronously
                            _error(context);
                          }
                        },
                        color: Colors.white,
                        colorBorder: buttonGreen,
                        border: 12,
                        width: 0.35,
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
                      CustomButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        color: redApp,
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
                          minFontSize: 16,
                          style: temaApp.textTheme.titleSmall!.copyWith(
                              color: Colors.white,
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
        minFontSize: 4,
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
        minFontSize: 4,
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

  Future<void> _error(BuildContext context) {
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
                'Ha sucedido un error inesperado, por favor intente de nuevo',
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

  Future<void> _alertConfirmPurchase(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomNotification(
          width: 300,
          height: 250,
          assetImage: './assets/gifts/compra_realizada.gif',
          title: 'Compra realizada',
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            alignment: Alignment.topCenter,
            width: 250,
            child: AutoSizeText(
              'La compra se realizo correctamente!',
              maxLines: 2,
              maxFontSize: 18,
              minFontSize: 4,
              textAlign: TextAlign.center,
              style: temaApp.textTheme.titleSmall!.copyWith(fontSize: 100),
            ),
          ),
          button: const SizedBox.shrink(),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 3));

    if (mounted && Navigator.of(context).canPop()) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Cierra el diálogo
    }

    if (mounted) {
      // ignore: use_build_context_synchronously
      GoRouter.of(context).go('/menu'); // Navega a '/menu'
    }
  }
}
