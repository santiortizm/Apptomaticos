import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomNotification extends StatefulWidget {
  final double width;
  final double height;
  final String assetImage;
  final String title;
  final Widget content;
  final Widget button;
  const CustomNotification(
      {super.key,
      required this.width,
      required this.height,
      required this.assetImage,
      required this.title,
      required this.content,
      required this.button});

  @override
  State<CustomNotification> createState() => _CustomNotificationState();
}

class _CustomNotificationState extends State<CustomNotification> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(10),
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        width: widget.width,
        height: widget.height,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                widget.assetImage,
                width: 70,
                height: 70,
              ),
              Container(
                alignment: Alignment.center,
                height: 50,
                child: AutoSizeText(
                  widget.title,
                  maxLines: 1,
                  maxFontSize: 28,
                  minFontSize: 4,
                  style: temaApp.textTheme.titleSmall!.copyWith(fontSize: 100),
                ),
              ),
              widget.content,
              widget.button,
            ],
          ),
        ),
      ),
    );
  }
}
