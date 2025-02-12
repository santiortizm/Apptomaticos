import 'package:apptomaticos/core/widgets/cards/custom_card_transportation.dart';
import 'package:flutter/material.dart';

class ListviewTransportation extends StatefulWidget {
  const ListviewTransportation({super.key});

  @override
  State<ListviewTransportation> createState() => _ListviewTransportationState();
}

class _ListviewTransportationState extends State<ListviewTransportation> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      width: size.width * 1,
      height: size.height * 1,
      child: const SingleChildScrollView(
        child: CustomCardTransportation(),
      ),
    );
  }
}
