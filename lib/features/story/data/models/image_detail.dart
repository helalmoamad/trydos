  import 'dart:typed_data';

class ImageDetail {
 
    final int width;
    final int height;
    final Uint8List? bytes;
 
    ImageDetail({required this.width, required this.height, this.bytes});
  }