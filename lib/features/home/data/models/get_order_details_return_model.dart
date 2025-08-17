// To parse this JSON data, do
//
//     final getOrderReturntDetailsModel = getOrderReturntDetailsModelFromJson(jsonString);

import 'dart:convert';

GetOrderReturntDetailsModel getOrderReturntDetailsModelFromJson(String str) =>
    GetOrderReturntDetailsModel.fromJson(json.decode(str));

String getOrderReturntDetailsModelToJson(GetOrderReturntDetailsModel data) =>
    json.encode(data.toJson());

class GetOrderReturntDetailsModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  GetOrderReturntDetailsModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GetOrderReturntDetailsModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) =>
      GetOrderReturntDetailsModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory GetOrderReturntDetailsModel.fromJson(Map<String, dynamic> json) =>
      GetOrderReturntDetailsModel(
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
  final double? totalReturnableAmount;
  final String? descriptionReturnableAmountLessThan0;
  final dynamic returnRequestDestinationId;
  final String? status;
  final List<OrderDetail>? orderDetails;

  Data({
    this.totalReturnableAmount,
    this.descriptionReturnableAmountLessThan0,
    this.returnRequestDestinationId,
    this.status,
    this.orderDetails,
  });

  Data copyWith({
    double? totalReturnableAmount,
    String? descriptionReturnableAmountLessThan0,
    dynamic returnRequestDestinationId,
    String? status,
    List<OrderDetail>? orderDetails,
  }) =>
      Data(
        totalReturnableAmount:
            totalReturnableAmount ?? this.totalReturnableAmount,
        descriptionReturnableAmountLessThan0:
            descriptionReturnableAmountLessThan0 ??
                this.descriptionReturnableAmountLessThan0,
        returnRequestDestinationId:
            returnRequestDestinationId ?? this.returnRequestDestinationId,
        status: status ?? this.status,
        orderDetails: orderDetails ?? this.orderDetails,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalReturnableAmount:
            double.tryParse(json["total_returnable_amount"].toString()),
        descriptionReturnableAmountLessThan0:
            json["description_returnable_amount_less_than_0"],
        returnRequestDestinationId: json["return_request_destination_id"],
        status: json["status"],
        orderDetails: json["order_details"] == null
            ? []
            : List<OrderDetail>.from(
                json["order_details"]!.map((x) => OrderDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total_returnable_amount": totalReturnableAmount ?? 0.toDouble(),
        "description_returnable_amount_less_than_0":
            descriptionReturnableAmountLessThan0,
        "return_request_destination_id": returnRequestDestinationId,
        "status": status,
        "order_details": orderDetails == null
            ? []
            : List<dynamic>.from(orderDetails!.map((x) => x.toJson())),
      };
}

class OrderDetail {
  final int? detailId;
  final int? productId;
  final int? returnRequestId;
  final int? quantity;
  final String? image;
  final String? name;
  final String? variant;
  final double? productPrice;
  final double? subtotal;
  final bool? alreadyReturn;
  final int? returnRequestProductId;
  final String? returnRequestProductQuantity;
  final int? returnRequestProductReasonId;
  final dynamic returnRequestProductDetails;
  final String? returnRequestProductStatus;
  final List<String>? imagesUrl;
  final List<String>? img;

  OrderDetail({
    this.detailId,
    this.productId,
    this.returnRequestId,
    this.quantity,
    this.image,
    this.name,
    this.variant,
    this.productPrice,
    this.subtotal,
    this.alreadyReturn,
    this.returnRequestProductId,
    this.returnRequestProductQuantity,
    this.returnRequestProductReasonId,
    this.returnRequestProductDetails,
    this.returnRequestProductStatus,
    this.imagesUrl,
    this.img,
  });

  OrderDetail copyWith({
    int? detailId,
    int? productId,
    int? returnRequestId,
    int? quantity,
    String? image,
    String? name,
    String? variant,
    double? productPrice,
    double? subtotal,
    bool? alreadyReturn,
    int? returnRequestProductId,
    String? returnRequestProductQuantity,
    int? returnRequestProductReasonId,
    dynamic returnRequestProductDetails,
    String? returnRequestProductStatus,
    List<String>? imagesUrl,
    List<String>? img,
  }) =>
      OrderDetail(
        detailId: detailId ?? this.detailId,
        productId: productId ?? this.productId,
        returnRequestId: returnRequestId ?? this.returnRequestId,
        quantity: quantity ?? this.quantity,
        image: image ?? this.image,
        name: name ?? this.name,
        variant: variant ?? this.variant,
        productPrice: productPrice ?? this.productPrice,
        subtotal: subtotal ?? this.subtotal,
        alreadyReturn: alreadyReturn ?? this.alreadyReturn,
        returnRequestProductId:
            returnRequestProductId ?? this.returnRequestProductId,
        returnRequestProductQuantity:
            returnRequestProductQuantity ?? this.returnRequestProductQuantity,
        returnRequestProductReasonId:
            returnRequestProductReasonId ?? this.returnRequestProductReasonId,
        returnRequestProductDetails:
            returnRequestProductDetails ?? this.returnRequestProductDetails,
        returnRequestProductStatus:
            returnRequestProductStatus ?? this.returnRequestProductStatus,
        imagesUrl: imagesUrl ?? this.imagesUrl,
        img: img ?? this.img,
      );

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        detailId: json["detail_id"],
        productId: json["product_id"],
        returnRequestId: json["return_request_id"],
        quantity: json["quantity"],
        image: json["image"],
        name: json["name"],
        variant: json["variant"],
        productPrice: double.tryParse(json["product_price"].toString()),
        subtotal: double.tryParse(json["subtotal"].toString()),
        alreadyReturn: json["already_return"],
        returnRequestProductId: json["return_request_product_id"],
        returnRequestProductQuantity: json["return_request_product_quantity"],
        returnRequestProductReasonId: json["return_request_product_reason_id"],
        returnRequestProductDetails: json["return_request_product_details"],
        returnRequestProductStatus: json["return_request_product_status"],
        imagesUrl: json["images_url"] == null
            ? []
            : List<String>.from(json["images_url"]!.map((x) => x)),
        img: json["img"] == null
            ? []
            : List<String>.from(json["img"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "detail_id": detailId,
        "product_id": productId,
        "return_request_id": returnRequestId,
        "quantity": quantity,
        "image": image,
        "name": name,
        "variant": variant,
        "product_price": productPrice,
        "subtotal": subtotal,
        "already_return": alreadyReturn,
        "return_request_product_id": returnRequestProductId,
        "return_request_product_quantity": returnRequestProductQuantity,
        "return_request_product_reason_id": returnRequestProductReasonId,
        "return_request_product_details": returnRequestProductDetails,
        "return_request_product_status": returnRequestProductStatus,
        "images_url": imagesUrl == null
            ? []
            : List<String>.from(imagesUrl!.map((x) => x)),
        "img": img == null ? [] : List<String>.from(img!.map((x) => x)),
      };
}
