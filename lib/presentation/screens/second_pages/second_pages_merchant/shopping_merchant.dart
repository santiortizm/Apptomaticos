import 'package:App_Tomaticos/core/models/buy_model.dart';
import 'package:App_Tomaticos/core/services/buy_service.dart';
import 'package:App_Tomaticos/core/services/product_service.dart';
import 'package:App_Tomaticos/core/widgets/cards/custom_card_purchases_merchant.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShoppingMerchant extends StatefulWidget {
  const ShoppingMerchant({super.key});

  @override
  State<ShoppingMerchant> createState() => _ShoppingMerchantState();
}

class _ShoppingMerchantState extends State<ShoppingMerchant> {
  final supabase = Supabase.instance.client;
  final BuyService purchasetService =
      BuyService(ProductService(Supabase.instance.client));
  late Future<List<Buy>> purchaseMerchantFuture;
  String? idUsuario;
  late RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchIdUsuario();
    _subscribeToProductChanges();
    _refreshProducts();
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    super.dispose();
  }

  /// Obtiene el `idUsuario` del usuario autenticado
  Future<void> _fetchIdUsuario() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      final response = await supabase
          .from('usuarios')
          .select('idUsuario')
          .eq('idUsuario',
              user.id) // Corregido: Usa 'idAuth' en lugar de 'idUsuario'
          .single();
      setState(() {
        idUsuario = response['idUsuario'].toString();
      });
    } catch (e) {
      return;
    }
  }

  /// Suscripción en tiempo real a los cambios en `productos`
  void _subscribeToProductChanges() {
    _channel = supabase
        .channel('public:productos')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'compras',
          callback: (payload, [ref]) {
            _refreshProducts();
          },
        )
        .subscribe();
  }

  Future<void> _refreshProducts() async {
    if (idUsuario != null) {
      setState(() {
        purchaseMerchantFuture = purchasetService.fetchPurchasesByUser();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (idUsuario == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Fondo de pantalla
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
                  horizontal: size.width * 0.05, vertical: 0.05),
              child: Center(
                child: Container(
                  width: size.width,
                  height: size.height * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // Botón Atrás

                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                GoRouter.of(context).go('/menu');
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

                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 20),
                        height: size.height * 0.07,
                        child: AutoSizeText(
                          'Mis Compras',
                          maxFontSize: 26,
                          minFontSize: 18,
                          maxLines: 1,
                          style: temaApp.textTheme.titleSmall!.copyWith(
                            fontSize: 26,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<List<Buy>>(
                          future: purchaseMerchantFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            if (snapshot.data == null ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('No hay compras realizadas'));
                            }
                            final purchase = snapshot.data!;
                            return RefreshIndicator(
                              onRefresh: _refreshProducts,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.05),
                                itemCount: purchase.length,
                                itemBuilder: (context, index) {
                                  final buy = purchase[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: CustomCardPurchasesMerchant(
                                        imagen: buy.imagenProducto.isNotEmpty
                                            ? '${buy.imagenProducto}?v=${DateTime.now().millisecondsSinceEpoch}'
                                            : 'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp',
                                        nombreProducto: buy.nombreProducto,
                                        fecha: buy.createdAt.toIso8601String(),
                                        cantidad: buy.cantidad.toString(),
                                        precio: buy.total.toString()),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
