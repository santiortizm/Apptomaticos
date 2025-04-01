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

  ///  Cabecera del Drawer
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
                image: AssetImage('./assets/images/icons_drawer/tomate.png'),
              ),
              'Mis Productos',
              context,
              '/myProducts'),
          _drawerItem(
              Image(
                image: AssetImage('./assets/images/icons_drawer/ventas.png'),
              ),
              'Mis Ventas',
              context,
              '/mySales'),
          _drawerItem(
              Image(
                image: AssetImage(
                    './assets/images/icons_drawer/contra_ofertas.png'),
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
                image: AssetImage('./assets/images/icons_drawer/ventas.png'),
              ),
              'Mis Compras',
              context,
              '/shoppingMerchant'),
          _drawerItem(
              Image(
                image: AssetImage(
                    './assets/images/icons_drawer/contra_ofertas.png'),
              ),
              'Mis Contra Ofertas',
              context,
              '/counterOfferMerchant'),
          _drawerItem(
              Image(
                image: AssetImage('./assets/images/icons_drawer/pedido.png'),
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
                image:
                    AssetImage('./assets/images/icons_drawer/transportes.png'),
              ),
              'Mis Transportes',
              context,
              '/myTransports'),
          _drawerItem(
              Image(
                image:
                    AssetImage('./assets/images/icons_drawer/transportes.png'),
              ),
              'Historial Transportes',
              context,
              '/transportHistory'),
          widget.cerrarSesion,
        ];
      default:
        return [
          _drawerItem(
              Image(
                image: AssetImage('./assets/images/icons_drawer/tomate.png'),
              ),
              'Rol no reconocido',
              context,
              '/')
        ];
    }
  }

  Widget _drawerItem(
      Widget icon, String title, BuildContext context, String route) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).go(route);
      },
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 10,
        ),
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.025),
          width: size.width * 0.8,
          height: size.height * 0.1,
          decoration: BoxDecoration(
              color: cardDrawer, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.center,
                height: size.height * 0.04,
                width: size.width * 0.62,
                child: AutoSizeText(
                  title,
                  maxLines: 1,
                  maxFontSize: 20,
                  minFontSize: 14,
                  style: temaApp.textTheme.titleSmall!
                      .copyWith(color: Colors.black, fontSize: 30),
                ),
              ),
              CircleAvatar(
                  radius: 24, backgroundColor: Colors.transparent, child: icon),
            ],
          ),
        ),
      ),
    );
  }
}
