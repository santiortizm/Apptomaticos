import 'package:flutter/material.dart';

class DrawerMerchantWidget extends StatelessWidget {
  const DrawerMerchantWidget({super.key});
  @override
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.blueAccent),
          child: Text('Menu de opciones'),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Inicio'),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configuraciones'),
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
