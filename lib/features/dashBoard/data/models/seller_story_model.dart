// To parse this JSON data, do
//
//     final sellerStoryModel = sellerStoryModelFromJson(jsonString);

import 'dart:convert';

SellerStoryModel sellerStoryModelFromJson(String str) =>
    SellerStoryModel.fromJson(json.decode(str));

String sellerStoryModelToJson(SellerStoryModel data) =>
    json.encode(data.toJson());

class SellerStoryModel {
  final int? id;
  final int? sellerId;
  final String? mediaKey;
  final String? mediaUrl;
  final String? mediaType;
  final String? link;
  final int? viewsCount;
  final String? createdAt;
  final String? expiresAt;
  final bool? isActive;

  SellerStoryModel({
    this.id,
    this.sellerId,
    this.mediaKey,
    this.mediaUrl,
    this.mediaType,
    this.link,
    this.viewsCount,
    this.createdAt,
    this.expiresAt,
    this.isActive,
  });

  SellerStoryModel copyWith({
    int? id,
    int? sellerId,
    String? mediaKey,
    String? mediaUrl,
    String? mediaType,
    String? link,
    int? viewsCount,
    String? createdAt,
    String? expiresAt,
    bool? isActive,
  }) => SellerStoryModel(
    id: id ?? this.id,
    sellerId: sellerId ?? this.sellerId,
    mediaKey: mediaKey ?? this.mediaKey,
    mediaUrl: mediaUrl ?? this.mediaUrl,
    mediaType: mediaType ?? this.mediaType,
    link: link ?? this.link,
    viewsCount: viewsCount ?? this.viewsCount,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
    isActive: isActive ?? this.isActive,
  );

  factory SellerStoryModel.fromJson(Map<String, dynamic> json) =>
      SellerStoryModel(
        id: json["id"],
        sellerId: json["seller_id"],
        mediaKey: json["key"] ?? json["media_key"],
        // The backend may expose the media under different names depending on
        // whether it is already resolved to a public url or still a raw key.
        mediaUrl: json["url"] ?? json["media_url"] ?? json["image"],
        mediaType: json["media_type"] ?? json["type"],
        link: json["link"],
        viewsCount: json["views_count"] ?? json["viewers"],
        createdAt: json["created_at"]?.toString(),
        expiresAt: json["expires_at"]?.toString(),
        isActive: json["is_active"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "seller_id": sellerId,
    "key": mediaKey,
    "url": mediaUrl,
    "media_type": mediaType,
    "link": link,
    "views_count": viewsCount,
    "created_at": createdAt,
    "expires_at": expiresAt,
    "is_active": isActive,
  };

  /// Extracts the stories list out of the standard dashBoard envelope
  /// (`{isSuccessful, hasContent, code, message, data: {stories: [...]}}`).
  /// Falls back to a bare list, or `data` being the list itself, so the parsing
  /// keeps working once the real endpoint shape is wired in.
  static List<SellerStoryModel> listFromResponse(dynamic response) {
    final dynamic payload = _decodeIfString(response);

    if (payload == null) return [];

    if (payload is List) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map((x) => SellerStoryModel.fromJson(x))
          .toList();
    }

    if (payload is Map<String, dynamic>) {
      final dynamic data = payload["data"] ?? payload;

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((x) => SellerStoryModel.fromJson(x))
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final dynamic stories = data["stories"] ?? data["items"];
        if (stories is List) {
          return stories
              .whereType<Map<String, dynamic>>()
              .map((x) => SellerStoryModel.fromJson(x))
              .toList();
        }
      }
    }

    return [];
  }

  /// Extracts a single story out of the standard dashBoard envelope.
  static SellerStoryModel fromResponse(dynamic response) {
    final dynamic payload = _decodeIfString(response);

    if (payload is Map<String, dynamic>) {
      final dynamic data = payload["data"] ?? payload;

      if (data is Map<String, dynamic>) {
        final dynamic story = data["story"] ?? data;
        if (story is Map<String, dynamic>) {
          return SellerStoryModel.fromJson(story);
        }
      }

      if (data is List) {
        final stories = SellerStoryModel.listFromResponse(data);
        if (stories.isNotEmpty) return stories.first;
      }
    }

    return SellerStoryModel();
  }

  static dynamic _decodeIfString(dynamic response) {
    if (response is String) {
      if (response.trim().isEmpty) return null;
      try {
        return json.decode(response);
      } catch (_) {
        return null;
      }
    }
    return response;
  }
}
