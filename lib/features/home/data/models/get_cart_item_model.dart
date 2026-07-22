// To parse this JSON data, do
//
//     final getCartShippingItemsModel = getCartShippingItemsModelFromJson(jsonString);

import 'dart:convert';

GetCartShippingItemsModel getCartShippingItemsModelFromJson(String str) =>
    GetCartShippingItemsModel.fromJson(json.decode(str));

String getCartShippingItemsModelToJson(GetCartShippingItemsModel data) =>
    json.encode(data.toJson());

class GetCartShippingItemsModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final CartShipping? data;

  GetCartShippingItemsModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GetCartShippingItemsModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    CartShipping? data,
  }) => GetCartShippingItemsModel(
    isSuccessful: isSuccessful ?? this.isSuccessful,
    hasContent: hasContent ?? this.hasContent,
    code: code ?? this.code,
    message: message ?? this.message,
    detailedError: detailedError ?? this.detailedError,
    data: data ?? this.data,
  );

  factory GetCartShippingItemsModel.fromJson(Map<String, dynamic> json) =>
      GetCartShippingItemsModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"],
        detailedError: json["detailed_error"],
        data: json["data"] == null ? null : CartShipping.fromJson(json["data"]),
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

class CartShipping {
  final double? subTotal;
  final int? totalTax;
  final double? totalShippingCost;
  final double? productsDiscount;
  final double? couponDiscount;
  final double? totalDiscount;
  final int? codCost;
  final String? couponCode;
  final double? limitFree;
  final double? estimatedTax;
  final double? total;
  final double? restForFreeShipping;
  final double? totalCash;
  final bool? hasCod;
  final bool? showMessageResetForShippingFree;
  final List<String>? availablePaymentMethod;
  final List<Cart>? cart;

  CartShipping({
    this.subTotal,
    this.totalTax,
    this.totalShippingCost,
    this.productsDiscount,
    this.couponDiscount,
    this.totalDiscount,
    this.codCost,
    this.limitFree,
    this.estimatedTax,
    this.total,
    this.restForFreeShipping,
    this.totalCash,
    this.hasCod,
    this.showMessageResetForShippingFree,
    this.availablePaymentMethod,
    this.cart,
    this.couponCode,
  });

  CartShipping copyWith({
    double? subTotal,
    int? totalTax,
    double? totalShippingCost,
    double? productsDiscount,
    double? couponDiscount,
    double? totalDiscount,
    String? couponCode,
    int? codCost,
    double? limitFree,
    double? estimatedTax,
    double? total,
    double? restForFreeShipping,
    double? totalCash,
    bool? hasCod,
    bool? showMessageResetForShippingFree,
    List<String>? availablePaymentMethod,
    List<Cart>? cart,
  }) => CartShipping(
    subTotal: subTotal ?? this.subTotal,
    totalTax: totalTax ?? this.totalTax,
    totalShippingCost: totalShippingCost ?? this.totalShippingCost,
    productsDiscount: productsDiscount ?? this.productsDiscount,
    couponDiscount: couponDiscount ?? this.couponDiscount,
    totalDiscount: totalDiscount ?? this.totalDiscount,
    couponCode: couponCode ?? this.couponCode,
    codCost: codCost ?? this.codCost,
    limitFree: limitFree ?? this.limitFree,
    estimatedTax: estimatedTax ?? this.estimatedTax,
    total: total ?? this.total,
    restForFreeShipping: restForFreeShipping ?? this.restForFreeShipping,
    totalCash: totalCash ?? this.totalCash,
    hasCod: hasCod ?? this.hasCod,
    showMessageResetForShippingFree:
        showMessageResetForShippingFree ?? this.showMessageResetForShippingFree,
    availablePaymentMethod:
        availablePaymentMethod ?? this.availablePaymentMethod,
    cart: cart ?? this.cart,
  );

  factory CartShipping.fromJson(Map<String, dynamic> json) => CartShipping(
    subTotal: json["sub_total"]?.toDouble(),
    totalTax: json["total_tax"],
    totalShippingCost: double.tryParse(json["total_shipping_cost"].toString()),
    productsDiscount: json["products_discount"]?.toDouble(),
    couponCode: json["coupon_code"]?.toString(),
    couponDiscount: json["coupon_discount"]?.toDouble(),
    totalDiscount: json["total_discount"]?.toDouble(),
    codCost: json["cod_cost"],
    limitFree: double.tryParse(json["limitFree"].toString()),
    estimatedTax: json["estimated_tax"]?.toDouble(),
    total: json["total"]?.toDouble(),
    restForFreeShipping: json["rest_for_free_shipping"]?.toDouble(),
    totalCash: json["total_cash"]?.toDouble(),
    hasCod: json["has_cod"],
    showMessageResetForShippingFree:
        json["show_message_reset_for_shipping_free"],
    availablePaymentMethod: json["available_payment_method"] == null
        ? []
        : List<String>.from(json["available_payment_method"]!.map((x) => x)),
    cart: json["cart"] == null
        ? []
        : List<Cart>.from(json["cart"]!.map((x) => Cart.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "sub_total": subTotal,
    "total_tax": totalTax,
    "total_shipping_cost": totalShippingCost?.toDouble(),
    "products_discount": productsDiscount,
    'coupon_code': couponCode,
    "coupon_discount": couponDiscount,
    "total_discount": totalDiscount,
    "cod_cost": codCost,
    "limitFree": limitFree?.toDouble(),
    "estimated_tax": estimatedTax,
    "total": total,
    "rest_for_free_shipping": restForFreeShipping,
    "total_cash": totalCash,
    "has_cod": hasCod,
    "show_message_reset_for_shipping_free": showMessageResetForShippingFree,
    "available_payment_method": availablePaymentMethod == null
        ? []
        : List<dynamic>.from(availablePaymentMethod!.map((x) => x)),
    "cart": cart == null
        ? []
        : List<dynamic>.from(cart!.map((x) => x.toJson())),
  };
}

class Cart {
  final int? id;
  final String? uuid;
  final int? customerId;
  final String? cartGroupId;
  final int? productId;
  final List<Choice>? choices;
  final VariationCart? variations;
  final String? variant;
  final int? availableQuantity;
  final String? maxAllowedQty;
  final String? vendorName;
  final int? quantity;
  final double? discount;
  final double? price;
  final double? offerPrice;
  final int? tax;
  final String? slug;
  final String? name;
  final int? countOfPieces;
  final Shop? shop;
  final bool? checkAvailability;
  final bool? isCountryRestricted;
  final bool? isActive;
  final CartBrand? brand;
  final BoutiquesCart? boutique;
  final String? thumbnail;
  final String? image;
  final int? shippingDays;
  final bool? haveHurryUpNotifyTimeLeft;
  final bool? haveHurryUpNotifyQty;
  final int? qtyLeft;
  final int? timeLeftInMinutes;
  final dynamic flashDealDetails;
  final bool? isRedeem;
  final dynamic flashDealMaxAllowedQuantity;
  final DateTime? createdAt;

  Cart({
    this.id,
    this.customerId,
    this.cartGroupId,
    this.uuid,
    this.productId,
    this.choices,
    this.variations,
    this.variant,
    this.isRedeem,
    this.availableQuantity,
    this.maxAllowedQty,
    this.vendorName,
    this.quantity,
    this.discount,
    this.price,
    this.offerPrice,
    this.tax,
    this.slug,
    this.name,
    this.countOfPieces,
    this.shop,
    this.checkAvailability,
    this.isActive,
    this.isCountryRestricted,
    this.brand,
    this.boutique,
    this.thumbnail,
    this.image,
    this.shippingDays,
    this.haveHurryUpNotifyTimeLeft,
    this.haveHurryUpNotifyQty,
    this.qtyLeft,
    this.timeLeftInMinutes,
    this.flashDealDetails,
    this.flashDealMaxAllowedQuantity,
    this.createdAt,
  });

  Cart copyWith({
    int? id,
    String? uuid,
    int? customerId,
    String? cartGroupId,
    int? productId,
    List<Choice>? choices,
    VariationCart? variations,
    String? variant,
    int? availableQuantity,
    bool? isCountryRestricted,
    bool? isActive,
    String? maxAllowedQty,
    bool? isRedeem,
    String? vendorName,
    int? quantity,
    double? discount,
    double? price,
    double? offerPrice,
    int? tax,
    String? slug,
    String? name,
    int? countOfPieces,
    Shop? shop,
    bool? checkAvailability,
    CartBrand? brand,
    BoutiquesCart? boutique,
    String? thumbnail,
    String? image,
    int? shippingDays,
    bool? haveHurryUpNotifyTimeLeft,
    bool? haveHurryUpNotifyQty,
    int? qtyLeft,
    int? timeLeftInMinutes,
    dynamic flashDealDetails,
    dynamic flashDealMaxAllowedQuantity,
    DateTime? createdAt,
  }) => Cart(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    customerId: customerId ?? this.customerId,
    cartGroupId: cartGroupId ?? this.cartGroupId,
    productId: productId ?? this.productId,
    choices: choices ?? this.choices,
    isRedeem: isRedeem ?? this.isRedeem,
    variations: variations ?? this.variations,
    variant: variant ?? this.variant,
    availableQuantity: availableQuantity ?? this.availableQuantity,
    isActive: isActive ?? this.isActive,
    isCountryRestricted: isCountryRestricted ?? this.isCountryRestricted,
    maxAllowedQty: maxAllowedQty ?? this.maxAllowedQty,
    vendorName: vendorName ?? this.vendorName,
    quantity: quantity ?? this.quantity,
    discount: discount ?? this.discount,
    price: price ?? this.price,
    offerPrice: offerPrice ?? this.offerPrice,
    tax: tax ?? this.tax,
    slug: slug ?? this.slug,
    name: name ?? this.name,
    countOfPieces: countOfPieces ?? this.countOfPieces,
    shop: shop ?? this.shop,
    checkAvailability: checkAvailability ?? this.checkAvailability,
    brand: brand ?? this.brand,
    boutique: boutique ?? this.boutique,
    thumbnail: thumbnail ?? this.thumbnail,
    image: image ?? this.image,
    shippingDays: shippingDays ?? this.shippingDays,
    haveHurryUpNotifyTimeLeft:
        haveHurryUpNotifyTimeLeft ?? this.haveHurryUpNotifyTimeLeft,
    haveHurryUpNotifyQty: haveHurryUpNotifyQty ?? this.haveHurryUpNotifyQty,
    qtyLeft: qtyLeft ?? this.qtyLeft,
    timeLeftInMinutes: timeLeftInMinutes ?? this.timeLeftInMinutes,
    flashDealDetails: flashDealDetails ?? this.flashDealDetails,
    flashDealMaxAllowedQuantity:
        flashDealMaxAllowedQuantity ?? this.flashDealMaxAllowedQuantity,
    createdAt: createdAt ?? this.createdAt,
  );

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: json["id"],
    uuid: json["uuid"],
    customerId: json["customer_id"],
    cartGroupId: json["cart_group_id"],
    productId: json["product_id"],
    isRedeem: json["is_luck"],
    choices: json["choices"] == null
        ? []
        : List<Choice>.from(json["choices"]!.map((x) => Choice.fromJson(x))),
    variations: json["variations"] == null
        ? null
        : json["variations"] is List
        ? json["variations"].isEmpty
              ? null
              : VariationCart.fromJson(json["variations"][0])
        : VariationCart.fromJson(json["variations"]),
    variant: json["variant"] == null ? null : json["variant"],
    availableQuantity: json["available_quantity"],
    maxAllowedQty: json["max_allowed_qty"].toString(),
    vendorName: json["vendor_name"],
    quantity: json["quantity"],
    discount: json["discount"]?.toDouble(),
    price: json["price"]?.toDouble(),
    offerPrice: json["offer_price"]?.toDouble(),
    tax: json["tax"],
    slug: json["slug"],
    name: json["name"],
    countOfPieces: json["count_of_pieces"],
    shop: json["shop"] == null ? null : Shop.fromJson(json["shop"]),
    checkAvailability: json["check_availability"] ?? false,
    isActive: json["is_active"] ?? false,
    isCountryRestricted: json["is_country_restricted"] ?? false,
    brand: json["brand"] == null ? null : CartBrand.fromJson(json["brand"]),
    boutique: json["boutique"] == null
        ? null
        : BoutiquesCart.fromJson(json["boutique"]),
    thumbnail: json["thumbnail"],
    image: json["image"],
    shippingDays: json["shipping_days"],
    haveHurryUpNotifyTimeLeft: json["have_hurry_up_notify_time_left"],
    haveHurryUpNotifyQty: json["have_hurry_up_notify_qty"],
    qtyLeft: json["qty_left"],
    timeLeftInMinutes: json["time_left_in_minutes"],
    flashDealDetails: json["flash_deal_details"],
    flashDealMaxAllowedQuantity: json["flash_deal_max_allowed_quantity"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid": uuid,
    "customer_id": customerId,
    "cart_group_id": cartGroupId,
    "product_id": productId,
    "choices": choices == null
        ? []
        : List<dynamic>.from(choices!.map((x) => x.toJson())),
    "variations": variations,
    "variant": variant,
    "available_quantity": availableQuantity,
    "max_allowed_qty": maxAllowedQty,
    "is_luck": isRedeem,
    "vendor_name": vendorName,
    "quantity": quantity,
    "discount": discount,
    "price": price,
    "offer_price": offerPrice,
    "tax": tax,
    "slug": slug,
    "name": name,
    "count_of_pieces": countOfPieces,
    "shop": shop?.toJson(),
    "check_availability": checkAvailability,
    "is_country_restricted": isCountryRestricted,
    "is_active": isActive,
    "brand": brand?.toJson(),
    "boutique": boutique?.toJson(),
    "thumbnail": thumbnail,
    "image": image,
    "shipping_days": shippingDays,
    "have_hurry_up_notify_time_left": haveHurryUpNotifyTimeLeft,
    "have_hurry_up_notify_qty": haveHurryUpNotifyQty,
    "qty_left": qtyLeft,
    "time_left_in_minutes": timeLeftInMinutes,
    "flash_deal_details": flashDealDetails,
    "flash_deal_max_allowed_quantity": flashDealMaxAllowedQuantity,
    "created_at": createdAt?.toIso8601String(),
  };
}

class BoutiquesCart {
  final int? id;
  final IconCart? icon;

  BoutiquesCart({this.id, this.icon});

  BoutiquesCart copyWith({int? id, IconCart? icon}) =>
      BoutiquesCart(id: id ?? this.id, icon: icon ?? this.icon);

  factory BoutiquesCart.fromJson(Map<String, dynamic> json) => BoutiquesCart(
    id: json["id"],
    icon: json["icon"] == null ? null : IconCart.fromJson(json["icon"]),
  );

  Map<String, dynamic> toJson() => {"id": id, "icon": icon?.toJson()};
}

class IconCart {
  final String? filePath;
  final String? originalWidth;
  final String? originalHeight;

  IconCart({this.filePath, this.originalWidth, this.originalHeight});

  IconCart copyWith({
    String? filePath,
    String? originalWidth,
    String? originalHeight,
  }) => IconCart(
    filePath: filePath ?? this.filePath,
    originalWidth: originalWidth ?? this.originalWidth,
    originalHeight: originalHeight ?? this.originalHeight,
  );

  factory IconCart.fromJson(Map<String, dynamic> json) => IconCart(
    filePath: json["file_path"],
    originalWidth: json["original_width"],
    originalHeight: json["original_height"],
  );

  Map<String, dynamic> toJson() => {
    "file_path": filePath,
    "original_width": originalWidth,
    "original_height": originalHeight,
  };
}

class CartBrand {
  final int? id;
  final String? slug;
  final String? name;
  final CartIcon? icon;

  CartBrand({this.id, this.slug, this.name, this.icon});

  CartBrand copyWith({int? id, String? slug, String? name, CartIcon? icon}) =>
      CartBrand(
        id: id ?? this.id,
        slug: slug ?? this.slug,
        name: name ?? this.name,
        icon: icon ?? this.icon,
      );

  factory CartBrand.fromJson(Map<String, dynamic> json) => CartBrand(
    id: json["id"],
    slug: json["slug"],
    name: json["name"],
    icon: json["icon"] == null ? null : CartIcon.fromJson(json["icon"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "name": name,
    "icon": icon?.toJson(),
  };
}

class CartIcon {
  final String? filePath;
  final String? originalWidth;
  final String? originalHeight;

  CartIcon({this.filePath, this.originalWidth, this.originalHeight});

  CartIcon copyWith({
    String? filePath,
    String? originalWidth,
    String? originalHeight,
  }) => CartIcon(
    filePath: filePath ?? this.filePath,
    originalWidth: originalWidth ?? this.originalWidth,
    originalHeight: originalHeight ?? this.originalHeight,
  );

  factory CartIcon.fromJson(Map<String, dynamic> json) => CartIcon(
    filePath: json["file_path"],
    originalWidth: json["original_width"],
    originalHeight: json["original_height"],
  );

  Map<String, dynamic> toJson() => {
    "file_path": filePath,
    "original_width": originalWidth,
    "original_height": originalHeight,
  };
}

class Choice {
  final String? choice1;

  Choice({this.choice1});

  Choice copyWith({String? choice1}) =>
      Choice(choice1: choice1 ?? this.choice1);

  factory Choice.fromJson(Map<String, dynamic> json) =>
      Choice(choice1: json["choice_1"]);

  Map<String, dynamic> toJson() => {"choice_1": choice1};
}

class Shop {
  final String? image;
  final String? name;

  Shop({this.image, this.name});

  Shop copyWith({String? image, String? name}) =>
      Shop(image: image ?? this.image, name: name ?? this.name);

  factory Shop.fromJson(Map<String, dynamic> json) =>
      Shop(image: json["image"], name: json["name"]);

  Map<String, dynamic> toJson() => {"image": image, "name": name};
}

class VariationCart {
  final String? sizeOption;
  final String? colorOption;
  final String? size;
  final String? color;

  VariationCart({this.sizeOption, this.colorOption, this.size, this.color});

  VariationCart copyWith({
    String? sizeOption,
    String? colorOption,
    String? size,
    String? color,
  }) => VariationCart(
    sizeOption: sizeOption ?? this.sizeOption,
    colorOption: colorOption ?? this.colorOption,
    size: size ?? this.size,
    color: color ?? this.color,
  );

  factory VariationCart.fromJson(Map<String, dynamic> json) => VariationCart(
    sizeOption: json["size_options"] == null
        ? null
        : json["size_options"].toString().replaceAll("-", "_"),
    colorOption: json["color_options"] == null
        ? null
        : json["color_options"].toString().replaceAll("-", "_"),
    size: json["Size"] == null
        ? null
        : json["Size"].toString().replaceAll("-", "_"),
    color: json["color"] == null
        ? null
        : json["color"].toString().replaceAll("-", "_"),
  );

  Map<String, dynamic> toJson() => {
    "size_options": sizeOption,
    "color_options": colorOption,
    "Size": size,
    "color": color,
  };
}
