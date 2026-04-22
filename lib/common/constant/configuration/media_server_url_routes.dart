import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class MediaServerEndPoints {
  static const String uploadEP = '/upload';
  static const String bulkUploadEP = '/upload/bulk';
}

abstract class MediaServerUrls {
  static final String _baseUrl = dotenv.env['MEDIA_SERVER_URL']!;
  static final String _apiKey = dotenv.env['MEDIA_API_KEY']!;

  static Uri get baseUri => Uri.parse(_baseUrl);

  static String get apiKey => _apiKey;
}
