import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageService {
  /// Comprime la imagen antes de subirla a Supabase
  static Future<File?> compressImage(XFile imageFile,
      {int quality = 50}) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) return null;

      //  Redimensionar la imagen (opcional)
      final img.Image resized = img.copyResize(image,
          width: 800); //  Cambia el tamaño si es necesario

      //  Comprimir la imagen
      final Uint8List compressedBytes =
          img.encodeJpg(resized, quality: quality);

      //  Guardar la imagen comprimida en un archivo temporal
      final File compressedFile = File('${imageFile.path}_compressed.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      return null;
    }
  }
}
