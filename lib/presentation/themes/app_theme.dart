import 'package:apptomaticos/core/constants/colors.dart';
import 'package:flutter/material.dart';

final temaApp = ThemeData(
  primaryColor: redApp,
  indicatorColor: redApp,
  primaryTextTheme: const TextTheme(
      titleSmall: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
  fontFamily: 'Poppins',
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: redApp,
  ),
  inputDecorationTheme: InputDecorationTheme(
    errorStyle: TextStyle(
      color: redApp,
    ),
    floatingLabelStyle: TextStyle(color: redApp, fontSize: 16),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: buttonGreen, width: 3.0),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey,
        width: 2.0,
      ),
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
    ),
  ),
  dialogTheme: const DialogTheme(
    backgroundColor: Color.fromARGB(255, 255, 255, 255),
  ),
  textTheme: const TextTheme(
    //Tipo de letra portada
    titleMedium: TextStyle(
      fontFamily: 'Riot',
    ),
    titleSmall: TextStyle(
      fontFamily: 'Poppins',
    ),
  ),
);
