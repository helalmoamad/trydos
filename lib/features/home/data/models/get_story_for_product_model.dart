// To parse this JSON data, do
//
//     final getStoryForProductModel = getStoryForProductModelFromJson(jsonString);

import 'dart:convert';

GetStoryForProductModel getStoryForProductModelFromJson(String str) =>
    GetStoryForProductModel.fromJson(json.decode(str));

String getStoryForProductModelToJson(GetStoryForProductModel data) =>
    json.encode(data.toJson());

class GetStoryForProductModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Data? data;

  GetStoryForProductModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GetStoryForProductModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      GetStoryForProductModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory GetStoryForProductModel.fromJson(Map<String, dynamic> json) =>
      GetStoryForProductModel(
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
  final int? currentPage;
  final List<Story>? story;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link>? links;
  final dynamic nextPageUrl;
  final String? path;
  final int? perPage;
  final dynamic prevPageUrl;
  final int? to;
  final int? total;

  Data({
    this.currentPage,
    this.story,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  Data copyWith({
    int? currentPage,
    List<Story>? data,
    String? firstPageUrl,
    int? from,
    int? lastPage,
    String? lastPageUrl,
    List<Link>? links,
    dynamic nextPageUrl,
    String? path,
    int? perPage,
    dynamic prevPageUrl,
    int? to,
    int? total,
  }) =>
      Data(
        currentPage: currentPage ?? this.currentPage,
        story: data ?? this.story,
        firstPageUrl: firstPageUrl ?? this.firstPageUrl,
        from: from ?? this.from,
        lastPage: lastPage ?? this.lastPage,
        lastPageUrl: lastPageUrl ?? this.lastPageUrl,
        links: links ?? this.links,
        nextPageUrl: nextPageUrl ?? this.nextPageUrl,
        path: path ?? this.path,
        perPage: perPage ?? this.perPage,
        prevPageUrl: prevPageUrl ?? this.prevPageUrl,
        to: to ?? this.to,
        total: total ?? this.total,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        currentPage: json["current_page"],
        story: json["data"] == null
            ? []
            : List<Story>.from(json["data"]!.map((x) => Story.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: json["links"] == null
            ? []
            : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": story == null
            ? []
            : List<dynamic>.from(story!.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": links == null
            ? []
            : List<dynamic>.from(links!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class Story {
  final int? id;
  final dynamic cutVideoName;
  final dynamic cutVideoPath;
  final dynamic fullVideoName;
  final dynamic fullVideoPath;
  final dynamic storageVideoPath;
  final int? userId;
  final int? isPhoto;
  final int? isVideo;
  final String? photoPath;
  final int? productId;
  final dynamic file;
  final bool? isSeen;
  final int? viewersCount;
  final List<dynamic>? media;

  Story({
    this.id,
    this.cutVideoName,
    this.cutVideoPath,
    this.fullVideoName,
    this.fullVideoPath,
    this.storageVideoPath,
    this.userId,
    this.isPhoto,
    this.isVideo,
    this.photoPath,
    this.productId,
    this.file,
    this.isSeen,
    this.viewersCount,
    this.media,
  });

  Story copyWith({
    int? id,
    dynamic cutVideoName,
    dynamic cutVideoPath,
    dynamic fullVideoName,
    dynamic fullVideoPath,
    dynamic storageVideoPath,
    int? userId,
    int? isPhoto,
    int? isVideo,
    String? photoPath,
    int? productId,
    dynamic file,
    bool? isSeen,
    int? viewersCount,
    List<dynamic>? media,
  }) =>
      Story(
        id: id ?? this.id,
        cutVideoName: cutVideoName ?? this.cutVideoName,
        cutVideoPath: cutVideoPath ?? this.cutVideoPath,
        fullVideoName: fullVideoName ?? this.fullVideoName,
        fullVideoPath: fullVideoPath ?? this.fullVideoPath,
        storageVideoPath: storageVideoPath ?? this.storageVideoPath,
        userId: userId ?? this.userId,
        isPhoto: isPhoto ?? this.isPhoto,
        isVideo: isVideo ?? this.isVideo,
        photoPath: photoPath ?? this.photoPath,
        productId: productId ?? this.productId,
        file: file ?? this.file,
        isSeen: isSeen ?? this.isSeen,
        viewersCount: viewersCount ?? this.viewersCount,
        media: media ?? this.media,
      );

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json["id"],
        cutVideoName: json["cut_video_name"],
        cutVideoPath: json["cut_video_path"],
        fullVideoName: json["full_video_name"],
        fullVideoPath: json["full_video_path"],
        storageVideoPath: json["storage_video_path"],
        userId: json["user_id"],
        isPhoto: json["is_photo"],
        isVideo: json["is_video"],
        photoPath: json["photo_path"],
        productId: json["product_id"],
        file: json["file"],
        isSeen: json["is_seen"],
        viewersCount: json["viewers_count"],
        media: json["media"] == null
            ? []
            : List<dynamic>.from(json["media"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cut_video_name": cutVideoName,
        "cut_video_path": cutVideoPath,
        "full_video_name": fullVideoName,
        "full_video_path": fullVideoPath,
        "storage_video_path": storageVideoPath,
        "user_id": userId,
        "is_photo": isPhoto,
        "is_video": isVideo,
        "photo_path": photoPath,
        "product_id": productId,
        "file": file,
        "is_seen": isSeen,
        "viewers_count": viewersCount,
        "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x)),
      };
}

class Link {
  final String? url;
  final String? label;
  final bool? active;

  Link({
    this.url,
    this.label,
    this.active,
  });

  Link copyWith({
    String? url,
    String? label,
    bool? active,
  }) =>
      Link(
        url: url ?? this.url,
        label: label ?? this.label,
        active: active ?? this.active,
      );

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}
