import 'dart:convert';

BulkUploadResponseModel bulkUploadResponseModelFromJson(String str) =>
    BulkUploadResponseModel.fromJson(json.decode(str));

String bulkUploadResponseModelToJson(BulkUploadResponseModel data) =>
    json.encode(data.toJson());

/// استجابة `POST /gated/upload/bulk` — صور فقط، والفيديوهات تُتخطّى وتُبلَّغ.
///
/// الخادم يعيد `url` مفرداً عند تخزين صورة واحدة، و`urls` عند تخزين أكثر من
/// صورة — ولذلك يوحّد هذا النموذج الحالتين في [urls].
class BulkUploadResponseModel {
  const BulkUploadResponseModel({this.urls = const [], this.skipped = const []});

  final List<String> urls;
  final List<SkippedUploadFile> skipped;

  factory BulkUploadResponseModel.fromJson(Map<String, dynamic> json) {
    final List<String> urls = <String>[];

    // صورة واحدة ⇒ { "url": "uuid.png" }
    if (json["url"] != null) {
      urls.add(json["url"].toString());
    }
    // عدّة صور ⇒ { "urls": [...] }
    if (json["urls"] is List) {
      urls.addAll((json["urls"] as List).map((e) => e.toString()));
    }

    return BulkUploadResponseModel(
      urls: urls,
      skipped: json["skipped"] is List
          ? (json["skipped"] as List)
                .map((e) => SkippedUploadFile.fromJson(e))
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    "urls": urls,
    "skipped": skipped.map((e) => e.toJson()).toList(),
  };
}

/// ملف تخطّاه الخادم في الرفع الجماعي (فيديو مثلاً).
class SkippedUploadFile {
  const SkippedUploadFile({this.filename, this.reason});

  final String? filename;
  final String? reason;

  factory SkippedUploadFile.fromJson(Map<String, dynamic> json) =>
      SkippedUploadFile(
        filename: json["filename"],
        reason: json["reason"],
      );

  Map<String, dynamic> toJson() => {"filename": filename, "reason": reason};
}
