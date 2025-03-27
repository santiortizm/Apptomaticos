import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/widgets/avatar.dart';
import 'package:App_Tomaticos/presentation/themes/app_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
      final roleResponse = await supabase
          .from('usuarios')
          .select('rol, nombre, apellido, celular')
          .eq('idUsuario', user.id)
          .single();

      // Verificar si la imagen existe en Supabase Storage
      final imagePath = 'profiles/${user.id}/profile.jpg';
      final response =
          await supabase.storage.from('profiles').list(path: user.id);

      String? imageUrl;
      if (response.any((file) => file.name == 'profile.jpg')) {
        imageUrl = supabase.storage.from('profiles').getPublicUrl(imagePath);
      }

      if (!mounted)
        return; //  Evita llamar `setState` si el widget ya no está en el árbol

      setState(() {
        _userInfo = roleResponse;
        userRole = roleResponse['rol'];
        _imageUrl = "$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}";
      });
    } catch (e) {
      if (!mounted) return; //Verifica `mounted` antes de actualizar el estado
      print('Error cargando datos de usuario: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
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
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          spacing: 16,
          children: [
            Container(
              width: 350,
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Avatar(
                        imageUrl: _imageUrl,
                        onUpLoad: (imageUrl) {
                          setState(() {
                            _imageUrl = imageUrl;
                          });
                        },
                      ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 8,
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
                ],
              ),
            ),
            _cardInfo('Nombre', _userInfo?['nombre']),
            _cardInfo('Apellido', _userInfo?['apellido']),
            _cardInfo('Rol', _userInfo?['rol']),
            _cardInfo('Celular', _userInfo?['celular']),
            _cardInfo('Correo', supabase.auth.currentUser?.email),
          ],
        ),
      ),
    );
  }

  Widget _cardInfo(
    String titleInfo,
    String? subTitle,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cardInfo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 3,
            children: [
              SizedBox(
                width: 120,
                child: AutoSizeText(
                  titleInfo,
                  maxFontSize: 18,
                  minFontSize: 11,
                  maxLines: 1,
                  style: temaApp.textTheme.titleSmall!.copyWith(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                width: 200,
                child: AutoSizeText(
                  subTitle ?? 'No disponible',
                  maxFontSize: 14,
                  minFontSize: 4,
                  maxLines: 1,
                  style: temaApp.textTheme.titleSmall!.copyWith(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
