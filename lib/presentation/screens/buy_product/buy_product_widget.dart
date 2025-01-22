import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/services/product_service.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyProductWidget extends StatefulWidget {
  final String productId;
  const BuyProductWidget({super.key, required this.productId});

  @override
  State<BuyProductWidget> createState() => _BuyProductWidgetState();
}

class _BuyProductWidgetState extends State<BuyProductWidget> {
  String? userRole;
  bool isOwner = false;
  final supabase = Supabase.instance.client;
  late final ProductService productService =
      ProductService(Supabase.instance.client);

  final dataProduct = ProductService(Supabase.instance.client);
  late Future<Map<String, dynamic>> productDetails;

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
            .eq('idAuth', user.id)
            .single();

        setState(() {
          userRole = response['rol'];
        });
      }
    } catch (e) {
      print('Error al obtener el rol del usuario: $e');
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

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
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

          return Stack(
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
              ListView(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.05),
                children: [
                  Container(
                    width: size.width * 1,
                    height: size.height * 1,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: size.height * 0.02,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              onPressed: () => Navigator.pop(context),
                              color: Colors.white,
                              border: 0,
                              width: 0.1,
                              height: 0.1,
                              elevation: 0,
                              child: Row(
                                spacing: size.width * 0.02,
                                children: const [
                                  Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                  ),
                                  Text('Atras'),
                                ],
                              ),
                            ),
                            if (isOwner)
                              CustomButton(
                                onPressed: () {
                                  print('Editar producto habilitado');
                                },
                                color: Colors.white,
                                border: 0,
                                width: 0.1,
                                height: 0.1,
                                elevation: 0,
                                child: Icon(
                                  size: 32,
                                  Icons.edit,
                                  color: redApp,
                                ),
                              ),
                          ],
                        ),
                        AutoSizeText(
                          productData['nombreProducto'] ??
                              'Nombre no disponible',
                          style: temaApp.textTheme.titleMedium!.copyWith(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05),
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.025,
                              horizontal: size.width * 0.05),
                          width: size.width * 1,
                          height: size.height * 0.26,
                          decoration: BoxDecoration(
                            border: Border.all(color: redApp),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            spacing: 10,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.45,
                                    child: AutoSizeText(
                                      'Cantidad disponible:',
                                      maxLines: 1,
                                      maxFontSize: 16,
                                      minFontSize: 12,
                                      style: temaApp.textTheme.titleSmall!
                                          .copyWith(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.24,
                                    child: AutoSizeText(
                                      productData['cantidad'].toString(),
                                      maxLines: 1,
                                      maxFontSize: 16,
                                      minFontSize: 12,
                                      style: temaApp.textTheme.titleSmall!
                                          .copyWith(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.45,
                                    child: AutoSizeText(
                                      'Fecha de cosecha:',
                                      maxLines: 1,
                                      maxFontSize: 16,
                                      minFontSize: 12,
                                      style: temaApp.textTheme.titleSmall!
                                          .copyWith(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.24,
                                    child: AutoSizeText(
                                      productData['fechaCosecha'],
                                      maxLines: 1,
                                      maxFontSize: 16,
                                      minFontSize: 12,
                                      style: temaApp.textTheme.titleSmall!
                                          .copyWith(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.45,
                                    child: AutoSizeText(
                                      'Fecha de caducidad:',
                                      maxLines: 1,
                                      maxFontSize: 16,
                                      minFontSize: 12,
                                      style: temaApp.textTheme.titleSmall!
                                          .copyWith(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.24,
                                    child: AutoSizeText(
                                      productData['fechaCaducidad'],
                                      maxLines: 1,
                                      maxFontSize: 16,
                                      minFontSize: 12,
                                      style: temaApp.textTheme.titleSmall!
                                          .copyWith(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.45,
                                    child: AutoSizeText(
                                      'Estado de maduración:',
                                      maxLines: 1,
                                      maxFontSize: 16,
                                      minFontSize: 12,
                                      style: temaApp.textTheme.titleSmall!
                                          .copyWith(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.24,
                                    child: AutoSizeText(
                                      productData['maduracion'],
                                      maxLines: 1,
                                      maxFontSize: 16,
                                      minFontSize: 12,
                                      style: temaApp.textTheme.titleSmall!
                                          .copyWith(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.45,
                                    child: AutoSizeText(
                                      'Precio canasta:',
                                      maxLines: 1,
                                      maxFontSize: 14,
                                      minFontSize: 12,
                                      style: temaApp.textTheme.titleSmall!
                                          .copyWith(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.24,
                                    child: AutoSizeText(
                                      productData['precio'].toString(),
                                      maxLines: 1,
                                      maxFontSize: 16,
                                      minFontSize: 12,
                                      style: temaApp.textTheme.titleSmall!
                                          .copyWith(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * 0.07),
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            'Descripción',
                            maxFontSize: 22,
                            minFontSize: 16,
                            maxLines: 1,
                            style: temaApp.textTheme.titleMedium!.copyWith(
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: FontWeight.w100),
                          ),
                        ),
                        Container(
                          height: size.height * 0.3,
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05),
                          alignment: Alignment.topLeft,
                          child: AutoSizeText(
                            productData['descripcion'] ??
                                'Descripció no disponible',
                            maxFontSize: 18,
                            minFontSize: 14,
                            maxLines: 10,
                            textAlign: TextAlign.justify,
                            style: temaApp.textTheme.titleSmall!.copyWith(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                        ),
                        if (userRole == null)
                          const CircularProgressIndicator()
                        else if (userRole == 'Comerciante') ...[
                          Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                onPressed: () {},
                                color: buttonGreen,
                                border: 8,
                                width: 0.2,
                                height: 0.06,
                                elevation: 1,
                                child: AutoSizeText(
                                  'COMPRAR',
                                  maxLines: 1,
                                  maxFontSize: 18,
                                  minFontSize: 14,
                                  style: temaApp.textTheme.titleSmall!.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              CustomButton(
                                onPressed: () {},
                                color: buttonGreen,
                                border: 8,
                                width: 0.2,
                                height: 0.06,
                                elevation: 1,
                                child: AutoSizeText(
                                  'OFERTAR',
                                  maxLines: 1,
                                  maxFontSize: 18,
                                  minFontSize: 14,
                                  style: temaApp.textTheme.titleSmall!.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
