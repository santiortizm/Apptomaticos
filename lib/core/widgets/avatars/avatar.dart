import 'dart:io';
import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/services/image_service.dart';
import 'package:App_Tomaticos/core/widgets/dialogs/custom_alert_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class Avatar extends StatefulWidget {
  final String? imageUrl;
  final void Function(String imageUrl) onUpLoad;

  const Avatar({super.key, required this.imageUrl, required this.onUpLoad});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  File? _imageFile;
  final supabase = Supabase.instance.client;
  bool isLoading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileImage();
  }

  /// Obtiene la imagen de perfil desde Supabase
  Future<void> _fetchUserProfileImage() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final String path = 'profiles/$userId/profile.jpg';
    final String imageUrl =
        supabase.storage.from('profiles').getPublicUrl(path);

    setState(() {
      _imageUrl = "$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}";
    });
  }

  ///  Verifica y solicita permisos antes de abrir la cámara o galería
  Future<bool> _checkPermissions(ImageSource source) async {
    Permission permission =
        (source == ImageSource.camera) ? Permission.camera : Permission.photos;

    var status = await permission.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      status = await permission.request();
      return status.isGranted;
    } else if (status.isPermanentlyDenied) {
      return await _showSettingsDialog();
    }

    return false;
  }

  ///  Abre la cámara o la galería si tiene permisos
  Future<void> _pickImage(ImageSource source) async {
    bool hasPermission = await _checkPermissions(source);
    if (!hasPermission) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;

    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      final bool confirm = await _confirmImageChange();
      if (!confirm) return;
    }

    setState(() {
      isLoading = true;
    });

    final userId = supabase.auth.currentUser!.id;
    final String path = 'profiles/$userId/profile.jpg';

    try {
      _imageFile = await ImageService.compressImage(image, quality: 50);
      if (_imageFile == null) throw 'Error al comprimir la imagen';

      await supabase.storage.from('profiles').upload(
            path,
            _imageFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      final String imageUrl =
          supabase.storage.from('profiles').getPublicUrl(path);

      setState(() {
        _imageUrl = "$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}";
      });

      widget.onUpLoad(_imageUrl!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen actualizada correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la imagen: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  ///  Muestra un modal para elegir entre galería o cámara
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar desde galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  ///  Si los permisos están bloqueados, muestra una alerta para abrir configuración
  Future<bool> _showSettingsDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permisos requeridos'),
            content: const Text(
                'Para continuar, habilita el acceso en la configuración.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context, true);
                },
                child: const Text('Abrir configuración'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Confirma si el usuario quiere cambiar la imagen actual

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 150,
      height: 150,
      child: Stack(
        children: [
          Center(
            child: CircleAvatar(
              backgroundImage: (_imageUrl != null && _imageUrl!.isNotEmpty)
                  ? NetworkImage(_imageUrl!)
                  : const AssetImage('./assets/images/icon_user/profile.png')
                      as ImageProvider,
              radius: 70,
              child: (_imageUrl == null || _imageUrl!.isEmpty)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, size: 60, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text('Agregar Imagen',
                            style: TextStyle(color: Colors.grey[700])),
                      ],
                    )
                  : null,
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 2,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.camera_alt),
              iconSize: 32,
              color: redApp,
              onPressed: isLoading ? null : _showImagePickerOptions,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmImageChange() async {
    return await showDialog<bool>(
            context: context,
            builder: (context) => CustomAlertDialog(
                width: 300,
                height: 300,
                assetImage: './assets/gifts/camara.gif',
                title: 'Confirmar cambio',
                content: SizedBox(
                  width: 250,
                  child: AutoSizeText(
                    '¿Estás seguro de que quieres cambiar la imagen?',
                    maxLines: 2,
                    maxFontSize: 35,
                    minFontSize: 4,
                    textAlign: TextAlign.justify,
                  ),
                ),
                onPressedAcept: () => Navigator.pop(context, true),
                onPressedCancel: () => Navigator.pop(context, false))) ??
        false;
  }
}
