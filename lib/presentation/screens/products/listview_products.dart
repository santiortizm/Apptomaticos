import 'package:App_Tomaticos/core/models/product_model.dart';
import 'package:App_Tomaticos/core/services/product_service.dart';
import 'package:App_Tomaticos/core/services/user_services.dart';
import 'package:App_Tomaticos/core/widgets/cards/custom_card_products.dart';
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

  ///  Función para refrescar manualmente la lista de productos
  Future<void> _refreshProducts() async {
    setState(() {
      _initializeStream();
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
                  return Center(
                    child: Image.asset(
                      fit: BoxFit.fill,
                      './assets/images/loading.gif',
                      width: 150,
                      height: 150,
                    ),
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
                          idUsuario: product.idPropietario,
                          title: product.nombreProducto,
                          state: product.maduracion,
                          price: product.precio,
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
                alignment: const Alignment(0.99, 0.99),
                child: IconButton(
                  onPressed: () {
                    context.go('/registerProduct');
                  },
                  icon: Image(
                    width: 55,
                    height: 55,
                    fit: BoxFit.fill,
                    image: AssetImage(
                      './assets/images/vender.png',
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
