import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/models/transport_model.dart';
import 'package:App_Tomaticos/core/services/cloudinary_service.dart';
import 'package:App_Tomaticos/core/services/transport_service.dart';
import 'package:App_Tomaticos/core/widgets/dialogs/custom_alert_dialog.dart';
import 'package:App_Tomaticos/core/widgets/button/custom_button.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomCardTransport extends StatefulWidget {
  final String idUsuario;
  final String imageUrlProduct;
  final String countTransport;
  final int idCompra;
  const CustomCardTransport({
    super.key,
    required this.idUsuario,
    required this.idCompra,
    required this.imageUrlProduct,
    required this.countTransport,
  });

  @override
  State<CustomCardTransport> createState() => _CustomCardTransportState();
}

class _CustomCardTransportState extends State<CustomCardTransport> {
  final supabase = Supabase.instance.client;
  final TransportService transportService = TransportService();
  final cloudinaryService =
      CloudinaryService(cloudName: dotenv.env['CLOUD_NAME'] ?? '');

  late double countTransport;
  late int transportPrice;
  String? buyerName;
  String? buyerImage;

  @override
  void initState() {
    super.initState();
    _calculateTransportPrice();
    _calculateCountTransport();
    _fetchUserData();
  }

  ///  Convierte la cantidad a toneladas
  void _calculateCountTransport() {
    try {
      final int cantidad = int.parse(widget.countTransport);
      countTransport = (cantidad * 23) / 1000;
    } catch (e) {
      countTransport = 0;
    }
  }

  ///  Calcula el precio del transporte
  void _calculateTransportPrice() {
    final int cantidad = int.parse(widget.countTransport);
    int operacion = cantidad * 23;
    transportPrice = operacion * 400;
  }

  String formatPrice(num price) {
    final formatter =
        NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0);
    return formatter.format(price);
  }

  ///  Obtiene la información del comprador
  Future<void> _fetchUserData() async {
    try {
      final response = await supabase
          .from('usuarios')
          .select('nombre')
          .eq('idUsuario', widget.idUsuario)
          .maybeSingle();

      final String imagePath = 'profiles/${widget.idUsuario}/profile.jpg';
      final String imageUrl =
          supabase.storage.from('profiles').getPublicUrl(imagePath);

      if (mounted) {
        setState(() {
          buyerName = response?['nombre'] ?? 'Desconocido';
          buyerImage = '$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}';
        });
      }
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
    }
  }

  /// 🔥 **Muestra el diálogo para seleccionar la fecha de cargue**
  Future<void> _showDateSelectionDialog() async {
    DateTime? selectedCargaDate;
    DateTime? entregaDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Fecha de Cargue'),
        backgroundColor: Colors.white,
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onTap: () async {
                    final DateTime? newDate =
                        await selectTransportDate(context);
                    if (newDate != null) {
                      setStateDialog(() {
                        selectedCargaDate = newDate;
                        entregaDate = newDate.add(const Duration(days: 1));
                      });
                    }
                  },
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Cargue',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: selectedCargaDate != null
                        ? "${selectedCargaDate!.day}/${selectedCargaDate!.month}/${selectedCargaDate!.year}"
                        : '',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Entrega',
                  ),
                  controller: TextEditingController(
                    text: entregaDate != null
                        ? "${entregaDate!.day}/${entregaDate!.month}/${entregaDate!.year}"
                        : '',
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text("Cancelar", style: TextStyle(color: redApp)),
          ),
          TextButton(
            onPressed: () {
              if (selectedCargaDate != null) {
                Navigator.pop(context, selectedCargaDate);
                _handleTransportCreation(selectedCargaDate!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: redApp,
                      content: Text('Seleccione una fecha de cargue')),
                );
              }
            },
            child: Text("Aceptar", style: TextStyle(color: buttonGreen)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTransportCreation(DateTime fechaCargue) async {
    final idTransportador = supabase.auth.currentUser!.id;
    final bool hasActiveTransport =
        await transportService.hasActiveTransport(idTransportador);

    if (hasActiveTransport) {
      _showActiveTransportDialog();
      return;
    }

    final transport = Transport(
      idTransporte: DateTime.now().millisecondsSinceEpoch,
      createdAt: DateTime.now(),
      fechaCargue: fechaCargue.toString(),
      fechaEntrega: fechaCargue.add(const Duration(days: 1)).toString(),
      estado: 'Aceptado',
      pesoCarga: countTransport,
      valorTransporte: transportPrice,
      idCompra: widget.idCompra,
      idTransportador: idTransportador,
    );

    final success = await transportService.createTransport(transport);

    if (success) {
      await supabase
          .from('compras')
          .update({'estadoCompra': 'Transportando'}).eq('id', widget.idCompra);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transporte registrado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar el transporte')),
      );
    }
  }

  void _showActiveTransportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transporte en Curso'),
        content: const Text(
            'Ya tienes un transporte en curso. Finalízalo antes de registrar otro.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Aceptar',
              style: TextStyle(color: buttonGreen),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      width: size.width * 1,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.020, vertical: size.height * .015),
        child: Column(
          spacing: 12,
          children: [
            Row(
              spacing: 12,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage:
                      (buyerImage != null && buyerImage!.isNotEmpty)
                          ? NetworkImage(buyerImage!)
                          : const AssetImage(
                                  "./assets/images/icon_user/profile.png")
                              as ImageProvider,
                ),
                SizedBox(
                  width: size.width * 0.5,
                  child: AutoSizeText(
                    buyerName ?? 'Cargando...',
                    maxLines: 1,
                    maxFontSize: 14,
                    minFontSize: 12,
                    style: temaApp.textTheme.titleSmall!
                        .copyWith(color: Colors.black, fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: size.width * .9,
              height: size.height * 0.2,
              child: CachedNetworkImage(
                imageUrl: cloudinaryService.getOptimizedImageUrl(
                  widget.imageUrlProduct,
                ),
                fit: BoxFit.scaleDown,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Image.network(
                    'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * .45,
                  child: AutoSizeText(
                    'Precio Transporte:',
                    maxLines: 1,
                    maxFontSize: 14,
                    minFontSize: 12,
                    style: temaApp.textTheme.titleSmall!.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  width: size.width * .25,
                  child: AutoSizeText(
                    '\$${formatPrice(transportPrice)} ',
                    maxLines: 1,
                    maxFontSize: 14,
                    minFontSize: 12,
                    style: temaApp.textTheme.titleSmall!.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * .45,
                  child: AutoSizeText(
                    'Peso Carga:',
                    maxLines: 1,
                    maxFontSize: 14,
                    minFontSize: 12,
                    style: temaApp.textTheme.titleSmall!.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  width: size.width * .25,
                  child: AutoSizeText(
                    '${countTransport.toStringAsFixed(2)} T',
                    maxLines: 1,
                    maxFontSize: 14,
                    minFontSize: 12,
                    style: temaApp.textTheme.titleSmall!.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.012),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    onPressed: _showDateSelectionDialog,
                    color: buttonGreen,
                    colorBorder: Colors.transparent,
                    border: 18,
                    width: 0.3,
                    height: 0.05,
                    elevation: 2,
                    sizeBorder: 0,
                    child: Row(
                      spacing: 4,
                      children: [
                        AutoSizeText(
                          'TRANSPORTAR',
                          maxLines: 1,
                          maxFontSize: 17,
                          minFontSize: 14,
                          style: temaApp.textTheme.titleSmall!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 30),
                        ),
                        Image.asset(
                          './assets/images/icon_button/camion.png',
                          width: 25,
                          height: 25,
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

  Future<DateTime?> selectTransportDate(BuildContext context) async {
    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        DateTime dateToSelect = DateTime.now();
        final DateTime firstDate = dateToSelect.hour >= 16
            ? dateToSelect.add(const Duration(days: 1))
            : dateToSelect;
        final DateTime lastDate = dateToSelect.add(const Duration(days: 2));
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: buttonGreen, // Color de la barra superior
            hintColor: Colors.green, // Color del selector
            colorScheme: ColorScheme.light(primary: buttonGreen),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return CustomAlertDialog(
                width: 300,
                height: 600,
                assetImage: './assets/images/more_icons/calendario.png',
                title: 'Seleccione una fecha',
                content: CalendarDatePicker(
                  initialDate: firstDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onDateChanged: (date) {
                    setStateDialog(() {
                      dateToSelect = date;
                    });
                  },
                ),
                onPressedAcept: () async {
                  bool confirm = await _confirmAction(context);
                  if (confirm) {
                    Navigator.pop(context, dateToSelect);
                  }
                },
                onPressedCancel: () => Navigator.pop(context, null),
              );
            },
          ),
        );
      },
    );

    return pickedDate;
  }

  Future<bool> _confirmAction(BuildContext context) async {
    return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                width: 300,
                height: 290,
                assetImage: './assets/images/more_icons/advertencia.png',
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
}
