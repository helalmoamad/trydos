// To parse this JSON data, do
//
//     final getCurrencyForCountryModel = getCurrencyForCountryModelFromJson(jsonString);
import 'dart:convert';

GetCurrencyForCountryModel getCurrencyForCountryModelFromJson(String str) =>
    GetCurrencyForCountryModel.fromJson(json.decode(str));
String getCurrencyForCountryModelToJson(GetCurrencyForCountryModel data) =>
    json.encode(data.toJson());

class GetCurrencyForCountryModel {
  final String? message;
  final Data? data;
  GetCurrencyForCountryModel({this.message, this.data});
  GetCurrencyForCountryModel copyWith({String? message, Data? data}) =>
      GetCurrencyForCountryModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );
  factory GetCurrencyForCountryModel.fromJson(Map<String, dynamic> json) =>
      GetCurrencyForCountryModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );
  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  final Currency? currency;
  Data({this.currency});
  Data copyWith({Currency? currency}) =>
      Data(currency: currency ?? this.currency);
  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currency: json["currency"] == null
        ? null
        : Currency.fromJson(json["currency"]),
  );
  Map<String, dynamic> toJson() => {"currency": currency?.toJson()};
}

class Currency {
  final int? id;
  final dynamic name;
  final String? symbol;
  final String? code;
  final double? exchangeRate;
  final int? decimalDigits;
  Currency({
    this.id,
    this.name,
    this.symbol,
    this.code,
    this.exchangeRate,
    this.decimalDigits,
  });
  Currency copyWith({
    int? id,
    dynamic name,
    String? symbol,
    String? code,
    double? exchangeRate,
    int? decimalDigits,
  }) => Currency(
    id: id ?? this.id,
    decimalDigits: decimalDigits ?? this.decimalDigits,
    name: name ?? this.name,
    symbol: symbol ?? this.symbol,
    code: code ?? this.code,
    exchangeRate: exchangeRate ?? this.exchangeRate,
  );
  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    id: json["id"],
    name: json["name"],
    symbol: json["symbol"],
    decimalDigits: int.tryParse(json["decimal_digits"].toString()) ?? 2,
    code: json["code"],
    exchangeRate: json["exchange_rate"] == null
        ? 0
        : json["exchange_rate"].toDouble(),
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "decimal_digits": decimalDigits,
    "name": name,
    "symbol": symbol,
    "code": code,
    "exchange_rate": exchangeRate,
  };
}
