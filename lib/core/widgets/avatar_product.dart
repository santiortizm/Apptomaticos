import 'dart:io';

import 'package:apptomaticos/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarProduct extends StatefulWidget {
  const AvatarProduct(
      {super.key, required this.imageUrl, required this.onUpLoad});

  final String? imageUrl;
  final void Function(String imageUrl) onUpLoad;

  @override
  State<AvatarProduct> createState() => _AvatarProductState();
}

class _AvatarProductState extends State<AvatarProduct> {
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final supabase = Supabase.instance.client;

    return Stack(
      children: [
        if (widget.imageUrl != null)
          Center(
            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.imageUrl!),
              radius: 70,
            ),
          )
        else
          const Center(
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey,
              child: Center(
                child: Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 55, 53, 53),
                  size: 100,
                ),
              ),
            ),
          ),
        Container(
          padding: EdgeInsets.only(top: size.height * 0.14),
          alignment: const Alignment(0.3, 0),
          child: IconButton(
            icon: const Icon(Icons.camera_alt),
            iconSize: 32,
            color: redApp,
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);

              if (image != null) {
                setState(() {
                  _imageFile = File(image.path);
                });
              }
              final fileName = DateTime.now().millisecondsSinceEpoch.toString();
              final path = 'product/$fileName';
              await supabase.storage
                  .from('products')
                  .upload(path, _imageFile!)
                  .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Imagen subida correctamente'))));
              final imageUrl =
                  supabase.storage.from('products').getPublicUrl(path);
              widget.onUpLoad(imageUrl);
            },
          ),
        ),
      ],
    );
  }
}
