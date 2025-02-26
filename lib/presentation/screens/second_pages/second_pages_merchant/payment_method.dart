import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/core/widgets/drop_down_field/custom_dropdown_field.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

const List<String> lista = <String>['PSE', 'CONTRA ENTREGA'];

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
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
                  child: Column(
                    spacing: 16,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.025),
                            alignment: Alignment.centerLeft,
                            width: size.width * .3,
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
                                    style: temaApp.textTheme.titleSmall!
                                        .copyWith(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                            fontSize: 28),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      texTitletWidget(context, 'Método de Pago', 25),
                      textWidget(
                          context,
                          'Seleccione el método de pago de su preferencia.',
                          16),
                      SizedBox(
                        width: size.width * 0.5,
                        child: CustomDropdownField(
                          options: lista,
                          labelText: 'Selecionar Opción',
                          onChanged: (String? value) {},
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.05),
                        child: CustomButton(
                          onPressed: () {},
                          color: buttonGreen,
                          colorBorder: Colors.transparent,
                          border: 12,
                          width: 0.4,
                          height: 0.07,
                          elevation: 2,
                          sizeBorder: 0,
                          child: AutoSizeText(
                            'CONTINUAR CON LA COMPRA',
                            maxLines: 1,
                            maxFontSize: 17,
                            minFontSize: 14,
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
        maxLines: 5,
        style: temaApp.textTheme.titleSmall!.copyWith(
          fontSize: 100,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
    );
  }
}
