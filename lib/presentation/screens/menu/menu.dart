import 'package:apptomaticos/core/widgets/drawer/drawer_producer_widget.dart';
import 'package:apptomaticos/presentation/screens/products/listview_products.dart';
import 'package:apptomaticos/presentation/screens/profile/profile_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:apptomaticos/core/widgets/custom_tabbar_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

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
      drawer: const DrawerProducerWidget(),
      body: SafeArea(
        child: Stack(
          children: [
            // Fondo con opacidad
            Container(
              width: size.width,
              height: size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/fondo1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(color: Colors.black.withOpacity(0.5)),
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
                      _buildPricesTab(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: size.height * 0.025),
                        child: const ProfileWidget(),
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
              label: 'Home', icon: Icons.home, isSelected: _selectedIndex == 0),
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

  Widget _buildPricesTab() {
    return const Center(
      child:
          Text('Aquí van los precios', style: TextStyle(color: Colors.white)),
    );
  }
}
