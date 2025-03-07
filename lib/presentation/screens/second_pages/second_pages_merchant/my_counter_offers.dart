import 'package:apptomaticos/core/models/counter_offer_model.dart';
import 'package:apptomaticos/core/services/counter_offer_service.dart';
import 'package:apptomaticos/core/services/product_service.dart';
import 'package:apptomaticos/core/widgets/cards/custom_card_counter_offer_merchant.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyCounterOffers extends StatefulWidget {
  const MyCounterOffers({super.key});

  @override
  State<MyCounterOffers> createState() => _MyCounterOffersState();
}

class _MyCounterOffersState extends State<MyCounterOffers> {
  final supabase = Supabase.instance.client;
  final CounterOfferService counterOfferService = CounterOfferService(
      Supabase.instance.client, ProductService(Supabase.instance.client));
  late Future<List<CounterOffer>> producerOffersFuture;
  String? idUsuario;
  late RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchIdUsuario();
    _subscribeToTableChanges();
    _refreshOffers();
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
          .eq('idUsuario', user.id)
          .single();

      setState(() {
        idUsuario = response['idUsuario'].toString();
      });
    } catch (e) {
      return;
    }
  }

  void _subscribeToTableChanges() {
    _channel = supabase
        .channel('public:productos')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'contra_oferta',
          callback: (payload, [ref]) {
            _refreshOffers();
          },
        )
        .subscribe();
  }

  Future<void> _refreshOffers() async {
    if (idUsuario != null) {
      setState(() {
        producerOffersFuture =
            counterOfferService.fetchCounterOfferByMerchant();
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
            Container(
              width: size.width * 1,
              height: size.height * 1,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/fondo_2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.2),
              ),
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.height * 0.025),
                    child: Column(
                      children: [
                        Align(
                          alignment: const Alignment(-0.9, 0),
                          child: TextButton(
                            onPressed: () {
                              GoRouter.of(context).go('/menu');
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
                                  style: temaApp.textTheme.titleSmall!.copyWith(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      fontSize: 28),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AutoSizeText(
                          'Mis Contra Ofertas',
                          maxFontSize: 26,
                          minFontSize: 18,
                          maxLines: 1,
                          style: temaApp.textTheme.titleSmall!.copyWith(
                              fontSize: 26,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        ),
                        Expanded(
                          child: FutureBuilder<List<CounterOffer>>(
                            future: producerOffersFuture,
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
                                    child: Text('No tienes contra ofertas.'));
                              }

                              final ofertas = snapshot.data!
                                  .where((o) =>
                                      o.estadoOferta != 'Rechazado' &&
                                      o.estadoOferta != 'En Espera' &&
                                      o.estadoPago != 'Finalizado')
                                  .toList();
                              return RefreshIndicator(
                                onRefresh: _refreshOffers,
                                child: ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.01),
                                  itemCount: ofertas.length,
                                  itemBuilder: (context, index) {
                                    final oferta = ofertas[index];

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: CustomCardCounterOfferMerchant(
                                        imagen: oferta.imagenProducto.isNotEmpty
                                            ? '${oferta.imagenProducto}?v=${DateTime.now().millisecondsSinceEpoch}'
                                            : 'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp',
                                        nombreProducto: oferta.nombreProducto,
                                        nombreOfertador: oferta.idComprador,
                                        cantidadOfertada:
                                            oferta.cantidad.toString(),
                                        totalOferta:
                                            oferta.valorOferta.toString(),
                                        acceptOffer: () async {
                                          try {
                                            final now = DateTime.now();

                                            await supabase
                                                .from('contra_oferta')
                                                .update({
                                              'estadoPago': 'Finalizado'
                                            }).eq('idContraOferta',
                                                    oferta.idContraOferta!);

                                            final insertResponse =
                                                await supabase
                                                    .from('compras')
                                                    .insert({
                                              'alternativaPago':
                                                  'Contra Oferta',
                                              'cantidad': oferta.cantidad,
                                              'total': oferta.valorOferta,
                                              'fecha': now.toIso8601String(),
                                              'idProducto': oferta.idProducto,
                                              'idComprador': oferta.idComprador,
                                              'nombreProducto':
                                                  oferta.nombreProducto,
                                              'idPropietario':
                                                  oferta.idPropietario,
                                              'imagenProducto':
                                                  oferta.imagenProducto,
                                              'estadoCompra': 'En Progreso',
                                            });

                                            if (insertResponse == null ||
                                                insertResponse['id'] == null) {
                                              throw Exception(
                                                  'No se pudo registrar la compra.');
                                            }

                                            _refreshOffers();
                                          } catch (e) {
                                            return print('Error');
                                          }
                                        },
                                      ),
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
              ),
            )
          ],
        ),
      ),
    );
  }
}
