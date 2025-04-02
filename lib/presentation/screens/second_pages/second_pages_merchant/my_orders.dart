import 'package:App_Tomaticos/core/models/transport_model.dart';
import 'package:App_Tomaticos/core/services/transport_service.dart';
import 'package:App_Tomaticos/core/widgets/cards/custom_card_order.dart';
import 'package:App_Tomaticos/core/widgets/dialogs/more_info.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  final supabase = Supabase.instance.client;
  final TransportService transportService = TransportService();
  late Future<List<Transport>> transportsFuture;
  String? idUsuario;
  late RealtimeChannel _channel;
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchIdUsuario();
    _subscribeToChanges();
    _refreshTransports();
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    super.dispose();
  }

  Future<Map<String, dynamic>?> fetchCompraById(int idCompra) async {
    try {
      final response = await supabase
          .from('compras')
          .select('*')
          .eq('id', idCompra)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error al obtener compra: $e');
      return null;
    }
  }

  Future<void> _fetchIdUsuario() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('usuarios')
          .select('idUsuario')
          .eq('idUsuario', user.id)
          .single();

      setState(() {
        idUsuario = response['idUsuario'].toString();
      });
    } catch (e) {
      print('Error obteniendo idUsuario: $e');
    }
  }

  /// Suscripción en tiempo real a los cambios en `transportes`
  void _subscribeToChanges() {
    _channel = supabase
        .channel('public:transportes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'transportes',
          callback: (payload, [ref]) {
            _refreshTransports();
          },
        )
        .subscribe();
  }

  Future<void> _refreshTransports() async {
    if (idUsuario != null) {
      setState(() {
        transportsFuture = transportService.fetchTransportsByBuyer(idUsuario!);
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
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background/fondo_2.jpg'),
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AutoSizeText(
                          'Mis Pedidos',
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
                      MoreInfo(
                        width: 300,
                        height: 190,
                        text:
                            'Sus pedidos aparecerán aquí cuando un transportador los acepte. Una vez asignado, podrá ver toda la información del envío.',
                        widthTextDialog: 120,
                      ),
                      Expanded(
                        child: FutureBuilder<List<Transport>>(
                          future: transportsFuture,
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
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        './assets/images/more_icons/no_hay_pedidos.png'),
                                    width: 60,
                                    height: 60,
                                  ),
                                  Text('No hay pedidos realizadas'),
                                ],
                              ));
                            }
                            final orders = snapshot.data!
                                .where((o) => o.estado != 'Finalizado')
                                .toList();
                            return RefreshIndicator(
                              onRefresh: _refreshTransports,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.025),
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  final order = orders[index];
                                  // Datos de la compra

                                  return FutureBuilder(
                                      future: fetchCompraById(
                                          order.idCompra), //  Obtener la compra
                                      builder: (context, compraSnapshot) {
                                        if (compraSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }

                                        final compra = compraSnapshot.data;
                                        if (compra == null) {
                                          return const Center(
                                              child: Text(
                                                  'Compra no encontrada.'));
                                        }
                                        if (compra['estadoCompra'] ==
                                            'Pagado') {
                                          return const SizedBox
                                              .shrink(); //  Oculta la card
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: CustomCardOrder(
                                            estado: order.estado,
                                            imagen: compra[
                                                'imagenProducto'], // Imagen de la compra
                                            nombreProducto: compra[
                                                'nombreProducto'], // Nombre del producto
                                            fechaEntrega: order
                                                .fechaEntrega, // Fecha de entrega del transporte
                                            totalAPagar: compra['total']
                                                .toString(), // Precio total de la compra
                                            cantidad: compra['cantidad']
                                                .toString(), // Cantidad comprada
                                            onPressed: () async {
                                              try {
                                                await supabase
                                                    .from('compras')
                                                    .update({
                                                  'estadoCompra': 'Entregado'
                                                }).eq('id', compra['id']);
                                                await supabase
                                                    .from('transportes')
                                                    .update({
                                                  'estado': 'Entregado'
                                                }).eq('idTransporte',
                                                        order.idTransporte);
                                                _refreshTransports();
                                              } catch (e) {
                                                return;
                                              }
                                            },
                                          ),
                                        );
                                      });
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
