import 'package:apptomaticos/core/constants/colors.dart';
import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget {
  final String labelText;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;

  const TextFormFieldWidget({
    super.key,
    required this.labelText,
    required this.controller,
    required this.icon,
    this.readOnly = false,
    this.onTap,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      controller: controller,
      readOnly: readOnly,
      cursorColor: buttonGreen,
      cursorErrorColor: redApp,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: redApp),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onTap: onTap,
    );
  }
}
