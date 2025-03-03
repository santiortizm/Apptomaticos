import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/services/cloudinary_service.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CustomCardCounterOfferMerchant extends StatelessWidget {
  final String imagen;
  final String nombreProducto;
  final String nombreOfertador;
  final String cantidadOfertada;
  final String totalOferta;
  final VoidCallback acceptOffer;
  const CustomCardCounterOfferMerchant(
      {super.key,
      required this.imagen,
      required this.nombreProducto,
      required this.nombreOfertador,
      required this.cantidadOfertada,
      required this.totalOferta,
      required this.acceptOffer});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cloudinaryService =
        CloudinaryService(cloudName: dotenv.env['CLOUD_NAME'] ?? '');
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.025, vertical: size.height * 0.025),
      width: size.width * 0.9,
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
                    imagen,
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
                  texTitletWidget(context, nombreProducto, 22),
                  texTitletWidget(context, nombreOfertador, 16),
                  moreInfo(context, 'Cantidad:', 12,
                      '$cantidadOfertada Canastas', 12, 0.2, 0.22),
                  moreInfo(
                      context, 'Precio Unitario:', 12, '2000', 12, 0.26, 0.15),
                  moreInfo(context, 'Total compra:', 12, totalOferta, 12, 0.26,
                      0.15),
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
                CustomButton(
                  onPressed: acceptOffer,
                  color: buttonGreen,
                  colorBorder: Colors.transparent,
                  border: 18,
                  width: 0.3,
                  height: 0.05,
                  elevation: 2,
                  sizeBorder: 0,
                  child: AutoSizeText(
                    'COMPRAR',
                    maxLines: 1,
                    maxFontSize: 17,
                    minFontSize: 14,
                    style: temaApp.textTheme.titleSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 30),
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
      width: size.width * .42,
      child: AutoSizeText(
        textAlign: TextAlign.center,
        text,
        minFontSize: 14,
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

    return Row(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          width: size.width * widthTitle,
          child: AutoSizeText(
            textAlign: TextAlign.center,
            textTitleInfo,
            minFontSize: 12,
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
