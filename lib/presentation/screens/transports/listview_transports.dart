import 'package:App_Tomaticos/core/models/buy_model.dart';
import 'package:App_Tomaticos/core/services/transport_service.dart';
import 'package:App_Tomaticos/core/services/user_services.dart';
import 'package:App_Tomaticos/core/widgets/cards/custom_card_transport.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListviewTransports extends StatefulWidget {
  const ListviewTransports({super.key});

  @override
  State<ListviewTransports> createState() => _ListviewTransportsState();
}

class _ListviewTransportsState extends State<ListviewTransports> {
  final supabase = Supabase.instance.client;
  final TransportService transportService = TransportService();
  final UserService userService = UserService(Supabase.instance.client);
  late RealtimeChannel _channel;

  late Future<List<Buy>> transportFuture;

  @override
  void initState() {
    super.initState();
    _initialize();
    transportFuture = transportService.fetchAllTransports();
  }

  Future<void> _initialize() async {
    _subscribeToProductChanges();
    _refreshTransports();
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    super.dispose();
  }

  void _subscribeToProductChanges() {
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

  ///  Función para refrescar manualmente la lista de transportes disponibles
  Future<void> _refreshTransports() async {
    setState(() {
      transportFuture = transportService.fetchAllTransports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: FutureBuilder<List<Buy>>(
        future: transportFuture,
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
                        './assets/images/more_icons/no_transports.png'),
                    width: 60,
                    height: 60,
                  ),
                  Text('No hay transportes disponibles'),
                ],
              ),
            );
          }

          final transports = snapshot.data!
              .where(
                (t) =>
                    t.estadoCompra != 'Transportando' &&
                    t.estadoCompra != 'Finalizado',
              )
              .toList();
          if (transports.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage(
                        './assets/images/more_icons/no_transports.png'),
                    width: 60,
                    height: 60,
                  ),
                  Text('No hay transportes disponibles'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refreshTransports,
            child: ListView.builder(
              padding: EdgeInsets.only(left: 10, right: 10),
              itemCount: transports.length,
              itemBuilder: (context, index) {
                final transport = transports[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CustomCardTransport(
                    idUsuario: transport.idComprador,
                    imageUrlProduct: transport.imagenProducto,
                    idCompra: transport.id,
                    countTransport: transport.cantidad.toString(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
