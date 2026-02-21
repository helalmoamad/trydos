  import 'dart:typed_data';

class ChatImageDetail {
 
    final int width;
    final int height;
    final Uint8List? bytes;

    ChatImageDetail({required this.width, required this.height, this.bytes});
  }