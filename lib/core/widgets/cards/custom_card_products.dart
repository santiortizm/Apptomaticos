import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/presentation/screens/products/buy_product_page.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomCardProducts extends StatelessWidget {
  final int productId;
  final String title;
  final String state;
  final String price;
  final String imageUrl;
  const CustomCardProducts(
      {super.key,
      required this.title,
      required this.state,
      required this.price,
      required this.imageUrl,
      required this.productId});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BuyProductPage(productId: productId),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
            vertical: size.height * 0.0025, horizontal: size.width * 0.005),
        width: size.width * 1,
        height: size.height * 0.38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: size.width * 1,
              height: size.height * 0.28,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: size.height * 0.015,
                  left: size.width * 0.025,
                  right: size.width * 0.025),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.4,
                        child: AutoSizeText(
                          title,
                          minFontSize: 12,
                          maxFontSize: 18,
                          maxLines: 1,
                          style: temaApp.textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: size.width * 0.17,
                            child: AutoSizeText(
                              'Estado :',
                              minFontSize: 12,
                              maxFontSize: 18,
                              maxLines: 1,
                              style: temaApp.textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.w700, fontSize: 18),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            width: size.width * 0.27,
                            child: AutoSizeText(
                              state,
                              minFontSize: 12,
                              maxFontSize: 16,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: buttonGreen),
                        width: size.width * 0.3,
                        height: size.height * 0.05,
                        child: AutoSizeText(
                          price,
                          minFontSize: 12,
                          maxFontSize: 16,
                          maxLines: 1,
                          style: temaApp.textTheme.titleSmall!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
