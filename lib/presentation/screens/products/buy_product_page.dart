import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/models/product_model.dart';
import 'package:apptomaticos/core/services/cloudinary_service.dart';
import 'package:apptomaticos/core/services/product_service.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/presentation/screens/products/update_product.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

          return SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  width: size.width,
                  height: size.height,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/fondo1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.05),
                  child: Container(
                    width: size.width * 1,
                    height: size.height * 1,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: size.height * 0.025),
                              alignment: Alignment.centerLeft,
                              width: size.width * .3,
                              child: TextButton(
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
                                    AutoSizeText(
                                      'Atras',
                                      maxLines: 1,
                                      minFontSize: 16,
                                      maxFontSize: 18,
                                      style: temaApp.textTheme.titleSmall!
                                          .copyWith(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontSize: 28),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isOwner)
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
                        Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05),
                          width: size.width * 1,
                          height: size.height * 0.8,
                          child: SingleChildScrollView(
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
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        cloudinaryService.getOptimizedImageUrl(
                                            productData.imagen!,
                                            width: 300,
                                            height: 300),
                                    fit: BoxFit.scaleDown,
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        Image.network(
                                            'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp'),
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
                                  productData.fechaCosecha,
                                  Icon(
                                    Icons.calendar_month,
                                    color: redApp,
                                  ),
                                ),
                                _cardInfo(
                                  'Fecha de caducidad:',
                                  productData.fechaCaducidad,
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
                                  productData.precio.toString(),
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
                                        top: 20, bottom: 40),
                                    child: Row(
                                      spacing: 10,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomButton(
                                          onPressed: () =>
                                              context.push('/purchase', extra: {
                                            'productId': widget.productId,
                                            'imageUrl': productData.imagen,
                                            'price': productData.precio,
                                            'availableQuantify':
                                                productData.cantidad,
                                          }),
                                          color: buttonGreen,
                                          border: 8,
                                          width: 0.2,
                                          height: 0.06,
                                          elevation: 1,
                                          colorBorder: Colors.transparent,
                                          sizeBorder: 0,
                                          child: AutoSizeText(
                                            'COMPRAR',
                                            maxLines: 1,
                                            maxFontSize: 18,
                                            minFontSize: 14,
                                            style: temaApp.textTheme.titleSmall!
                                                .copyWith(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                        CustomButton(
                                          onPressed: () => context
                                              .push('/offerProduct', extra: {
                                            'productId': productData.idProducto,
                                            'imageUrl': productData.imagen,
                                            'price': productData.precio,
                                            'availableQuantity':
                                                productData.cantidad,
                                            'productName':
                                                productData.nombreProducto,
                                            'ownerId':
                                                productData.idPropietario,
                                          }),
                                          color: Colors.white,
                                          border: 8,
                                          width: 0.2,
                                          height: 0.06,
                                          elevation: 1,
                                          colorBorder: buttonGreen,
                                          sizeBorder: 2,
                                          child: AutoSizeText(
                                            'OFERTAR',
                                            maxLines: 1,
                                            maxFontSize: 18,
                                            minFontSize: 14,
                                            style: temaApp.textTheme.titleSmall!
                                                .copyWith(
                                                    color: buttonGreen,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else if (userRole == 'Productor') ...[
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 20, bottom: 20),
                                    child: CustomButton(
                                        onPressed: () async {
                                          final success = await productService
                                              .deleteProduct(widget.productId);

                                          if (success) {
                                            setState(() {
                                              productDetails = productService
                                                  .fetchProductDetails(
                                                      widget.productId);
                                            });
                                            // ignore: use_build_context_synchronously
                                            Navigator.of(context).pop();
                                            // ignore: use_build_context_synchronously
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Producto eliminado exitosamente')),
                                            );
                                          } else {
                                            // ignore: use_build_context_synchronously
                                            Navigator.of(context).pop();
                                            // ignore: use_build_context_synchronously
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Error al eliminar el producto')),
                                            );
                                          }
                                        },
                                        color: redApp,
                                        border: 12,
                                        width: 0.2,
                                        height: 0.08,
                                        elevation: 0,
                                        colorBorder: Colors.transparent,
                                        sizeBorder: 0,
                                        child: AutoSizeText(
                                          'Eliminar',
                                          minFontSize: 12,
                                          maxFontSize: 18,
                                          maxLines: 1,
                                          style: temaApp.textTheme.titleSmall!
                                              .copyWith(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                        )),
                                  )
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
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
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Actualizar Datos'),
          content: FutureBuilder<Product?>(
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

              return SizedBox(
                width: MediaQuery.of(context).size.width * 1,
                child: UpdateProduct(
                  titleController: titleController,
                  descriptionController: descriptionController,
                  priceController: priceController,
                  quantityController: quantityController,
                  productId: widget.productId,
                  imageUrl: productData.imagen,
                  onUpLoad: (String imageUrl) async {
                    //  **Actualizar en la base de datos**
                    final success = await productService.updateProductDetails(
                      widget.productId,
                      {
                        'imagen': imageUrl,
                        'updated_at': DateTime.now()
                            .toIso8601String(), // Fuerza actualización en Supabase
                      },
                    );

                    if (success) {
                      setState(() {
                        productDetails = productService
                            .fetchProductDetails(widget.productId);
                      });
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Imagen actualizada')),
                      );
                    } else {
                      // ignore: use_build_context_synchronously
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
                      'updated_at': DateTime.now()
                          .toIso8601String(), // Fuerza actualización en Supabase
                    };

                    final success = await productService.updateProductDetails(
                      widget.productId,
                      updatedData,
                    );

                    if (success) {
                      setState(() {
                        productDetails = productService
                            .fetchProductDetails(widget.productId);
                      });
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Producto actualizado exitosamente')),
                      );
                    } else {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Error al actualizar el producto')),
                      );
                    }
                  },
                ),
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
      height: size.height * 0.105,
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
              AutoSizeText(
                titleInfo,
                maxFontSize: 18,
                minFontSize: 16,
                maxLines: 1,
                style: temaApp.textTheme.titleSmall!.copyWith(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              AutoSizeText(
                subTitle,
                maxFontSize: 16,
                minFontSize: 12,
                maxLines: 1,
                style: temaApp.textTheme.titleSmall!.copyWith(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
          icon
        ],
      ),
    );
  }
}
