import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomCardTransportationHistory extends StatefulWidget {
  final int idTransporte;
  final int idCompra;
  final String pesoCarga;
  final String valorTransporte;

  const CustomCardTransportationHistory(
      {super.key,
      required this.pesoCarga,
      required this.valorTransporte,
      required this.idCompra,
      required this.idTransporte});

  @override
  State<CustomCardTransportationHistory> createState() =>
      _CustomCardTransportationHistoryState();
}

class _CustomCardTransportationHistoryState
    extends State<CustomCardTransportationHistory> {
  Future<Map<String, dynamic>?> _fetchCompraData() async {
    try {
      final response = await Supabase.instance.client
          .from('compras')
          .select('*')
          .eq('id', widget.idCompra)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error obteniendo datos de la compra: $e');
      return null;
    }
  }

  Map<String, dynamic>? compraData;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadCompraData();
  }

  Future<void> _loadCompraData() async {
    final data = await _fetchCompraData();
    if (mounted) {
      setState(() {
        compraData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.025, vertical: size.height * 0.025),
      width: size.width * 0.8,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Row(
            spacing: 12,
            children: [
              Container(
                width: size.width * 0.28,
                height: size.height * 0.16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                        compraData?['imagenProducto'] ??
                            'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp',
                      )),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  texTitletWidget(
                      context, compraData?['nombreProducto'] ?? '', 22),
                  moreInfo(
                      context, 'Cantidad:', 12, '10 Canastas', 12, 0.2, 0.22),
                  moreInfo(context, 'Peso Carga:', 12, '${widget.pesoCarga} T',
                      12, 0.26, 0.15),
                  moreInfo(context, 'Total compra:', 12,
                      '${widget.valorTransporte}\$', 12, 0.26, 0.15),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: size.height * 0.012),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  onPressed: () {
                    context.push('/transportStatus',
                        extra: {'idTransporte': widget.idTransporte});
                  },
                  color: buttonGreen,
                  colorBorder: Colors.transparent,
                  border: 18,
                  width: 0.3,
                  height: 0.05,
                  elevation: 2,
                  sizeBorder: 0,
                  child: AutoSizeText(
                    'ACTUALIZAR ESTADO',
                    maxLines: 1,
                    maxFontSize: 17,
                    minFontSize: 14,
                    style: temaApp.textTheme.titleSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget texTitletWidget(
      BuildContext context, String text, double maxFontSize) {
    final size = MediaQuery.of(context).size;

    return Container(
      alignment: Alignment.center,
      width: size.width * .42,
      child: AutoSizeText(
        textAlign: TextAlign.center,
        text,
        minFontSize: 14,
        maxFontSize: maxFontSize,
        maxLines: 1,
        style: temaApp.textTheme.titleSmall!.copyWith(
          fontSize: 100,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget moreInfo(
      BuildContext context,
      String textTitleInfo,
      double maxFontSizeTitleInfo,
      String textTextInfo,
      double maxFontSizeTextInfo,
      double widthTitle,
      double widthText) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          width: size.width * widthTitle,
          child: AutoSizeText(
            textAlign: TextAlign.center,
            textTitleInfo,
            minFontSize: 12,
            maxFontSize: maxFontSizeTitleInfo,
            maxLines: 1,
            style: temaApp.textTheme.titleSmall!.copyWith(
              fontSize: 100,
              fontWeight: FontWeight.w900,
              color: buttonGreen,
            ),
          ),
        ),
        SizedBox(
          width: size.width * widthText,
          child: AutoSizeText(
            textAlign: TextAlign.center,
            textTextInfo,
            minFontSize: 12,
            maxFontSize: maxFontSizeTextInfo,
            maxLines: 1,
            style: temaApp.textTheme.titleSmall!.copyWith(
              fontSize: 100,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
