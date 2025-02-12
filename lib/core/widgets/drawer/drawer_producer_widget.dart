import 'package:flutter/material.dart';

class DrawerProducerWidget extends StatelessWidget {
  const DrawerProducerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.blueAccent),
          child: Text('Opciones'),
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
