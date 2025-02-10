import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class OffertPage extends StatefulWidget {
  const OffertPage({super.key});

  @override
  State<OffertPage> createState() => _OffertPageState();
}

class _OffertPageState extends State<OffertPage> {
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
                                'Atras',
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
                      textWidget(context, 'Ofertar', 28),
                      Container(
                        width: size.width * 1,
                        height: size.height * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          image: const DecorationImage(
                            image: NetworkImage(
                                'https://blog.lexmed.com/images/librariesprovider80/blog-post-featured-images/shutterstock_1896755260.jpg?sfvrsn=52546e0a_0'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      containerPrice(context, 'Precio Canasta', '20.000', 16),
                      textWidget(context, 'Cantidad a Comprar:', 18),
                      SizedBox(
                        width: size.width * 0.6,
                        child: textFormField(context, 'Cantidad en Canastas',
                            TextInputType.number),
                      ),
                      textWidget(context, 'Precio a ofertar (Por canasta)', 18),
                      SizedBox(
                        width: size.width * 0.6,
                        child: textFormField(
                            context, 'Precio a ofertar', TextInputType.number),
                      ),
                      containerPrice(context, 'Total a Pagar:', '0.0', 16),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: size.height * 0.025),
                        child: CustomButton(
                          onPressed: () {},
                          color: buttonGreen,
                          colorBorder: buttonGreen,
                          border: 12,
                          width: 0.4,
                          height: 0.07,
                          elevation: 1,
                          sizeBorder: 0,
                          child: AutoSizeText(
                            'OFERTAR',
                            maxLines: 1,
                            maxFontSize: 20,
                            minFontSize: 18,
                            style: temaApp.textTheme.titleSmall!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 30),
                          ),
                        ),
                      )
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
              minFontSize: 14,
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
              minFontSize: 14,
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

  Widget textFormField(
      BuildContext context, String label, TextInputType keynoardType) {
    return TextFormField(
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
}
