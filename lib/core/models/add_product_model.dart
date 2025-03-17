import 'package:App_Tomaticos/core/constants/colors.dart';
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

  // Lista de objetos de ejemplo para los dropdowns
  final List<String> maturityOptions = ['Verde', 'Maduro', 'Muy Maduro'];
  final List<String> fertilizerOptions = ['Etileno', 'Sin Etileno'];

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
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: const Text("Selecciona una fecha"),
                content: SizedBox(
                  height: 300,
                  child: CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2026),
                    onDateChanged: (date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: Text("Cancelar", style: TextStyle(color: redApp)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, selectedDate),
                    child:
                        Text("Aceptar", style: TextStyle(color: buttonGreen)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat.yMMMd().format(pickedDate);
      harvestDateController.text = formattedDate;
      calculateExpirationDate(
          pickedDate); // ✅ Actualiza la fecha de vencimiento
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
