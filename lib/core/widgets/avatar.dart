import 'package:apptomaticos/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.imageUrl, required this.onUpLoad});

  final String? imageUrl;
  final void Function(String imageUrl) onUpLoad;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final supabase = Supabase.instance.client;

    return Stack(
      children: [
        if (imageUrl != null)
          Center(
            child: CircleAvatar(
              backgroundImage: NetworkImage(imageUrl!),
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
              if (image == null) {
                return;
              }
              final imageBytes = await image.readAsBytes();
              final userId = supabase.auth.currentUser!.id;
              final imagePath = '/$userId/profile';
              await supabase.storage
                  .from('profiles')
                  .uploadBinary(imagePath, imageBytes);
              final imageUrl =
                  supabase.storage.from('profiles').getPublicUrl(imagePath);
              onUpLoad(imageUrl);
            },
          ),
        ),
      ],
    );
  }
}
