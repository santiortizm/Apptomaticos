import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/services/user_services.dart';
import 'package:App_Tomaticos/core/widgets/avatars/avatar.dart';
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
  final UserService userService = UserService(Supabase.instance.client);

  String? _imageUrl;
  Map<String, dynamic>? _userInfo;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserProfileData();
  }

  /// Carga los datos del perfil
  Future<void> _loadUserProfileData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final roleResponse = await supabase
          .from('usuarios')
          .select('rol, nombre, apellido, celular')
          .eq('idUsuario', user.id)
          .single();

      final imagePath = 'profiles/${user.id}/profile.jpg';
      final response =
          await supabase.storage.from('profiles').list(path: user.id);

      String? imageUrl;
      if (response.any((file) => file.name == 'profile.jpg')) {
        imageUrl = supabase.storage.from('profiles').getPublicUrl(imagePath);
      }

      if (!mounted) return;

      setState(() {
        _userInfo = roleResponse;
        userRole = roleResponse['rol'];
        _imageUrl = "$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}";
      });
    } catch (e) {
      if (!mounted) return;
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
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
                    top: 20,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Image.asset(
                        './assets/images/icon_button/menu.png',
                        width: 50,
                        height: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _cardInfo(
              'Nombre',
              _userInfo?['nombre'],
              IconButton(
                onPressed: () => _editDialog(context, 'nombre'),
                icon: Icon(
                  Icons.edit_rounded,
                  color: redApp,
                ),
              ),
            ),
            _cardInfo(
              'Apellido',
              _userInfo?['apellido'],
              IconButton(
                onPressed: () => _editDialog(context, 'apellido'),
                icon: Icon(
                  Icons.edit_rounded,
                  color: redApp,
                ),
              ),
            ),
            _cardInfo('Rol', _userInfo?['rol'], const SizedBox.shrink()),
            _cardInfo(
              'Celular',
              _userInfo?['celular'],
              IconButton(
                onPressed: () => _editDialog(context, 'celular'),
                icon: Icon(
                  Icons.edit_rounded,
                  color: redApp,
                ),
              ),
            ),
            _cardInfo('Correo', supabase.auth.currentUser?.email,
                const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _cardInfo(String titleInfo, String? subTitle, Widget editButton) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: cardInfo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontWeight: FontWeight.w700,
                  ),
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
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          editButton,
        ],
      ),
    );
  }

  /// Muestra el diálogo de edición del perfil
  Future<void> _editDialog(BuildContext contextDialog, String field) async {
    final TextEditingController controller = TextEditingController(
      text: _userInfo?[field] ?? '',
    );

    await showDialog(
      context: contextDialog,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Editar $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              style:
                  ButtonStyle(foregroundColor: WidgetStatePropertyAll(redApp)),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(buttonGreen)),
              onPressed: () async {
                final user = supabase.auth.currentUser;
                if (user == null) return;

                final bool success = await userService.updateInfoUser(
                  user.id,
                  {field: controller.text.trim()},
                );

                if (success) {
                  Navigator.pop(dialogContext);
                  _loadUserProfileData(); // Recarga los datos actualizados
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al actualizar')),
                  );
                }
              },
              child: const Text(
                'Editar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
