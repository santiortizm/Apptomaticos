import 'dart:io';
import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/services/image_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    _fetchUserProfileImage(); //  Cargar la imagen de perfil al iniciar
  }

  ///  Obtiene la imagen actualizada desde Supabase
  Future<void> _fetchUserProfileImage() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final String path = 'profiles/$userId/profile.jpg';
    final String imageUrl =
        supabase.storage.from('profiles').getPublicUrl(path);

    setState(() {
      _imageUrl =
          "$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}"; // 🔥 Evita caché
    });
  }

  ///  Permite seleccionar y subir una nueva imagen
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

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
        _imageUrl =
            "$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}"; // 🔥 Evita caché
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

  ///  Confirma si el usuario quiere cambiar la imagen actual
  Future<bool> _confirmImageChange() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar cambio'),
            content:
                const Text('¿Estás seguro de que quieres cambiar la imagen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Editar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: CircleAvatar(
            backgroundImage: (_imageUrl != null && _imageUrl!.isNotEmpty)
                ? NetworkImage(_imageUrl!)
                : null,
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
          bottom: 1,
          right: 80,
          child: IconButton(
            icon: const Icon(Icons.camera_alt),
            iconSize: 32,
            color: redApp,
            onPressed: isLoading ? null : _pickAndUploadImage,
          ),
        ),
      ],
    );
  }
}
