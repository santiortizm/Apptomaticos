import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/models/add_product_model.dart';
import 'package:App_Tomaticos/core/widgets/dialogs/custom_alert_dialog.dart';
import 'package:App_Tomaticos/core/widgets/button/custom_button.dart';
import 'package:App_Tomaticos/core/widgets/dialogs/custom_notification.dart';
import 'package:App_Tomaticos/core/widgets/drop_down_field/drop_down_field_controller.dart';
import 'package:App_Tomaticos/core/widgets/textfield/text_form_field_widget.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
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
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
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
                          minFontSize: 4,
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
                            TextButton(
                              onPressed: () {
                                GoRouter.of(context).go('/menu');
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_back,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    width: 70,
                                    height: 35,
                                    child: AutoSizeText('Atrás',
                                        maxFontSize: 18,
                                        minFontSize: 4,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: temaApp.textTheme.titleSmall!
                                            .copyWith(
                                                fontSize: 18,
                                                color: Colors.black)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: size.height * 0.025),
                          child: SizedBox(
                            width: 300,
                            child: AutoSizeText(
                              'Registro de Producto',
                              maxFontSize: 22,
                              minFontSize: 4,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: temaApp.textTheme.titleSmall!.copyWith(
                                  fontSize: 22, fontWeight: FontWeight.w600),
                            ),
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
                            SizedBox(
                              width: 130,
                              child: CustomButton(
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
                                  minFontSize: 4,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 130,
                              child: CustomButton(
                                onPressed: () async {
                                  try {
                                    if (_model.nameController.text.isEmpty ||
                                        _model
                                            .quantityController.text.isEmpty ||
                                        _model.harvestDateController.text
                                            .isEmpty ||
                                        _model.expirationDateController.text
                                            .isEmpty ||
                                        _model.priceController.text.isEmpty ||
                                        _model.selectedMaturity == null ||
                                        _model.selectedFertilizer == null) {
                                      _errorCampos(context);
                                      return;
                                    }
                                    final idUsuario =
                                        supabase.auth.currentUser!.id;
                                    // Insertar producto y obtener datos
                                    final response = await supabase
                                        .from('productos')
                                        .insert({
                                      'nombreProducto':
                                          _model.nameController.text,
                                      'cantidad': int.parse(
                                          _model.quantityController.text),
                                      'descripcion':
                                          _model.descriptionController.text,
                                      'maduracion': _model.selectedMaturity,
                                      'fertilizantes':
                                          _model.selectedFertilizer,
                                      'fechaCosecha':
                                          _model.harvestDateController.text,
                                      'fechaCaducidad':
                                          _model.expirationDateController.text,
                                      'imagen':
                                          'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp',
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
                                      _alertAddProduct(context);
                                    } else {
                                      // ignore: use_build_context_synchronously
                                      _error(context);
                                    }
                                  } catch (e) {
                                    // ignore: use_build_context_synchronously
                                    _error(context);
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
                                  minFontSize: 4,
                                  maxLines: 1,
                                ),
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
          return CustomAlertDialog(
            width: 300,
            height: 290,
            assetImage: './assets/images/advertencia.png',
            title: 'Alerta',
            content: Container(
              alignment: Alignment.center,
              width: 250,
              child: AutoSizeText(
                'Estás seguro de cancelar esta operacion?',
                maxLines: 2,
                maxFontSize: 26,
                minFontSize: 4,
                style: temaApp.textTheme.titleSmall!.copyWith(fontSize: 100),
              ),
            ),
            onPressedAcept: () {
              GoRouter.of(context).go('/menu');
            },
            onPressedCancel: () {
              Navigator.of(context).pop();
            },
          );
        });
  }

  Future<void> _errorCampos(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomNotification(
            width: 300,
            height: 300,
            assetImage: './assets/images/error.gif',
            title: 'Error',
            content: Container(
              alignment: Alignment.center,
              width: 250,
              child: AutoSizeText(
                'Debes llenar todos los campos para añadir un producto',
                maxLines: 2,
                maxFontSize: 26,
                minFontSize: 4,
                style: temaApp.textTheme.titleSmall!.copyWith(fontSize: 100),
              ),
            ),
            button: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(buttonGreen),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Container(
                      alignment: Alignment.center,
                      width: 80,
                      height: 28,
                      child: AutoSizeText('Aceptar',
                          maxLines: 1,
                          maxFontSize: 14,
                          minFontSize: 4,
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> _error(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomNotification(
            width: 300,
            height: 300,
            assetImage: './assets/images/error.gif',
            title: 'Error',
            content: Container(
              alignment: Alignment.center,
              width: 250,
              child: AutoSizeText(
                'Ha sucedido un error inesperado, por favor intente de nuevo',
                maxLines: 2,
                maxFontSize: 26,
                minFontSize: 4,
                style: temaApp.textTheme.titleSmall!.copyWith(fontSize: 100),
              ),
            ),
            button: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(buttonGreen),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Container(
                      alignment: Alignment.center,
                      width: 80,
                      height: 28,
                      child: AutoSizeText('Aceptar',
                          maxLines: 1,
                          maxFontSize: 14,
                          minFontSize: 4,
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> _alertAddProduct(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomNotification(
          width: 300,
          height: 250,
          assetImage: './assets/images/producto_agregado.gif',
          title: 'Producto agregado',
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            width: 250,
            child: AutoSizeText(
              'El producto ha sido agregado exitosamente!',
              maxLines: 2,
              maxFontSize: 26,
              minFontSize: 4,
              textAlign: TextAlign.justify,
              style: temaApp.textTheme.titleSmall!.copyWith(fontSize: 100),
            ),
          ),
          button: const SizedBox.shrink(),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted && Navigator.of(context).canPop()) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Cierra el diálogo
    }

    if (mounted) {
      // ignore: use_build_context_synchronously
      GoRouter.of(context).go('/menu'); // Navega a '/menu'
    }
  }
}
