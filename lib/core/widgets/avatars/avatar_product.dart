import 'dart:io';
import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:App_Tomaticos/core/services/image_service.dart';
import 'package:App_Tomaticos/core/widgets/dialogs/custom_alert_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarProduct extends StatefulWidget {
  final String? imageUrl;
  final void Function(String imageUrl) onUpLoad;
  final int productId;
  const AvatarProduct({
    super.key,
    required this.imageUrl,
    required this.onUpLoad,
    required this.productId,
  });

  @override
  State<AvatarProduct> createState() => _AvatarProductState();
}

class _AvatarProductState extends State<AvatarProduct> {
  File? _imageFile;
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  ///  **Mantiene la URL de la imagen actualizada**
  late String? _currentImageUrl = widget.imageUrl;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final bool confirm = await _confirmImageChange();
    if (!confirm) return;

    setState(() {
      isLoading = true;
    });

    final String fileName = '${widget.productId}';
    final String path = 'products/$fileName.jpg';

    try {
      _imageFile = await ImageService.compressImage(image, quality: 50);
      if (_imageFile == null) throw 'Error al comprimir la imagen';

      await supabase.storage.from('products').upload(
            path,
            _imageFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      final String imageUrl =
          "${supabase.storage.from('products').getPublicUrl(path)}?v=${DateTime.now().millisecondsSinceEpoch}";

      setState(() {
        _currentImageUrl = imageUrl; //  Actualiza la imagen al instante
      });

      widget.onUpLoad(imageUrl); // Notificar cambio

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen actualizada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la imagen: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Confirma si el usuario quiere cambiar la imagen
  Future<bool> _confirmImageChange() async {
    return await showDialog<bool>(
            context: context,
            builder: (context) => CustomAlertDialog(
                width: 300,
                height: 300,
                assetImage: './assets/images/camara.gif',
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

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 150,
      height: 140,
      child: Stack(
        children: [
          CircleAvatar(
            backgroundImage:
                (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                    ? CachedNetworkImageProvider(_currentImageUrl!)
                    : null,
            radius: 70,
            child: (_currentImageUrl == null || _currentImageUrl!.isEmpty)
                ? const Icon(Icons.image, size: 50, color: Colors.grey)
                : null,
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            top: 100,
            right: 2.5,
            child: IconButton(
              icon: const Icon(Icons.camera_alt),
              iconSize: 32,
              color: redApp,
              onPressed: isLoading ? null : _pickAndUploadImage,
            ),
          ),
        ],
      ),
    );
  }
}
