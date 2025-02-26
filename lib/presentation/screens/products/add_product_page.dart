import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/models/add_product_model.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/core/widgets/drop_down_field/drop_down_field_controller.dart';
import 'package:apptomaticos/core/widgets/text_form_field_widget.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final AddProductModel _model = AddProductModel();
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/fondo1.jpg'),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.only(
                  top: size.height * 0.03,
                  left: size.width * 0.025,
                  right: size.width * 0.025),
              child: Column(
                spacing: 12,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.015,
                        horizontal: size.width * 0.025),
                    margin: EdgeInsets.only(bottom: size.height * 0.025),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: size.width * 1,
                    child: Column(
                      spacing: 8,
                      children: [
                        const CircleAvatar(
                          radius: 52,
                          backgroundImage:
                              AssetImage('assets/images/img_portada.webp'),
                        ),
                        AutoSizeText(
                          '¡ Hola, este espacio fue diseñado para que pueda publicar sus productos !',
                          maxFontSize: 18,
                          minFontSize: 14,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: temaApp.textTheme.titleMedium!.copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.015,
                        horizontal: size.width * 0.025),
                    margin: EdgeInsets.only(bottom: size.height * 0.025),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: size.width * 1,
                    child: Column(
                      spacing: 20,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              iconSize: 36,
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                GoRouter.of(context).go('/menu');
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: size.height * 0.025),
                          child: AutoSizeText(
                            'Registro de Producto',
                            maxFontSize: 22,
                            minFontSize: 18,
                            maxLines: 1,
                            style: temaApp.textTheme.titleSmall!.copyWith(
                                fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextFormFieldWidget(
                          labelText: 'Nombre Producto',
                          keyboardType: TextInputType.name,
                          controller: _model.nameController,
                          icon: Icons.shopping_cart,
                        ),
                        TextFormFieldWidget(
                          labelText: 'Cantidad (CANASTA)',
                          keyboardType: TextInputType.number,
                          controller: _model.quantityController,
                          icon: Icons.shopping_basket,
                        ),
                        TextFormFieldWidget(
                          labelText: 'Descripción (OPCIONAL)',
                          keyboardType: TextInputType.text,
                          controller: _model.descriptionController,
                          icon: Icons.description,
                        ),
                        DropDownFieldController(
                          labelText: 'Seleccionar Maduración Actual',
                          selectedValue: _model.selectedMaturity,
                          options: _model.maturityOptions,
                          onChanged: (value) {
                            setState(() {
                              _model.selectedMaturity = value;
                              // Actualizar la fecha de caducidad
                              _model.calculateExpirationDate(DateTime.now());
                            });
                          },
                        ),
                        DropDownFieldController(
                          labelText: 'Seleccionar Fertilizantes Usados',
                          selectedValue: _model.selectedFertilizer,
                          options: _model.fertilizerOptions,
                          onChanged: (value) {
                            setState(() {
                              _model.selectedFertilizer = value;
                            });
                          },
                        ),
                        TextFormFieldWidget(
                          labelText: 'Fecha de Cosecha',
                          controller: _model.harvestDateController,
                          keyboardType: TextInputType.datetime,
                          icon: Icons.calendar_today,
                          readOnly: true,
                          onTap: () => _model.selectHarvestDate(context),
                        ),
                        TextFormFieldWidget(
                          labelText: 'Fecha de Caducidad',
                          controller: _model.expirationDateController,
                          keyboardType: TextInputType.datetime,
                          icon: Icons.calendar_today,
                          readOnly: true,
                        ),
                        TextFormFieldWidget(
                          labelText: 'Precio Canasta',
                          keyboardType: TextInputType.number,
                          controller: _model.priceController,
                          icon: Icons.attach_money,
                        ),
                        Row(
                          spacing: 16,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                              onPressed: () {
                                _alertForCancelAction(context);
                              },
                              color: redApp,
                              border: 18,
                              width: 0.2,
                              height: 0.07,
                              elevation: 0,
                              colorBorder: Colors.transparent,
                              sizeBorder: 0,
                              child: AutoSizeText(
                                'Cancelar',
                                style: temaApp.textTheme.titleSmall!.copyWith(
                                    fontSize: 18, color: Colors.white),
                                maxFontSize: 18,
                                minFontSize: 14,
                              ),
                            ),
                            CustomButton(
                              onPressed: () async {
                                try {
                                  if (_model.nameController.text.isEmpty ||
                                      _model.quantityController.text.isEmpty ||
                                      _model
                                          .harvestDateController.text.isEmpty ||
                                      _model.expirationDateController.text
                                          .isEmpty ||
                                      _model.priceController.text.isEmpty ||
                                      _model.selectedMaturity == null ||
                                      _model.selectedFertilizer == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Por favor complete todos los campos requeridos.'),
                                      ),
                                    );
                                    return;
                                  }
                                  final idUsuario =
                                      supabase.auth.currentUser!.id;
                                  // Insertar producto y obtener datos
                                  final response =
                                      await supabase.from('productos').insert({
                                    'nombreProducto':
                                        _model.nameController.text,
                                    'cantidad': int.parse(
                                        _model.quantityController.text),
                                    'descripcion':
                                        _model.descriptionController.text,
                                    'maduracion': _model.selectedMaturity,
                                    'fertilizantes': _model.selectedFertilizer,
                                    'fechaCosecha':
                                        _model.harvestDateController.text,
                                    'fechaCaducidad':
                                        _model.expirationDateController.text,
                                    'precio': double.parse(
                                        _model.priceController.text),
                                    'idPropietario': idUsuario,
                                  }).select();
                                  // Verificar si response contiene datos
                                  if (response.isNotEmpty) {
                                    // Limpiar campos
                                    _model.nameController.clear();
                                    _model.quantityController.clear();
                                    _model.descriptionController.clear();
                                    _model.harvestDateController.clear();
                                    _model.expirationDateController.clear();
                                    _model.priceController.clear();
                                    setState(() {
                                      _model.selectedMaturity = null;
                                      _model.selectedFertilizer = null;
                                    });

                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Producto agregado correctamente')),
                                    );

                                    // ignore: use_build_context_synchronously
                                    GoRouter.of(context).go('/menu');
                                  } else {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'No se devolvieron datos de la inserción')),
                                    );
                                  }
                                } catch (e) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Error inesperado: $e')),
                                  );
                                }
                              },
                              color: buttonGreen,
                              border: 18,
                              width: 0.2,
                              height: 0.07,
                              elevation: 0,
                              colorBorder: Colors.transparent,
                              sizeBorder: 0,
                              child: AutoSizeText(
                                'Aceptar',
                                style: temaApp.textTheme.titleSmall!.copyWith(
                                    fontSize: 18, color: Colors.white),
                                maxFontSize: 18,
                                minFontSize: 14,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _alertForCancelAction(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alerta'),
            content: const Text('Estás seguro de cancelar esta operacion?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  GoRouter.of(context).go('/menu');
                },
              ),
            ],
          );
        });
  }
}
