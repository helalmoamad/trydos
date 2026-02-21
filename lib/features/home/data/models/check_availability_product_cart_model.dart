class CheckAvailabilityProductCartModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final List<CheckAvailabilityProductCartDataModel>? data;

  CheckAvailabilityProductCartModel({
    required this.isSuccessful,
    required this.hasContent,
    required this.code,
    required this.message,
    required this.detailedError,
    required this.data,
  });

  CheckAvailabilityProductCartModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    List<CheckAvailabilityProductCartDataModel>? data,
  }) =>
      CheckAvailabilityProductCartModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory CheckAvailabilityProductCartModel.fromJson(
          Map<String, dynamic> json) =>
      CheckAvailabilityProductCartModel(
        isSuccessful: json["isSuccessful"] ?? false,
        hasContent: json["hasContent"] ?? false,
        code: json["code"] ?? 0,
        message: json["message"] ?? '',
        detailedError: json["detailed_error"],
        data: List<CheckAvailabilityProductCartDataModel>.from(json["data"]
            .map((x) => CheckAvailabilityProductCartDataModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "isSuccessful": isSuccessful,
        "hasContent": hasContent,
        "code": code,
        "message": message,
        "detailed_error": detailedError,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CheckAvailabilityProductCartDataModel {
  final int? cartId;
  final int? productId;
  final String? cause;

  CheckAvailabilityProductCartDataModel({
    required this.cartId,
    required this.productId,
    required this.cause,
  });

  CheckAvailabilityProductCartDataModel copyWith({
    int? cartId,
    int? productId,
    String? cause,
  }) =>
      CheckAvailabilityProductCartDataModel(
        cartId: cartId ?? this.cartId,
        productId: productId ?? this.productId,
        cause: cause ?? this.cause,
      );

  factory CheckAvailabilityProductCartDataModel.fromJson(
          Map<String, dynamic> json) =>
      CheckAvailabilityProductCartDataModel(
        cartId: json["cart_id"],
        productId: json["product_id"],
        cause: json["cause"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "cart_id": cartId,
        "product_id": productId,
        "cause": cause,
      };
}
