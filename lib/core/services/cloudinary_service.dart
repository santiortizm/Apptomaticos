import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_url_gen/transformation/transformation.dart';
import 'package:cloudinary_url_gen/transformation/resize/resize.dart';

class CloudinaryService {
  final Cloudinary cloudinary;

  CloudinaryService({required String cloudName})
      : cloudinary = Cloudinary.fromCloudName(cloudName: cloudName);

  /// Genera una URL optimizada con Cloudinary
  String getOptimizedImageUrl(String imageUrl,
      {int width = 300, int height = 300}) {
    return (cloudinary.image(imageUrl)
          ..transformation(Transformation()
            ..resize(Resize.fill()
              ..width(width)
              ..height(height))))
        .toString();
  }
}
