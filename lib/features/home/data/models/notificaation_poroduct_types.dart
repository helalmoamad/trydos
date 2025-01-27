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
  final bool? success;
  final List<NotificationType>? notificationTypes;

  NotificationTypeForProductModel({
    this.success,
    this.notificationTypes,
  });

  NotificationTypeForProductModel copyWith({
    bool? success,
    List<NotificationType>? notificationTypes,
  }) =>
      NotificationTypeForProductModel(
        success: success ?? this.success,
        notificationTypes: notificationTypes ?? this.notificationTypes,
      );

  factory NotificationTypeForProductModel.fromJson(Map<String, dynamic> json) =>
      NotificationTypeForProductModel(
        success: json["success"],
        notificationTypes: json["notification_types"] == null
            ? []
            : List<NotificationType>.from(json["notification_types"]!
                .map((x) => NotificationType.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
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
  final int? isChosenByCustomer;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<dynamic>? customNotificationTypes;

  NotificationType({
    this.id,
    this.name,
    this.title,
    this.body,
    this.entityType,
    this.className,
    this.isChosenByCustomer,
    this.createdAt,
    this.updatedAt,
    this.customNotificationTypes,
  });

  NotificationType copyWith({
    int? id,
    String? name,
    String? title,
    String? body,
    int? entityType,
    String? className,
    int? isChosenByCustomer,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<dynamic>? customNotificationTypes,
  }) =>
      NotificationType(
        id: id ?? this.id,
        name: name ?? this.name,
        title: title ?? this.title,
        body: body ?? this.body,
        entityType: entityType ?? this.entityType,
        className: className ?? this.className,
        isChosenByCustomer: isChosenByCustomer ?? this.isChosenByCustomer,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        customNotificationTypes:
            customNotificationTypes ?? this.customNotificationTypes,
      );

  factory NotificationType.fromJson(Map<String, dynamic> json) =>
      NotificationType(
        id: json["id"],
        name: json["name"],
        title: json["title"],
        body: json["body"],
        entityType: json["entity_type"],
        className: json["class_name"],
        isChosenByCustomer: json["is_chosen_by_customer"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        customNotificationTypes: json["custom_notification_types"] == null
            ? []
            : List<dynamic>.from(
                json["custom_notification_types"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "title": title,
        "body": body,
        "entity_type": entityType,
        "class_name": className,
        "is_chosen_by_customer": isChosenByCustomer,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "custom_notification_types": customNotificationTypes == null
            ? []
            : List<dynamic>.from(customNotificationTypes!.map((x) => x)),
      };
}
