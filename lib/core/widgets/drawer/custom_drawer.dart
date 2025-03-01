import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomDrawer extends StatefulWidget {
  final String userRole;
  final Widget cerrarSesion;
  const CustomDrawer(
      {super.key, required this.userRole, required this.cerrarSesion});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              children: _getDrawerOptions(context),
            ),
          ),
        ],
      ),
    );
  }

  ///  Cabecera del Drawer (puedes personalizarlo con la info del usuario)
  Widget _buildHeader() {
    return DrawerHeader(
        decoration: BoxDecoration(color: redApp),
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          child: AutoSizeText(
            'Más Opciones',
            maxLines: 1,
            maxFontSize: 32,
            minFontSize: 26,
            style: temaApp.textTheme.titleSmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 100),
          ),
        ));
  }

  ///  Retorna las opciones del menú según el rol
  List<Widget> _getDrawerOptions(BuildContext context) {
    switch (widget.userRole) {
      case 'Productor':
        return [
          _drawerItem(Icons.store, 'Mis Productos', context, '/myProducts'),
          _drawerItem(Icons.add, 'Mis Ventas', context, '/agregarProducto'),
          _drawerItem(
              Icons.add, 'Mis Contra Ofertas', context, '/myCouterOffers'),
          widget.cerrarSesion,
        ];
      case 'Comerciante':
        return [
          _drawerItem(
              Icons.shopping_cart, 'Mis Compras', context, '/shoppingMerchant'),
          _drawerItem(
              Icons.business, 'Mis Contra Ofertas', context, '/proveedores'),
          _drawerItem(Icons.business, 'Mis Pedidos', context, '/proveedores'),
          widget.cerrarSesion,
        ];
      case 'Transportador':
        return [
          _drawerItem(
              Icons.local_shipping, 'Mis Envíos', context, '/misEnvios'),
          _drawerItem(Icons.map, 'Rutas Disponibles', context, '/rutas'),
          widget.cerrarSesion,
        ];
      default:
        return [_drawerItem(Icons.error, 'Rol no reconocido', context, '/')];
    }
  }

  ///  Genera cada ítem del Drawer
  Widget _drawerItem(
      IconData icon, String title, BuildContext context, String route) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).go(route);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.025),
          width: size.width * 0.8,
          height: size.height * 0.1,
          decoration: BoxDecoration(
              color: cardDrawer, borderRadius: BorderRadius.circular(20)),
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: size.width * 0.6,
                child: AutoSizeText(
                  title,
                  maxLines: 1,
                  maxFontSize: 20,
                  minFontSize: 18,
                  style: temaApp.textTheme.titleSmall!
                      .copyWith(color: Colors.black, fontSize: 30),
                ),
              ),
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  icon,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
