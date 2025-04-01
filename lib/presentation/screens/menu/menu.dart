import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/widgets/button/custom_button.dart';
import 'package:App_Tomaticos/core/widgets/drawer/custom_drawer.dart';
import 'package:App_Tomaticos/presentation/screens/price/price_page.dart';
import 'package:App_Tomaticos/presentation/screens/products/listview_products.dart';
import 'package:App_Tomaticos/presentation/screens/profile/profile.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:App_Tomaticos/core/widgets/tabbar/custom_tabbar_button.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final supabase = Supabase.instance.client;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      _setFcmToken(fcmToken);
    });

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  Future<void> _fetchUserRole() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('usuarios')
          .select('rol')
          .eq('idUsuario', user.id)
          .maybeSingle();

      setState(() {
        userRole = response?['rol'];
      });
    } catch (e) {
      return;
    }
  }

  Future<void> _setFcmToken(String fcmToken) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await supabase
          .from('usuarios')
          .update({'fcm_token': fcmToken}).eq('idUsuario', userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      drawer: userRole == null
          ? const Drawer(child: Center(child: CircularProgressIndicator()))
          : CustomDrawer(
              userRole: userRole!,
              cerrarSesion: Padding(
                padding: EdgeInsets.only(
                  left: size.width * 0.1,
                  right: size.width * 0.1,
                  top: size.height * 0.10,
                ),
                child: CustomButton(
                  onPressed: () async {
                    await supabase.auth.signOut();
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      GoRouter.of(context).go('/');
                    }
                  },
                  color: redApp,
                  border: 18,
                  width: 0.2,
                  height: 0.07,
                  elevation: 0,
                  colorBorder: Colors.transparent,
                  sizeBorder: 0,
                  child: AutoSizeText(
                    'Cerrar Sesión',
                    maxFontSize: 20,
                    minFontSize: 16,
                    maxLines: 1,
                    style: temaApp.textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 30),
                  ),
                ),
              ),
            ),
      body: SafeArea(
        child: Stack(
          children: [
            // Fondo con opacidad
            Container(
              width: size.width,
              height: size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background/fondo1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
            // Contenido principal
            Column(
              children: [
                _buildTabBar(context, size),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: size.height * 0.025),
                        child: const ListviewProducts(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: size.height * 0.025),
                        child: PriceScreen(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: size.height * 0.025),
                        child: const Profile(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: TabBar(
        controller: _tabController,
        labelPadding: EdgeInsets.symmetric(horizontal: size.width * 0.025),
        indicatorColor: Colors.transparent,
        tabs: [
          CustomTabButton(
              label: 'Inicio',
              icon: Icons.home,
              isSelected: _selectedIndex == 0),
          CustomTabButton(
              label: 'Precios',
              icon: Icons.attach_money,
              isSelected: _selectedIndex == 1),
          CustomTabButton(
              label: 'Perfil',
              icon: Icons.person,
              isSelected: _selectedIndex == 2),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _tabController.animateTo(index,
              duration: const Duration(milliseconds: 1));
        },
      ),
    );
  }
}
