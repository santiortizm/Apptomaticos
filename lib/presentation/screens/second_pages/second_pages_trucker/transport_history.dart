import 'package:App_Tomaticos/core/services/transport_service.dart';
import 'package:App_Tomaticos/core/widgets/cards/custom_card_transportation_info.dart';
import 'package:App_Tomaticos/core/widgets/custom_button.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/transport_model.dart';

class TransportHistory extends StatefulWidget {
  const TransportHistory({super.key});

  @override
  State<TransportHistory> createState() => _TransportHistoryState();
}

class _TransportHistoryState extends State<TransportHistory> {
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
    _subscribeToListChanges();
    _refreshTransports();
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

  void _subscribeToListChanges() {
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
        transportsFuture =
            transportService.fetchTransportsByTrucker(idUsuario!);
      });
    }
  }

  String formatPrice(num price) {
    final formatter =
        NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0);
    return formatter.format(price);
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
                      Align(
                        alignment: const Alignment(-0.9, 0),
                        child: SizedBox(
                          width: size.width * 0.35,
                          child: CustomButton(
                            onPressed: () {
                              GoRouter.of(context).go('/menuTrucker');
                            },
                            color: Colors.white.withValues(alpha: 0.05),
                            border: 20,
                            width: 0.2,
                            height: 0.1,
                            elevation: 0,
                            colorBorder: Colors.transparent,
                            sizeBorder: 0,
                            child: Row(
                              spacing: size.width * 0.02,
                              children: [
                                const Icon(Icons.arrow_back,
                                    color: Colors.black),
                                AutoSizeText(
                                  'Atrás',
                                  maxFontSize: 18,
                                  minFontSize: 14,
                                  maxLines: 1,
                                  style: temaApp.textTheme.titleSmall!.copyWith(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: AutoSizeText(
                          'Mis Transportes Realizados',
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
                                  child: Text(
                                      'No tienes transportes finalizados.'));
                            }

                            final transports = snapshot.data!
                                .where((t) => t.estado == 'Finalizado')
                                .toList();
                            return RefreshIndicator(
                              onRefresh: _refreshTransports,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.02),
                                itemCount: transports.length,
                                itemBuilder: (context, index) {
                                  final transport = transports[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: CustomCardTransportationInfo(
                                      idTransporte: transport.idTransporte,
                                      estado: transport.estado,
                                      idCompra: transport.idCompra,
                                      pesoCarga: transport.pesoCarga.toString(),
                                      valorTransporte: formatPrice(
                                          transport.valorTransporte),
                                      confirmarPago: () async {
                                        await supabase.from('compras').update({
                                          'estadoCompra': 'Pagado'
                                        }).eq('id', transport.idCompra);

                                        await supabase
                                            .from('transportes')
                                            .update({
                                          'estado': 'Finalizado'
                                        }).eq('idTransporte',
                                                transport.idTransporte);
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
            )
          ],
        ),
      ),
    );
  }
}
