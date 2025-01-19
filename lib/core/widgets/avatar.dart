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
    final supabase = Supabase.instance.client;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          width: 150,
          height: 150,
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                )
              : Container(
                  color: Colors.grey,
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 100,
                      color: Color.fromARGB(255, 53, 50, 50),
                    ),
                  ),
                ),
        ),
        MaterialButton(
          color: redApp,
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
// Pick an image.
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
          child: const Text('Subir imagen'),
        )
      ],
    );
  }
}
