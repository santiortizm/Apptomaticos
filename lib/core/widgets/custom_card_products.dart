import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/presentation/screens/buy_product/buy_product_widget.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomCardProducts extends StatelessWidget {
  final String productId;
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
            builder: (context) => BuyProductWidget(productId: productId),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
            vertical: size.height * 0.015, horizontal: size.width * 0.025),
        width: size.width * 1,
        height: size.height * 0.4,
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
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.015),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.45,
                        child: AutoSizeText(
                          title,
                          minFontSize: 12,
                          maxFontSize: 18,
                          maxLines: 1,
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: size.width * 0.16,
                            child: const AutoSizeText(
                              'Estado :',
                              minFontSize: 12,
                              maxFontSize: 16,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            width: size.width * 0.28,
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
