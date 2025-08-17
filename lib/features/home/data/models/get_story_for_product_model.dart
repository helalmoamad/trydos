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
  final List<Datum>? data;
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
    this.data,
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
    List<Datum>? data,
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
        data: data ?? this.data,
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
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
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
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
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

class Datum {
  final int? id;
  final String? mobilePhone;
  final dynamic photoPath;
  final String? name;
  final String? username;
  final int? originalUserId;
  final String? email;
  final List<Story>? stories;

  Datum({
    this.id,
    this.mobilePhone,
    this.photoPath,
    this.name,
    this.username,
    this.originalUserId,
    this.email,
    this.stories,
  });

  Datum copyWith({
    int? id,
    String? mobilePhone,
    dynamic photoPath,
    String? name,
    String? username,
    int? originalUserId,
    String? email,
    List<Story>? stories,
  }) =>
      Datum(
        id: id ?? this.id,
        mobilePhone: mobilePhone ?? this.mobilePhone,
        photoPath: photoPath ?? this.photoPath,
        name: name ?? this.name,
        username: username ?? this.username,
        originalUserId: originalUserId ?? this.originalUserId,
        email: email ?? this.email,
        stories: stories ?? this.stories,
      );

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        mobilePhone: json["mobile_phone"],
        photoPath: json["photo_path"],
        name: json["name"],
        username: json["username"],
        originalUserId: json["original_user_id"],
        email: json["email"],
        stories: json["stories"] == null
            ? []
            : List<Story>.from(json["stories"]!.map((x) => Story.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "mobile_phone": mobilePhone,
        "photo_path": photoPath,
        "name": name,
        "username": username,
        "original_user_id": originalUserId,
        "email": email,
        "stories": stories == null
            ? []
            : List<dynamic>.from(stories!.map((x) => x.toJson())),
      };
}

class Story {
  final int? id;
  final dynamic cutVideoName;
  final dynamic cutVideoPath;
  final dynamic fullVideoName;
  final dynamic fullVideoPath;
  final dynamic storageVideoPath;
  final dynamic link;
  final int? userId;
  final DateTime? createdAt;
  final int? isPhoto;
  final int? isVideo;
  final String? photoPath;
  final int? productId;
  final dynamic orderDetailId;
  final int? status;
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
    this.link,
    this.userId,
    this.createdAt,
    this.isPhoto,
    this.isVideo,
    this.photoPath,
    this.productId,
    this.orderDetailId,
    this.status,
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
    dynamic link,
    int? userId,
    DateTime? createdAt,
    int? isPhoto,
    int? isVideo,
    String? photoPath,
    int? productId,
    dynamic orderDetailId,
    int? status,
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
        link: link ?? this.link,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        isPhoto: isPhoto ?? this.isPhoto,
        isVideo: isVideo ?? this.isVideo,
        photoPath: photoPath ?? this.photoPath,
        productId: productId ?? this.productId,
        orderDetailId: orderDetailId ?? this.orderDetailId,
        status: status ?? this.status,
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
        link: json["link"],
        userId: json["user_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        isPhoto: json["is_photo"],
        isVideo: json["is_video"],
        photoPath: json["photo_path"],
        productId: json["product_id"],
        orderDetailId: json["order_detail_id"],
        status: json["status"],
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
        "link": link,
        "user_id": userId,
        "created_at": createdAt?.toIso8601String(),
        "is_photo": isPhoto,
        "is_video": isVideo,
        "photo_path": photoPath,
        "product_id": productId,
        "order_detail_id": orderDetailId,
        "status": status,
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
