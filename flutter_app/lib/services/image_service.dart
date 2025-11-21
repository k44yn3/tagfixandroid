import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageService {
  /// Resizes the given image bytes to the specified width and height.
  /// Returns the resized image as JPEG bytes.
  Future<List<int>?> resizeImage(List<int> imageBytes, {int width = 500, int height = 500}) async {
    try {
      // Decode the image
      final image = img.decodeImage(Uint8List.fromList(imageBytes));
      if (image == null) return null;

      // Resize the image (Crop to square)
      final resized = img.copyResizeCropSquare(image, size: width);

      // Encode back to JPEG
      return img.encodeJpg(resized);
    } catch (e) {
      print('Error resizing image: $e');
      return null;
    }
  }
}
