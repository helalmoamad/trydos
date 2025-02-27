class ApplyCouponModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final ApplyCouponDataModel? data;

  ApplyCouponModel({
    required this.isSuccessful,
    required this.hasContent,
    required this.code,
    required this.message,
    required this.detailedError,
    required this.data,
  });

  ApplyCouponModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    ApplyCouponDataModel? data,
  }) =>
      ApplyCouponModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory ApplyCouponModel.fromJson(Map<String, dynamic> json) =>
      ApplyCouponModel(
        isSuccessful: json["isSuccessful"] ?? false,
        hasContent: json["hasContent"] ?? false,
        code: json["code"] ?? 0,
        message: json["message"] ?? '',
        detailedError: json["detailed_error"],
        data: json["data"] == null
            ? null
            : ApplyCouponDataModel.fromJson(json["data"]),
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

class ApplyCouponDataModel {
  final int? status;
  final double? discount;

  ApplyCouponDataModel({
    required this.status,
    required this.discount,
  });

  ApplyCouponDataModel copyWith({
    int? status,
    double? discount,
  }) =>
      ApplyCouponDataModel(
        status: status ?? this.status,
        discount: discount ?? this.discount,
      );

  factory ApplyCouponDataModel.fromJson(Map<String, dynamic> json) =>
      ApplyCouponDataModel(
        status: json["status"] ?? 0,
        discount: json["discount"] == null
            ? 0
            : double.parse(json["discount"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "discount": discount,
      };
}
