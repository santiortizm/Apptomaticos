import 'package:App_Tomaticos/core/models/buy_model.dart';
import 'package:App_Tomaticos/core/services/buy_service.dart';
import 'package:App_Tomaticos/core/services/product_service.dart';
import 'package:App_Tomaticos/core/widgets/cards/custom_card_sale_producer.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MySales extends StatefulWidget {
  const MySales({super.key});

  @override
  State<MySales> createState() => _MySalesState();
}

class _MySalesState extends State<MySales> {
  final BuyService buyService =
      BuyService(ProductService(Supabase.instance.client));
  late Future<List<Buy>> completedSalesFuture;

  @override
  void initState() {
    super.initState();
    _fetchSales();
  }

  void _fetchSales() {
    setState(() {
      completedSalesFuture = buyService.fetchCompletedSalesForProducer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
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
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: AutoSizeText(
                          'Mis Ventas',
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
                          future: completedSalesFuture,
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
                                        './assets/images/more_icons/ventas_no_realizadas.png'),
                                    width: 50,
                                    height: 50,
                                  ),
                                  Text('No hay ventas finalizadas.'),
                                ],
                              ));
                            }

                            final sales = snapshot.data!;

                            return RefreshIndicator(
                              onRefresh: () async => _fetchSales(),
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.05),
                                itemCount: sales.length,
                                itemBuilder: (context, index) {
                                  final sale = sales[index];

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: CustomCardSaleProducer(
                                      imagen: sale.imagenProducto,
                                      nombreProducto: sale.nombreProducto,
                                      fechaCompra: sale.fecha.toString(),
                                      total: sale.total.toString(),
                                      cantidad: sale.cantidad.toString(),
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
