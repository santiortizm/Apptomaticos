import 'dart:io';

import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/services/permissions_service.dart';

import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/core/widgets/custom_dialog_confimation.dart';
import 'package:apptomaticos/core/widgets/text_form_field_widget.dart';
import 'package:apptomaticos/core/models/add_product_model.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddProductWidget extends StatefulWidget {
  const AddProductWidget({super.key});

  @override
  _AddProductWidgetState createState() => _AddProductWidgetState();
}

class _AddProductWidgetState extends State<AddProductWidget> {
  final AddProductModel _model = AddProductModel();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  // Método para verificar permisos y abrir opciones de selección de imagen
  Future<void> _selectImage() async {
    // Verificar y solicitar permisos de cámara y almacenamiento
    final bool permissionGranted = await storagePermission();

    if (permissionGranted) {
      // Si los permisos están concedidos, mostrar opciones
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Seleccionar de la galería'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _selectedImage = image;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Tomar una foto'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setState(() {
                        _selectedImage = image;
                      });
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Si no se concedieron permisos, mostrar un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Permisos de almacenamiento y cámara no concedidos.'),
          action: SnackBarAction(
            label: 'Configurar',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/fondo1.jpg'),
              ),
            ),
          ),
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05, vertical: 20),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05, vertical: 15),
              width: size.width,
              height: size.height * 1.04,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.08),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _selectedImage != null
                              ? FileImage(File(_selectedImage!.path))
                              : const AssetImage('assets/images/fondo1.jpg')
                                  as ImageProvider,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.075,
                          ),
                          child: IconButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(redApp)),
                            color: redApp,
                            onPressed: _selectImage,
                            icon: const Icon(
                              size: 26,
                              Icons.camera_alt_rounded,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormFieldWidget(
                    labelText: 'Nombre Producto',
                    controller: _model.nameController,
                    icon: Icons.shopping_cart,
                  ),
                  const SizedBox(height: 16),
                  TextFormFieldWidget(
                    labelText: 'Cantidad (CANASTA)',
                    controller: _model.quantityController,
                    icon: Icons.shopping_basket,
                  ),
                  const SizedBox(height: 16),
                  // Descripción (Opcional)
                  TextFormFieldWidget(
                    labelText: 'Descripción (OPCIONAL)',
                    controller: _model.descriptionController,
                    icon: Icons.description,
                  ),
                  const SizedBox(height: 16),
                  // Dropdown de Maduración
                  _buildDropdownField(
                    'Seleccionar Maduración Actual',
                    _model.maturityOptions,
                    _model.selectedMaturity,
                    (value) {
                      setState(() {
                        _model.selectedMaturity = value;
                        // Actualizar la fecha de caducidad
                        _model.calculateExpirationDate(DateTime.now());
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Dropdown de Fertilizantes
                  _buildDropdownField(
                    'Seleccionar Fertilizantes Usados',
                    _model.fertilizerOptions,
                    _model.selectedFertilizer,
                    (value) {
                      setState(() {
                        _model.selectedFertilizer = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Fecha de Cosecha
                  TextFormFieldWidget(
                    labelText: 'Fecha de Cosecha',
                    controller: _model.harvestDateController,
                    icon: Icons.calendar_today,
                    readOnly: true,
                    onTap: () => _model.selectHarvestDate(context),
                  ),
                  const SizedBox(height: 16),
                  // Fecha de Caducidad (Automática)
                  TextFormFieldWidget(
                    labelText: 'Fecha de Caducidad',
                    controller: _model.expirationDateController,
                    icon: Icons.calendar_today,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  // Precio Canasta
                  TextFormFieldWidget(
                    labelText: 'Precio Canasta',
                    controller: _model.priceController,
                    icon: Icons.attach_money,
                  ),
                  const SizedBox(height: 16),
                  // Botones Cancelar y Publicar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        onPressed: () {
                          CustomDialogConfirmation.showConfirmationDialog(
                            context: context,
                            title: 'Advertencia',
                            content: 'Está seguro de cancelar la publicación?',
                            confirmText: 'Aceptar',
                            cancelText: 'Cancelar',
                            onConfirm: () => context.go('/menu'),
                            onCancel: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                        color: redApp,
                        border: 18,
                        width: 0.2,
                        height: 0.07,
                        elevation: 0,
                        child: AutoSizeText(
                          'Cancelar',
                          style: temaApp.textTheme.titleSmall!
                              .copyWith(fontSize: 18, color: Colors.white),
                          maxFontSize: 18,
                          minFontSize: 14,
                        ),
                      ),
                      CustomButton(
                        onPressed: () {},
                        color: buttonGreen,
                        border: 18,
                        width: 0.2,
                        height: 0.07,
                        elevation: 0,
                        child: AutoSizeText(
                          'Publicar',
                          style: temaApp.textTheme.titleSmall!
                              .copyWith(fontSize: 18, color: Colors.white),
                          maxFontSize: 18,
                          minFontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String labelText,
    List<String> options,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: options
          .map((option) => DropdownMenuItem(
                value: option,
                child: Text(option),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
