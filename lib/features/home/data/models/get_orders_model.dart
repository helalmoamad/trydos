import 'package:trydos/core/utils/extensions/list.dart';

class OrderModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final OrderDataModel? data;

  OrderModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  OrderModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    OrderDataModel? data,
  }) => OrderModel(
    isSuccessful: isSuccessful ?? this.isSuccessful,
    hasContent: hasContent ?? this.hasContent,
    code: code ?? this.code,
    message: message ?? this.message,
    detailedError: detailedError ?? this.detailedError,
    data: data ?? this.data,
  );

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    isSuccessful: json["isSuccessful"],
    hasContent: json["hasContent"],
    code: json["code"],
    message: json["message"],
    detailedError: json["detailed_error"],
    data: json["data"] == null ? null : OrderDataModel.fromJson(json["data"]),
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

class OrderDataModel {
  final int? total;
  final int? limit;
  final int? offset;
  final List<OrderListModel>? orders;

  OrderDataModel({this.total, this.limit, this.offset, this.orders});

  OrderDataModel copyWith({
    int? total,
    int? limit,
    int? offset,
    List<OrderListModel>? orders,
  }) => OrderDataModel(
    total: total ?? this.total,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
    orders: orders ?? this.orders,
  );

  factory OrderDataModel.fromJson(Map<String, dynamic> json) => OrderDataModel(
    total: json["total"],
    limit: json["limit"],
    offset: json["offset"],
    orders: json["orders"] == null
        ? []
        : List<OrderListModel>.from(
            json["orders"]!.map((x) => OrderListModel.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "limit": limit,
    "offset": offset,
    "orders": orders == null
        ? []
        : List<dynamic>.from(orders!.map((x) => x.toJson())),
  };
}

class OrderListModel {
  final int? id;
  final int? customerId;
  final String? paymentStatus;
  final OrderStatus? orderStatus;

  final OrderStatus? orderGroupStatus;
  final OrderStatus? paymentMethod;
  final String? transactionRef;
  final double? orderAmount;
  final double? partialPaymentByWallet;
  final double? discountAmount;
  final double? shippingCost;
  final int? shippingAddress;
  final ShippingAddressData? shippingAddressData;
  final dynamic billingAddress;
  final dynamic billingAddressData;
  final String? discountType;
  final String? couponCode;
  final int? shippingMethodId;
  final String? orderGroupId;
  final String? verificationCode;
  final String? orderNote;
  final String? sellerId;
  final String? ownerType;
  final String? ownerId;
  final bool? canReturnOrder;
  final String? createdAt;
  final bool? orderCanReturn;
  final bool? orderHasReturnRequest;
  final String? returnRequestId;
  final bool? showReturnRequest;
  final bool? editReturnRequest;
  final bool? orderCanExchange;
  final bool? canUpdateAddress;
  final bool? canCanceleOrder;
  final bool? canChangeVariant;
  final List<OrderListDetailModel>? details;

  OrderListModel({
    this.id,
    this.canReturnOrder,
    this.customerId,
    this.paymentStatus,
    this.orderStatus,
    this.orderGroupStatus,
    this.paymentMethod,
    this.transactionRef,
    this.ownerType,
    this.ownerId,
    this.orderAmount,
    this.partialPaymentByWallet,
    this.discountAmount,
    this.shippingCost,
    this.shippingAddress,
    this.shippingAddressData,
    this.billingAddress,
    this.billingAddressData,
    this.discountType,
    this.couponCode,
    this.shippingMethodId,
    this.orderGroupId,
    this.verificationCode,
    this.orderNote,
    this.sellerId,
    this.canUpdateAddress,
    this.canCanceleOrder,
    this.createdAt,
    this.canChangeVariant,
    this.orderCanReturn,
    this.orderHasReturnRequest,
    this.returnRequestId,
    this.showReturnRequest,
    this.editReturnRequest,
    this.orderCanExchange,
    this.details,
  });

  OrderListModel copyWith({
    int? id,
    int? customerId,
    String? paymentStatus,
    OrderStatus? orderStatus,
    OrderStatus? orderGroupStatus,
    OrderStatus? paymentMethod,
    String? transactionRef,
    double? orderAmount,
    double? partialPaymentByWallet,
    double? discountAmount,
    bool? canReturnOrder,
    double? shippingCost,
    int? shippingAddress,
    ShippingAddressData? shippingAddressData,
    dynamic billingAddress,
    dynamic billingAddressData,
    String? discountType,
    String? couponCode,
    int? shippingMethodId,
    String? orderGroupId,
    String? verificationCode,
    String? orderNote,
    String? sellerId,
    String? ownerType,
    String? ownerId,
    String? createdAt,
    bool? orderCanReturn,
    bool? orderHasReturnRequest,
    String? returnRequestId,
    bool? showReturnRequest,
    bool? editReturnRequest,
    bool? orderCanExchange,
    bool? canUpdateAddress,
    bool? canCanceleOrder,
    bool? canChangeVariant,
    List<OrderListDetailModel>? details,
  }) => OrderListModel(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    canUpdateAddress: canUpdateAddress ?? this.canUpdateAddress,
    canCanceleOrder: canCanceleOrder ?? this.canCanceleOrder,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    orderStatus: orderStatus ?? this.orderStatus,
    orderGroupStatus: orderGroupStatus ?? this.orderGroupStatus,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    transactionRef: transactionRef ?? this.transactionRef,
    orderAmount: orderAmount ?? this.orderAmount,
    canChangeVariant: canChangeVariant ?? this.canChangeVariant,
    partialPaymentByWallet:
        partialPaymentByWallet ?? this.partialPaymentByWallet,
    discountAmount: discountAmount ?? this.discountAmount,
    canReturnOrder: canReturnOrder ?? this.canReturnOrder,
    shippingCost: shippingCost ?? this.shippingCost,
    shippingAddress: shippingAddress ?? this.shippingAddress,
    shippingAddressData: shippingAddressData ?? this.shippingAddressData,
    billingAddress: billingAddress ?? this.billingAddress,
    billingAddressData: billingAddressData ?? this.billingAddressData,
    discountType: discountType ?? this.discountType,
    couponCode: couponCode ?? this.couponCode,
    shippingMethodId: shippingMethodId ?? this.shippingMethodId,
    orderGroupId: orderGroupId ?? this.orderGroupId,
    verificationCode: verificationCode ?? this.verificationCode,
    orderNote: orderNote ?? this.orderNote,
    ownerType: ownerType ?? this.ownerType,
    ownerId: ownerId ?? this.ownerId,
    sellerId: sellerId ?? this.sellerId,
    createdAt: createdAt ?? this.createdAt,
    orderCanReturn: orderCanReturn ?? this.orderCanReturn,
    orderHasReturnRequest: orderHasReturnRequest ?? this.orderHasReturnRequest,
    returnRequestId: returnRequestId ?? this.returnRequestId,
    showReturnRequest: showReturnRequest ?? this.showReturnRequest,
    editReturnRequest: editReturnRequest ?? this.editReturnRequest,
    orderCanExchange: orderCanExchange ?? this.orderCanExchange,
    details: details ?? this.details,
  );

  factory OrderListModel.fromJson(Map<String, dynamic> json) => OrderListModel(
    id: json["id"],
    customerId: json["customer_id"],
    paymentStatus: json["payment_status"],
    orderStatus: json["order_status"] == null
        ? null
        : OrderStatus.fromJson(json["order_status"]),
    orderGroupStatus: json["order_group_status"] == null
        ? null
        : OrderStatus.fromJson(json["order_group_status"]),
    canReturnOrder: json["can_return_order"],
    paymentMethod: json["payment_method"] == null
        ? null
        : OrderStatus.fromJson(json["payment_method"]),
    transactionRef: json["transaction_ref"],
    orderAmount: json["order_amount"] == null
        ? 0
        : double.parse(json["order_amount"].toString()),
    partialPaymentByWallet: json["partial_payment_by_wallet"] == null
        ? 0
        : double.parse(json["partial_payment_by_wallet"].toString()),
    discountAmount: json["discount_amount"] == null
        ? 0
        : double.parse(json["discount_amount"].toString()),
    shippingCost: json["shipping_cost"] == null
        ? 0
        : double.parse(json["shipping_cost"].toString()),
    shippingAddress: json["shipping_address"],
    shippingAddressData: json["shipping_address_data"] == null
        ? null
        : ShippingAddressData.fromJson(json["shipping_address_data"]),
    billingAddress: json["billing_address"],
    billingAddressData: json["billing_address_data"],
    discountType: json["discount_type"],
    couponCode: json["coupon_code"],
    shippingMethodId: json["shipping_method_id"],
    ownerType: json["owner_type"],
    ownerId: json["owner_id"].toString(),
    orderGroupId: json["order_group_id"],
    canUpdateAddress: json["can_update_address"],
    canChangeVariant: json["can_change_variant"],
    canCanceleOrder: json["can_cancele_order"],
    verificationCode: json["verification_code"],
    orderNote: json["order_note"],
    sellerId: json["seller_id"] == null ? null : json["seller_id"].toString(),
    createdAt: json["created_at"] ?? '',
    orderCanReturn: json["order_can_return"],
    orderHasReturnRequest: json["order_has_return_request"],
    returnRequestId: json["return_request_id"] == null
        ? null
        : json["return_request_id"].toString(),
    showReturnRequest: json["show_return_request"],
    editReturnRequest: json["edit_return_request"],
    orderCanExchange: json["order_can_exchange"],
    details: json["details"] == null
        ? []
        : List<OrderListDetailModel>.from(
            json["details"]!.map((x) => OrderListDetailModel.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customer_id": customerId,
    "payment_status": paymentStatus,
    "order_status": orderStatus?.toJson(),
    "order_group_status": orderGroupStatus?.toJson(),
    "payment_method": paymentMethod?.toJson(),
    "transaction_ref": transactionRef,
    "order_amount": orderAmount,
    "can_change_variant": canChangeVariant,
    "can_return_order": canReturnOrder,
    "partial_payment_by_wallet": partialPaymentByWallet,
    "discount_amount": discountAmount,
    "owner_type": ownerType,
    "owner_id": ownerId,
    "shipping_cost": shippingCost,
    "shipping_address": shippingAddress,
    "can_update_address": canUpdateAddress,
    "can_cancele_order": canCanceleOrder,
    "shipping_address_data": shippingAddressData?.toJson(),
    "billing_address": billingAddress,
    "billing_address_data": billingAddressData,
    "discount_type": discountType,
    "coupon_code": couponCode,
    "shipping_method_id": shippingMethodId,
    "order_group_id": orderGroupId,
    "verification_code": verificationCode,
    "order_note": orderNote,
    "seller_id": sellerId,
    "created_at": createdAt,
    "order_can_return": orderCanReturn,
    "order_has_return_request": orderHasReturnRequest,
    "return_request_id": returnRequestId.toString(),
    "show_return_request": showReturnRequest,
    "edit_return_request": editReturnRequest,
    "order_can_exchange": orderCanExchange,
    "details": details == null
        ? []
        : List<dynamic>.from(details!.map((x) => x.toJson())),
  };
}

class OrderListDetailModel {
  final int? id;
  final int? orderId;
  final int? productId;
  final String? productSlug;
  final OrderProductDetailsModel? productDetails;
  final double? qty;
  final double? price;

  final double? discount;
  final double? priceAfterDiscount;
  final double? tax;
  final String? deliveryStatus;
  final String? paymentStatus;
  final dynamic shippingMethodId;
  final String? variant;
  final bool? collectProductAfterOrdering;
  final List<GetOrderVariationModel>? variation;
  final String? discountType;
  final int? isStockDecreased;
  final String? refundRequest;
  final dynamic refundRequestStatus;
  final int? isOdooProduct;
  final int? odooId;
  final int? odooOrderId;
  //final List<OrderRatingAndComment>? comments;
  final String? image;

  OrderListDetailModel({
    this.id,
    this.orderId,
    this.productId,
    this.productDetails,
    this.qty,
    this.price,
    this.discount,
    //this.comments,
    this.priceAfterDiscount,
    this.tax,
    this.deliveryStatus,
    this.paymentStatus,
    this.shippingMethodId,
    this.variant,
    this.collectProductAfterOrdering,
    this.variation,
    this.discountType,
    this.isStockDecreased,
    this.refundRequest,
    this.refundRequestStatus,
    this.isOdooProduct,
    this.odooId,
    this.odooOrderId,
    this.image,
    this.productSlug,
  });

  OrderListDetailModel copyWith({
    int? id,
    int? orderId,
    int? productId,
    String? productSlug,
    OrderProductDetailsModel? productDetails,
    double? qty,
    double? price,
    double? discount,
    //List<OrderRatingAndComment>? comments,
    double? priceAfterDiscount,
    double? tax,
    String? deliveryStatus,
    String? paymentStatus,
    dynamic shippingMethodId,
    String? variant,
    bool? collectProductAfterOrdering,
    List<GetOrderVariationModel>? variation,
    String? discountType,
    int? isStockDecreased,
    String? refundRequest,
    dynamic refundRequestStatus,
    int? isOdooProduct,
    int? odooId,
    int? odooOrderId,
    String? image,
  }) => OrderListDetailModel(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    productId: productId ?? this.productId,
    // comments: comments ?? this.comments,
    productDetails: productDetails ?? this.productDetails,
    qty: qty ?? this.qty,
    price: price ?? this.price,
    productSlug: productSlug ?? this.productSlug,
    discount: discount ?? this.discount,
    priceAfterDiscount: priceAfterDiscount ?? this.priceAfterDiscount,
    tax: tax ?? this.tax,
    deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    shippingMethodId: shippingMethodId ?? this.shippingMethodId,
    variant: variant ?? this.variant,
    collectProductAfterOrdering:
        collectProductAfterOrdering ?? this.collectProductAfterOrdering,
    variation: variation ?? this.variation,
    discountType: discountType ?? this.discountType,
    isStockDecreased: isStockDecreased ?? this.isStockDecreased,
    refundRequest: refundRequest ?? this.refundRequest,
    refundRequestStatus: refundRequestStatus ?? this.refundRequestStatus,
    isOdooProduct: isOdooProduct ?? this.isOdooProduct,
    odooId: odooId ?? this.odooId,
    odooOrderId: odooOrderId ?? this.odooOrderId,
    image: image ?? this.image,
  );

  factory OrderListDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderListDetailModel(
      id: json["id"],
      orderId: json["order_id"],
      productId: json["product_id"],
      productSlug: json["product_slug"],
      // comments: json["comments"] == null
      //    ? []
      //    : List<OrderRatingAndComment>.from(
      //        json["comments"]!.map((x) => OrderRatingAndComment.fromJson(x))),
      productDetails: json["product_details"] == null
          ? null
          : OrderProductDetailsModel.fromJson(json["product_details"]),
      qty: json["qty"] == null ? 0 : double.parse(json["qty"].toString()),
      price: json["price"] == null ? 0 : double.parse(json["price"].toString()),
      discount: json["discount"] == null
          ? 0
          : double.parse(json["discount"].toString()),
      priceAfterDiscount: json["price_after_discount"] == null
          ? 0
          : double.parse(json["price_after_discount"].toString()),
      tax: json["tax"] == null ? 0 : double.parse(json["tax"].toString()),
      deliveryStatus: json["delivery_status"],
      paymentStatus: json["payment_status"],
      shippingMethodId: json["shipping_method_id"],
      variant: json["variant"] == null ? null : json["variant"],
      collectProductAfterOrdering: json["collect_product_after_ordering"],
      variation: json["variation"] == null
          ? []
          : (json["variation"] is List)
          ? (json["variation"] as List).isEmpty
                ? []
                : json["variation"]?.first.isEmpty
                ? []
                : List<GetOrderVariationModel>.from(
                    json["variation"].map(
                      (x) => GetOrderVariationModel.fromJson(x),
                    ),
                  ).where((element) => element.type == json["variant"]).toList()
          : [],
      discountType: json["discount_type"],
      isStockDecreased: json["is_stock_decreased"],
      refundRequest: json["refund_request"].toString(),
      refundRequestStatus: json["refund_request_status"],
      isOdooProduct: json["is_odoo_product"],
      odooId: json["odoo_id"],
      odooOrderId: json["odoo_order_id"],
      image: json["image"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "product_id": productId,
    "product_details": productDetails?.toJson(),
    "qty": qty,
    "price": price,
    "discount": discount,
    "price_after_discount": priceAfterDiscount,
    "tax": tax,
    "delivery_status": deliveryStatus,
    "payment_status": paymentStatus,
    "product_slug": productSlug,
    "shipping_method_id": shippingMethodId,
    "variant": variant,
    // "comments": comments == null
    //    ? []
    //    : List<dynamic>.from(comments!.map((x) => x.toJson())),
    "collect_product_after_ordering": collectProductAfterOrdering,
    "variation": variation.isNullOrEmpty
        ? []
        : (variation?.first is List)
        ? []
        : List<dynamic>.from(variation!.map((x) => x.toJson())),
    "discount_type": discountType,
    "is_stock_decreased": isStockDecreased,
    "refund_request": refundRequest.toString(),
    "refund_request_status": refundRequestStatus,
    "is_odoo_product": isOdooProduct,
    "odoo_id": odooId,
    "odoo_order_id": odooOrderId,
    "image": image,
  };
}

class OrderRatingAndComment {
  final int? id;
  final String? comment;
  final String? starRating;

  OrderRatingAndComment({this.id, this.comment, this.starRating});

  OrderRatingAndComment copyWith({
    int? id,
    String? comment,
    String? starRating,
  }) => OrderRatingAndComment(
    id: id ?? this.id,
    comment: comment ?? this.comment,
    starRating: starRating ?? this.starRating,
  );

  factory OrderRatingAndComment.fromJson(Map<String, dynamic> json) =>
      OrderRatingAndComment(
        id: json["id"],
        comment: json["comment"],
        starRating: json["star_rating"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "comment": comment,
    "star_rating": starRating,
  };
}

class OrderProductDetailsModel {
  final int? id;
  final String? name;
  final String? slug;
  final String? shareLink;
  final String? details;
  final int? countOfPieces;
  final String? thumbnail;
  final List<String>? images;
  //final double? price;
  // final double? offerPrice;
  final bool? isFavourite;
  final bool? inStock;
  final GetOrderRatingModel? rating;

  OrderProductDetailsModel({
    this.id,
    this.name,
    this.slug,
    this.shareLink,
    this.details,
    this.thumbnail,
    this.images,
    // this.price,
    this.countOfPieces,
    //  this.offerPrice,
    this.isFavourite,
    this.inStock,
    this.rating,
  });

  OrderProductDetailsModel copyWith({
    int? id,
    String? name,
    String? slug,
    int? countOfPieces,
    String? shareLink,
    String? details,
    String? thumbnail,
    List<String>? images,
    double? price,
    double? offerPrice,
    bool? isFavourite,
    bool? inStock,
    GetOrderRatingModel? rating,
  }) => OrderProductDetailsModel(
    id: id ?? this.id,
    name: name ?? this.name,
    slug: slug ?? this.slug,
    shareLink: shareLink ?? this.shareLink,
    details: details ?? this.details,
    thumbnail: thumbnail ?? this.thumbnail,
    images: images ?? this.images,
    //  price: price ?? this.price,
    //offerPrice: offerPrice ?? this.offerPrice,
    isFavourite: isFavourite ?? this.isFavourite,
    inStock: inStock ?? this.inStock,
    countOfPieces: countOfPieces ?? this.countOfPieces,
    rating: rating ?? this.rating,
  );

  factory OrderProductDetailsModel.fromJson(Map<String, dynamic> json) =>
      OrderProductDetailsModel(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        shareLink: json["share_link"],
        details: json["details"],
        thumbnail: json["thumbnail"],
        countOfPieces: json["count_of_pieces"] ?? 0,
        images: json["images"] == null
            ? []
            : List<String>.from(json["images"]!.map((x) => x)),
        //  price:
        //   json["price"] == null ? 0 : double.parse(json["price"].toString()),
        //  offerPrice: json["offer_price"] == null
        //    ? 0
        //: double.parse(json["offer_price"].toString()),
        isFavourite: json["is_favourite"],
        inStock: json["in_stock"],
        rating: json["rating"] == null
            ? null
            : GetOrderRatingModel.fromJson(json["rating"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "share_link": shareLink,
    "details": details,
    "thumbnail": thumbnail,
    "count_of_pieces": countOfPieces,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    // "price": price,
    // "offer_price": offerPrice,
    "is_favourite": isFavourite,
    "in_stock": inStock,
    "rating": rating?.toJson(),
  };
}

class GetOrderRatingModel {
  final int? overallRating;
  final int? totalRating;

  GetOrderRatingModel({this.overallRating, this.totalRating});

  GetOrderRatingModel copyWith({int? overallRating, int? totalRating}) =>
      GetOrderRatingModel(
        overallRating: overallRating ?? this.overallRating,
        totalRating: totalRating ?? this.totalRating,
      );

  factory GetOrderRatingModel.fromJson(Map<String, dynamic> json) =>
      GetOrderRatingModel(
        overallRating: json["overall_rating"],
        totalRating: json["total_rating"],
      );

  Map<String, dynamic> toJson() => {
    "overall_rating": overallRating,
    "total_rating": totalRating,
  };
}

class GetOrderVariationModel {
  final String? id;
  final String? size;
  final VariationColor? color;
  final String? type;
  final double? price;
  final double? offerPrice;
  final double? luckPrice;
  final String? sku;
  final int? qty;

  GetOrderVariationModel({
    this.id,
    this.size,
    this.color,
    this.type,
    this.price,
    this.offerPrice,
    this.luckPrice,
    this.sku,
    this.qty,
  });

  GetOrderVariationModel copyWith({
    String? id,
    String? size,
    VariationColor? color,
    String? type,
    double? price,
    double? offerPrice,
    double? luckPrice,
    String? sku,
    int? qty,
  }) => GetOrderVariationModel(
    id: id ?? this.id,
    size: size ?? this.size,
    color: color ?? this.color,
    type: type ?? this.type,
    price: price ?? this.price,
    offerPrice: offerPrice ?? this.offerPrice,
    luckPrice: luckPrice ?? this.luckPrice,
    sku: sku ?? this.sku,
    qty: qty ?? this.qty,
  );

  factory GetOrderVariationModel.fromJson(Map<String, dynamic> json) =>
      GetOrderVariationModel(
        id: json["id"],
        size: json["size"],
        color: json["color"] == null
            ? null
            : VariationColor.fromJson(json["color"]),
        type: json["type"],
        price: double.tryParse(json["price"].toString()),
        offerPrice: double.tryParse(json["offer_price"].toString()),
        luckPrice: double.tryParse(json["luck_price"].toString()),
        sku: json["sku"],
        qty: json["qty"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "size": size,
    "color": color?.toJson(),
    "type": type,
    "price": price,
    "offer_price": offerPrice,
    "luck_price": luckPrice,
    "sku": sku,
    "qty": qty,
  };
}

class VariationColor {
  final String? name;
  final String? code;

  VariationColor({this.name, this.code});

  VariationColor copyWith({String? name, String? code}) =>
      VariationColor(name: name ?? this.name, code: code ?? this.code);

  factory VariationColor.fromJson(Map<String, dynamic> json) =>
      VariationColor(name: json["name"], code: json["code"]);

  Map<String, dynamic> toJson() => {"name": name, "code": code};
}

class OrderStatus {
  final String? value;
  final String? label;

  OrderStatus({this.value, this.label});

  OrderStatus copyWith({String? value, String? label}) =>
      OrderStatus(value: value ?? this.value, label: label ?? this.label);

  factory OrderStatus.fromJson(Map<String, dynamic> json) =>
      OrderStatus(value: json["value"], label: json["label"]);

  Map<String, dynamic> toJson() => {"value": value, "label": label};
}

class ShippingAddressData {
  final int? id;
  final String? countryIso;
  final int? customerId;
  final String? contactPersonName;
  final String? addressType;
  final String? address;
  final String? addressDetail;
  final String? country;
  final String? province;
  final String? city;
  final String? town;
  final String? street;
  final String? building;
  final dynamic zip;
  final String? phone;
  final dynamic alternativePhone;
  final String? createdAt;
  final String? updatedAt;
  final String? latitude;
  final String? longitude;
  final int? isBilling;
  final int? isDefault;
  final dynamic email;
  final String? cost;
  final dynamic duration;

  ShippingAddressData({
    this.id,
    this.countryIso,
    this.customerId,
    this.contactPersonName,
    this.addressType,
    this.address,
    this.addressDetail,
    this.country,
    this.province,
    this.city,
    this.town,
    this.street,
    this.building,
    this.zip,
    this.phone,
    this.alternativePhone,
    this.createdAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.isBilling,
    this.isDefault,
    this.email,
    this.cost,
    this.duration,
  });

  ShippingAddressData copyWith({
    int? id,
    String? countryIso,
    int? customerId,
    String? contactPersonName,
    String? addressType,
    String? address,
    String? addressDetail,
    String? country,
    String? province,
    String? city,
    String? town,
    String? street,
    String? building,
    dynamic zip,
    String? phone,
    dynamic alternativePhone,
    String? createdAt,
    String? updatedAt,
    String? latitude,
    String? longitude,
    int? isBilling,
    int? isDefault,
    dynamic email,
    String? cost,
    dynamic duration,
  }) => ShippingAddressData(
    id: id ?? this.id,
    countryIso: countryIso ?? this.countryIso,
    customerId: customerId ?? this.customerId,
    contactPersonName: contactPersonName ?? this.contactPersonName,
    addressType: addressType ?? this.addressType,
    address: address ?? this.address,
    addressDetail: addressDetail ?? this.addressDetail,
    country: country ?? this.country,
    province: province ?? this.province,
    city: city ?? this.city,
    town: town ?? this.town,
    street: street ?? this.street,
    building: building ?? this.building,
    zip: zip ?? this.zip,
    phone: phone ?? this.phone,
    alternativePhone: alternativePhone ?? this.alternativePhone,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    isBilling: isBilling ?? this.isBilling,
    isDefault: isDefault ?? this.isDefault,
    email: email ?? this.email,
    cost: cost ?? this.cost,
    duration: duration ?? this.duration,
  );

  factory ShippingAddressData.fromJson(Map<String, dynamic> json) =>
      ShippingAddressData(
        id: json["id"],
        countryIso: json["country_iso"],
        customerId: json["customer_id"],
        contactPersonName: json["contact_person_name"],
        addressType: json["address_type"],
        address: json["address"],
        addressDetail: json["address_detail"],
        country: json["country"],
        province: json["province"],
        city: json["city"],
        town: json["town"],
        street: json["street"],
        building: json["building"],
        zip: json["zip"],
        phone: json["phone"],
        alternativePhone: json["alternative_phone"],
        createdAt: json["created_at"] ?? '',
        updatedAt: json["updated_at"] ?? '',
        latitude: json["latitude"],
        longitude: json["longitude"],
        isBilling: json["is_billing"],
        isDefault: json["is_default"],
        email: json["email"],
        cost: json["cost"].toString(),
        duration: json["duration"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "country_iso": countryIso,
    "customer_id": customerId,
    "contact_person_name": contactPersonName,
    "address_type": addressType,
    "address": address,
    "address_detail": addressDetail,
    "country": country,
    "province": province,
    "city": city,
    "town": town,
    "street": street,
    "building": building,
    "zip": zip,
    "phone": phone,
    "alternative_phone": alternativePhone,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "latitude": latitude,
    "longitude": longitude,
    "is_billing": isBilling,
    "is_default": isDefault,
    "email": email,
    "cost": cost.toString(),
    "duration": duration,
  };
}
