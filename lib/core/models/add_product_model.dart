import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/widgets/dialogs/custom_alert_dialog.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddProductModel {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController harvestDateController = TextEditingController();
  final TextEditingController expirationDateController =
      TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedMaturity;
  String? selectedFertilizer;
  String? selectedProduct;
  // Lista de objetos de ejemplo para los dropdowns

  final List<String> maturityOptions = ['Verde', 'Maduro', 'Muy Maduro'];
  final List<String> fertilizerOptions = ['Etileno', 'Sin Etileno'];
  final List<String> productOptions = [
    'Tomate Chonto',
    'Tomate Eterei',
    'Tomate Libertador'
  ];
  // Método para seleccionar la fecha de cosecha usando el datepicker
  void selectHarvestDate(BuildContext context) async {
    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        DateTime selectedDate = DateTime.now();

        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: buttonGreen, // Color de la barra superior
            hintColor: Colors.green, // Color del selector
            colorScheme: ColorScheme.light(primary: buttonGreen),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return CustomAlertDialog(
                width: 300,
                height: 600,
                assetImage: './assets/images/calendario.png',
                title: 'Seleccione una fecha',
                content: CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2026),
                  onDateChanged: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
                onPressedAcept: () async {
                  bool? confirm = await _confirmAction(context);
                  if (confirm == true) {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context, selectedDate);
                  } else {
                    return;
                  }
                },
                onPressedCancel: () => Navigator.pop(context, null),
              );
            },
          ),
        );
      },
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat.yMMMd().format(pickedDate);
      harvestDateController.text = formattedDate;
      calculateExpirationDate(pickedDate); //  Actualiza la fecha de vencimiento
    }
  }

  // Método que calcula la fecha de caducidad dependiendo de la maduración
  void calculateExpirationDate(DateTime harvestDate) {
    if (selectedMaturity == null) return;

    int weeksToAdd = 0;

    if (selectedMaturity == 'Verde') {
      weeksToAdd = 3;
    } else if (selectedMaturity == 'Maduro') {
      weeksToAdd = 2;
    } else if (selectedMaturity == 'Muy Maduro') {
      weeksToAdd = 1;
    }

    // Calcula la fecha de caducidad sumando días
    final expirationDate = harvestDate.add(Duration(days: 7 * weeksToAdd));
    expirationDateController.text = DateFormat.yMMMd().format(expirationDate);
  }

  Future<bool> _confirmAction(BuildContext context) async {
    return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                width: 300,
                height: 290,
                assetImage: './assets/images/advertencia.png',
                title: 'Alerta',
                content: Container(
                  alignment: Alignment.center,
                  width: 250,
                  child: AutoSizeText(
                    'Debes asegurarte que la fecha sea la correcta',
                    maxLines: 2,
                    maxFontSize: 26,
                    minFontSize: 4,
                    style:
                        temaApp.textTheme.titleSmall!.copyWith(fontSize: 100),
                  ),
                ),
                onPressedAcept: () => Navigator.pop(context, true),
                onPressedCancel: () => Navigator.pop(context, false),
              );
            }) ??
        false;
  }

  // Método para limpiar los controladores
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    harvestDateController.dispose();
    expirationDateController.dispose();
    priceController.dispose();
  }
}
