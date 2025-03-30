import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/widgets/button/custom_button.dart';
import 'package:App_Tomaticos/core/widgets/drop_down_field/custom_dropdown_field.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const List<String> estadoTransporte = <String>[
  'En Camino',
  'En Central de abastos'
];

class TransportStatus extends StatefulWidget {
  final int idTransporte;
  const TransportStatus({super.key, required this.idTransporte});

  @override
  State<TransportStatus> createState() => _TransportStatusState();
}

class _TransportStatusState extends State<TransportStatus> {
  final SupabaseClient supabase = Supabase.instance.client;
  String? selectedEstado;
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondo_2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05, vertical: size.height * 0.025),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              width: size.width * 1,
              height: size.height,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.025),
                child: Column(
                  spacing: 12,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              GoRouter.of(context).go('/menuTrucker');
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
                    ),
                    AutoSizeText(
                      textAlign: TextAlign.center,
                      'Estado del transporte del producto',
                      maxFontSize: 26,
                      minFontSize: 18,
                      maxLines: 2,
                      style: temaApp.textTheme.titleSmall!.copyWith(
                        fontSize: 26,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.8,
                      child: AutoSizeText(
                        'Seleccione el estado actual del transporte del producto: \n - En camino: Indique que ha recibido el producto del agricultor.\n- En central de abastos: Indique que el producto está listo para ser entregado al destinatario.\nSeleccione la opción correspondiente para actualizar el estado del transporte.',
                        maxFontSize: 18,
                        minFontSize: 16,
                        maxLines: 13,
                        textAlign: TextAlign.justify,
                        style: temaApp.textTheme.titleSmall!.copyWith(
                          fontSize: 26,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.6,
                      child: CustomDropdownField(
                        labelText: 'Estado Transporte',
                        options: estadoTransporte,
                        onChanged: (value) {
                          setState(() {
                            selectedEstado = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: CustomButton(
                        onPressed: () async {
                          if (selectedEstado == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor selecciona un estado'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          try {
                            await supabase
                                .from('transportes')
                                .update({'estado': selectedEstado}).eq(
                                    'idTransporte', widget.idTransporte);
                            // ignore: use_build_context_synchronously
                            GoRouter.of(context).go('/myTransports');
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Estado actualizado correctamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al actualizar estado: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        color: buttonGreen,
                        colorBorder: buttonGreen,
                        border: 12,
                        width: 0.4,
                        height: 0.07,
                        elevation: 1,
                        sizeBorder: 0,
                        child: AutoSizeText(
                          'CONFIRMAR',
                          maxLines: 1,
                          maxFontSize: 20,
                          minFontSize: 18,
                          style: temaApp.textTheme.titleSmall!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
