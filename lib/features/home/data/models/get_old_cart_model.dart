// To parse this JSON data, do
//
//     final getOldCartModel = getOldCartModelFromJson(jsonString);

import 'dart:convert';

import 'package:trydos/features/home/data/models/get_cart_item_model.dart';

GetOldCartModel getOldCartModelFromJson(String str) =>
    GetOldCartModel.fromJson(json.decode(str));

String getOldCartModelToJson(GetOldCartModel data) =>
    json.encode(data.toJson());

class GetOldCartModel {
  final String? message;
  final GetOldCartModelData? data;

  GetOldCartModel({
    this.message,
    this.data,
  });

  GetOldCartModel copyWith({
    String? message,
    GetOldCartModelData? data,
  }) =>
      GetOldCartModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetOldCartModel.fromJson(Map<String, dynamic> json) =>
      GetOldCartModel(
        message: json["message"],
        data: json["data"] == null
            ? null
            : GetOldCartModelData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class GetOldCartModelData {
  final Original? original;
  final dynamic exception;

  GetOldCartModelData({
    this.original,
    this.exception,
  });

  GetOldCartModelData copyWith({
    Original? original,
    dynamic exception,
  }) =>
      GetOldCartModelData(
        original: original ?? this.original,
        exception: exception ?? this.exception,
      );

  factory GetOldCartModelData.fromJson(Map<String, dynamic> json) =>
      GetOldCartModelData(
        original: json["original"] == null
            ? null
            : Original.fromJson(json["original"]),
        exception: json["exception"],
      );

  Map<String, dynamic> toJson() => {
        "original": original?.toJson(),
        "exception": exception,
      };
}

class Original {
  final String? message;
  final OriginalData? data;

  Original({
    this.message,
    this.data,
  });

  Original copyWith({
    String? message,
    OriginalData? data,
  }) =>
      Original(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory Original.fromJson(Map<String, dynamic> json) => Original(
        message: json["message"],
        data: json["data"] == null ? null : OriginalData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class OriginalData {
  final double? subTotal;
  final double? totalTax;
  final double? totalDiscountOnProduct;
  final double? totalShippingCost;
  final double? couponDiscount;
  final double? codCost;
  final double? limitFree;
  final double? estimatedTax;
  final double? total;
  final double? restForFreeShipping;
  final double? totalCash;
  final bool? hasCod;
  final bool? showMessageResetForShippingFree;
  final List<String>? availablePaymentMethod;
  final List<OldCart>? oldCart;

  OriginalData({
    this.subTotal,
    this.totalTax,
    this.totalDiscountOnProduct,
    this.totalShippingCost,
    this.couponDiscount,
    this.codCost,
    this.limitFree,
    this.estimatedTax,
    this.total,
    this.restForFreeShipping,
    this.totalCash,
    this.hasCod,
    this.showMessageResetForShippingFree,
    this.availablePaymentMethod,
    this.oldCart,
  });

  OriginalData copyWith({
    double? subTotal,
    double? totalTax,
    double? totalDiscountOnProduct,
    double? totalShippingCost,
    double? couponDiscount,
    double? codCost,
    double? limitFree,
    double? estimatedTax,
    double? total,
    double? restForFreeShipping,
    double? totalCash,
    bool? hasCod,
    bool? showMessageResetForShippingFree,
    List<String>? availablePaymentMethod,
    List<OldCart>? oldCart,
  }) =>
      OriginalData(
        subTotal: subTotal ?? this.subTotal,
        totalTax: totalTax ?? this.totalTax,
        totalDiscountOnProduct:
            totalDiscountOnProduct ?? this.totalDiscountOnProduct,
        totalShippingCost: totalShippingCost ?? this.totalShippingCost,
        couponDiscount: couponDiscount ?? this.couponDiscount,
        codCost: codCost ?? this.codCost,
        limitFree: limitFree ?? this.limitFree,
        estimatedTax: estimatedTax ?? this.estimatedTax,
        total: total ?? this.total,
        restForFreeShipping: restForFreeShipping ?? this.restForFreeShipping,
        totalCash: totalCash ?? this.totalCash,
        hasCod: hasCod ?? this.hasCod,
        showMessageResetForShippingFree: showMessageResetForShippingFree ??
            this.showMessageResetForShippingFree,
        availablePaymentMethod:
            availablePaymentMethod ?? this.availablePaymentMethod,
        oldCart: oldCart ?? this.oldCart,
      );

  factory OriginalData.fromJson(Map<String, dynamic> json) => OriginalData(
        subTotal: json["sub_total"]?.toDouble(),
        totalTax: double.tryParse(json["total_tax"].toString()),
        totalDiscountOnProduct: json["total_discount_on_product"]?.toDouble(),
        totalShippingCost:
            double.tryParse(json["total_shipping_cost"].toString()),
        couponDiscount: double.tryParse(json["coupon_discount"].toString()),
        codCost: double.tryParse(json["cod_cost"].toString()),
        limitFree: json["limitFree"]?.toDouble(),
        estimatedTax: json["estimated_tax"]?.toDouble(),
        total: json["total"]?.toDouble(),
        restForFreeShipping: json["rest_for_free_shipping"]?.toDouble(),
        totalCash: json["total_cash"]?.toDouble(),
        hasCod: json["has_cod"],
        showMessageResetForShippingFree:
            json["show_message_reset_for_shipping_free"],
        availablePaymentMethod: json["available_payment_method"] == null
            ? []
            : List<String>.from(
                json["available_payment_method"]!.map((x) => x)),
        oldCart: json["oldCart"] == null
            ? []
            : List<OldCart>.from(
                json["oldCart"]!.map((x) => OldCart.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "sub_total": subTotal,
        "total_tax": totalTax,
        "total_discount_on_product": totalDiscountOnProduct,
        "total_shipping_cost": totalShippingCost,
        "coupon_discount": couponDiscount,
        "cod_cost": codCost,
        "limitFree": limitFree,
        "estimated_tax": estimatedTax,
        "total": total,
        "rest_for_free_shipping": restForFreeShipping,
        "total_cash": totalCash,
        "has_cod": hasCod,
        "show_message_reset_for_shipping_free": showMessageResetForShippingFree,
        "available_payment_method": availablePaymentMethod == null
            ? []
            : List<dynamic>.from(availablePaymentMethod!.map((x) => x)),
        "oldCart": oldCart == null
            ? []
            : List<dynamic>.from(oldCart!.map((x) => x.toJson())),
      };
}

class OldCart {
  final int? id;
  final int? customerId;
  final String? cartGroupId;
  final int? productId;
  final List<Choice>? choices;
  final List<VariationCart>? variations;
  final String? variant;
  final int? availableQuantity;
  final String? maxAllowedQty;
  final String? vendorName;
  final int? quantity;
  final double? discount;
  final double? priceOfVariant;
  final int? tax;
  final String? slug;
  final String? name;
  final dynamic countOfPieces;
  final Shop? shop;
  final Brand? brand;
  final BoutiquesCart? boutique;
  final String? thumbnail;
  final String? image;
  final DateTime? createdAt;
  final dynamic flashDealDetails;
  final dynamic flashDealMaxAllowedQuantity;

  OldCart({
    this.id,
    this.customerId,
    this.cartGroupId,
    this.productId,
    this.choices,
    this.variations,
    this.variant,
    this.availableQuantity,
    this.maxAllowedQty,
    this.vendorName,
    this.quantity,
    this.discount,
    this.priceOfVariant,
    this.tax,
    this.slug,
    this.name,
    this.countOfPieces,
    this.shop,
    this.brand,
    this.boutique,
    this.thumbnail,
    this.image,
    this.createdAt,
    this.flashDealDetails,
    this.flashDealMaxAllowedQuantity,
  });

  OldCart copyWith({
    int? id,
    int? customerId,
    String? cartGroupId,
    int? productId,
    List<Choice>? choices,
    List<VariationCart>? variations,
    String? variant,
    int? availableQuantity,
    String? maxAllowedQty,
    String? vendorName,
    int? quantity,
    double? discount,
    double? priceOfVariant,
    int? tax,
    String? slug,
    String? name,
    dynamic countOfPieces,
    Shop? shop,
    Brand? brand,
    BoutiquesCart? boutique,
    String? thumbnail,
    String? image,
    DateTime? createdAt,
    dynamic flashDealDetails,
    dynamic flashDealMaxAllowedQuantity,
  }) =>
      OldCart(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        cartGroupId: cartGroupId ?? this.cartGroupId,
        productId: productId ?? this.productId,
        choices: choices ?? this.choices,
        variations: variations ?? this.variations,
        variant: variant ?? this.variant,
        availableQuantity: availableQuantity ?? this.availableQuantity,
        maxAllowedQty: maxAllowedQty ?? this.maxAllowedQty,
        vendorName: vendorName ?? this.vendorName,
        quantity: quantity ?? this.quantity,
        discount: discount ?? this.discount,
        priceOfVariant: priceOfVariant ?? this.priceOfVariant,
        tax: tax ?? this.tax,
        slug: slug ?? this.slug,
        name: name ?? this.name,
        countOfPieces: countOfPieces ?? this.countOfPieces,
        shop: shop ?? this.shop,
        brand: brand ?? this.brand,
        boutique: boutique ?? this.boutique,
        thumbnail: thumbnail ?? this.thumbnail,
        image: image ?? this.image,
        createdAt: createdAt ?? this.createdAt,
        flashDealDetails: flashDealDetails ?? this.flashDealDetails,
        flashDealMaxAllowedQuantity:
            flashDealMaxAllowedQuantity ?? this.flashDealMaxAllowedQuantity,
      );

  factory OldCart.fromJson(Map<String, dynamic> json) => OldCart(
        id: json["id"],
        customerId: json["customer_id"],
        cartGroupId: json["cart_group_id"],
        productId: json["product_id"],
        choices: json["choices"] == null
            ? []
            : List<Choice>.from(
                json["choices"]!.map((x) => Choice.fromJson(x))),
        variations: json["variations"] == null
            ? []
            : List<VariationCart>.from(
                json["variations"]!.map((x) => VariationCart.fromJson(x))),
        variant: json["variant"],
        availableQuantity:
            double.tryParse(json["available_quantity"].toString())!.round(),
        maxAllowedQty: json["max_allowed_qty"],
        vendorName: json["vendor_name"],
        quantity: double.tryParse(json["quantity"].toString())!.round(),
        discount: json["discount"]?.toDouble(),
        priceOfVariant: double.tryParse(json["price_of_variant"].toString()),
        tax: json["tax"],
        slug: json["slug"],
        name: json["name"],
        countOfPieces: json["count_of_pieces"],
        shop: json["shop"] == null ? null : Shop.fromJson(json["shop"]),
        brand: json["brand"] == null ? null : Brand.fromJson(json["brand"]),
        boutique: json["boutique"] == null
            ? null
            : BoutiquesCart.fromJson(json["boutique"]),
        thumbnail: json["thumbnail"],
        image: json["image"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        flashDealDetails: json["flash_deal_details"],
        flashDealMaxAllowedQuantity: json["flash_deal_max_allowed_quantity"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "cart_group_id": cartGroupId,
        "product_id": productId,
        "choices": choices == null
            ? []
            : List<dynamic>.from(choices!.map((x) => x.toJson())),
        "variations": variations == null
            ? []
            : List<dynamic>.from(variations!.map((x) => x.toJson())),
        "variant": variant,
        "available_quantity": availableQuantity,
        "max_allowed_qty": maxAllowedQty,
        "vendor_name": vendorName,
        "quantity": quantity,
        "discount": discount,
        "price_of_variant": priceOfVariant,
        "tax": tax,
        "slug": slug,
        "name": name,
        "count_of_pieces": countOfPieces,
        "shop": shop?.toJson(),
        "brand": brand?.toJson(),
        "boutique": boutique?.toJson(),
        "thumbnail": thumbnail,
        "image": image,
        "created_at": createdAt?.toIso8601String(),
        "flash_deal_details": flashDealDetails,
        "flash_deal_max_allowed_quantity": flashDealMaxAllowedQuantity,
      };
}

class Boutique {
  final int? id;
  final Icon? icon;

  Boutique({
    this.id,
    this.icon,
  });

  Boutique copyWith({
    int? id,
    Icon? icon,
  }) =>
      Boutique(
        id: id ?? this.id,
        icon: icon ?? this.icon,
      );

  factory Boutique.fromJson(Map<String, dynamic> json) => Boutique(
        id: json["id"],
        icon: json["icon"] == null ? null : Icon.fromJson(json["icon"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "icon": icon?.toJson(),
      };
}

class Icon {
  final String? filePath;
  final String? originalWidth;
  final String? originalHeight;

  Icon({
    this.filePath,
    this.originalWidth,
    this.originalHeight,
  });

  Icon copyWith({
    String? filePath,
    String? originalWidth,
    String? originalHeight,
  }) =>
      Icon(
        filePath: filePath ?? this.filePath,
        originalWidth: originalWidth ?? this.originalWidth,
        originalHeight: originalHeight ?? this.originalHeight,
      );

  factory Icon.fromJson(Map<String, dynamic> json) => Icon(
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

class Brand {
  final int? id;
  final String? name;
  final String? slug;
  final String? image;

  Brand({
    this.id,
    this.name,
    this.slug,
    this.image,
  });

  Brand copyWith({
    int? id,
    String? name,
    String? slug,
    String? image,
  }) =>
      Brand(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        image: image ?? this.image,
      );

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "image": image,
      };
}

class Choice {
  final String? choice1;

  Choice({
    this.choice1,
  });

  Choice copyWith({
    String? choice1,
  }) =>
      Choice(
        choice1: choice1 ?? this.choice1,
      );

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
        choice1: json["choice_1"],
      );

  Map<String, dynamic> toJson() => {
        "choice_1": choice1,
      };
}

class Shop {
  final String? image;
  final String? name;

  Shop({
    this.image,
    this.name,
  });

  Shop copyWith({
    String? image,
    String? name,
  }) =>
      Shop(
        image: image ?? this.image,
        name: name ?? this.name,
      );

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        image: json["image"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "name": name,
      };
}
