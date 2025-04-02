import 'package:App_Tomaticos/core/models/counter_offer_model.dart';
import 'package:App_Tomaticos/core/services/counter_offer_service.dart';
import 'package:App_Tomaticos/core/services/product_service.dart';
import 'package:App_Tomaticos/core/widgets/cards/custom_card_counter_offer_producer.dart';
import 'package:App_Tomaticos/core/widgets/dialogs/more_info.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CounterOffersProducer extends StatefulWidget {
  const CounterOffersProducer({super.key});

  @override
  State<CounterOffersProducer> createState() => _CounterOffersProducerState();
}

class _CounterOffersProducerState extends State<CounterOffersProducer> {
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

  /// Obtiene el idUsuario del usuario autenticado
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
            counterOfferService.fetchCounterOfferByProducer();
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
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AutoSizeText(
                          'Mis Contra Ofertas',
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
                        height: 255,
                        text:
                            'Aquí se mostrarán las ofertas realizadas por los comerciantes. Estas estarán visibles solo 30 minutos. Si no responde en ese tiempo, la oferta será rechazada automáticamente y el comerciante será notificado.',
                        widthTextDialog: 180,
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
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        './assets/images/more_icons/contra_oferta.png'),
                                    width: 60,
                                    height: 60,
                                  ),
                                  Text('No tienes contra ofertas.'),
                                ],
                              ));
                            }

                            final ofertas = snapshot.data!
                                .where((o) => o.estadoOferta != 'Rechazado')
                                .toList();
                            return RefreshIndicator(
                              onRefresh: _refreshOffers,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.05),
                                itemCount: ofertas.length,
                                itemBuilder: (context, index) {
                                  final oferta = ofertas[index];

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Stack(
                                      children: [
                                        CustomCardCounterOfferProducer(
                                          idOfertador: oferta.idComprador,
                                          imagen: oferta
                                                  .imagenProducto.isNotEmpty
                                              ? '${oferta.imagenProducto}?v=${DateTime.now().millisecondsSinceEpoch}'
                                              : 'https://aqrtkpecnzicwbmxuswn.supabase.co/storage/v1/object/public/products/product/img_portada.webp',
                                          nombreProducto: oferta.nombreProducto,
                                          cantidadOfertada:
                                              oferta.cantidad.toString(),
                                          valorOferta:
                                              oferta.valorOferta.toString(),
                                          acceptOffer: () async {
                                            try {
                                              await supabase
                                                  .from('contra_oferta')
                                                  .update({
                                                'estadoOferta': 'Aceptado',
                                                'estadoPago': 'En Espera'
                                              }).eq('idContraOferta',
                                                      oferta.idContraOferta);

                                              setState(() {});
                                            } catch (e) {
                                              return;
                                            }
                                          },
                                          declineOffer: () async {
                                            await supabase
                                                .from('contra_oferta')
                                                .update({
                                              'estadoOferta': 'Rechazado'
                                            }).eq('idContraOferta',
                                                    oferta.idContraOferta);
                                          },
                                        ),
                                        if (oferta.estadoOferta == 'Aceptado')
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withValues(alpha: .5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18)),
                                              child: const Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.check_circle,
                                                        color: Colors.white,
                                                        size: 60),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      'Oferta Aceptada',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
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
