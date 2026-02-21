class GetPresignedUrlModel {
  final String? uploadUrl;
  final String? key;
  final int? expiresInSeconds;

  GetPresignedUrlModel({this.uploadUrl, this.key, this.expiresInSeconds});

  factory GetPresignedUrlModel.fromJson(Map<String, dynamic> json) {
    return GetPresignedUrlModel(
      uploadUrl: json['upload_url'] as String?,
      key: json['key'] as String?,
      expiresInSeconds: json['expires_in_seconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upload_url': uploadUrl,
      'key': key,
      'expires_in_seconds': expiresInSeconds,
    };
  }
}
