// To parse this JSON data, do
//
//     final refreshCommentTokenResponseModel = refreshCommentTokenResponseModelFromJson(jsonString);

import 'dart:convert';

/// Answer of the two **comments** token endpoints, which return the same shape:
/// `POST public_comment/auth/exchange_token` (the first pair, obtained from the
/// market session) and `POST public_comment/auth/refresh-token` (a renewed
/// pair).
///
/// Both use the `{isSuccessful, code, hasContent, message, data}` envelope the
/// market server returns, so the access token is `data.token` — not
/// `data.access_token` (chat) and not a root-level field (stories). Both
/// answers were captured from the running app.
///
/// `data.expires_at` is parsed so nothing is silently dropped, but the app does
/// not use it: renewal stays reactive, driven by a 401.
RefreshCommentTokenResponseModel refreshCommentTokenResponseModelFromJson(
  String str,
) => RefreshCommentTokenResponseModel.fromJson(json.decode(str));

String refreshCommentTokenResponseModelToJson(
  RefreshCommentTokenResponseModel data,
) => json.encode(data.toJson());

class RefreshCommentTokenResponseModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final String? message;
  final RefreshCommentTokenData? data;

  RefreshCommentTokenResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.message,
    this.data,
  });

  factory RefreshCommentTokenResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => RefreshCommentTokenResponseModel(
    isSuccessful: json["isSuccessful"] as bool?,
    hasContent: json["hasContent"] as bool?,
    message: json["message"]?.toString(),
    data: json["data"] == null
        ? null
        : RefreshCommentTokenData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "isSuccessful": isSuccessful,
    "hasContent": hasContent,
    "message": message,
    "data": data?.toJson(),
  };
}

class RefreshCommentTokenData {
  /// The comments access token. Replaces the stored one.
  ///
  /// `comments_token` is accepted as a fallback: it is the field the old code
  /// read from the **root** of the exchange answer, where it does not exist —
  /// so the stored token was the string "null" and every comments request went
  /// out as `Bearer null`.
  final String? token;

  /// New comments refresh token. The presented one is now revoked (single-use
  /// rotation), so this must replace the stored one as well.
  final String? refreshToken;

  /// When [token] expires. Kept for diagnostics only.
  final DateTime? expiresAt;

  RefreshCommentTokenData({this.token, this.refreshToken, this.expiresAt});

  factory RefreshCommentTokenData.fromJson(Map<String, dynamic> json) =>
      RefreshCommentTokenData(
        token: (json["token"] ?? json["comments_token"])?.toString(),
        refreshToken: json["refresh_token"]?.toString(),
        expiresAt: json["expires_at"] == null
            ? null
            : DateTime.tryParse(json["expires_at"].toString()),
      );

  Map<String, dynamic> toJson() => {
    "token": token,
    "refresh_token": refreshToken,
    "expires_at": expiresAt?.toIso8601String(),
  };
}
