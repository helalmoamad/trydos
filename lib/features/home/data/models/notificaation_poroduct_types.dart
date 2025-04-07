// To parse this JSON data, do
//
//     final notificationTypeForProductModel = notificationTypeForProductModelFromJson(jsonString);

import 'dart:convert';

NotificationTypeForProductModel notificationTypeForProductModelFromJson(
        String str) =>
    NotificationTypeForProductModel.fromJson(json.decode(str));

String notificationTypeForProductModelToJson(
        NotificationTypeForProductModel data) =>
    json.encode(data.toJson());

class NotificationTypeForProductModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final dynamic message;
  final dynamic detailedError;
  final Data? data;

  NotificationTypeForProductModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  NotificationTypeForProductModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    dynamic message,
    dynamic detailedError,
    Data? data,
  }) =>
      NotificationTypeForProductModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory NotificationTypeForProductModel.fromJson(Map<String, dynamic> json) =>
      NotificationTypeForProductModel(
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
  final List<NotificationType>? notificationTypes;

  Data({
    this.notificationTypes,
  });

  Data copyWith({
    List<NotificationType>? notificationTypes,
  }) =>
      Data(
        notificationTypes: notificationTypes ?? this.notificationTypes,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        notificationTypes: json["notification_types"] == null
            ? []
            : List<NotificationType>.from(json["notification_types"]!
                .map((x) => NotificationType.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "notification_types": notificationTypes == null
            ? []
            : List<dynamic>.from(notificationTypes!.map((x) => x.toJson())),
      };
}

class NotificationType {
  final int? id;
  final String? name;
  final String? title;
  final String? body;
  final int? entityType;
  final String? className;
  final dynamic whatsappLinkUrl;
  final int? isChosenByCustomer;
  final dynamic recommendationTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? topic;
  final String? showedName;

  NotificationType({
    this.id,
    this.name,
    this.title,
    this.body,
    this.entityType,
    this.className,
    this.whatsappLinkUrl,
    this.isChosenByCustomer,
    this.recommendationTime,
    this.createdAt,
    this.updatedAt,
    this.topic,
    this.showedName,
  });

  NotificationType copyWith({
    int? id,
    String? name,
    String? title,
    String? body,
    int? entityType,
    String? className,
    dynamic whatsappLinkUrl,
    int? isChosenByCustomer,
    dynamic recommendationTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? topic,
    String? showedName,
  }) =>
      NotificationType(
        id: id ?? this.id,
        name: name ?? this.name,
        title: title ?? this.title,
        body: body ?? this.body,
        entityType: entityType ?? this.entityType,
        className: className ?? this.className,
        whatsappLinkUrl: whatsappLinkUrl ?? this.whatsappLinkUrl,
        isChosenByCustomer: isChosenByCustomer ?? this.isChosenByCustomer,
        recommendationTime: recommendationTime ?? this.recommendationTime,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        topic: topic ?? this.topic,
        showedName: showedName ?? this.showedName,
      );

  factory NotificationType.fromJson(Map<String, dynamic> json) =>
      NotificationType(
        id: json["id"],
        name: json["name"],
        title: json["title"],
        body: json["body"],
        entityType: json["entity_type"],
        className: json["class_name"],
        whatsappLinkUrl: json["whatsapp_link_url"],
        isChosenByCustomer: json["is_chosen_by_customer"],
        recommendationTime: json["recommendation_time"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        topic: json["topic"],
        showedName: json["showed_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "title": title,
        "body": body,
        "entity_type": entityType,
        "class_name": className,
        "whatsapp_link_url": whatsappLinkUrl,
        "is_chosen_by_customer": isChosenByCustomer,
        "recommendation_time": recommendationTime,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "topic": topic,
        "showed_name": showedName,
      };
}
