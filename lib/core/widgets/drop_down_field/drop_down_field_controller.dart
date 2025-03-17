import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:flutter/material.dart';

class DropDownFieldController extends StatefulWidget {
  final String labelText;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  const DropDownFieldController(
      {super.key,
      required this.labelText,
      required this.options,
      this.selectedValue,
      required this.onChanged});

  @override
  State<DropDownFieldController> createState() =>
      _DropDownFieldControllerState();
}

class _DropDownFieldControllerState extends State<DropDownFieldController> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: widget.selectedValue,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: widget.labelText,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: widget.options
          .map((option) => DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  style: temaApp.textTheme.titleSmall,
                ),
              ))
          .toList(),
      onChanged: widget.onChanged,
    );
  }
}
