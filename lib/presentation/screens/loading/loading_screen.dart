import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image:
                      AssetImage('./assets/images/background/img_portada.webp'),
                  fit: BoxFit.cover,
                  opacity: 0.6),
              color: Colors.black),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  'APPTOMATICOS',
                  maxLines: 1,
                  maxFontSize: 68,
                  minFontSize: 26,
                  style: temaApp.textTheme.titleMedium!
                      .copyWith(color: Colors.white, fontSize: 100),
                ),
                CircularProgressIndicator(
                  color: redApp,
                )
              ],
            ),
          )),
    );
  }
}
