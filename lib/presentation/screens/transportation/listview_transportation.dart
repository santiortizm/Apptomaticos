import 'package:apptomaticos/core/models/buy_model.dart';
import 'package:apptomaticos/core/services/buy_service.dart';
import 'package:apptomaticos/core/services/product_service.dart';
import 'package:apptomaticos/core/widgets/cards/custom_card_transport.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListviewTransportation extends StatefulWidget {
  const ListviewTransportation({super.key});

  @override
  State<ListviewTransportation> createState() => _ListviewTransportationState();
}

class _ListviewTransportationState extends State<ListviewTransportation> {
  final supabase = Supabase.instance.client;
  final BuyService buyService =
      BuyService(ProductService(Supabase.instance.client));
  late Stream<List<Buy>> buyStream;
  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    buyStream = supabase
        .from('compras')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((row) => Buy.fromJson(row)).toList());
  }

  Future<void> _refreshList() async {
    setState(() {
      _initializeStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.025),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      width: size.width * 1,
      child: RefreshIndicator(
        onRefresh: _refreshList,
        child: StreamBuilder<List<Buy>>(
          stream: buyStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Error obteniendo transportes'),
              );
            } else if (snapshot.hasData) {
              final transports = snapshot.data!
                  .where((t) =>
                      t.estadoCompra != 'Transportando' &&
                      t.estadoCompra != 'Finalizado')
                  .toList();
              return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  itemCount: transports.length,
                  itemBuilder: (context, index) {
                    final transport = transports[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CustomCardTransport(
                          idUsuario: transport.idComprador,
                          imageUrlProduct: transport.imagenProducto,
                          idCompra: transport.id!,
                          countTransport: transport.cantidad.toString()),
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
    );
  }
}
