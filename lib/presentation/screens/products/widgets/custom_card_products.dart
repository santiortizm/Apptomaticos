import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomCardProducts extends StatelessWidget {
  final String title;
  final String state;
  final String price;
  const CustomCardProducts(
      {super.key,
      required this.title,
      required this.state,
      required this.price});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/fondo_2.jpg'),
                  fit: BoxFit.cover),
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
                          color: Colors.amber),
                      width: size.width * 0.3,
                      height: size.height * 0.05,
                      child: AutoSizeText(
                        price,
                        minFontSize: 12,
                        maxFontSize: 16,
                        maxLines: 1,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
