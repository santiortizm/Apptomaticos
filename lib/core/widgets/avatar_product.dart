import 'dart:io';
import 'package:apptomaticos/core/constants/colors.dart';
import 'package:apptomaticos/core/services/image_service.dart'; // 🔥 Importar servicio de compresión
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
  bool isLoading = false; // Para feedback visual

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      print('No se seleccionó ninguna imagen.');
      return;
    }

    final bool confirm = await _confirmImageChange();
    if (!confirm) return;

    setState(() {
      isLoading = true;
    });

    final String fileName = '${widget.productId}';
    final String path = 'product/$fileName';

    try {
      print('Imagen seleccionada: ${image.path}');

      // 🔥 Comprimir la imagen antes de subirla
      _imageFile = await ImageService.compressImage(image, quality: 50);

      if (_imageFile == null) {
        throw 'Error al comprimir la imagen';
      }

      print('Imagen comprimida: ${_imageFile!.path}');

      // 1️⃣ **Subir la nueva imagen con `upsert: true` para sobrescribir si ya existe**
      print('Subiendo nueva imagen...');
      await supabase.storage.from('products').upload(
            path,
            _imageFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      // 2️⃣ **Obtener la URL pública de la imagen**
      final String imageUrl =
          supabase.storage.from('products').getPublicUrl(path);
      print('Imagen subida con éxito: $imageUrl');

      // 3️⃣ **Actualizar la URL de la imagen en la tabla `productos`**
      final response = await supabase
          .from('productos')
          .update({'imagen': imageUrl})
          .eq('idProducto', widget.productId)
          .select(); // 🔥 Agregar .select() para obtener la fila actualizada

      print('Respuesta de actualización en DB: $response');

      // 4️⃣ **Actualizar la UI**
      widget.onUpLoad(imageUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen actualizada correctamente')),
      );
    } catch (e) {
      print('Error al subir la imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la imagen: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Muestra un diálogo de confirmación antes de cambiar la imagen.
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
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Center(
          child: CircleAvatar(
            backgroundImage:
                (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                    ? NetworkImage(widget.imageUrl!)
                    : null,
            radius: 70,
            child: (widget.imageUrl == null || widget.imageUrl!.isEmpty)
                ? const Icon(Icons.image, size: 50, color: Colors.grey)
                : null,
          ),
        ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
        Container(
          padding: EdgeInsets.only(top: size.height * 0.14),
          alignment: const Alignment(0.3, 0),
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
