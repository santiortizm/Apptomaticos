import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/models/product_model.dart';
import 'package:apptomaticos/core/services/product_service.dart';
import 'package:apptomaticos/core/services/user_services.dart';
import 'package:apptomaticos/core/widgets/cards/custom_card_products.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListviewProducts extends StatefulWidget {
  const ListviewProducts({super.key});

  @override
  State<ListviewProducts> createState() => _ListviewProductsState();
}

class _ListviewProductsState extends State<ListviewProducts> {
  final supabase = Supabase.instance.client;
  final ProductService productService =
      ProductService(Supabase.instance.client);
  final UserService userService = UserService(Supabase.instance.client);

  String? userRole;

  /// Stream para escuchar cambios en la tabla productos
  late Stream<List<Product>> productStream;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _initializeStream();
  }

  /// Inicializa el Stream de productos
  void _initializeStream() {
    productStream = supabase
        .from('productos')
        .stream(
            primaryKey: ['idProducto']) // Escucha cambios en la clave primaria
        .order('updated_at',
            ascending: false) // Ordenar por última actualización
        .map((data) => data.map((row) => Product.fromMap(row)).toList());
  }

  /// Obtiene el rol del usuario autenticado
  Future<void> _fetchUserRole() async {
    final role = await userService.getUserRole();
    if (mounted) {
      setState(() {
        userRole = role;
      });
    }
  }

  /// 🔄 Función para refrescar manualmente la lista de productos
  Future<void> _refreshProducts() async {
    setState(() {
      _initializeStream(); // 🔥 Reinicia el Stream para forzar actualización
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh:
                _refreshProducts, // 🔄 Función que se ejecuta al hacer pull-to-refresh
            child: StreamBuilder<List<Product>>(
              stream: productStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error obteniendo productos'),
                  );
                } else if (snapshot.hasData) {
                  final products = snapshot.data!;
                  return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        // Ocultar productos con cantidad 0
                        if (product.cantidad == 0) {
                          return const SizedBox.shrink();
                        }

                        return CustomCardProducts(
                          title: product.nombreProducto,
                          state: product.maduracion,
                          price: product.precio.toString(),
                          imageUrl: product.imagen ??
                              'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp',
                          productId: product.idProducto,
                        );
                      });
                } else {
                  return const Center(
                    child: Text('No hay productos disponibles'),
                  );
                }
              },
            ),
          ),
          if (userRole == 'Productor')
            Center(
              child: Container(
                width: size.width * 0.4,
                alignment: const Alignment(0.0, 0.95),
                child: CustomButton(
                  onPressed: () {
                    context.go('/registerProduct');
                  },
                  color: buttonGreen,
                  border: 18,
                  width: 0.4,
                  height: 0.07,
                  elevation: 4,
                  colorBorder: Colors.transparent,
                  sizeBorder: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sell, color: redApp, size: 26),
                      AutoSizeText(
                        'Vender',
                        maxFontSize: 32,
                        minFontSize: 14,
                        maxLines: 1,
                        style: temaApp.textTheme.titleSmall!.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
