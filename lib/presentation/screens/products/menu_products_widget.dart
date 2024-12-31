import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/presentation/screens/products/add_product_widget.dart';
import 'package:apptomaticos/core/widgets/custom_listview.dart';
import 'package:apptomaticos/presentation/screens/profile/profile_widget.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:apptomaticos/core/widgets/custom_tabbar_button.dart';

class MenuProductsWidget extends StatefulWidget {
  const MenuProductsWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MenuProductsWidgetState createState() => _MenuProductsWidgetState();
}

class _MenuProductsWidgetState extends State<MenuProductsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      body: Stack(
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
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          // Contenido principal
          Column(
            children: [
              SizedBox(height: size.height * 0.05),
              _buildTabBar(context, size),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.025),
                      child: const CustomListview(),
                    ),
                    _buildPricesTab(context, size),
                    const ProfileWidget(),
                  ],
                ),
              ),
            ],
          ),
          Center(
            child: Container(
              width: size.width * 0.4,
              alignment: const Alignment(0.0, 0.95),
              child: CustomButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddProductWidget())),
                color: buttonGreen,
                border: 18,
                width: 0.4,
                height: 0.07,
                elevation: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sell,
                      color: redApp,
                      size: 26,
                    ),
                    AutoSizeText(
                      'Vender',
                      maxFontSize: 32,
                      minFontSize: 14,
                      maxLines: 1,
                      style: temaApp.textTheme.titleSmall!.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
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
            label: 'Precios',
            icon: Icons.attach_money,
            isSelected: _selectedIndex == 1,
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

  Widget _buildPricesTab(BuildContext context, Size size) {
    return const Center(
      child:
          Text('Aquí van los precios', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildProfileTab(BuildContext context, Size size) {
    return const Column(
      children: [
        Center(
          child:
              Text('Aquí va el perfil', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
