// To parse this JSON data, do
//
//     final mediaCount = mediaCountFromJson(jsonString);

import 'dart:convert';

MediaCount mediaCountFromJson(String str) =>
    MediaCount.fromJson(json.decode(str));

String mediaCountToJson(MediaCount data) => json.encode(data.toJson());

class MediaCount {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Data? data;

  MediaCount({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  MediaCount copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      MediaCount(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory MediaCount.fromJson(Map<String, dynamic> json) => MediaCount(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"],
        detailedError: json["detailed_error"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "isSuccessful": isSuccessful,
        "hasContent": hasContent,
        "code": code,
        "message": message,
        "detailed_error": detailedError,
        "data": data?.toJson(),
      };
}

class Data {
  final int? imageMessagesCount;
  final int? videoMessagesCount;
  final int? fileMessagesCount;

  Data({
    this.imageMessagesCount,
    this.videoMessagesCount,
    this.fileMessagesCount,
  });

  Data copyWith({
    int? imageMessagesCount,
    int? videoMessagesCount,
    int? fileMessagesCount,
  }) =>
      Data(
        imageMessagesCount: imageMessagesCount ?? this.imageMessagesCount,
        videoMessagesCount: videoMessagesCount ?? this.videoMessagesCount,
        fileMessagesCount: fileMessagesCount ?? this.fileMessagesCount,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        imageMessagesCount: json["image_messages_count"],
        videoMessagesCount: json["video_messages_count"],
        fileMessagesCount: json["file_messages_count"],
      );

  Map<String, dynamic> toJson() => {
        "image_messages_count": imageMessagesCount,
        "video_messages_count": videoMessagesCount,
        "file_messages_count": fileMessagesCount,
      };
}
