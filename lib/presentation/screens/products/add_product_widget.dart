import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/widgets/avatar_product.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/core/widgets/custom_dialog_confimation.dart';
import 'package:apptomaticos/core/widgets/text_form_field_widget.dart';
import 'package:apptomaticos/core/models/add_product_model.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductWidget extends StatefulWidget {
  const AddProductWidget({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _AddProductWidgetState createState() => _AddProductWidgetState();
}

class _AddProductWidgetState extends State<AddProductWidget> {
  final AddProductModel _model = AddProductModel();
  final SupabaseClient supabase = Supabase.instance.client;
  String? _imageUrl;

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Altura máxima de una pantalla pequeña (por ejemplo, iPhone SE)
    const double smallScreenHeight = 667.0; // Altura en píxeles de iPhone SE

    // Condicional para ajustar la altura del contenedor
    final containerHeight = size.height <= smallScreenHeight
        ? size.height * 1.28
        : size.height * 1.15;
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
            decoration:
                BoxDecoration(color: Colors.black.withValues(alpha: 0.3)),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05, vertical: 20),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05, vertical: 15),
              width: size.width,
              height: containerHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.08),
                    child: AvatarProduct(
                      imageUrl: _imageUrl,
                      onUpLoad: (imageUrl) {
                        setState(() {
                          _imageUrl = imageUrl;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Nombre del producto
                  TextFormFieldWidget(
                    labelText: 'Nombre Producto',
                    keyboardType: TextInputType.name,
                    controller: _model.nameController,
                    icon: Icons.shopping_cart,
                  ),
                  const SizedBox(height: 16),
                  // Cantidad (Canasta)
                  TextFormFieldWidget(
                    labelText: 'Cantidad (CANASTA)',
                    keyboardType: TextInputType.number,
                    controller: _model.quantityController,
                    icon: Icons.shopping_basket,
                  ),
                  const SizedBox(height: 16),
                  // Descripción (Opcional)
                  TextFormFieldWidget(
                    labelText: 'Descripción (OPCIONAL)',
                    keyboardType: TextInputType.text,
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
                    keyboardType: TextInputType.datetime,
                    icon: Icons.calendar_today,
                    readOnly: true,
                    onTap: () => _model.selectHarvestDate(context),
                  ),
                  const SizedBox(height: 16),
                  // Fecha de Caducidad (Automática)
                  TextFormFieldWidget(
                    labelText: 'Fecha de Caducidad',
                    controller: _model.expirationDateController,
                    keyboardType: TextInputType.datetime,
                    icon: Icons.calendar_today,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  // Precio Canasta
                  TextFormFieldWidget(
                    labelText: 'Precio Canasta',
                    keyboardType: TextInputType.number,
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
                        colorBorder: Colors.transparent,
                        sizeBorder: 0,
                        child: AutoSizeText(
                          'Cancelar',
                          style: temaApp.textTheme.titleSmall!
                              .copyWith(fontSize: 18, color: Colors.white),
                          maxFontSize: 18,
                          minFontSize: 14,
                        ),
                      ),
                      CustomButton(
                        onPressed: () async {
                          try {
                            // Validar que todos los campos requeridos estén completos
                            if (_model.nameController.text.isEmpty ||
                                _model.quantityController.text.isEmpty ||
                                _model.harvestDateController.text.isEmpty ||
                                _model.expirationDateController.text.isEmpty ||
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

                            // Obtener el ID del usuario autenticado
                            final userIdResponse = await supabase
                                .from('usuarios')
                                .select('idUsuario')
                                .eq('idAuth', supabase.auth.currentUser!.id)
                                .single();

                            final idUsuario = userIdResponse['idUsuario'];

                            // Insertar producto y obtener datos
                            final response =
                                await supabase.from('productos').insert({
                              'nombreProducto': _model.nameController.text,
                              'cantidad':
                                  int.parse(_model.quantityController.text),
                              'descripcion': _model.descriptionController.text,
                              'maduracion': _model.selectedMaturity,
                              'fertilizantes': _model.selectedFertilizer,
                              'fechaCosecha': _model.harvestDateController.text,
                              'fechaCaducidad':
                                  _model.expirationDateController.text,
                              'precio':
                                  double.parse(_model.priceController.text),
                              'idUsuario': idUsuario,
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

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Producto agregado correctamente')),
                              );

                              // Redirigir al menú
                              context.go('/menu');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'No se devolvieron datos de la inserción')),
                              );
                            }
                          } catch (e) {
                            print('Error inesperado: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error inesperado: $e')),
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
