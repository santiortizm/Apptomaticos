import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
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
    final size = MediaQuery.of(context).size;
    return Drawer(
      width: size.width * .9,
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
          _drawerItem(
              Image(
                image: AssetImage('./assets/images/tomate.png'),
              ),
              'Mis Productos',
              context,
              '/myProducts'),
          _drawerItem(
              Image(
                image: AssetImage('./assets/images/ventas.png'),
              ),
              'Mis Ventas',
              context,
              '/mySales'),
          _drawerItem(
              Image(
                image: AssetImage('./assets/images/contra_oferta.png'),
              ),
              'Mis Contra Ofertas',
              context,
              '/myCouterOffers'),
          widget.cerrarSesion,
        ];
      case 'Comerciante':
        return [
          _drawerItem(
              Image(
                image: AssetImage('./assets/images/ventas.png'),
              ),
              'Mis Compras',
              context,
              '/shoppingMerchant'),
          _drawerItem(
              Image(
                image: AssetImage('./assets/images/contra_oferta.png'),
              ),
              'Mis Contra Ofertas',
              context,
              '/counterOfferMerchant'),
          _drawerItem(
              Image(
                image: AssetImage('./assets/images/pedido.png'),
              ),
              'Mis Pedidos',
              context,
              '/myOrders'),
          widget.cerrarSesion,
        ];
      case 'Transportador':
        return [
          _drawerItem(
              Image(
                image: AssetImage('./assets/images/transportes.png'),
              ),
              'Mis Transportes',
              context,
              '/myTransports'),
          _drawerItem(
              Image(
                image: AssetImage('./assets/images/transportes.png'),
              ),
              'Historial de transportes',
              context,
              '/transportHistory'),
          widget.cerrarSesion,
        ];
      default:
        return [
          _drawerItem(
              Image(
                image: AssetImage('./assets/images/tomate.png'),
              ),
              'Rol no reconocido',
              context,
              '/')
        ];
    }
  }

  ///  Genera cada ítem del Drawer
  Widget _drawerItem(
      Widget icon, String title, BuildContext context, String route) {
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
                  radius: 30, backgroundColor: Colors.white, child: icon),
            ],
          ),
        ),
      ),
    );
  }
}
