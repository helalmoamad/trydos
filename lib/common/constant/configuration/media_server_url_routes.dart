import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class MediaServerEndPoints {
  /// الخطوة الأولى: استخراج تذكرة رفع قصيرة العمر برمز دخول المستخدم.
  static const String ticketEP = '/gated/ticket';

  /// الخطوة الثانية: الرفع بالتذكرة عبر ترويسة `X-Upload-Ticket`.
  static const String uploadEP = '/gated/upload';
  static const String bulkUploadEP = '/gated/upload/bulk';
  static const String excelUploadEP = '/gated/upload/excel';
  static const String chatUploadFileEP = '/gated/chat/upload_file';
}

abstract class MediaServerUrls {
  static final String _baseUrl = dotenv.env['MEDIA_SERVER_URL']!;
  static final String _apiKey = dotenv.env['MEDIA_API_KEY']!;

  static Uri get baseUri => Uri.parse(_baseUrl);

  static String get apiKey => _apiKey;

  /// عمر التذكرة: 120 ثانية، ولمرّة واحدة فقط. أي إعادة محاولة تتطلّب
  /// استخراج تذكرة جديدة.
  static const Duration ticketTtl = Duration(seconds: 120);

  /// ترويسة تمرير التذكرة في طلبات الرفع.
  static const String ticketHeader = 'X-Upload-Ticket';
}
