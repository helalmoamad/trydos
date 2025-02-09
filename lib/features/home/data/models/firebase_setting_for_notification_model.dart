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
  final String? email;
  final String? firebase;
  final String? whatsapp;
  final List<SubscribedTopic>? subscribedTopics;
  final List<SubscribedTopic>? unsubscribedTopics;
  final String? notificationFrequency;

  FirebaseSettings({
    this.email,
    this.firebase,
    this.whatsapp,
    this.subscribedTopics,
    this.unsubscribedTopics,
    this.notificationFrequency,
  });

  FirebaseSettings copyWith({
    String? email,
    String? firebase,
    String? whatsapp,
    List<SubscribedTopic>? subscribedTopics,
    List<SubscribedTopic>? unsubscribedTopics,
    String? notificationFrequency,
  }) =>
      FirebaseSettings(
        email: email ?? this.email,
        firebase: firebase ?? this.firebase,
        whatsapp: whatsapp ?? this.whatsapp,
        subscribedTopics: subscribedTopics ?? this.subscribedTopics,
        unsubscribedTopics: unsubscribedTopics ?? this.unsubscribedTopics,
        notificationFrequency:
            notificationFrequency ?? this.notificationFrequency,
      );

  factory FirebaseSettings.fromJson(Map<String, dynamic> json) =>
      FirebaseSettings(
        email: json["email"].toString(),
        firebase: json["firebase"].toString(),
        whatsapp: json["whatsapp"].toString(),
        subscribedTopics: json["subscribed_topics"] == null
            ? []
            : List<SubscribedTopic>.from(json["subscribed_topics"]!
                .map((x) => SubscribedTopic.fromJson(x))),
        unsubscribedTopics: json["unsubscribed_topics"] == null
            ? []
            : List<SubscribedTopic>.from(json["unsubscribed_topics"]!
                .map((x) => SubscribedTopic.fromJson(x))),
        notificationFrequency: json["notification_frequency"],
      );

  Map<String, dynamic> toJson() => {
        "email": email.toString(),
        "firebase": firebase.toString(),
        "whatsapp": whatsapp.toString(),
        "subscribed_topics": subscribedTopics == null
            ? []
            : List<dynamic>.from(subscribedTopics!.map((x) => x.toJson())),
        "unsubscribed_topics": unsubscribedTopics == null
            ? []
            : List<dynamic>.from(unsubscribedTopics!.map((x) => x.toJson())),
        "notification_frequency": notificationFrequency,
      };
}

class SubscribedTopic {
  final String? name;
  final String? showedName;
  final String? topic;
  final List<dynamic>? variants;

  SubscribedTopic({
    this.name,
    this.showedName,
    this.topic,
    this.variants,
  });

  SubscribedTopic copyWith({
    String? name,
    String? showedName,
    String? topic,
    List<dynamic>? variants,
  }) =>
      SubscribedTopic(
        name: name ?? this.name,
        showedName: showedName ?? this.showedName,
        topic: topic ?? this.topic,
        variants: variants ?? this.variants,
      );

  factory SubscribedTopic.fromJson(Map<String, dynamic> json) =>
      SubscribedTopic(
        name: json["name"],
        showedName: json["showed_name"],
        topic: json["topic"],
        variants: json["variants"] == null
            ? []
            : List<dynamic>.from(json["variants"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "showed_name": showedName,
        "topic": topic,
        "variants":
            variants == null ? [] : List<dynamic>.from(variants!.map((x) => x)),
      };
}
