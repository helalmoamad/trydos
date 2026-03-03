// To parse this JSON data, do
//
//     final customerWalletModel = customerWalletModelFromJson(jsonString);

import 'dart:convert';

CustomerWalletModel customerWalletModelFromJson(String str) =>
    CustomerWalletModel.fromJson(json.decode(str));

String customerWalletModelToJson(CustomerWalletModel data) =>
    json.encode(data.toJson());

class CustomerWalletModel {
  final String? id;
  final String? accountId;
  final String? assetType;
  final String? assetId;
  final String? assetSymbol;
  final double? available;
  final int? locked;
  final int? reserved;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Asset? asset;
  final String? accountSubtype;

  CustomerWalletModel({
    this.id,
    this.accountId,
    this.assetType,
    this.assetId,
    this.assetSymbol,
    this.available,
    this.locked,
    this.reserved,
    this.createdAt,
    this.updatedAt,
    this.asset,
    this.accountSubtype,
  });

  CustomerWalletModel copyWith({
    String? id,
    String? accountId,
    String? assetType,
    String? assetId,
    String? assetSymbol,
    double? available,
    int? locked,
    int? reserved,
    DateTime? createdAt,
    DateTime? updatedAt,
    Asset? asset,
    String? accountSubtype,
  }) => CustomerWalletModel(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    assetType: assetType ?? this.assetType,
    assetId: assetId ?? this.assetId,
    assetSymbol: assetSymbol ?? this.assetSymbol,
    available: available ?? this.available,
    locked: locked ?? this.locked,
    reserved: reserved ?? this.reserved,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    asset: asset ?? this.asset,
    accountSubtype: accountSubtype ?? this.accountSubtype,
  );

  factory CustomerWalletModel.fromJson(Map<String, dynamic> json) =>
      CustomerWalletModel(
        id: json["id"],
        accountId: json["accountId"],
        assetType: json["assetType"],
        assetId: json["assetId"],
        assetSymbol: json["assetSymbol"],
        available: json["available"]?.toDouble(),
        locked: json["locked"],
        reserved: json["reserved"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        asset: json["asset"] == null ? null : Asset.fromJson(json["asset"]),
        accountSubtype: json["accountSubtype"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "accountId": accountId,
    "assetType": assetType,
    "assetId": assetId,
    "assetSymbol": assetSymbol,
    "available": available,
    "locked": locked,
    "reserved": reserved,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "asset": asset?.toJson(),
    "accountSubtype": accountSubtype,
  };
}

class Asset {
  final String? id;
  final String? symbol;
  final String? name;

  Asset({this.id, this.symbol, this.name});

  Asset copyWith({String? id, String? symbol, String? name}) => Asset(
    id: id ?? this.id,
    symbol: symbol ?? this.symbol,
    name: name ?? this.name,
  );

  factory Asset.fromJson(Map<String, dynamic> json) =>
      Asset(id: json["id"], symbol: json["symbol"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "symbol": symbol, "name": name};
}
