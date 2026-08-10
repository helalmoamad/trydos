import 'dart:convert';

UploadFileMediaServerResponseModel uploadFileMediaServerResponseModelFromJson(
  String str,
) => UploadFileMediaServerResponseModel.fromJson(json.decode(str));

String uploadFileMediaServerResponseModelToJson(
  UploadFileMediaServerResponseModel data,
) => json.encode(data.toJson());

class UploadFileMediaServerResponseModel {
  String? key;
  int? size;
  double? durationSeconds;
  String? type;
  String? url;
  MediaServerVideoVariants? variants;
  MediaServerStoryVariants? story;

  UploadFileMediaServerResponseModel({
    this.key,
    this.size,
    this.type,
    this.url,
    this.durationSeconds,
    this.variants,
    this.story,
  });

  /// المسار الفرعي المكافئ لـ `sub_path` في نقاط الرفع القديمة.
  ///
  /// خادم الميديا يعيد `url` بصيغة `/image/upload/customers/profile/uuid.jpg`،
  /// بينما يخزّن خادم السوق المسار الفرعي وحده (`customers/profile/uuid.jpg`)
  /// ويركّب الرابط الكامل عند الإرجاع — فنقتطع بادئة التسليم
  /// (`/image/upload/` أو `/video/upload/` …) ليبقى العقد كما كان.
  String? get subPath {
    final String? source = url;
    if (source == null || source.isEmpty) return source;

    const String marker = '/upload/';
    final int markerIndex = source.indexOf(marker);
    if (markerIndex == -1) {
      // شكل غير متوقّع: نعيده بلا الشرطة البادئة فقط
      return source.startsWith('/') ? source.substring(1) : source;
    }
    return source.substring(markerIndex + marker.length);
  }

  UploadFileMediaServerResponseModel copyWith({
    String? key,
    int? size,
    String? type,
    double? durationSeconds,
    String? url,
    MediaServerVideoVariants? variants,
    MediaServerStoryVariants? story,
  }) => UploadFileMediaServerResponseModel(
    key: key ?? this.key,
    size: size ?? this.size,
    type: type ?? this.type,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    url: url ?? this.url,
    variants: variants ?? this.variants,
    story: story ?? this.story,
  );

  factory UploadFileMediaServerResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => UploadFileMediaServerResponseModel(
    key: json["key"],
    size: json["size"],
    type: json["type"],
    durationSeconds: json["durationSeconds"] != null
        ? json["durationSeconds"].toDouble()
        : null,
    url: json["url"],
    variants: json["variants"] != null
        ? MediaServerVideoVariants.fromJson(json["variants"])
        : null,
    story: json["story"] != null
        ? MediaServerStoryVariants.fromJson(json["story"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "key": key,
    "size": size,
    "type": type,
    "url": url,
    "durationSeconds": durationSeconds,
    "variants": variants?.toJson(),
    "story": story?.toJson(),
  };
}

/// يرد فقط حين تُستخرَج التذكرة بـ `story: true` (فيديو الستوري).
class MediaServerStoryVariants {
  MediaServerStoryVariants({this.enabled, this.variants});

  final bool? enabled;
  final MediaServerVideoVariants? variants;

  factory MediaServerStoryVariants.fromJson(Map<String, dynamic> json) =>
      MediaServerStoryVariants(
        enabled: json["enabled"],
        variants: json["variants"] != null
            ? MediaServerVideoVariants.fromJson(json["variants"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "enabled": enabled,
    "variants": variants?.toJson(),
  };
}

class MediaServerVideoVariants {
  String? full;
  String? preview;
  String? snapshot;

  MediaServerVideoVariants({this.full, this.preview, this.snapshot});

  factory MediaServerVideoVariants.fromJson(Map<String, dynamic> json) =>
      MediaServerVideoVariants(
        full: json["full"],
        preview: json["preview"],
        snapshot: json["snapshot"],
      );

  Map<String, dynamic> toJson() => {
    "full": full,
    "preview": preview,
    "snapshot": snapshot,
  };
}
