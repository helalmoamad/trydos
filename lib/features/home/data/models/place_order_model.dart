class OrdersGroupModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final List<OrdersGroupDataModel>? data;

  OrdersGroupModel({
    required this.isSuccessful,
    required this.hasContent,
    required this.code,
    required this.message,
    required this.detailedError,
    required this.data,
  });

  OrdersGroupModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    List<OrdersGroupDataModel>? data,
  }) =>
      OrdersGroupModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory OrdersGroupModel.fromJson(Map<String, dynamic> json) =>
      OrdersGroupModel(
        isSuccessful: json["isSuccessful"] ?? '',
        hasContent: json["hasContent"] ?? false,
        code: json["code"] ?? 0,
        message: json["message"] ?? '',
        detailedError: json["detailed_error"],
        data: List<OrdersGroupDataModel>.from(
            json["data"].map((x) => OrdersGroupDataModel.fromJson(x))),
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

class OrdersGroupDataModel {
  final int? id;
  final int? customerId;
  final String? url;
  final String? paymentStatus;
  final ValueLableModel? orderStatus;
  final ValueLableModel? paymentMethod;
  final String? transactionRef;
  final double? orderAmount;
  final double? discountAmount;
  final double? shippingCost;
  final double? partialPaymentByWallet;
  final int? shippingAddress;
  final ShippingAddressDataModel? shippingAddressData;
  final dynamic billingAddress;
  final dynamic billingAddressData;
  final dynamic discountType;
  final dynamic couponCode;
  final int? shippingMethodId;
  final String? orderGroupId;
  final String? verificationCode;
  final String? orderNote;
  final String? sellerId;
  final bool? orderCanReturn;
  final bool? orderHasReturnRequest;
  final dynamic returnRequestId;
  final bool? showReturnRequest;
  final bool? editReturnRequest;
  final bool? orderCanExchange;
  final List<PlaceOrderDetailsModel>? details;

  OrdersGroupDataModel({
    required this.id,
    required this.customerId,
    required this.url,
    required this.paymentStatus,
    required this.orderStatus,
    required this.paymentMethod,
    required this.transactionRef,
    required this.orderAmount,
    required this.discountAmount,
    required this.shippingCost,
    required this.partialPaymentByWallet,
    required this.shippingAddress,
    required this.shippingAddressData,
    required this.billingAddress,
    required this.billingAddressData,
    required this.discountType,
    required this.couponCode,
    required this.shippingMethodId,
    required this.orderGroupId,
    required this.verificationCode,
    required this.orderNote,
    required this.sellerId,
    required this.orderCanReturn,
    required this.orderHasReturnRequest,
    required this.returnRequestId,
    required this.showReturnRequest,
    required this.editReturnRequest,
    required this.orderCanExchange,
    required this.details,
  });

  OrdersGroupDataModel copyWith({
    int? id,
    int? customerId,
    String? url,
    String? paymentStatus,
    ValueLableModel? orderStatus,
    ValueLableModel? paymentMethod,
    String? transactionRef,
    double? orderAmount,
    double? discountAmount,
    double? shippingCost,
    int? shippingAddress,
    double? partialPaymentByWallet,
    ShippingAddressDataModel? shippingAddressData,
    dynamic billingAddress,
    dynamic billingAddressData,
    dynamic discountType,
    dynamic couponCode,
    int? shippingMethodId,
    String? orderGroupId,
    String? verificationCode,
    String? orderNote,
    String? sellerId,
    bool? orderCanReturn,
    bool? orderHasReturnRequest,
    dynamic returnRequestId,
    bool? showReturnRequest,
    bool? editReturnRequest,
    bool? orderCanExchange,
    List<PlaceOrderDetailsModel>? details,
  }) =>
      OrdersGroupDataModel(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        url: url ?? this.url,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        orderStatus: orderStatus ?? this.orderStatus,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        transactionRef: transactionRef ?? this.transactionRef,
        orderAmount: orderAmount ?? this.orderAmount,
        discountAmount: discountAmount ?? this.discountAmount,
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
        sellerId: sellerId ?? this.sellerId,
        orderCanReturn: orderCanReturn ?? this.orderCanReturn,
        orderHasReturnRequest:
            orderHasReturnRequest ?? this.orderHasReturnRequest,
        returnRequestId: returnRequestId ?? this.returnRequestId,
        showReturnRequest: showReturnRequest ?? this.showReturnRequest,
        editReturnRequest: editReturnRequest ?? this.editReturnRequest,
        orderCanExchange: orderCanExchange ?? this.orderCanExchange,
        details: details ?? this.details,
        partialPaymentByWallet:
            partialPaymentByWallet ?? this.partialPaymentByWallet,
      );

  factory OrdersGroupDataModel.fromJson(Map<String, dynamic> json) =>
      OrdersGroupDataModel(
        id: json["id"] ?? 0,
        customerId: json["customer_id"] ?? 0,
        url: json["url"],
        paymentStatus: json["payment_status"] ?? '',
        orderStatus: json["order_status"] == null
            ? null
            : ValueLableModel.fromJson(json["order_status"]),
        paymentMethod: json["payment_method"] == null
            ? null
            : ValueLableModel.fromJson(json["payment_method"]),
        transactionRef: json["transaction_ref"] ?? '',
        orderAmount: json["order_amount"] == null
            ? 0
            : double.parse(json["order_amount"].toString()),
        discountAmount: json["discount_amount"] == null
            ? 0
            : double.parse(json["discount_amount"].toString()),
        shippingCost: json["shipping_cost"] == null
            ? 0
            : double.parse(json["shipping_cost"].toString()),
        shippingAddress: json["shipping_address"] ?? 0,
        shippingAddressData: json["shipping_address_data"] == null
            ? null
            : ShippingAddressDataModel.fromJson(json["shipping_address_data"]),
        billingAddress: json["billing_address"],
        billingAddressData: json["billing_address_data"],
        discountType: json["discount_type"],
        couponCode: json["coupon_code"],
        shippingMethodId: json["shipping_method_id"],
        orderGroupId: json["order_group_id"] ?? '',
        verificationCode: json["verification_code"] ?? '',
        orderNote: json["order_note"] ?? '',
        sellerId: json["seller_id"],
        orderCanReturn: json["order_can_return"] ?? false,
        orderHasReturnRequest: json["order_has_return_request"] ?? false,
        returnRequestId: json["return_request_id"],
        showReturnRequest: json["show_return_request"] ?? false,
        editReturnRequest: json["edit_return_request"] ?? false,
        orderCanExchange: json["order_can_exchange"] ?? false,
        partialPaymentByWallet: json["partial_payment_by_wallet"] == null
            ? 0
            : json["partial_payment_by_wallet"].toDouble(),
        details: json["details"] == null
            ? null
            : List<PlaceOrderDetailsModel>.from(
                json["details"].map((x) => PlaceOrderDetailsModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "payment_status": paymentStatus,
        "order_status": orderStatus?.toJson(),
        "payment_method": paymentMethod?.toJson(),
        "transaction_ref": transactionRef,
        "order_amount": orderAmount,
        "discount_amount": discountAmount,
        "shipping_cost": shippingCost,
        "shipping_address": shippingAddress,
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
        "order_can_return": orderCanReturn,
        "order_has_return_request": orderHasReturnRequest,
        "return_request_id": returnRequestId,
        "show_return_request": showReturnRequest,
        "edit_return_request": editReturnRequest,
        "order_can_exchange": orderCanExchange,
        "details": details == null
            ? null
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class ValueLableModel {
  final String? value;
  final String? label;

  ValueLableModel({
    this.value,
    this.label,
  });

  ValueLableModel copyWith({
    String? value,
    String? label,
  }) =>
      ValueLableModel(
        value: value ?? this.value,
        label: label ?? this.label,
      );

  factory ValueLableModel.fromJson(Map<String, dynamic> json) =>
      ValueLableModel(
        value: json["value"],
        label: json["label"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "label": label,
      };
}

class ShippingAddressDataModel {
  final int? id;
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
  final String? zip;
  final String? phone;
  final dynamic alternativePhone;
  final String? latitude;
  final String? longitude;
  final int? isBilling;
  final int? isDefault;
  final dynamic email;
  final String? cost;
  final String duration;

  ShippingAddressDataModel({
    required this.id,
    required this.customerId,
    required this.contactPersonName,
    required this.addressType,
    required this.address,
    required this.addressDetail,
    required this.country,
    required this.province,
    required this.city,
    required this.town,
    required this.street,
    required this.building,
    required this.zip,
    required this.phone,
    required this.alternativePhone,
    required this.latitude,
    required this.longitude,
    required this.isBilling,
    required this.isDefault,
    required this.email,
    required this.cost,
    required this.duration,
  });

  ShippingAddressDataModel copyWith({
    int? id,
    int? customerId,
    String? contactPersonName,
    String? addressType,
    String? address,
    String? addressDetail,
    String? country,
    String? province,
    String? city,
    dynamic town,
    String? street,
    String? building,
    dynamic zip,
    String? phone,
    dynamic alternativePhone,
    String? latitude,
    String? longitude,
    int? isBilling,
    int? isDefault,
    dynamic email,
    String? cost,
    String? duration,
  }) =>
      ShippingAddressDataModel(
        id: id ?? this.id,
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
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isBilling: isBilling ?? this.isBilling,
        isDefault: isDefault ?? this.isDefault,
        email: email ?? this.email,
        cost: cost ?? this.cost,
        duration: duration ?? this.duration,
      );

  factory ShippingAddressDataModel.fromJson(Map<String, dynamic> json) =>
      ShippingAddressDataModel(
        id: json["id"],
        customerId: json["customer_id"],
        contactPersonName: json["contact_person_name"] ?? '',
        addressType: json["address_type"] ?? '',
        address: json["address"] ?? '',
        addressDetail: json["address_detail"] ?? '',
        country: json["country"] ?? '',
        province: json["province"] ?? '',
        city: json["city"] ?? '',
        town: json["town"] ?? '',
        street: json["street"] ?? '',
        building: json["building"] ?? '',
        zip: json["zip"] ?? '',
        phone: json["phone"] ?? '',
        alternativePhone: json["alternative_phone"] ?? '',
        latitude: json["latitude"] ?? '',
        longitude: json["longitude"] ?? '',
        isBilling: json["is_billing"] ?? '',
        isDefault: json["is_default"] ?? '',
        email: json["email"] ?? '',
        cost: json["cost"].toString(),
        duration: json["duration"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
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
        "latitude": latitude,
        "longitude": longitude,
        "is_billing": isBilling,
        "is_default": isDefault,
        "email": email,
        "cost": cost,
        "duration": duration,
      };
}

class PlaceOrderDetailsModel {
  final int? id;
  final int? orderId;
  final int? productId;
  final ProductDetails? productDetails;
  final double? qty;
  final double? price;
  final double? discount;
  final double? priceAfterDiscount;
  final double? tax;
  final String? deliveryStatus;
  final String? paymentStatus;
  final dynamic shippingMethodId;
  final String? variant;
  final Variation? variation;
  final bool? collectProductAfterOrdering;
  final String? discountType;
  final int? isStockDecreased;
  final String? refundRequest;
  final dynamic refundRequestStatus;
  final int? isOdooProduct;
  final int? odooId;
  final int? odooOrderId;
  final String? image;

  PlaceOrderDetailsModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productDetails,
    required this.qty,
    required this.price,
    required this.discount,
    required this.priceAfterDiscount,
    required this.tax,
    required this.deliveryStatus,
    required this.paymentStatus,
    required this.shippingMethodId,
    required this.variant,
    required this.variation,
    required this.collectProductAfterOrdering,
    required this.discountType,
    required this.isStockDecreased,
    required this.refundRequest,
    required this.refundRequestStatus,
    required this.isOdooProduct,
    required this.odooId,
    required this.odooOrderId,
    required this.image,
  });

  PlaceOrderDetailsModel copyWith({
    int? id,
    int? orderId,
    int? productId,
    ProductDetails? productDetails,
    double? qty,
    double? price,
    double? discount,
    double? priceAfterDiscount,
    double? tax,
    String? deliveryStatus,
    String? paymentStatus,
    dynamic shippingMethodId,
    String? variant,
    Variation? variation,
    bool? collectProductAfterOrdering,
    String? discountType,
    int? isStockDecreased,
    String? refundRequest,
    dynamic refundRequestStatus,
    int? isOdooProduct,
    int? odooId,
    int? odooOrderId,
    String? image,
  }) =>
      PlaceOrderDetailsModel(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        productId: productId ?? this.productId,
        productDetails: productDetails ?? this.productDetails,
        qty: qty ?? this.qty,
        price: price ?? this.price,
        discount: discount ?? this.discount,
        priceAfterDiscount: priceAfterDiscount ?? this.priceAfterDiscount,
        tax: tax ?? this.tax,
        deliveryStatus: deliveryStatus ?? this.deliveryStatus,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        shippingMethodId: shippingMethodId ?? this.shippingMethodId,
        variant: variant ?? this.variant,
        collectProductAfterOrdering:
            collectProductAfterOrdering ?? this.collectProductAfterOrdering,
        discountType: discountType ?? this.discountType,
        isStockDecreased: isStockDecreased ?? this.isStockDecreased,
        refundRequest: refundRequest ?? this.refundRequest,
        refundRequestStatus: refundRequestStatus ?? this.refundRequestStatus,
        isOdooProduct: isOdooProduct ?? this.isOdooProduct,
        odooId: odooId ?? this.odooId,
        odooOrderId: odooOrderId ?? this.odooOrderId,
        variation: variation ?? this.variation,
        image: image ?? this.image,
      );

  factory PlaceOrderDetailsModel.fromJson(Map<String, dynamic> json) =>
      PlaceOrderDetailsModel(
        id: json["id"],
        orderId: json["order_id"],
        productId: json["product_id"],
        productDetails: ProductDetails.fromJson(json["product_details"]),
        qty: json["qty"] == null ? null : double.parse(json["qty"].toString()),
        price:
            json["price"] == null ? 0 : double.parse(json["price"].toString()),
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
        variant: json["variant"],
        collectProductAfterOrdering: json["collect_product_after_ordering"],
        discountType: json["discount_type"],
        isStockDecreased: json["is_stock_decreased"],
        refundRequest: json["refund_request"].toString(),
        refundRequestStatus: json["refund_request_status"],
        isOdooProduct: json["is_odoo_product"],
        odooId: json["odoo_id"],
        odooOrderId: json["odoo_order_id"],
        variation: json["variation"] == null
            ? null
            : Variation.fromJson(json["variation"]),
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "product_id": productId,
        "product_details": productDetails!.toJson(),
        "qty": qty,
        "price": price,
        "discount": discount,
        "price_after_discount": priceAfterDiscount,
        "tax": tax,
        "delivery_status": deliveryStatus,
        "payment_status": paymentStatus,
        "shipping_method_id": shippingMethodId,
        "variant": variant,
        "collect_product_after_ordering": collectProductAfterOrdering,
        "discount_type": discountType,
        "is_stock_decreased": isStockDecreased,
        "refund_request": refundRequest.toString(),
        "refund_request_status": refundRequestStatus,
        "is_odoo_product": isOdooProduct,
        "odoo_id": odooId,
        "odoo_order_id": odooOrderId,
        "image": image,
        "variation": variation?.toJson(),
      };
}

class Variation {
  final String? color;
  final String? size;

  Variation({
    required this.color,
    required this.size,
  });

  Variation copyWith({
    String? color,
    String? size,
  }) =>
      Variation(
        color: color ?? this.color,
        size: size ?? this.size,
      );

  factory Variation.fromJson(Map<String, dynamic> json) => Variation(
        color: json["color"] ?? '',
        size: json["Size"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "color": color,
        "Size": size,
      };
}

class ProductDetails {
  final int? id;
  final String? name;
  final String? slug;
  final String? shareLink;
  final String? details;
  final String? thumbnail;
  final List<String>? images;
  final double? price;
  final double? offerPrice;
  final bool? isFavourite;
  final bool? inStock;
  final Rating? rating;

  ProductDetails({
    required this.id,
    required this.name,
    required this.slug,
    required this.shareLink,
    required this.details,
    required this.thumbnail,
    required this.images,
    required this.price,
    required this.offerPrice,
    required this.isFavourite,
    required this.inStock,
    required this.rating,
  });

  ProductDetails copyWith({
    int? id,
    String? name,
    String? slug,
    String? shareLink,
    String? details,
    String? thumbnail,
    List<String>? images,
    double? price,
    double? offerPrice,
    bool? isFavourite,
    bool? inStock,
    Rating? rating,
  }) =>
      ProductDetails(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        shareLink: shareLink ?? this.shareLink,
        details: details ?? this.details,
        thumbnail: thumbnail ?? this.thumbnail,
        images: images ?? this.images,
        price: price ?? this.price,
        offerPrice: offerPrice ?? this.offerPrice,
        isFavourite: isFavourite ?? this.isFavourite,
        inStock: inStock ?? this.inStock,
        rating: rating ?? this.rating,
      );

  factory ProductDetails.fromJson(Map<String, dynamic> json) => ProductDetails(
        id: json["id"],
        name: json["name"] ?? '',
        slug: json["slug"] ?? '',
        shareLink: json["share_link"] ?? '',
        details: json["details"] ?? '',
        thumbnail: json["thumbnail"] ?? '',
        images: List<String>.from(json["images"].map((x) => x)),
        price:
            json["price"] == null ? 0 : double.parse(json["price"].toString()),
        offerPrice: json["offer_price"] == null
            ? 0
            : double.parse(json["offer_price"].toString()),
        isFavourite: json["is_favourite"] ?? false,
        inStock: json["in_stock"] ?? false,
        rating: Rating.fromJson(json["rating"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "share_link": shareLink,
        "details": details,
        "thumbnail": thumbnail,
        "images": List<dynamic>.from(images!.map((x) => x)),
        "price": price,
        "offer_price": offerPrice,
        "is_favourite": isFavourite,
        "in_stock": inStock,
        "rating": rating!.toJson(),
      };
}

class Rating {
  final int? overallRating;
  final int? totalRating;

  Rating({
    required this.overallRating,
    required this.totalRating,
  });

  Rating copyWith({
    int? overallRating,
    int? totalRating,
  }) =>
      Rating(
        overallRating: overallRating ?? this.overallRating,
        totalRating: totalRating ?? this.totalRating,
      );

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        overallRating: json["overall_rating"] ?? 0,
        totalRating: json["total_rating"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "overall_rating": overallRating,
        "total_rating": totalRating,
      };
}
