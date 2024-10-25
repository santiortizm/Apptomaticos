import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  final Widget child;
  final double border;
  final double width;
  final double height;
  final double elevation;
  const CustomButton(
      {super.key,
      required this.onPressed,
      required this.color,
      required this.child,
      required this.border,
      required this.width,
      required this.height,
      required this.elevation});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return MaterialButton(
      height: size.height * height,
      minWidth: size.width * width,
      onPressed: onPressed,
      color: color,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(border),
      ),
      child: child,
    );
  }
}
