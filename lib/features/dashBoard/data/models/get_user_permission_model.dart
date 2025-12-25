// To parse this JSON data, do
//
//     final getUserPermissionModel = getUserPermissionModelFromJson(jsonString);

import 'dart:convert';

GetUserPermissionModel getUserPermissionModelFromJson(String str) =>
    GetUserPermissionModel.fromJson(json.decode(str));

String getUserPermissionModelToJson(GetUserPermissionModel data) =>
    json.encode(data.toJson());

class GetUserPermissionModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final List<Shop>? shops;

  GetUserPermissionModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.shops,
  });

  GetUserPermissionModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    List<Shop>? shops,
  }) => GetUserPermissionModel(
    isSuccessful: isSuccessful ?? this.isSuccessful,
    hasContent: hasContent ?? this.hasContent,
    code: code ?? this.code,
    message: message ?? this.message,
    detailedError: detailedError ?? this.detailedError,
    shops: shops ?? this.shops,
  );

  factory GetUserPermissionModel.fromJson(Map<String, dynamic> json) =>
      GetUserPermissionModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"],
        detailedError: json["detailed_error"],
        shops: json["data"] == null
            ? []
            : List<Shop>.from(json["data"]!.map((x) => Shop.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "isSuccessful": isSuccessful,
    "hasContent": hasContent,
    "code": code,
    "message": message,
    "detailed_error": detailedError,
    "data": shops == null
        ? []
        : List<dynamic>.from(shops!.map((x) => x.toJson())),
  };
}

class Shop {
  final int? sellerId;
  final String? shopName;
  final List<String>? permissions;

  Shop({this.sellerId, this.shopName, this.permissions});

  Shop copyWith({int? sellerId, String? shopName, List<String>? permissions}) =>
      Shop(
        sellerId: sellerId ?? this.sellerId,
        shopName: shopName ?? this.shopName,
        permissions: permissions ?? this.permissions,
      );

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
    sellerId: json["seller_id"],
    shopName: json["shop_name"],
    permissions: json["permissions"] == null
        ? []
        : List<String>.from(json["permissions"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "seller_id": sellerId,
    "shop_name": shopName,
    "permissions": permissions == null
        ? []
        : List<dynamic>.from(permissions!.map((x) => x)),
  };
}
