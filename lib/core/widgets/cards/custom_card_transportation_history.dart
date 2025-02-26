import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomCardTransportationHistory extends StatelessWidget {
  const CustomCardTransportationHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                  image: const DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1616943269705-f8d095067a4e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHx0b21hdG9lfGVufDB8fHx8MTczNzY1NzI1Nnww&ixlib=rb-4.0.3&q=80&w=1080'),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  texTitletWidget(context, 'Tomate Chonto', 22),
                  texTitletWidget(context, 'Juan Peréz', 16),
                  moreInfo(
                      context, 'Cantidad:', 12, '10 Canastas', 12, 0.2, 0.22),
                  moreInfo(context, 'Precio Unitario:', 12, '30.000', 12, 0.26,
                      0.15),
                  moreInfo(
                      context, 'Total compra:', 12, '300.000', 12, 0.26, 0.15),
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
                  onPressed: () {},
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
                    minFontSize: 14,
                    style: temaApp.textTheme.titleSmall!.copyWith(
                        color: redApp,
                        fontWeight: FontWeight.w600,
                        fontSize: 30),
                  ),
                ),
                CustomButton(
                  onPressed: () {},
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
