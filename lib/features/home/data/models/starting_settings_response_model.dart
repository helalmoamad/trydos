// To parse this JSON data, do
//
//     final startingSettingsResponseModel = startingSettingsResponseModelFromJson(jsonString);

import 'dart:convert';

StartingSettingsResponseModel startingSettingsResponseModelFromJson(
        String str) =>
    StartingSettingsResponseModel.fromJson(json.decode(str));

String startingSettingsResponseModelToJson(
        StartingSettingsResponseModel data) =>
    json.encode(data.toJson());

class StartingSettingsResponseModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  StartingSettingsResponseModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  StartingSettingsResponseModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) =>
      StartingSettingsResponseModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory StartingSettingsResponseModel.fromJson(Map<String, dynamic> json) =>
      StartingSettingsResponseModel(
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
  final StartingSetting? startingSetting;

  Data({
    this.startingSetting,
  });

  Data copyWith({
    StartingSetting? startingSetting,
  }) =>
      Data(
        startingSetting: startingSetting ?? this.startingSetting,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        startingSetting: json["starting-setting"] == null
            ? null
            : StartingSetting.fromJson(json["starting-setting"]),
      );

  Map<String, dynamic> toJson() => {
        "starting-setting": startingSetting?.toJson(),
      };
}

class StartingSetting {
  final List<NotificationType>? notificationTypes;
  final int? decimalPointSettings;
  final List<Language>? languages;
  final int? androidMinVersion;
  final int? iosMinVersion;
  final int? shippingDay;
  final int? shippingCost;
  final List<OrderStatusModel>? orderGroupStatuses;
  final List<OrderStatusModel>? orderStatuses;

  StartingSetting({
    this.notificationTypes,
    this.decimalPointSettings,
    this.languages,
    this.shippingDay,
    this.androidMinVersion,
    this.iosMinVersion,
    this.shippingCost,
    this.orderGroupStatuses,
    this.orderStatuses,
  });

  StartingSetting copyWith({
    List<NotificationType>? notificationTypes,
    int? decimalPointSettings,
    List<Language>? languages,
    int? androidMinVersion,
    int? iosMinVersion,
    int? shippingCost,
    int? shippingDay,
    List<OrderStatusModel>? orderGroupStatuses,
    List<OrderStatusModel>? orderStatuses,
  }) =>
      StartingSetting(
        notificationTypes: notificationTypes ?? this.notificationTypes,
        decimalPointSettings: decimalPointSettings ?? this.decimalPointSettings,
        languages: languages ?? this.languages,
        androidMinVersion: androidMinVersion ?? this.androidMinVersion,
        iosMinVersion: iosMinVersion ?? this.iosMinVersion,
        shippingCost: shippingCost ?? this.shippingCost,
        shippingDay: shippingDay ?? this.shippingDay,
        orderGroupStatuses: orderGroupStatuses ?? this.orderGroupStatuses,
        orderStatuses: orderStatuses ?? this.orderStatuses,
      );

  factory StartingSetting.fromJson(Map<String, dynamic> json) =>
      StartingSetting(
        notificationTypes: json["notificationTypes"] == null
            ? []
            : List<NotificationType>.from(json["notificationTypes"]!
                .map((x) => NotificationType.fromJson(x))),
        decimalPointSettings: json["decimal_point_settings"],
        languages: json["languages"] == null
            ? []
            : List<Language>.from(
                json["languages"]!.map((x) => Language.fromJson(x))),
        androidMinVersion: json["android_min_version"],
        iosMinVersion: json["ios_min_version"],
        shippingCost: json["shipping_cost"],
        shippingDay: json["shipping_day"],
        orderGroupStatuses: json["order_group_statuses"] == null
            ? []
            : List<OrderStatusModel>.from(json["order_group_statuses"]!
                .map((x) => OrderStatusModel.fromJson(x))),
        orderStatuses: json["order_statuses"] == null
            ? []
            : List<OrderStatusModel>.from(json["order_statuses"]!
                .map((x) => OrderStatusModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "notificationTypes": notificationTypes == null
            ? []
            : List<dynamic>.from(notificationTypes!.map((x) => x.toJson())),
        "decimal_point_settings": decimalPointSettings,
        "languages": languages == null
            ? []
            : List<dynamic>.from(languages!.map((x) => x.toJson())),
        "android_min_version": androidMinVersion,
        "ios_min_version": iosMinVersion,
        "shipping_cost": shippingCost,
        "shipping_day": shippingDay,
        "order_group_statuses": orderGroupStatuses == null
            ? []
            : List<dynamic>.from(orderGroupStatuses!.map((x) => x.toJson())),
        "order_statuses": orderStatuses == null
            ? []
            : List<dynamic>.from(orderStatuses!.map((x) => x.toJson())),
      };
}

class OrderStatusModel {
  final String? value;
  final String? label;

  OrderStatusModel({
    this.value,
    this.label,
  });

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) =>
      OrderStatusModel(
        value: json["value"] ?? '',
        label: json["label"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "label": label,
      };
}

class Language {
  final String? code;
  final String? name;

  Language({
    this.code,
    this.name,
  });

  Language copyWith({
    String? code,
    String? name,
  }) =>
      Language(
        code: code ?? this.code,
        name: name ?? this.name,
      );

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        code: json["code"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
      };
}

class NotificationType {
  final int? id;
  final String? name;

  NotificationType({
    this.id,
    this.name,
  });

  NotificationType copyWith({
    int? id,
    String? name,
  }) =>
      NotificationType(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory NotificationType.fromJson(Map<String, dynamic> json) =>
      NotificationType(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
