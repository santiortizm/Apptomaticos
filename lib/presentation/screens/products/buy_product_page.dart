import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/models/product_model.dart';
import 'package:App_Tomaticos/core/services/cloudinary_service.dart';
import 'package:App_Tomaticos/core/services/product_service.dart';
import 'package:App_Tomaticos/core/widgets/custom_alert_dialog.dart';
import 'package:App_Tomaticos/core/widgets/custom_button.dart';
import 'package:App_Tomaticos/presentation/screens/products/update_product.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class BuyProductPage extends StatefulWidget {
  final int productId;
  const BuyProductPage({super.key, required this.productId});

  @override
  State<BuyProductPage> createState() => _BuyProductPageState();
}

class _BuyProductPageState extends State<BuyProductPage> {
  String? userRole;
  bool isOwner = false;
  final supabase = Supabase.instance.client;
  late final ProductService productService =
      ProductService(Supabase.instance.client);

  final dataProduct = ProductService(Supabase.instance.client);
  late Future<Product?> productDetails;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _checkProductOwnership();

    productDetails = dataProduct.fetchProductDetails(widget.productId);
  }

  Future<void> _fetchUserRole() async {
    try {
      // Obtén el usuario autenticado
      final user = supabase.auth.currentUser;

      if (user != null) {
        // Consulta el rol del usuario
        final response = await supabase
            .from('usuarios')
            .select('rol')
            .eq('idUsuario', user.id)
            .single();

        setState(() {
          userRole = response['rol'];
        });
      }
    } catch (e) {
      return;
    }
  }

  Future<void> _checkProductOwnership() async {
    final ownership = await productService.isProductOwner(widget.productId);
    setState(() {
      isOwner = ownership;
    });
  }

  String formatPrice(num price) {
    final formatter =
        NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0);
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cloudinaryService =
        CloudinaryService(cloudName: dotenv.env['CLOUD_NAME'] ?? '');
    return Scaffold(
      body: FutureBuilder<Product?>(
        future: productDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Producto no encontrado'));
          }

          final productData = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                        opacity: 0.4,
                        image: AssetImage(
                          'assets/images/fondo1.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.05),
                      child: Container(
                        width: size.width * 1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Row(
                                    spacing: size.width * 0.02,
                                    children: [
                                      const Icon(
                                        size: 24,
                                        Icons.arrow_back,
                                        color: Colors.black,
                                      ),
                                      SizedBox(
                                        height: 30,
                                        child: AutoSizeText(
                                          'Atrás',
                                          maxLines: 1,
                                          minFontSize: 4,
                                          maxFontSize: 18,
                                          style: temaApp.textTheme.titleSmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black,
                                                  fontSize: 28),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isOwner)
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _deleteProduct();
                                        },
                                        icon: Icon(Icons.delete, color: redApp),
                                      ),
                                      CustomButton(
                                        onPressed: () {
                                          _dialogBuilder(context);
                                        },
                                        color: Colors.white,
                                        border: 0,
                                        width: 0.1,
                                        height: 0.1,
                                        elevation: 0,
                                        colorBorder: Colors.transparent,
                                        sizeBorder: 0,
                                        child: Icon(
                                          size: 32,
                                          Icons.edit,
                                          color: redApp,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            Container(
                              alignment: Alignment.topCenter,
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.05,
                                  vertical: size.height * 0.025),
                              width: size.width * 1,
                              child: Column(
                                spacing: 12,
                                children: [
                                  AutoSizeText(
                                    productData.nombreProducto,
                                    style: temaApp.textTheme.titleMedium!
                                        .copyWith(
                                            fontSize: 26,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                  ),
                                  Container(
                                    width: size.width * 0.85,
                                    height: size.height * 0.28,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.scaleDown,
                                        image: CachedNetworkImageProvider(
                                          cloudinaryService
                                              .getOptimizedImageUrl(
                                            productData.imagen ??
                                                'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp',
                                          ),
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  _cardInfo(
                                    'Cantidad disponible:',
                                    productData.cantidad.toString(),
                                    Icon(
                                      Icons.production_quantity_limits,
                                      color: redApp,
                                    ),
                                  ),
                                  _cardInfo(
                                    'Fecha de cosecha:',
                                    DateFormat('dd/MM/yyyy').format(
                                        DateTime.parse(
                                            productData.fechaCosecha)),
                                    Icon(
                                      Icons.calendar_month,
                                      color: redApp,
                                    ),
                                  ),
                                  _cardInfo(
                                    'Fecha de caducidad:',
                                    DateFormat('dd/MM/yyyy').format(
                                        DateTime.parse(
                                            productData.fechaCaducidad)),
                                    Icon(
                                      Icons.date_range,
                                      color: redApp,
                                    ),
                                  ),
                                  _cardInfo(
                                    'Estado de maduración:',
                                    productData.maduracion,
                                    Icon(
                                      Icons.timelapse,
                                      color: redApp,
                                    ),
                                  ),
                                  _cardInfo(
                                    'Precio canasta:',
                                    productData.precio.toStringAsFixed(0),
                                    Icon(
                                      Icons.attach_money,
                                      color: redApp,
                                    ),
                                  ),
                                  Container(
                                    width: size.width * 1,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.07),
                                    alignment: Alignment.center,
                                    child: AutoSizeText(
                                      'Descripción',
                                      maxFontSize: 22,
                                      minFontSize: 16,
                                      maxLines: 1,
                                      style: temaApp.textTheme.titleMedium!
                                          .copyWith(
                                              fontSize: 22,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w100),
                                    ),
                                  ),
                                  Container(
                                    width: size.width * 0.8,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.05,
                                        vertical: size.height * 0.015),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.grey)),
                                    height: size.height * 0.2,
                                    alignment: Alignment.topLeft,
                                    child: SingleChildScrollView(
                                      child: AutoSizeText(
                                        productData.descripcion,
                                        maxFontSize: 16,
                                        minFontSize: 14,
                                        maxLines: 10,
                                        textAlign: TextAlign.justify,
                                        style: temaApp.textTheme.titleSmall!
                                            .copyWith(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w100,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (userRole == null)
                                    const CircularProgressIndicator()
                                  else if (userRole == 'Comerciante') ...[
                                    Container(
                                      margin: const EdgeInsets.only(
                                        top: 20,
                                      ),
                                      child: Row(
                                        spacing: 30,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: CustomButton(
                                              onPressed: () => context
                                                  .push('/purchase', extra: {
                                                'productId': widget.productId,
                                                'imageUrl': productData.imagen,
                                                'price': productData.precio,
                                                'cantidad':
                                                    productData.cantidad,
                                                'availableQuantify':
                                                    productData.cantidad,
                                              }),
                                              color: buttonGreen,
                                              colorBorder: buttonGreen,
                                              border: 12,
                                              width: 0.35,
                                              height: 0.07,
                                              elevation: 1,
                                              sizeBorder: 0,
                                              child: AutoSizeText(
                                                'COMPRAR',
                                                maxLines: 1,
                                                maxFontSize: 20,
                                                minFontSize: 4,
                                                style: temaApp
                                                    .textTheme.titleSmall!
                                                    .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 30,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: CustomButton(
                                              onPressed: () => context.push(
                                                  '/offerProduct',
                                                  extra: {
                                                    'productId':
                                                        productData.idProducto,
                                                    'imageUrl':
                                                        productData.imagen,
                                                    'price': productData.precio,
                                                    'availableQuantity':
                                                        productData.cantidad,
                                                    'cantidad':
                                                        productData.cantidad,
                                                    'productName': productData
                                                        .nombreProducto,
                                                    'ownerId': productData
                                                        .idPropietario,
                                                  }),
                                              color: Colors.white,
                                              colorBorder: buttonGreen,
                                              border: 12,
                                              width: 0.35,
                                              height: 0.07,
                                              elevation: 2,
                                              sizeBorder: 2.5,
                                              child: AutoSizeText(
                                                'OFERTAR',
                                                maxLines: 1,
                                                maxFontSize: 18,
                                                minFontSize: 4,
                                                style: temaApp
                                                    .textTheme.titleSmall!
                                                    .copyWith(
                                                        color: buttonGreen,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 30),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else if (userRole == 'Productor')
                                    ...[],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          backgroundColor: Colors.white,
          child: FutureBuilder<Product?>(
            future: productDetails,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('Producto no encontrado'));
              }

              final productData = snapshot.data!;
              titleController.text = productData.nombreProducto;
              descriptionController.text = productData.descripcion;
              priceController.text = productData.precio.toString();
              quantityController.text = productData.cantidad.toString();

              return UpdateProduct(
                titleController: titleController,
                descriptionController: descriptionController,
                priceController: priceController,
                quantityController: quantityController,
                productId: widget.productId,
                imageUrl:
                    "${productData.imagen}?v=${DateTime.now().millisecondsSinceEpoch}", // 🔥 Evita caché
                onUpLoad: (String imageUrl) async {
                  final success = await productService.updateProductDetails(
                    widget.productId,
                    {
                      'imagen': imageUrl,
                      'updated_at': DateTime.now().toIso8601String(),
                    },
                  );

                  if (success) {
                    setState(() {
                      productDetails =
                          productService.fetchProductDetails(widget.productId);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Imagen actualizada')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error al actualizar la imagen')),
                    );
                  }
                },
                onPressedDecline: () {
                  Navigator.of(context).pop();
                },
                onPressedAccept: () async {
                  final updatedData = {
                    'nombreProducto': titleController.text,
                    'descripcion': descriptionController.text,
                    'precio': double.tryParse(priceController.text),
                    'cantidad': int.tryParse(quantityController.text),
                    'updated_at': DateTime.now().toIso8601String(),
                  };

                  final success = await productService.updateProductDetails(
                    widget.productId,
                    updatedData,
                  );

                  if (success) {
                    setState(() {
                      productDetails =
                          productService.fetchProductDetails(widget.productId);
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Producto actualizado exitosamente')),
                    );
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error al actualizar el producto')),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _cardInfo(
    String titleInfo,
    String subTitle,
    Icon icon,
  ) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.025, vertical: size.height * 0.015),
      width: size.width * 1,
      decoration: BoxDecoration(
        color: cardInfo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              SizedBox(
                height: 22,
                child: AutoSizeText(
                  titleInfo,
                  maxFontSize: 18,
                  minFontSize: 11,
                  maxLines: 1,
                  style: temaApp.textTheme.titleSmall!.copyWith(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                width: 200,
                child: AutoSizeText(
                  subTitle,
                  maxFontSize: 14,
                  minFontSize: 4,
                  maxLines: 1,
                  style: temaApp.textTheme.titleSmall!.copyWith(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
          icon
        ],
      ),
    );
  }

  Future<void> _deleteProduct() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          width: 220,
          height: 270,
          assetImage: './assets/images/alert.gif',
          title: 'Alerta',
          content: Container(
            width: 200,
            alignment: Alignment.center,
            child: AutoSizeText(
              '¿Estás seguro de eliminar este producto?',
              maxLines: 2,
              minFontSize: 4,
              maxFontSize: 18,
              textAlign: TextAlign.center,
              style: temaApp.textTheme.titleSmall!
                  .copyWith(color: Colors.black, fontSize: 18),
            ),
          ),
          onPressedAcept: () async {
            Navigator.of(context).pop();
            final success =
                await productService.deleteProduct(widget.productId);

            if (success) {
              setState(
                () {
                  productDetails =
                      productService.fetchProductDetails(widget.productId);
                  Navigator.of(context).pop();
                },
              );
            } else {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    backgroundColor: redApp,
                    content: Text('Error al eliminar el producto')),
              );
            }
          },
          onPressedCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
