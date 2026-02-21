// To parse this JSON data, do
//
//     final returnReasonsModel = returnReasonsModelFromJson(jsonString);

import 'dart:convert';

ReturnReasonsModel returnReasonsModelFromJson(String str) =>
    ReturnReasonsModel.fromJson(json.decode(str));

String returnReasonsModelToJson(ReturnReasonsModel data) =>
    json.encode(data.toJson());

class ReturnReasonsModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final ReturnReasonsDataModel? data;

  ReturnReasonsModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  ReturnReasonsModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    ReturnReasonsDataModel? data,
  }) =>
      ReturnReasonsModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory ReturnReasonsModel.fromJson(Map<String, dynamic> json) =>
      ReturnReasonsModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"],
        detailedError: json["detailed_error"],
        data: json["data"] == null
            ? null
            : ReturnReasonsDataModel.fromJson(json["data"]),
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

class ReturnReasonsDataModel {
  final List<ReturnReasonModel>? returnReasons;
  final List<ExchangeReasonModel>? exchangeReasons;

  ReturnReasonsDataModel({
    this.returnReasons,
    this.exchangeReasons,
  });

  ReturnReasonsDataModel copyWith({
    List<ReturnReasonModel>? returnReasons,
    List<ExchangeReasonModel>? exchangeReasons,
  }) =>
      ReturnReasonsDataModel(
        returnReasons: returnReasons ?? this.returnReasons,
        exchangeReasons: exchangeReasons ?? this.exchangeReasons,
      );

  factory ReturnReasonsDataModel.fromJson(Map<String, dynamic> json) =>
      ReturnReasonsDataModel(
        returnReasons: json["return_reasons"] == null
            ? []
            : List<ReturnReasonModel>.from(
                json["return_reasons"]!.map((x) => ReturnReasonModel.fromJson(x))),
        exchangeReasons: json["exchange_reasons"] == null
            ? []
            : List<ExchangeReasonModel>.from(
                json["exchange_reasons"]!.map((x) => ExchangeReasonModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "return_reasons": returnReasons == null
            ? []
            : List<dynamic>.from(returnReasons!.map((x) => x.toJson())),
        "exchange_reasons": exchangeReasons == null
            ? []
            : List<dynamic>.from(exchangeReasons!.map((x) => x.toJson())),
      };
}

class ReturnReasonModel {
  final int? id;
  final String? reasonAeEn;
  final String? reason;
  final String? reasonDetailsAeEn;
  final double? cost;
  final int? isCostBySystem;
  final int? isForExchange;

  ReturnReasonModel({
    this.id,
    this.reasonAeEn,
    this.reason,
    this.reasonDetailsAeEn,
    this.cost,
    this.isCostBySystem,
    this.isForExchange,
  });

  ReturnReasonModel copyWith({
    int? id,
    String? reasonAeEn,
    String? reason,
    String? reasonDetailsAeEn,
    double? cost,
    int? isCostBySystem,
    int? isForExchange,
  }) =>
      ReturnReasonModel(
        id: id ?? this.id,
        reasonAeEn: reasonAeEn ?? this.reasonAeEn,
        reason: reason ?? this.reason,
        reasonDetailsAeEn: reasonDetailsAeEn ?? this.reasonDetailsAeEn,
        cost: cost ?? this.cost,
        isCostBySystem: isCostBySystem ?? this.isCostBySystem,
        isForExchange: isForExchange ?? this.isForExchange,
      );

  factory ReturnReasonModel.fromJson(Map<String, dynamic> json) =>
      ReturnReasonModel(
        id: json["id"],
        reasonAeEn: json["reason_ae_en"],
        reason: json["reason"],
        reasonDetailsAeEn: json["reason_details_ae_en"],
        cost: json["cost"]?.toDouble(),
        isCostBySystem: json["is_cost_by_system"],
        isForExchange: json["is_for_exchange"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reason_ae_en": reasonAeEn,
        "reason": reason,
        "reason_details_ae_en": reasonDetailsAeEn,
        "cost": cost,
        "is_cost_by_system": isCostBySystem,
        "is_for_exchange": isForExchange,
      };
}

class ExchangeReasonModel {
  final int? id;
  final String? reasonAeEn;
  final String? reason;
  final String? reasonDetailsAeEn;
  final double? cost;
  final int? isCostBySystem;
  final int? isForExchange;

  ExchangeReasonModel({
    this.id,
    this.reasonAeEn,
    this.reason,
    this.reasonDetailsAeEn,
    this.cost,
    this.isCostBySystem,
    this.isForExchange,
  });

  ExchangeReasonModel copyWith({
    int? id,
    String? reasonAeEn,
    String? reason,
    String? reasonDetailsAeEn,
    double? cost,
    int? isCostBySystem,
    int? isForExchange,
  }) =>
      ExchangeReasonModel(
        id: id ?? this.id,
        reasonAeEn: reasonAeEn ?? this.reasonAeEn,
        reason: reason ?? this.reason,
        reasonDetailsAeEn: reasonDetailsAeEn ?? this.reasonDetailsAeEn,
        cost: cost ?? this.cost,
        isCostBySystem: isCostBySystem ?? this.isCostBySystem,
        isForExchange: isForExchange ?? this.isForExchange,
      );

  factory ExchangeReasonModel.fromJson(Map<String, dynamic> json) =>
      ExchangeReasonModel(
        id: json["id"],
        reasonAeEn: json["reason_ae_en"],
        reason: json["reason"],
        reasonDetailsAeEn: json["reason_details_ae_en"],
        cost: json["cost"]?.toDouble(),
        isCostBySystem: json["is_cost_by_system"],
        isForExchange: json["is_for_exchange"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reason_ae_en": reasonAeEn,
        "reason": reason,
        "reason_details_ae_en": reasonDetailsAeEn,
        "cost": cost,
        "is_cost_by_system": isCostBySystem,
        "is_for_exchange": isForExchange,
      };
} 