// To parse this JSON data, do
//
//     final firebaseSettingForNotificationModel = firebaseSettingForNotificationModelFromJson(jsonString);

import 'dart:convert';

FirebaseSettingForNotificationModel firebaseSettingForNotificationModelFromJson(
        String str) =>
    FirebaseSettingForNotificationModel.fromJson(json.decode(str));

String firebaseSettingForNotificationModelToJson(
        FirebaseSettingForNotificationModel data) =>
    json.encode(data.toJson());

class FirebaseSettingForNotificationModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  FirebaseSettingForNotificationModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  FirebaseSettingForNotificationModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) =>
      FirebaseSettingForNotificationModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory FirebaseSettingForNotificationModel.fromJson(
          Map<String, dynamic> json) =>
      FirebaseSettingForNotificationModel(
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
  final FirebaseSettings? firebaseSettings;

  Data({
    this.firebaseSettings,
  });

  Data copyWith({
    FirebaseSettings? firebaseSettings,
  }) =>
      Data(
        firebaseSettings: firebaseSettings ?? this.firebaseSettings,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        firebaseSettings: json["firebase_settings"] == null
            ? null
            : FirebaseSettings.fromJson(json["firebase_settings"]),
      );

  Map<String, dynamic> toJson() => {
        "firebase_settings": firebaseSettings?.toJson(),
      };
}

class FirebaseSettings {
  final List<String>? subscribedTopics;
  final List<String>? unsubscribedTopics;

  FirebaseSettings({
    this.subscribedTopics,
    this.unsubscribedTopics,
  });

  FirebaseSettings copyWith({
    List<String>? subscribedTopics,
    List<String>? unsubscribedTopics,
  }) =>
      FirebaseSettings(
        subscribedTopics: subscribedTopics ?? this.subscribedTopics,
        unsubscribedTopics: unsubscribedTopics ?? this.unsubscribedTopics,
      );

  factory FirebaseSettings.fromJson(Map<String, dynamic> json) =>
      FirebaseSettings(
        subscribedTopics: json["subscribed_topics"] == null
            ? []
            : List<String>.from(json["subscribed_topics"]!.map((x) => x)),
        unsubscribedTopics: json["unsubscribed_topics"] == null
            ? []
            : List<String>.from(json["unsubscribed_topics"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "subscribed_topics": subscribedTopics == null
            ? []
            : List<dynamic>.from(subscribedTopics!.map((x) => x)),
        "unsubscribed_topics": unsubscribedTopics == null
            ? []
            : List<dynamic>.from(unsubscribedTopics!.map((x) => x)),
      };
}
