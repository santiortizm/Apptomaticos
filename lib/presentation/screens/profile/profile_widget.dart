import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/widgets/avatar.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
import 'package:apptomaticos/presentation/screens/second_pages/second_pages_producer/products_of_producer.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final supabase = Supabase.instance.client;

  String? _imageUrl;
  Map<String, dynamic>? _userInfo;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserProfileData();
  }

  /// Carga los datos del perfil: información del usuario y rol
  Future<void> _loadUserProfileData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Carga el rol del usuario
      final roleResponse = await supabase
          .from('usuarios')
          .select('rol, nombre, apellido, celular')
          .eq('idUsuario', user.id)
          .single();

      // Carga la imagen de perfil
      final imagePath = '${user.id}/profile';
      final publicUrl =
          supabase.storage.from('profiles').getPublicUrl(imagePath);

      setState(() {
        _userInfo = roleResponse;
        userRole = roleResponse['rol'];
        _imageUrl = publicUrl;
      });
    } catch (e) {
      print('Error al cargar los datos del perfil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(vertical: size.width * 0.05),
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            Stack(
              children: [
                Avatar(
                  imageUrl: _imageUrl,
                  onUpLoad: (imageUrl) {
                    setState(() {
                      _imageUrl = imageUrl;
                    });
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(
                      Icons.list,
                      size: 50,
                      color: redApp,
                    ),
                  ),
                ),
                if (userRole == 'Productor')
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductsOfProducer(),
                        ),
                      ),
                      icon: Icon(
                        Icons.list,
                        size: 50,
                        color: redApp,
                      ),
                    ),
                  ),
              ],
            ),
            _cardInfo('Nombre', _userInfo?['nombre']),
            _cardInfo('Apellido', _userInfo?['apellido']),
            _cardInfo('Rol', _userInfo?['rol']),
            _cardInfo('Celular', _userInfo?['celular']),
            _cardInfo('Correo', supabase.auth.currentUser?.email),
            CustomButton(
              onPressed: () async {
                await supabase.auth.signOut();
              },
              color: redApp,
              border: 18,
              width: 0.3,
              height: 0.07,
              elevation: 0,
              colorBorder: Colors.transparent,
              sizeBorder: 0,
              child: AutoSizeText(
                'Cerrar Sesión',
                maxFontSize: 18,
                minFontSize: 16,
                maxLines: 1,
                style: temaApp.textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardInfo(
    String titleInfo,
    String? subTitle,
  ) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.025, vertical: size.height * 0.015),
      height: size.height * 0.105,
      width: size.width * 0.75,
      decoration: BoxDecoration(
        color: cardInfo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              AutoSizeText(
                titleInfo,
                maxFontSize: 18,
                minFontSize: 16,
                maxLines: 1,
                style: temaApp.textTheme.titleSmall!.copyWith(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              AutoSizeText(
                subTitle ?? 'No disponible',
                maxFontSize: 16,
                minFontSize: 12,
                maxLines: 1,
                style: temaApp.textTheme.titleSmall!.copyWith(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
