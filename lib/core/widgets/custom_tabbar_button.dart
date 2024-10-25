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
      width: size.width * 0.4,
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? Colors.red : Colors.blueAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: size.height * 0.03,
          ),
          SizedBox(width: size.width * 0.02),
          AutoSizeText(
            label,
            style: textTheme.bodyMedium!.copyWith(color: Colors.white),
            maxLines: 1,
            minFontSize: 12,
            maxFontSize: 14,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
