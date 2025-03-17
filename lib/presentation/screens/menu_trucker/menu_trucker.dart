import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/widgets/custom_button.dart';
import 'package:App_Tomaticos/core/widgets/custom_tabbar_button.dart';
import 'package:App_Tomaticos/core/widgets/drawer/custom_drawer.dart';
import 'package:App_Tomaticos/presentation/screens/profile/profile_widget.dart';
import 'package:App_Tomaticos/presentation/screens/transportation/listview_transportation.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuTrucker extends StatefulWidget {
  const MenuTrucker({super.key});

  @override
  State<MenuTrucker> createState() => _MenuTruckerState();
}

class _MenuTruckerState extends State<MenuTrucker>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final supabase = Supabase.instance.client;
  String? userRole;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
    _fetchUserRole();
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
                  image: AssetImage('assets/images/fondo1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
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
                        child: const ListviewTransportation(),
                      ),
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
            label: 'Home',
            icon: Icons.home,
            isSelected: _selectedIndex == 0,
          ),
          CustomTabButton(
            label: 'Perfil',
            icon: Icons.person,
            isSelected: _selectedIndex == 1,
          ),
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
