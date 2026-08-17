// To parse this JSON data, do
//
//     final refreshStoriesTokenResponseModel = refreshStoriesTokenResponseModelFromJson(jsonString);

import 'dart:convert';

/// Answer of `POST /api/v1/auth/refresh-token` on the **stories** server.
///
/// This response does **not** use the `{isSuccessful, hasContent, code, data}`
/// envelope that every other stories endpoint returns — the tokens sit at the
/// root of the body. That is why it has its own model instead of reusing
/// `LoginToStoriesResponseModel`, whose `data` field would always be `null`
/// here.
///
/// The body carries the same pair twice: once inside `user` in camelCase
/// (`accessToken` / `refreshToken`) and once at the root in snake_case
/// (`access_token` / `refresh_token`). The root pair is the one read here; the
/// copy inside `user` is kept in [StoriesTokenUser] so nothing is silently
/// dropped.
RefreshStoriesTokenResponseModel refreshStoriesTokenResponseModelFromJson(
  String str,
) => RefreshStoriesTokenResponseModel.fromJson(json.decode(str));

String refreshStoriesTokenResponseModelToJson(
  RefreshStoriesTokenResponseModel data,
) => json.encode(data.toJson());

class RefreshStoriesTokenResponseModel {
  final StoriesTokenUser? user;

  /// New stories access token. Replaces the stored one.
  final String? accessToken;

  /// New stories refresh token. The presented one is now revoked (single-use
  /// rotation), so this must replace the stored one as well.
  final String? refreshToken;
  final String? tokenType;

  /// Lifetime of [accessToken] in seconds.
  final int? expiresIn;

  RefreshStoriesTokenResponseModel({
    this.user,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
  });

  RefreshStoriesTokenResponseModel copyWith({
    StoriesTokenUser? user,
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
  }) => RefreshStoriesTokenResponseModel(
    user: user ?? this.user,
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    tokenType: tokenType ?? this.tokenType,
    expiresIn: expiresIn ?? this.expiresIn,
  );

  factory RefreshStoriesTokenResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => RefreshStoriesTokenResponseModel(
    user: json["user"] == null ? null : StoriesTokenUser.fromJson(json["user"]),
    accessToken: json["access_token"]?.toString(),
    refreshToken: json["refresh_token"]?.toString(),
    tokenType: json["token_type"]?.toString(),
    expiresIn: json["expires_in"] is int
        ? json["expires_in"]
        : int.tryParse((json["expires_in"] ?? '').toString()),
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "access_token": accessToken,
    "refresh_token": refreshToken,
    "token_type": tokenType,
    "expires_in": expiresIn,
  };
}

/// The stories user the refreshed pair belongs to.
class StoriesTokenUser {
  final int? id;
  final String? name;
  final dynamic username;
  final dynamic email;
  final String? mobilePhone;
  final dynamic originalUserId;
  final String? referenceType;

  /// `is_allowed_to_upload_story` arrives as `0`/`1`; some stories endpoints
  /// send a real boolean, so both forms are accepted.
  final bool? isAllowedToUploadStory;
  final dynamic photoPath;
  final bool? isLockedByAdminForDelete;
  final bool? isLockedByAdminForUpdate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final List<dynamic>? roles;

  /// Same value as the root `access_token`.
  final String? accessToken;

  /// Same value as the root `refresh_token`.
  final String? refreshToken;

  StoriesTokenUser({
    this.id,
    this.name,
    this.username,
    this.email,
    this.mobilePhone,
    this.originalUserId,
    this.referenceType,
    this.isAllowedToUploadStory,
    this.photoPath,
    this.isLockedByAdminForDelete,
    this.isLockedByAdminForUpdate,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.roles,
    this.accessToken,
    this.refreshToken,
  });

  factory StoriesTokenUser.fromJson(Map<String, dynamic> json) =>
      StoriesTokenUser(
        id: json["id"] is int
            ? json["id"]
            : int.tryParse((json["id"] ?? '').toString()),
        name: json["name"]?.toString(),
        username: json["username"],
        email: json["email"],
        mobilePhone: json["mobile_phone"]?.toString(),
        originalUserId: json["original_user_id"],
        referenceType: json["reference_type"]?.toString(),
        isAllowedToUploadStory: json["is_allowed_to_upload_story"] is int
            ? json["is_allowed_to_upload_story"] == 1
            : json["is_allowed_to_upload_story"] as bool?,
        photoPath: json["photo_path"],
        isLockedByAdminForDelete: json["is_locked_by_admin_for_delete"] as bool?,
        isLockedByAdminForUpdate: json["is_locked_by_admin_for_update"] as bool?,
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"].toString()),
        deletedAt: json["deleted_at"] == null
            ? null
            : DateTime.tryParse(json["deleted_at"].toString()),
        roles: json["roles"] == null
            ? null
            : List<dynamic>.from(json["roles"].map((x) => x)),
        accessToken: json["accessToken"]?.toString(),
        refreshToken: json["refreshToken"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "username": username,
    "email": email,
    "mobile_phone": mobilePhone,
    "original_user_id": originalUserId,
    "reference_type": referenceType,
    "is_allowed_to_upload_story": isAllowedToUploadStory,
    "photo_path": photoPath,
    "is_locked_by_admin_for_delete": isLockedByAdminForDelete,
    "is_locked_by_admin_for_update": isLockedByAdminForUpdate,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt?.toIso8601String(),
    "roles": roles == null ? null : List<dynamic>.from(roles!.map((x) => x)),
    "accessToken": accessToken,
    "refreshToken": refreshToken,
  };
}
