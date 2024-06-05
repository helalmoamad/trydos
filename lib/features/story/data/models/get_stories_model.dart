// To parse this JSON data, do
//
//     final getStoriesModel = getStoriesModelFromJson(jsonString);

import 'dart:convert';

import 'package:trydos/features/story/data/models/image_detail.dart';
import 'package:video_player/video_player.dart';

GetStoriesModel getStoriesModelFromJson(String str) =>
    GetStoriesModel.fromJson(json.decode(str));

String getStoriesModelToJson(GetStoriesModel data) =>
    json.encode(data.toJson());

class GetStoriesModel {
  bool? isSuccessful;
  bool? hasContent;
  int? code;
  dynamic message;
  dynamic detailedError;
  Data? data;

  GetStoriesModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GetStoriesModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      GetStoriesModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory GetStoriesModel.fromJson(Map<String, dynamic> json) =>
      GetStoriesModel(
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
  int? currentPage;
  List<CollectionStoryModel>? collections;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Link>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;

  Data({
    this.currentPage,
    this.collections,
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
    List<CollectionStoryModel>? collections,
    String? firstPageUrl,
    int? from,
    int? lastPage,
    String? lastPageUrl,
    List<Link>? links,
    String? nextPageUrl,
    String? path,
    int? perPage,
    dynamic prevPageUrl,
    int? to,
    int? total,
  }) =>
      Data(
        currentPage: currentPage ?? this.currentPage,
        collections: collections ?? this.collections,
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
        collections: json["data"] == null
            ? []
            : List<CollectionStoryModel>.from(
                json["data"]!.map((x) => CollectionStoryModel.fromJson(x))),
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
        "data": collections == null
            ? []
            : List<dynamic>.from(collections!.map((x) => x.toJson())),
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

enum SelectedStoriesStatus { init, loading, success, failure }

class CollectionStoryModel {
  int? id;
  String? mobilePhone;
  dynamic photoPath;
  String? name;
  dynamic username;
  dynamic originalUserId;
  dynamic email;
  List<Story>? stories;
  List<dynamic>? media;
  SelectedStoriesStatus selectedStoriesStatusForCollection;
  ImageDetail? imageDetail;

  CollectionStoryModel({
    this.id,
    this.mobilePhone,
    this.photoPath,
    this.name,
    this.imageDetail,
    this.selectedStoriesStatusForCollection = SelectedStoriesStatus.init,
    this.username,
    this.originalUserId,
    this.email,
    this.stories,
    this.media,
  });

  CollectionStoryModel copyWith({
    int? id,
    String? mobilePhone,
    dynamic photoPath,
    String? name,
    dynamic username,
    ImageDetail? imageDetail,
    SelectedStoriesStatus? selectedStoriesStatusForCollection,
    dynamic originalUserId,
    dynamic email,
    List<Story>? stories,
    List<dynamic>? media,
  }) =>
      CollectionStoryModel(
        id: id ?? this.id,
        mobilePhone: mobilePhone ?? this.mobilePhone,
        selectedStoriesStatusForCollection:
            selectedStoriesStatusForCollection ??
                this.selectedStoriesStatusForCollection,
        imageDetail: imageDetail ?? this.imageDetail,
        photoPath: photoPath ?? this.photoPath,
        name: name ?? this.name,
        username: username ?? this.username,
        originalUserId: originalUserId ?? this.originalUserId,
        email: email ?? this.email,
        stories: stories ?? this.stories,
        media: media ?? this.media,
      );

  factory CollectionStoryModel.fromJson(Map<String, dynamic> json) =>
      CollectionStoryModel(
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
        media: json["media"] == null
            ? []
            : List<dynamic>.from(json["media"]!.map((x) => x)),
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
        "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x)),
      };
}

class Story {
  int? height;
  int? width;
  int? id;
  dynamic cutVideoName;
  dynamic cutVideoPath;
  dynamic fullVideoName;
  String? fullVideoPath;
  dynamic storageVideoPath;
  int? userId;
  int? isPhoto;
  int? isVideo;
  String? photoPath;
  dynamic file;
  bool? isSeen;
  int? viewersCount;
  List<dynamic>? media;
  bool isInitialStory;
  Story({
    this.height,
    this.width,
    this.isInitialStory = false,
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
    this.file,
    this.isSeen,
    this.viewersCount,
    this.media,
  });

  Story copyWith({
    int? width,
    int? height,
    bool? isInitialStory,
    int? id,
    dynamic cutVideoName,
    dynamic cutVideoPath,
    dynamic fullVideoName,
    String? fullVideoPath,
    dynamic storageVideoPath,
    int? userId,
    int? isPhoto,
    int? isVideo,
    String? photoPath,
    dynamic file,
    bool? isSeen,
    int? viewersCount,
    List<dynamic>? media,
  }) =>
      Story(
        height: height ?? this.height,
        width: width ?? this.width,
        isInitialStory: isInitialStory ?? this.isInitialStory,
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
        "file": file,
        "is_seen": isSeen,
        "viewers_count": viewersCount,
        "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x)),
      };
}

class Link {
  String? url;
  String? label;
  bool? active;

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
