// To parse this JSON data, do
//
//     final getSellerOrdersModel = getSellerOrdersModelFromJson(jsonString);

import 'dart:convert';

GetSellerOrdersModel getSellerOrdersModelFromJson(String str) =>
    GetSellerOrdersModel.fromJson(json.decode(str));

String getSellerOrdersModelToJson(GetSellerOrdersModel data) =>
    json.encode(data.toJson());

class GetSellerOrdersModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  GetSellerOrdersModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GetSellerOrdersModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) => GetSellerOrdersModel(
    isSuccessful: isSuccessful ?? this.isSuccessful,
    hasContent: hasContent ?? this.hasContent,
    code: code ?? this.code,
    message: message ?? this.message,
    detailedError: detailedError ?? this.detailedError,
    data: data ?? this.data,
  );

  factory GetSellerOrdersModel.fromJson(Map<String, dynamic> json) =>
      GetSellerOrdersModel(
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
  final List<UserOrder>? orders;
  final UserAbilities? userAbilities;
  final Meta? meta;

  Data({this.orders, this.userAbilities, this.meta});

  Data copyWith({
    List<UserOrder>? orders,
    UserAbilities? userAbilities,
    Meta? meta,
  }) => Data(
    orders: orders ?? this.orders,
    userAbilities: userAbilities ?? this.userAbilities,
    meta: meta ?? this.meta,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    orders: json["orders"] == null
        ? []
        : List<UserOrder>.from(
            json["orders"]!.map((x) => UserOrder.fromJson(x)),
          ),
    userAbilities: json["user_abilities"] == null
        ? null
        : UserAbilities.fromJson(json["user_abilities"]),
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "orders": orders == null
        ? []
        : List<dynamic>.from(orders!.map((x) => x.toJson())),
    "user_abilities": userAbilities?.toJson(),
    "meta": meta?.toJson(),
  };
}

class Meta {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final int? from;
  final int? to;
  final bool? hasMorePages;
  final String? nextPageUrl;
  final dynamic prevPageUrl;

  Meta({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.from,
    this.to,
    this.hasMorePages,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  Meta copyWith({
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
    int? from,
    int? to,
    bool? hasMorePages,
    String? nextPageUrl,
    dynamic prevPageUrl,
  }) => Meta(
    currentPage: currentPage ?? this.currentPage,
    lastPage: lastPage ?? this.lastPage,
    perPage: perPage ?? this.perPage,
    total: total ?? this.total,
    from: from ?? this.from,
    to: to ?? this.to,
    hasMorePages: hasMorePages ?? this.hasMorePages,
    nextPageUrl: nextPageUrl ?? this.nextPageUrl,
    prevPageUrl: prevPageUrl ?? this.prevPageUrl,
  );

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
    from: json["from"],
    to: json["to"],
    hasMorePages: json["has_more_pages"],
    nextPageUrl: json["next_page_url"],
    prevPageUrl: json["prev_page_url"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
    "from": from,
    "to": to,
    "has_more_pages": hasMorePages,
    "next_page_url": nextPageUrl,
    "prev_page_url": prevPageUrl,
  };
}

class UserOrder {
  final int? id;
  final bool? canReturnOrder;
  final String? cartGroupId;
  final String? orderGroupId;
  final String? orderStatus;
  final String? orderGroupStatus;
  final String? paymentMethod;
  final PaymentStatus? paymentStatus;
  final double? codCost;
  final String? transactionRef;
  final double? orderAmount;
  final Type? deliveryType;
  final int? shippingAddress;
  final Type? shippingType;
  final double? discountAmount;
  final dynamic discountType;
  final dynamic couponCode;
  final double? shippingCost;
  final List<Detail>? details;
  final List<String>? availableOrderStatusChange;

  UserOrder({
    this.id,
    this.canReturnOrder,
    this.cartGroupId,
    this.orderGroupId,
    this.orderStatus,
    this.orderGroupStatus,
    this.paymentMethod,
    this.paymentStatus,
    this.codCost,
    this.transactionRef,
    this.orderAmount,
    this.deliveryType,
    this.shippingAddress,
    this.shippingType,
    this.discountAmount,
    this.discountType,
    this.couponCode,
    this.shippingCost,
    this.details,
    this.availableOrderStatusChange,
  });

  UserOrder copyWith({
    int? id,
    bool? canReturnOrder,
    String? cartGroupId,
    String? orderGroupId,
    String? orderStatus,
    String? orderGroupStatus,
    String? paymentMethod,
    PaymentStatus? paymentStatus,
    double? codCost,
    String? transactionRef,
    double? orderAmount,
    Type? deliveryType,
    int? shippingAddress,
    Type? shippingType,
    double? discountAmount,
    dynamic discountType,
    dynamic couponCode,
    double? shippingCost,
    List<Detail>? details,
    List<String>? availableOrderStatusChange,
  }) => UserOrder(
    id: id ?? this.id,
    canReturnOrder: canReturnOrder ?? this.canReturnOrder,
    cartGroupId: cartGroupId ?? this.cartGroupId,
    orderGroupId: orderGroupId ?? this.orderGroupId,
    orderStatus: orderStatus ?? this.orderStatus,
    orderGroupStatus: orderGroupStatus ?? this.orderGroupStatus,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    codCost: codCost ?? this.codCost,
    transactionRef: transactionRef ?? this.transactionRef,
    orderAmount: orderAmount ?? this.orderAmount,
    deliveryType: deliveryType ?? this.deliveryType,
    shippingAddress: shippingAddress ?? this.shippingAddress,
    shippingType: shippingType ?? this.shippingType,
    discountAmount: discountAmount ?? this.discountAmount,
    discountType: discountType ?? this.discountType,
    couponCode: couponCode ?? this.couponCode,
    shippingCost: shippingCost ?? this.shippingCost,
    details: details ?? this.details,
    availableOrderStatusChange: availableOrderStatusChange ?? this.availableOrderStatusChange,
  );

  factory UserOrder.fromJson(Map<String, dynamic> json) => UserOrder(
    id: json["id"],
    canReturnOrder: json["can_return_order"],
    cartGroupId: json["cart_group_id"],
    orderGroupId: json["order_group_id"],
    orderStatus: json["order_status"],
    orderGroupStatus: json["order_group_status"],
    paymentMethod: json["payment_method"]?.toString(),
    paymentStatus: paymentStatusValues.map[json["payment_status"]],
    codCost: double.tryParse(json["cod_cost"].toString()),
    transactionRef: json["transaction_ref"],
    orderAmount: double.tryParse(json["order_amount"].toString()),
    deliveryType: typeValues.map[json["delivery_type"]],
    shippingAddress: json["shipping_address"],
    shippingType: typeValues.map[json["shipping_type"]],
    discountAmount: double.tryParse(json["discount_amount"].toString()),
    discountType: json["discount_type"],
    couponCode: json["coupon_code"],
    shippingCost: double.tryParse(json["shipping_cost"].toString()),
    details: json["details"] == null
    ? []
    : List<Detail>.from(
        json["details"].map(
          (x) => Detail.fromJson(x),
        ),
      ),
    availableOrderStatusChange: json["available_order_status_change"] == null
        ? []
        : List<String>.from(json["available_order_status_change"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "can_return_order": canReturnOrder,
    "cart_group_id": cartGroupId,
    "order_group_id": orderGroupId,
    "order_status": orderStatus,
    "order_group_status": orderGroupStatus,
    "payment_method": paymentMethod,
    "payment_status": paymentStatusValues.reverse[paymentStatus],
    "cod_cost": codCost,
    "transaction_ref": transactionRef,
    "order_amount": orderAmount,
    "delivery_type": typeValues.reverse[deliveryType],
    "shipping_address": shippingAddress,
    "shipping_type": typeValues.reverse[shippingType],
    "discount_amount": discountAmount,
    "discount_type": discountType,
    "coupon_code": couponCode,
    "shipping_cost": shippingCost,
    "details": details == null
        ? []
        : List<dynamic>.from(
            details!.map((x) => x.toJson()),
          ),
    "available_order_status_change": availableOrderStatusChange == null
        ? []
        : List<dynamic>.from(availableOrderStatusChange!.map((x) => x)),
  };
}

enum Type { EXTERNAL_SHIPPING_COMPANY, PRODUCT_WISE }

final typeValues = EnumValues({
  "external_shipping_company": Type.EXTERNAL_SHIPPING_COMPANY,
  "product_wise": Type.PRODUCT_WISE,
});

class Detail {
  final int? id;
  final int? orderId;
  final int? sellerId;
  final int? productId;
  final String? productDetails;
  final String? variant;
  final String? cartImage;
  final int? qty;
  final double? price;
  final double? weight;
  final double? shippingCost;
  final int? isRedeem;
  final DeliveryStatus? deliveryStatus;
  final PaymentStatus? paymentStatus;

  Detail({
    this.id,
    this.orderId,
    this.sellerId,
    this.productId,
    this.productDetails,
    this.variant,
    this.cartImage,
    this.qty,
    this.price,
    this.weight,
    this.shippingCost,
    this.isRedeem,
    this.deliveryStatus,
    this.paymentStatus,
  });

  Detail copyWith({
    int? id,
    int? orderId,
    int? sellerId,
    int? productId,
    String? productDetails,
    String? variant,
    String? cartImage,
    int? qty,
    double? price,
    double? weight,
    double? shippingCost,
    int? isRedeem,
    DeliveryStatus? deliveryStatus,
    PaymentStatus? paymentStatus,
  }) => Detail(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    sellerId: sellerId ?? this.sellerId,
    productId: productId ?? this.productId,
    productDetails: productDetails ?? this.productDetails,
    variant: variant ?? this.variant,
    cartImage: cartImage ?? this.cartImage,
    qty: qty ?? this.qty,
    price: price ?? this.price,
    weight: weight ?? this.weight,
    shippingCost: shippingCost ?? this.shippingCost,
    isRedeem: isRedeem ?? this.isRedeem,
    deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    paymentStatus: paymentStatus ?? this.paymentStatus,
  );

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    id: json["id"],
    orderId: json["order_id"],
    sellerId: json["seller_id"],
    productId: json["product_id"],
    productDetails: json["product_details"],
    variant: json["variant"],
    cartImage: json["cart_image"],
    qty: json["qty"],
    price: double.tryParse(json["price"].toString()),
    weight: double.tryParse(json["weight"].toString()),
    shippingCost: double.tryParse(json["shipping_cost"].toString()),
    isRedeem: json["is_redeem"],
    deliveryStatus: deliveryStatusValues.map[json["delivery_status"]],
    paymentStatus: paymentStatusValues.map[json["payment_status"]],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "seller_id": sellerId,
    "product_id": productId,
    "product_details": productDetails,
    "variant": variant,
    "cart_image": cartImage,
    "qty": qty,
    "price": price,
    "weight": weight,
    "shipping_cost": shippingCost,
    "is_redeem": isRedeem,
    "delivery_status": deliveryStatusValues.reverse[deliveryStatus],
    "payment_status": paymentStatusValues.reverse[paymentStatus],
  };
}

enum DeliveryStatus { PENDING }

final deliveryStatusValues = EnumValues({"pending": DeliveryStatus.PENDING});

enum PaymentStatus { PAID, UNPAID }

final paymentStatusValues = EnumValues({
  "paid": PaymentStatus.PAID,
  "unpaid": PaymentStatus.UNPAID,
});

// PaymentMethod is now a dynamic string to support any payment method from API

class UserAbilities {
  final List<String>? changeOrderStatus;

  UserAbilities({this.changeOrderStatus});

  UserAbilities copyWith({List<String>? changeOrderStatus}) => UserAbilities(
    changeOrderStatus: changeOrderStatus ?? this.changeOrderStatus,
  );

  factory UserAbilities.fromJson(Map<String, dynamic> json) => UserAbilities(
    changeOrderStatus: json["change_order_status"] == null
        ? []
        : List<String>.from(json["change_order_status"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "change_order_status": changeOrderStatus == null
        ? []
        : List<dynamic>.from(changeOrderStatus!.map((x) => x)),
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
