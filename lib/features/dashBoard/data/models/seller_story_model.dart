// To parse this JSON data, do
//
//     final sellerStoryModel = sellerStoryModelFromJson(jsonString);

import 'dart:convert';

SellerStoryModel sellerStoryModelFromJson(String str) =>
    SellerStoryModel.fromJson(json.decode(str));

String sellerStoryModelToJson(SellerStoryModel data) =>
    json.encode(data.toJson());

/// A single seller (shop) story as returned by
/// `{STORIES_API}/api/v1/stories/seller-stories`.
///
/// The stories server uses the same story shape as the user stories feature
/// (`photo_path` / `full_video_path` / `is_video` / `viewers_count` ...), so
/// the json keys below mirror `Story` in
/// `features/story/data/models/get_stories_model.dart`.
class SellerStoryModel {
  final int? id;

  /// The logged-in user that published the story (NOT the shop).
  final int? userId;

  /// The shop the story belongs to.
  final int? sellerId;
  final String? photoPath;
  final String? fullVideoPath;
  final String? cutVideoPath;

  /// `1` / `0` as sent by the backend.
  final int? isVideo;
  final int? isPhoto;
  final String? link;
  final String? productId;
  final String? productSlug;

  /// Only present when the backend expands the linked product.
  final String? productName;
  final String? productImage;
  final int? viewersCount;
  final String? createdAt;
  final int? videoDurationInSecond;

  SellerStoryModel({
    this.id,
    this.userId,
    this.sellerId,
    this.photoPath,
    this.fullVideoPath,
    this.cutVideoPath,
    this.isVideo,
    this.isPhoto,
    this.link,
    this.productId,
    this.productSlug,
    this.productName,
    this.productImage,
    this.viewersCount,
    this.createdAt,
    this.videoDurationInSecond,
  });

  /// True when the story media is a video (used to pick the right badge).
  bool get isVideoStory {
    if (isVideo != null) return isVideo == 1;
    if (isPhoto != null) return isPhoto == 0;
    // No explicit flag: fall back to "a video path was returned".
    return (fullVideoPath ?? cutVideoPath) != null;
  }

  /// The url to render: the video for a video story, the photo otherwise.
  String? get mediaUrl => isVideoStory
      ? (fullVideoPath ?? cutVideoPath ?? photoPath)
      : (photoPath ?? fullVideoPath);

  bool get hasLinkedProduct =>
      (productId != null && productId!.isNotEmpty) ||
      (productSlug != null && productSlug!.isNotEmpty);

  SellerStoryModel copyWith({
    int? id,
    int? userId,
    int? sellerId,
    String? photoPath,
    String? fullVideoPath,
    String? cutVideoPath,
    int? isVideo,
    int? isPhoto,
    String? link,
    String? productId,
    String? productSlug,
    String? productName,
    String? productImage,
    int? viewersCount,
    String? createdAt,
    int? videoDurationInSecond,
  }) => SellerStoryModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    sellerId: sellerId ?? this.sellerId,
    photoPath: photoPath ?? this.photoPath,
    fullVideoPath: fullVideoPath ?? this.fullVideoPath,
    cutVideoPath: cutVideoPath ?? this.cutVideoPath,
    isVideo: isVideo ?? this.isVideo,
    isPhoto: isPhoto ?? this.isPhoto,
    link: link ?? this.link,
    productId: productId ?? this.productId,
    productSlug: productSlug ?? this.productSlug,
    productName: productName ?? this.productName,
    productImage: productImage ?? this.productImage,
    viewersCount: viewersCount ?? this.viewersCount,
    createdAt: createdAt ?? this.createdAt,
    videoDurationInSecond:
        videoDurationInSecond ?? this.videoDurationInSecond,
  );

  factory SellerStoryModel.fromJson(Map<String, dynamic> json) {
    final dynamic product = json["product"];
    final Map<String, dynamic>? productJson = product is Map<String, dynamic>
        ? product
        : null;

    return SellerStoryModel(
      id: _toInt(json["id"]),
      userId: _toInt(json["user_id"]),
      sellerId: _toInt(json["seller_id"]),
      photoPath: _toStringOrNull(json["photo_path"]),
      fullVideoPath: _toStringOrNull(json["full_video_path"]),
      cutVideoPath: _toStringOrNull(json["cut_video_path"]),
      isVideo: _toInt(json["is_video"]),
      isPhoto: _toInt(json["is_photo"]),
      link: _toStringOrNull(json["link"]),
      productId: _toStringOrNull(json["product_id"] ?? productJson?["id"]),
      productSlug: _toStringOrNull(
        json["product_slug"] ?? productJson?["slug"],
      ),
      productName: _toStringOrNull(json["product_name"] ?? productJson?["name"]),
      productImage: _toStringOrNull(
        json["product_image"] ?? productJson?["image"],
      ),
      viewersCount: _toInt(json["viewers_count"] ?? json["viewers"]),
      createdAt: _toStringOrNull(json["created_at"]),
      videoDurationInSecond: _toInt(json["video_duration_in_second"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "seller_id": sellerId,
    "photo_path": photoPath,
    "full_video_path": fullVideoPath,
    "cut_video_path": cutVideoPath,
    "is_video": isVideo,
    "is_photo": isPhoto,
    "link": link,
    "product_id": productId,
    "product_slug": productSlug,
    "product_name": productName,
    "product_image": productImage,
    "viewers_count": viewersCount,
    "created_at": createdAt,
    "video_duration_in_second": videoDurationInSecond,
  };

  /// Extracts the stories list out of the stories-server envelope.
  ///
  /// The list endpoint may return the array at `data.data` (paginated),
  /// `data.stories`, or `data` itself, and the entries may either be stories
  /// or groups carrying a nested `stories[]` — all of those are flattened here.
  static List<SellerStoryModel> listFromResponse(dynamic response) {
    final dynamic payload = _decodeIfString(response);

    if (payload == null) return [];

    if (payload is List) return _flatten(payload);

    if (payload is Map<String, dynamic>) {
      final dynamic data = payload["data"] ?? payload;

      if (data is List) return _flatten(data);

      if (data is Map<String, dynamic>) {
        final dynamic stories = data["data"] ?? data["stories"] ?? data["items"];
        if (stories is List) return _flatten(stories);
        // A single story returned directly under `data`.
        if (data["id"] != null) return [SellerStoryModel.fromJson(data)];
      }
    }

    return [];
  }

  /// Extracts a single story out of the stories-server envelope.
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
        final stories = _flatten(data);
        if (stories.isNotEmpty) return stories.first;
      }
    }

    return SellerStoryModel();
  }

  /// Maps a list that holds either stories or groups of stories.
  static List<SellerStoryModel> _flatten(List<dynamic> entries) {
    final List<SellerStoryModel> stories = [];

    for (final entry in entries) {
      if (entry is! Map<String, dynamic>) continue;

      final dynamic nested = entry["stories"];
      if (nested is List) {
        stories.addAll(_flatten(nested));
      } else {
        stories.add(SellerStoryModel.fromJson(entry));
      }
    }

    return stories;
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

  /// The backend is inconsistent about sending ids/counters as int or String.
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is bool) return value ? 1 : 0;
    return int.tryParse(value.toString());
  }

  static String? _toStringOrNull(dynamic value) {
    if (value == null) return null;
    final asString = value.toString();
    return asString.isEmpty ? null : asString;
  }
}
