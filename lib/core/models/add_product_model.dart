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
  final List<String> fertilizerOptions = ['Orgánico', 'Inorgánico', 'Mixto'];

  // Método para seleccionar la fecha de cosecha usando el datepicker
  void selectHarvestDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      final formattedDate = DateFormat.yMMMd().format(pickedDate);
      harvestDateController.text = formattedDate;
      calculateExpirationDate(pickedDate); // Cambiado a método público
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
