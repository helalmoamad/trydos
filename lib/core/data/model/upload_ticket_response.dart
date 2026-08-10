import 'dart:convert';

UploadTicketResponseModel uploadTicketResponseModelFromJson(String str) =>
    UploadTicketResponseModel.fromJson(json.decode(str));

String uploadTicketResponseModelToJson(UploadTicketResponseModel data) =>
    json.encode(data.toJson());

/// استجابة `POST /gated/ticket`.
///
/// التذكرة **لمرّة واحدة** وعمرها [expiresIn] ثانية (120 افتراضاً)، ويجب
/// استخراجها مباشرة قبل الرفع. أي رفع فاشل أو منقطع يستهلكها، وإعادة المحاولة
/// تتطلّب تذكرة جديدة.
class UploadTicketResponseModel {
  const UploadTicketResponseModel({this.ticket, this.expiresIn, this.maxBytes});

  final String? ticket;

  /// عمر التذكرة بالثواني.
  final int? expiresIn;

  /// الحدّ الأعلى لحجم الملف بالبايت:
  /// 104857600 (100 ميغابايت) افتراضاً، و10485760 (10 ميغابايت) عند `story`.
  final int? maxBytes;

  bool get isValid => (ticket ?? '').isNotEmpty;

  factory UploadTicketResponseModel.fromJson(Map<String, dynamic> json) =>
      UploadTicketResponseModel(
        ticket: json["ticket"],
        expiresIn: json["expires_in"],
        maxBytes: json["max_bytes"],
      );

  Map<String, dynamic> toJson() => {
    "ticket": ticket,
    "expires_in": expiresIn,
    "max_bytes": maxBytes,
  };
}
