import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomCardTransportation extends StatefulWidget {
  const CustomCardTransportation({super.key});

  @override
  State<CustomCardTransportation> createState() =>
      _CustomCardTransportationState();
}

class _CustomCardTransportationState extends State<CustomCardTransportation> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      width: size.width * 1,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.025, vertical: size.height * .015),
        child: Column(
          spacing: 12,
          children: [
            Row(
              spacing: 12,
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1625023725961-2a2b2d17e0c1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHw1fHxhZ3JpY3VsdG9yfGVufDB8fHx8MTcyODEwMjg3MHww&ixlib=rb-4.0.3&q=80&w=1080'),
                ),
                SizedBox(
                  width: size.width * 0.6,
                  child: AutoSizeText(
                    'Santiago Ortiz',
                    maxLines: 1,
                    maxFontSize: 14,
                    minFontSize: 12,
                    style: temaApp.textTheme.titleSmall!
                        .copyWith(color: Colors.black, fontSize: 14),
                  ),
                ),
              ],
            ),
            Container(
              width: size.width * .9,
              height: size.height * 0.2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://ieb-chile.cl/wp-content/uploads/2021/11/tomates-pixabay.jpg'),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * .5,
                  child: AutoSizeText(
                    'Precio Transporte:',
                    maxLines: 1,
                    maxFontSize: 14,
                    minFontSize: 12,
                    style: temaApp.textTheme.titleSmall!.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  width: size.width * .4,
                  child: AutoSizeText(
                    '7.000.000',
                    maxLines: 1,
                    maxFontSize: 14,
                    minFontSize: 12,
                    style: temaApp.textTheme.titleSmall!.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * .5,
                  child: AutoSizeText(
                    'Cantidad:',
                    maxLines: 1,
                    maxFontSize: 14,
                    minFontSize: 12,
                    style: temaApp.textTheme.titleSmall!.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  width: size.width * .4,
                  child: AutoSizeText(
                    '7 Toneladas',
                    maxLines: 1,
                    maxFontSize: 14,
                    minFontSize: 12,
                    style: temaApp.textTheme.titleSmall!.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.012),
              child: Row(
                spacing: 24,
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
            )
          ],
        ),
      ),
    );
  }
}
