import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatefulWidget {
  final double width;
  final double height;
  final String assetImage;
  final String title;
  final Widget content;
  final VoidCallback onPressedAcept;
  final VoidCallback onPressedCancel;
  const CustomAlertDialog(
      {super.key,
      required this.width,
      required this.height,
      required this.assetImage,
      required this.title,
      required this.content,
      required this.onPressedAcept,
      required this.onPressedCancel});

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
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
                height: 42,
                child: AutoSizeText(
                  widget.title,
                  maxLines: 1,
                  maxFontSize: 32,
                  minFontSize: 4,
                  style: temaApp.textTheme.titleSmall!.copyWith(fontSize: 100),
                ),
              ),
              widget.content,
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(redApp),
                      ),
                      onPressed: widget.onPressedCancel,
                      child: Container(
                        alignment: Alignment.center,
                        width: 80,
                        height: 28,
                        child: AutoSizeText(
                          'Cancelar',
                          maxLines: 1,
                          maxFontSize: 14,
                          minFontSize: 4,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(buttonGreen),
                      ),
                      onPressed: widget.onPressedAcept,
                      child: Container(
                        alignment: Alignment.center,
                        width: 80,
                        height: 28,
                        child: AutoSizeText('Aceptar',
                            maxLines: 1,
                            maxFontSize: 14,
                            minFontSize: 4,
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
