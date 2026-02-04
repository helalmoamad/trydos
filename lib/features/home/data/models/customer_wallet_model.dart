// To parse this JSON data, do
//
//     final customerWalletModel = customerWalletModelFromJson(jsonString);

import 'dart:convert';

CustomerWalletModel customerWalletModelFromJson(String str) =>
    CustomerWalletModel.fromJson(json.decode(str));

String customerWalletModelToJson(CustomerWalletModel data) =>
    json.encode(data.toJson());

class CustomerWalletModel {
  final String? currencySymbol;
  final double? totalAvailable;
  final int? totalLocked;
  final double? totalValue;
  final List<Wallet>? wallets;

  CustomerWalletModel({
    this.currencySymbol,
    this.totalAvailable,
    this.totalLocked,
    this.totalValue,
    this.wallets,
  });

  CustomerWalletModel copyWith({
    String? currencySymbol,
    double? totalAvailable,
    int? totalLocked,
    double? totalValue,
    List<Wallet>? wallets,
  }) => CustomerWalletModel(
    currencySymbol: currencySymbol ?? this.currencySymbol,
    totalAvailable: totalAvailable ?? this.totalAvailable,
    totalLocked: totalLocked ?? this.totalLocked,
    totalValue: totalValue ?? this.totalValue,
    wallets: wallets ?? this.wallets,
  );

  factory CustomerWalletModel.fromJson(Map<String, dynamic> json) =>
      CustomerWalletModel(
        currencySymbol: json["currencySymbol"],
        totalAvailable: json["totalAvailable"]?.toDouble(),
        totalLocked: json["totalLocked"],
        totalValue: json["totalValue"]?.toDouble(),
        wallets: json["wallets"] == null
            ? []
            : List<Wallet>.from(
                json["wallets"]!.map((x) => Wallet.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "currencySymbol": currencySymbol,
    "totalAvailable": totalAvailable,
    "totalLocked": totalLocked,
    "totalValue": totalValue,
    "wallets": wallets == null
        ? []
        : List<dynamic>.from(wallets!.map((x) => x.toJson())),
  };
}

class Wallet {
  final String? id;
  final String? type;
  final String? userId;
  final String? subtype;
  final String? status;
  final String? name;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Balance>? balances;

  Wallet({
    this.id,
    this.type,
    this.userId,
    this.subtype,
    this.status,
    this.name,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.balances,
  });

  Wallet copyWith({
    String? id,
    String? type,
    String? userId,
    String? subtype,
    String? status,
    String? name,
    dynamic deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Balance>? balances,
  }) => Wallet(
    id: id ?? this.id,
    type: type ?? this.type,
    userId: userId ?? this.userId,
    subtype: subtype ?? this.subtype,
    status: status ?? this.status,
    name: name ?? this.name,
    deletedAt: deletedAt ?? this.deletedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    balances: balances ?? this.balances,
  );

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json["id"],
    type: json["type"],
    userId: json["userId"],
    subtype: json["subtype"],
    status: json["status"],
    name: json["name"],
    deletedAt: json["deletedAt"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    balances: json["balances"] == null
        ? []
        : List<Balance>.from(json["balances"]!.map((x) => Balance.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "userId": userId,
    "subtype": subtype,
    "status": status,
    "name": name,
    "deletedAt": deletedAt,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "balances": balances == null
        ? []
        : List<dynamic>.from(balances!.map((x) => x.toJson())),
  };
}

class Balance {
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

  Balance({
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
  });

  Balance copyWith({
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
  }) => Balance(
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
  );

  factory Balance.fromJson(Map<String, dynamic> json) => Balance(
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
