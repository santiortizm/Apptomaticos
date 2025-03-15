import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/services/cloudinary_service.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomCardProducts extends StatefulWidget {
  final int productId;
  final String idUsuario;
  final String title;
  final String state;
  final double price;
  final String imageUrl;
  const CustomCardProducts(
      {super.key,
      required this.title,
      required this.state,
      required this.price,
      required this.imageUrl,
      required this.productId,
      required this.idUsuario});

  @override
  State<CustomCardProducts> createState() => _CustomCardProductsState();
}

class _CustomCardProductsState extends State<CustomCardProducts> {
  final supabase = Supabase.instance.client;

  String? producerName;
  String? producerImage;
  @override
  void initState() {
    super.initState();

    _fetchUserData();
  }

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
          producerName = response?['nombre'] ?? 'Desconocido';
          producerImage =
              '$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}';
        });
      }
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
    }
  }

  String formatPrice(num price) {
    final formatter =
        NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0);
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final cloudinaryService =
        CloudinaryService(cloudName: dotenv.env['CLOUD_NAME'] ?? '');

    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        context.push('/buyProduct', extra: {'productId': widget.productId});
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
            vertical: size.height * 0.015, horizontal: size.width * 0.025),
        width: size.width * 1,
        height: 380,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          spacing: 6,
          children: [
            Row(
              spacing: 12,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage:
                      (producerImage != null && producerImage!.isNotEmpty)
                          ? NetworkImage(producerImage!)
                          : const AssetImage("./assets/images/user.png")
                              as ImageProvider,
                ),
                SizedBox(
                  width: size.width * 0.5,
                  child: AutoSizeText(
                    producerName ?? 'Cargando...',
                    maxLines: 1,
                    maxFontSize: 14,
                    minFontSize: 12,
                    style: temaApp.textTheme.titleSmall!
                        .copyWith(color: Colors.black, fontSize: 14),
                  ),
                ),
              ],
            ),
            Container(
              width: size.width * 1,
              height: size.height * 0.28,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
              ),
              child: CachedNetworkImage(
                imageUrl: cloudinaryService.getOptimizedImageUrl(
                    widget.imageUrl,
                    width: 300,
                    height: 300),
                fit: BoxFit.scaleDown,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Image.network(
                    'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: size.height * 0.015,
                  left: size.width * 0.025,
                  right: size.width * 0.025),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.4,
                        child: AutoSizeText(
                          widget.title,
                          minFontSize: 12,
                          maxFontSize: 18,
                          maxLines: 1,
                          style: temaApp.textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: size.width * 0.17,
                            child: AutoSizeText(
                              'Estado :',
                              minFontSize: 12,
                              maxFontSize: 18,
                              maxLines: 1,
                              style: temaApp.textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.w700, fontSize: 18),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            width: size.width * 0.27,
                            child: AutoSizeText(
                              widget.state,
                              minFontSize: 12,
                              maxFontSize: 16,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: buttonGreen),
                        width: size.width * 0.3,
                        height: size.height * 0.05,
                        child: AutoSizeText(
                          textAlign: TextAlign.center,
                          '\$${formatPrice(widget.price)}',
                          minFontSize: 12,
                          maxFontSize: 16,
                          maxLines: 1,
                          style: temaApp.textTheme.titleSmall!.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
