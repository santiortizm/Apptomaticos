import 'package:apptomaticos/core/widgets/cards/custom_card_buys_merchant.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class MyCounterOffers extends StatefulWidget {
  const MyCounterOffers({super.key});

  @override
  State<MyCounterOffers> createState() => _MyCounterOffersState();
}

class _MyCounterOffersState extends State<MyCounterOffers> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: size.width * 1,
              height: size.height * 1,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/fondo_2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05, vertical: 0.05),
              child: Center(
                child: Container(
                  width: size.width,
                  height: size.height * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.height * 0.025),
                    child: Column(
                      children: [
                        Align(
                          alignment: const Alignment(-0.9, 0),
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
                        AutoSizeText(
                          'Mis productos',
                          maxFontSize: 26,
                          minFontSize: 18,
                          maxLines: 1,
                          style: temaApp.textTheme.titleSmall!.copyWith(
                              fontSize: 26,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: size.height * 0.7,
                          width: size.width * 1,
                          child: const SingleChildScrollView(
                            child: CustomCardBuysMerchant(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
