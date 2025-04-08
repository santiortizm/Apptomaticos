import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/models/product_model.dart';
import 'package:App_Tomaticos/core/services/product_service.dart';
import 'package:App_Tomaticos/core/services/user_services.dart';
import 'package:App_Tomaticos/core/widgets/cards/custom_card_products.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
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

  /// Filtros
  String _selectedOrder = 'Precio';
  String _selectedRipeness = 'Maduración';

  /// Stream para escuchar cambios en la tabla productos
  late Stream<List<Product>> productStream;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _initializeStream();
  }

  void _initializeStream() {
    productStream = supabase
        .from('productos')
        .stream(primaryKey: ['idProducto'])
        .order('updated_at', ascending: false)
        .map((data) => data.map((row) => Product.fromMap(row)).toList());
  }

  Future<void> _fetchUserRole() async {
    final role = await userService.getUserRole();
    if (mounted) {
      setState(() {
        userRole = role;
      });
    }
  }

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
          Column(
            children: [
              // Filtros
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        dropdownColor: Colors.white,
                        style: temaApp.textTheme.titleSmall!
                            .copyWith(color: Colors.black),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: redApp,
                        ),
                        value: _selectedOrder,
                        items: ['Precio', 'Precio ↑', 'Precio ↓']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedOrder = value!;
                          });
                        },
                      ),
                      DropdownButton<String>(
                        dropdownColor: Colors.white,
                        style: temaApp.textTheme.titleSmall!
                            .copyWith(color: Colors.black),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: redApp,
                        ),
                        value: _selectedRipeness,
                        items: ['Maduración', 'Verde', 'Maduro', 'Muy Maduro']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRipeness = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Lista de productos
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshProducts,
                  child: StreamBuilder<List<Product>>(
                    stream: productStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage(
                                    './assets/images/more_icons/no_products.png'),
                                width: 60,
                                height: 60,
                              ),
                              Text('No hay productos publicados'),
                            ],
                          ),
                        );
                      }

                      var products =
                          snapshot.data!.where((p) => p.cantidad != 0).toList();
                      if (products.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage(
                                    './assets/images/more_icons/no_products.png'),
                                width: 60,
                                height: 60,
                              ),
                              Text('No hay productos publicados'),
                            ],
                          ),
                        );
                      }
                      // Filtro por maduración
                      if (_selectedRipeness != 'Maduración') {
                        products = products
                            .where((p) =>
                                p.maduracion.toLowerCase() ==
                                _selectedRipeness.toLowerCase())
                            .toList();
                        if (products.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage(
                                      './assets/images/more_icons/no_products.png'),
                                  width: 60,
                                  height: 60,
                                ),
                                Text('No hay productos con esa caracteristica'),
                              ],
                            ),
                          );
                        }
                      }

                      // Ordenar por precio o reciente
                      if (_selectedOrder == 'Precio ↑') {
                        products.sort((a, b) => a.precio.compareTo(b.precio));
                      } else if (_selectedOrder == 'Precio ↓') {
                        products.sort((a, b) => b.precio.compareTo(a.precio));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return CustomCardProducts(
                            idUsuario: product.idPropietario,
                            title: product.nombreProducto,
                            state: product.maduracion,
                            price: product.precio,
                            imageUrl: product.imagen ??
                                'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp',
                            productId: product.idProducto,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (userRole == 'Productor')
            Positioned(
              bottom: 10,
              right: 10,
              child: IconButton(
                onPressed: () {
                  context.go('/registerProduct');
                },
                icon: Image.asset(
                  './assets/images/icon_button/vender.png',
                  width: 55,
                  height: 55,
                  fit: BoxFit.fill,
                ),
              ),
            )
        ],
      ),
    );
  }
}
