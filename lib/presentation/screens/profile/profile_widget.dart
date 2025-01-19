import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/widgets/avatar.dart';
import 'package:apptomaticos/core/widgets/custom_button.dart';
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
  String? _imageUrl;
  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? _authInfo;
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
    _loadUserInfo();
    _loadAuthUserInfo();
  }

  Future<void> _loadUserProfileImage() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final imagePath = '$userId/profile';
        final publicUrl =
            supabase.storage.from('profiles').getPublicUrl(imagePath);
        await supabase.storage.from('profiles').download(imagePath);

        setState(() {
          _imageUrl = publicUrl;
        });
      }
    } catch (e) {
      setState(() {
        _imageUrl = null;
      });
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await supabase
            .from('usuarios')
            .select()
            .eq('idAuth', userId)
            .single();

        setState(() {
          _userInfo = response;
        });
      }
    } catch (e) {
      print('Error al cargar información del usuario: $e');
    }
  }

  Future<void> _loadAuthUserInfo() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        setState(() {
          _authInfo = {
            'email': user.email,
          };
        });
      }
    } catch (e) {
      print('Error al cargar información de auth.users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(vertical: size.width * 0.05),
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            Avatar(
              imageUrl: _imageUrl,
              onUpLoad: (imageUrl) {
                setState(() {
                  _imageUrl = imageUrl;
                });
              },
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: size.width * 0.07),
              alignment: Alignment.center,
              child: AutoSizeText(
                'Nombre',
                maxFontSize: 16,
                minFontSize: 16,
                maxLines: 1,
                style: temaApp.textTheme.titleSmall!.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Text('${_userInfo?['nombre']}'),
            Container(
              margin: EdgeInsets.symmetric(horizontal: size.width * 0.07),
              alignment: Alignment.center,
              child: AutoSizeText(
                'Apellido',
                maxFontSize: 16,
                minFontSize: 16,
                maxLines: 1,
                style: temaApp.textTheme.titleSmall!.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Text('${_userInfo?['apellido']}'),
            Container(
              margin: EdgeInsets.symmetric(horizontal: size.width * 0.07),
              alignment: Alignment.center,
              child: AutoSizeText(
                'Rol',
                maxFontSize: 16,
                minFontSize: 16,
                maxLines: 1,
                style: temaApp.textTheme.titleSmall!.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Text('${_userInfo?['rol']}'),
            Container(
              margin: EdgeInsets.symmetric(horizontal: size.width * 0.07),
              alignment: Alignment.center,
              child: AutoSizeText(
                'Celular',
                maxFontSize: 16,
                minFontSize: 16,
                maxLines: 1,
                style: temaApp.textTheme.titleSmall!.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Text('${_userInfo?['celular']}'),
            Container(
              margin: EdgeInsets.symmetric(horizontal: size.width * 0.07),
              alignment: Alignment.center,
              child: AutoSizeText(
                'Correo ',
                maxFontSize: 16,
                minFontSize: 16,
                maxLines: 1,
                style: temaApp.textTheme.titleSmall!.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Text('${_authInfo?['email']}'),
            CustomButton(
              onPressed: () async {
                await supabase.auth.signOut();
              },
              color: redApp,
              border: 18,
              width: 0.3,
              height: 0.07,
              elevation: 0,
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
}
