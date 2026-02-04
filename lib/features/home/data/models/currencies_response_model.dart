import 'dart:convert';

CurrenciesForWalletResponseModel currenciesResponseModelFromJson(String str) =>
    CurrenciesForWalletResponseModel.fromJson(json.decode(str));

String currenciesResponseModelToJson(CurrenciesForWalletResponseModel data) =>
    json.encode(data.toJson());

class CurrenciesForWalletResponseModel {
  final List<CurrencyItem>? items;
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;
  final bool? hasNext;
  final bool? hasPrevious;

  CurrenciesForWalletResponseModel({
    this.items,
    this.total,
    this.page,
    this.limit,
    this.totalPages,
    this.hasNext,
    this.hasPrevious,
  });

  factory CurrenciesForWalletResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => CurrenciesForWalletResponseModel(
    items: json["items"] == null
        ? null
        : List<CurrencyItem>.from(
            json["items"].map((x) => CurrencyItem.fromJson(x)),
          ),
    total: json["total"],
    page: json["page"],
    limit: json["limit"],
    totalPages: json["totalPages"],
    hasNext: json["hasNext"],
    hasPrevious: json["hasPrevious"],
  );

  Map<String, dynamic> toJson() => {
    "items": items == null
        ? null
        : List<dynamic>.from(items!.map((x) => x.toJson())),
    "total": total,
    "page": page,
    "limit": limit,
    "totalPages": totalPages,
    "hasNext": hasNext,
    "hasPrevious": hasPrevious,
  };
}

class CurrencyItem {
  final String? name;
  final String? displayName;
  final String? id;
  final String? symbol;
  final String? symbolImageUrl;
  final CurrencyPaytab? paytab;
  final dynamic deletedAt;
  final String? createdAt;
  final String? updatedAt;

  CurrencyItem({
    this.name,
    this.displayName,
    this.id,
    this.symbol,
    this.symbolImageUrl,
    this.paytab,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory CurrencyItem.fromJson(Map<String, dynamic> json) => CurrencyItem(
    name: json["name"],
    displayName: json["displayName"],
    id: json["id"],
    symbol: json["symbol"],
    symbolImageUrl: json["symbolImageUrl"],
    paytab: json["paytab"] == null
        ? null
        : CurrencyPaytab.fromJson(json["paytab"]),
    deletedAt: json["deletedAt"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "displayName": displayName,
    "id": id,
    "symbol": symbol,
    "symbolImageUrl": symbolImageUrl,
    "paytab": paytab?.toJson(),
    "deletedAt": deletedAt,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class CurrencyPaytab {
  final bool? paytabEnabled;
  final CurrencyPaytabFees? paytabFees;
  final CurrencyPaytabTax? paytabTax;

  CurrencyPaytab({this.paytabEnabled, this.paytabFees, this.paytabTax});

  factory CurrencyPaytab.fromJson(Map<String, dynamic> json) => CurrencyPaytab(
    paytabEnabled: json["paytabEnabled"],
    paytabFees: json["paytabFees"] == null
        ? null
        : CurrencyPaytabFees.fromJson(json["paytabFees"]),
    paytabTax: json["paytabTax"] == null
        ? null
        : CurrencyPaytabTax.fromJson(json["paytabTax"]),
  );

  Map<String, dynamic> toJson() => {
    "paytabEnabled": paytabEnabled,
    "paytabFees": paytabFees?.toJson(),
    "paytabTax": paytabTax?.toJson(),
  };
}

class CurrencyPaytabFees {
  final bool? enabled;
  final String? type;
  final num? percentage;
  final num? fixedAmount;

  CurrencyPaytabFees({
    this.enabled,
    this.type,
    this.percentage,
    this.fixedAmount,
  });

  factory CurrencyPaytabFees.fromJson(Map<String, dynamic> json) =>
      CurrencyPaytabFees(
        enabled: json["enabled"],
        type: json["type"],
        percentage: json["percentage"],
        fixedAmount: json["fixedAmount"],
      );

  Map<String, dynamic> toJson() => {
    "enabled": enabled,
    "type": type,
    "percentage": percentage,
    "fixedAmount": fixedAmount,
  };
}

class CurrencyPaytabTax {
  final bool? enabled;
  final String? type;
  final num? percentage;
  final num? fixedAmount;

  CurrencyPaytabTax({
    this.enabled,
    this.type,
    this.percentage,
    this.fixedAmount,
  });

  factory CurrencyPaytabTax.fromJson(Map<String, dynamic> json) =>
      CurrencyPaytabTax(
        enabled: json["enabled"],
        type: json["type"],
        percentage: json["percentage"],
        fixedAmount: json["fixedAmount"],
      );

  Map<String, dynamic> toJson() => {
    "enabled": enabled,
    "type": type,
    "percentage": percentage,
    "fixedAmount": fixedAmount,
  };
}
