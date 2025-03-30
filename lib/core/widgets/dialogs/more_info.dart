import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class MoreInfo extends StatefulWidget {
  final double width;
  final double height;
  final String text;

  const MoreInfo(
      {super.key,
      required this.width,
      required this.height,
      required this.text});

  @override
  State<MoreInfo> createState() => _MoreInfoState();
}

class _MoreInfoState extends State<MoreInfo> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext messageContext) {
              return Dialog(
                insetPadding: EdgeInsets.all(10),
                backgroundColor: Colors.white,
                child: Container(
                  padding: EdgeInsets.only(bottom: 20),
                  alignment: Alignment.center,
                  width: widget.width,
                  height: widget.height,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 28,
                                  )),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 250,
                          child: AutoSizeText(
                            textAlign: TextAlign.justify,
                            widget.text,
                            maxLines: 8,
                            maxFontSize: 28,
                            minFontSize: 4,
                            style: temaApp.textTheme.titleSmall!
                                .copyWith(fontSize: 100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        alignment: Alignment.center,
        width: 300,
        height: 80,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          spacing: 6,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info,
              size: 20,
            ),
            SizedBox(
              width: 240,
              child: Text(
                widget.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: temaApp.textTheme.titleSmall!.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
