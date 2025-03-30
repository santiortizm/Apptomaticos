import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;

  const CustomTabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 100,
      height: 50,
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? buttonGreen : buttoGreenSelected,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        spacing: 2,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          AutoSizeText(
            label,
            style: textTheme.bodyMedium!.copyWith(color: Colors.white),
            maxLines: 1,
            minFontSize: 4,
            maxFontSize: 16,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
