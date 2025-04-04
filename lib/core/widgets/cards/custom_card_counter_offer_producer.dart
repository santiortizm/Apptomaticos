import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/services/cloudinary_service.dart';
import 'package:App_Tomaticos/core/widgets/button/custom_button.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomCardCounterOfferProducer extends StatefulWidget {
  final String imagen;
  final String nombreProducto;
  final String cantidadOfertada;
  final String valorOferta;
  final String idOfertador;
  final VoidCallback acceptOffer;
  final VoidCallback declineOffer;
  const CustomCardCounterOfferProducer(
      {super.key,
      required this.imagen,
      required this.nombreProducto,
      required this.cantidadOfertada,
      required this.valorOferta,
      required this.acceptOffer,
      required this.declineOffer,
      required this.idOfertador});

  @override
  State<CustomCardCounterOfferProducer> createState() =>
      _CustomCardCounterOfferProducerState();
}

class _CustomCardCounterOfferProducerState
    extends State<CustomCardCounterOfferProducer> {
  final supabase = Supabase.instance.client;
  String nombreOfertador = '';
  Future<void> nameUser() async {
    try {
      final response = await supabase
          .from('usuarios')
          .select('nombre, apellido')
          .eq('idUsuario', widget.idOfertador)
          .maybeSingle();

      if (response != null) {
        setState(() {
          nombreOfertador = '${response['nombre']} ${response['apellido']}';
        });
      } else {
        setState(() {
          nombreOfertador = 'Desconocido';
        });
      }
    } catch (e) {
      print(' Error obteniendo nombre del ofertador: $e');
      setState(() {
        nombreOfertador = 'Error';
      });
    }
  }

  late int valorTotal = 0;

  void _calculateTotalValue() {
    final int cantidad = int.parse(widget.cantidadOfertada);
    final int valorOfetado = (double.tryParse(widget.valorOferta) ?? 0).toInt();

    valorTotal = cantidad * valorOfetado;
  }

  @override
  void initState() {
    super.initState();
    _calculateTotalValue();
    nameUser();
  }

  String formatValue(num value) {
    final formatter =
        NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cloudinaryService =
        CloudinaryService(cloudName: dotenv.env['CLOUD_NAME'] ?? '');
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.025, vertical: size.height * 0.025),
      width: size.width * 0.8,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Row(
            spacing: 12,
            children: [
              Container(
                width: size.width * 0.28,
                height: size.height * 0.16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: CachedNetworkImage(
                  imageUrl: cloudinaryService.getOptimizedImageUrl(
                    widget.imagen,
                  ),
                  fit: BoxFit.scaleDown,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Image.network(
                      'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp'),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  texTitletWidget(context, widget.nombreProducto, 22),
                  texTitletWidget(context, nombreOfertador, 16),
                  moreInfo(context, 'Cantidad:', 12,
                      '${widget.cantidadOfertada} Canastas', 12, 0.26, 0.26),
                  moreInfo(
                      context,
                      'Precio Unitario:',
                      12,
                      ' \$${formatValue(double.parse(widget.valorOferta))}',
                      12,
                      0.40,
                      0.26),
                  moreInfo(context, 'Total compra:', 12,
                      '\$${formatValue(valorTotal)}', 12, 0.40, 0.26),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: size.height * 0.012),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 115,
                  child: CustomButton(
                    onPressed: widget.declineOffer,
                    color: Colors.white,
                    colorBorder: redApp,
                    border: 18,
                    width: 0.3,
                    height: 0.05,
                    elevation: 2,
                    sizeBorder: 2,
                    child: AutoSizeText(
                      'RECHAZAR',
                      maxLines: 1,
                      maxFontSize: 17,
                      minFontSize: 8,
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
                    onPressed: widget.acceptOffer,
                    color: buttonGreen,
                    colorBorder: Colors.transparent,
                    border: 18,
                    width: 0.3,
                    height: 0.05,
                    elevation: 2,
                    sizeBorder: 0,
                    child: AutoSizeText(
                      'ACEPTAR',
                      maxLines: 1,
                      maxFontSize: 17,
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
          ),
        ],
      ),
    );
  }

  Widget texTitletWidget(
      BuildContext context, String text, double maxFontSize) {
    final size = MediaQuery.of(context).size;

    return Container(
      alignment: Alignment.center,
      width: size.width * .43,
      child: AutoSizeText(
        textAlign: TextAlign.center,
        text,
        minFontSize: 8,
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

  Widget moreInfo(
      BuildContext context,
      String textTitleInfo,
      double maxFontSizeTitleInfo,
      String textTextInfo,
      double maxFontSizeTextInfo,
      double widthTitle,
      double widthText) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          width: size.width * widthTitle,
          child: AutoSizeText(
            textAlign: TextAlign.center,
            textTitleInfo,
            minFontSize: 8,
            maxFontSize: maxFontSizeTitleInfo,
            maxLines: 1,
            style: temaApp.textTheme.titleSmall!.copyWith(
              fontSize: 100,
              fontWeight: FontWeight.w900,
              color: buttonGreen,
            ),
          ),
        ),
        SizedBox(
          width: size.width * widthText,
          child: AutoSizeText(
            textAlign: TextAlign.center,
            textTextInfo,
            minFontSize: 12,
            maxFontSize: maxFontSizeTextInfo,
            maxLines: 1,
            style: temaApp.textTheme.titleSmall!.copyWith(
              fontSize: 100,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
