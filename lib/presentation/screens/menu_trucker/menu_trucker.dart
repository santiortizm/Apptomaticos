import 'package:apptomaticos/core/widgets/custom_tabbar_button.dart';
import 'package:flutter/material.dart';

class MenuTrucker extends StatefulWidget {
  const MenuTrucker({super.key});

  @override
  State<MenuTrucker> createState() => _MenuTruckerState();
}

class _MenuTruckerState extends State<MenuTrucker>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
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
            _buildTabBar(context, size),
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
            isSelected: _selectedIndex == 2,
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
