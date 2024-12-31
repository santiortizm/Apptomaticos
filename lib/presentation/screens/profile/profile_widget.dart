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
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
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
      // Si ocurre un error (ejemplo: 404), mantener `_imageUrl` como null
      setState(() {
        _imageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
      ),
      child: Column(
        children: [
          Avatar(
            imageUrl: _imageUrl,
            onUpLoad: (imageUrl) {
              setState(() {
                _imageUrl = imageUrl;
              });
            },
          ),
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
    );
  }
}
