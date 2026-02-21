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
  final String? orderGroupId;
  final int? totalReturnRequests;
  final List<ReturnRequestsDatum>? returnRequestsData;

  Data({
    this.orderGroupId,
    this.totalReturnRequests,
    this.returnRequestsData,
  });

  Data copyWith({
    String? orderGroupId,
    int? totalReturnRequests,
    List<ReturnRequestsDatum>? returnRequestsData,
  }) =>
      Data(
        orderGroupId: orderGroupId ?? this.orderGroupId,
        totalReturnRequests: totalReturnRequests ?? this.totalReturnRequests,
        returnRequestsData: returnRequestsData ?? this.returnRequestsData,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderGroupId: json["order_group_id"],
        totalReturnRequests: json["total_return_requests"],
        returnRequestsData: json["return_requests_data"] == null
            ? []
            : List<ReturnRequestsDatum>.from(json["return_requests_data"]!
                .map((x) => ReturnRequestsDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "order_group_id": orderGroupId,
        "total_return_requests": totalReturnRequests,
        "return_requests_data": returnRequestsData == null
            ? []
            : List<dynamic>.from(returnRequestsData!.map((x) => x.toJson())),
      };
}

class ReturnRequestsDatum {
  final int? orderId;
  final int? returnRequestId;
  final double? totalReturnableAmount;
  final String? descriptionReturnableAmountLessThan0;
  final dynamic returnRequestDestinationId;
  final Status? status;
  final List<ReturnOrderDetail>? orderDetails;

  ReturnRequestsDatum({
    this.orderId,
    this.returnRequestId,
    this.totalReturnableAmount,
    this.descriptionReturnableAmountLessThan0,
    this.returnRequestDestinationId,
    this.status,
    this.orderDetails,
  });

  ReturnRequestsDatum copyWith({
    int? orderId,
    int? returnRequestId,
    double? totalReturnableAmount,
    String? descriptionReturnableAmountLessThan0,
    dynamic returnRequestDestinationId,
    Status? status,
    List<ReturnOrderDetail>? orderDetails,
  }) =>
      ReturnRequestsDatum(
        orderId: orderId ?? this.orderId,
        returnRequestId: returnRequestId ?? this.returnRequestId,
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

  factory ReturnRequestsDatum.fromJson(Map<String, dynamic> json) =>
      ReturnRequestsDatum(
        orderId: json["order_id"],
        returnRequestId: json["return_request_id"],
        totalReturnableAmount:
            double.tryParse(json["total_returnable_amount"].toString()),
        descriptionReturnableAmountLessThan0:
            json["description_returnable_amount_less_than_0"],
        returnRequestDestinationId: json["return_request_destination_id"],
        status: json["status"] == null ? null : Status.fromJson(json["status"]),
        orderDetails: json["order_details"] == null
            ? []
            : List<ReturnOrderDetail>.from(json["order_details"]!
                .map((x) => ReturnOrderDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "return_request_id": returnRequestId,
        "total_returnable_amount": totalReturnableAmount?.toDouble(),
        "description_returnable_amount_less_than_0":
            descriptionReturnableAmountLessThan0,
        "return_request_destination_id": returnRequestDestinationId,
        "status": status?.toJson(),
        "order_details": orderDetails == null
            ? []
            : List<dynamic>.from(orderDetails!.map((x) => x.toJson())),
      };
}

class ReturnOrderDetail {
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
  final Status? returnRequestProductStatus;
  final List<String>? imagesUrl;
  final List<String>? img;

  ReturnOrderDetail({
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

  ReturnOrderDetail copyWith({
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
    Status? returnRequestProductStatus,
    List<String>? imagesUrl,
    List<String>? img,
  }) =>
      ReturnOrderDetail(
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

  factory ReturnOrderDetail.fromJson(Map<String, dynamic> json) =>
      ReturnOrderDetail(
        detailId: json["detail_id"],
        productId: json["product_id"],
        returnRequestId: json["return_request_id"],
        quantity: json["quantity"],
        image: json["image"],
        name: json["name"],
        variant: json["variant"],
        productPrice: json["product_price"]?.toDouble(),
        subtotal: double.tryParse(json["subtotal"].toString()),
        alreadyReturn: json["already_return"],
        returnRequestProductId: json["return_request_product_id"],
        returnRequestProductQuantity: json["return_request_product_quantity"],
        returnRequestProductReasonId: json["return_request_product_reason_id"],
        returnRequestProductDetails: json["return_request_product_details"],
        returnRequestProductStatus:
            json["return_request_product_status"] == null
                ? null
                : Status.fromJson(json["return_request_product_status"]),
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
        "return_request_product_status": returnRequestProductStatus?.toJson(),
        "images_url": imagesUrl == null
            ? []
            : List<dynamic>.from(imagesUrl!.map((x) => x)),
        "img": img == null ? [] : List<dynamic>.from(img!.map((x) => x)),
      };
}

class Status {
  final String? name;
  final String? value;

  Status({
    this.name,
    this.value,
  });

  Status copyWith({
    String? name,
    String? value,
  }) =>
      Status(
        name: name ?? this.name,
        value: value ?? this.value,
      );

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        name: json["name"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "value": value,
      };
}
