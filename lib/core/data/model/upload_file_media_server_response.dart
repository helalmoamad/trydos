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

  UploadFileMediaServerResponseModel({
    this.key,
    this.size,
    this.type,
    this.url,
    this.durationSeconds,
    this.variants,
  });

  UploadFileMediaServerResponseModel copyWith({
    String? key,
    int? size,
    String? type,
    double? durationSeconds,
    String? url,
    MediaServerVideoVariants? variants,
  }) => UploadFileMediaServerResponseModel(
    key: key ?? this.key,
    size: size ?? this.size,
    type: type ?? this.type,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    url: url ?? this.url,
    variants: variants ?? this.variants,
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
  );

  Map<String, dynamic> toJson() => {
    "key": key,
    "size": size,
    "type": type,
    "url": url,
    "durationSeconds": durationSeconds,
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
