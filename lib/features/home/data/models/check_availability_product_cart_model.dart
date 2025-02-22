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
  final int? id;
  final String? name;
  final String? pictureUrl;
  final String? cause;
  final int? cartPosition;

  CheckAvailabilityProductCartDataModel({
    required this.id,
    required this.name,
    required this.pictureUrl,
    required this.cause,
    required this.cartPosition,
  });

  CheckAvailabilityProductCartDataModel copyWith({
    int? id,
    String? name,
    String? pictureUrl,
    String? cause,
    int? cartPosition,
  }) =>
      CheckAvailabilityProductCartDataModel(
        id: id ?? this.id,
        name: name ?? this.name,
        pictureUrl: pictureUrl ?? this.pictureUrl,
        cause: cause ?? this.cause,
        cartPosition: cartPosition ?? this.cartPosition,
      );

  factory CheckAvailabilityProductCartDataModel.fromJson(
          Map<String, dynamic> json) =>
      CheckAvailabilityProductCartDataModel(
        id: json["id"],
        name: json["name"] ?? '',
        pictureUrl: json["picture_url"] ?? '',
        cause: json["cause"] ?? '',
        cartPosition: json["cart_position"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "picture_url": pictureUrl,
        "cause": cause,
        "cart_position": cartPosition,
      };
}
