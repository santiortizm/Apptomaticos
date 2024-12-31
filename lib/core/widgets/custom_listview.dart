import 'package:apptomaticos/data/repositories/product_repository.dart';
import 'package:apptomaticos/core/widgets/custom_card_products.dart';
import 'package:flutter/material.dart';

class CustomListview extends StatefulWidget {
  const CustomListview({super.key});

  @override
  State<CustomListview> createState() => _CustomListviewState();
}

class _CustomListviewState extends State<CustomListview> {
  final ProductRepository productRepository = ProductRepository();
  late Future<List> productsFuture;

  @override
  void initState() {
    productsFuture = productRepository.readData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20)),
      width: size.width * 1,
      height: size.height * 1,
      child: FutureBuilder(
        future: productsFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Dialog(
              child: SizedBox(
                width: size.width * 0.4,
                height: size.height * 0.3,
                child: const Text('Error'),
              ),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return const Center(
                child: Text('Datos no disponibles'),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, int index) {
                var data = snapshot.data[index];
                return CustomCardProducts(
                  title: data['nombreProducto'],
                  state: data['maduracion'],
                  price: data['precio'].toString(),
                  imageUrl: data['imageUrl'] ?? '',
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
