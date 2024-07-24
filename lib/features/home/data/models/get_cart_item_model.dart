// To parse this JSON data, do
//
//     final getCartShippingItemsModel = getCartShippingItemsModelFromJson(jsonString);

import 'dart:convert';

GetCartShippingItemsModel getCartShippingItemsModelFromJson(String str) =>
    GetCartShippingItemsModel.fromJson(json.decode(str));

String getCartShippingItemsModelToJson(GetCartShippingItemsModel data) =>
    json.encode(data.toJson());

class GetCartShippingItemsModel {
  final String? message;
  final Data? data;

  GetCartShippingItemsModel({
    this.message,
    this.data,
  });

  GetCartShippingItemsModel copyWith({
    String? message,
    Data? data,
  }) =>
      GetCartShippingItemsModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetCartShippingItemsModel.fromJson(Map<String, dynamic> json) =>
      GetCartShippingItemsModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final double? subTotal;
  final String? subTotalFormated;
  final double? totalTax;
  final String? totalTaxFormated;
  final double? totalDiscountOnProduct;
  final String? totalDiscountOnProductFormated;
  final double? totalShippingCost;
  final String? totalShippingCostFormated;
  final double? couponDiscount;
  final String? couponDiscountFormated;
  final double? codCost;
  final String? codCostFormated;
  final bool? hasCod;
  final double? limitFree;
  final String? limitFreeFormated;
  final double? estimatedTax;
  final String? estimatedTaxFormated;
  final double? total;
  final String? totalFormated;
  final double? restForFreeShipping;
  final String? restForFreeShippingFormatted;
  final bool? showMessageResetForShippingFree;
  final List<String>? availablePaymentMethod;
  final double? totalCash;
  final String? totalCashFormated;
  final List<Cart>? cart;

  Data({
    this.subTotal,
    this.subTotalFormated,
    this.totalTax,
    this.totalTaxFormated,
    this.totalDiscountOnProduct,
    this.totalDiscountOnProductFormated,
    this.totalShippingCost,
    this.totalShippingCostFormated,
    this.couponDiscount,
    this.couponDiscountFormated,
    this.codCost,
    this.codCostFormated,
    this.hasCod,
    this.limitFree,
    this.limitFreeFormated,
    this.estimatedTax,
    this.estimatedTaxFormated,
    this.total,
    this.totalFormated,
    this.restForFreeShipping,
    this.restForFreeShippingFormatted,
    this.showMessageResetForShippingFree,
    this.availablePaymentMethod,
    this.totalCash,
    this.totalCashFormated,
    this.cart,
  });

  Data copyWith({
    double? subTotal,
    String? subTotalFormated,
    double? totalTax,
    String? totalTaxFormated,
    double? totalDiscountOnProduct,
    String? totalDiscountOnProductFormated,
    double? totalShippingCost,
    String? totalShippingCostFormated,
    double? couponDiscount,
    String? couponDiscountFormated,
    double? codCost,
    String? codCostFormated,
    bool? hasCod,
    double? limitFree,
    String? limitFreeFormated,
    double? estimatedTax,
    String? estimatedTaxFormated,
    double? total,
    String? totalFormated,
    double? restForFreeShipping,
    String? restForFreeShippingFormatted,
    bool? showMessageResetForShippingFree,
    List<String>? availablePaymentMethod,
    double? totalCash,
    String? totalCashFormated,
    List<Cart>? cart,
  }) =>
      Data(
        subTotal: subTotal ?? this.subTotal,
        subTotalFormated: subTotalFormated ?? this.subTotalFormated,
        totalTax: totalTax ?? this.totalTax,
        totalTaxFormated: totalTaxFormated ?? this.totalTaxFormated,
        totalDiscountOnProduct:
            totalDiscountOnProduct ?? this.totalDiscountOnProduct,
        totalDiscountOnProductFormated: totalDiscountOnProductFormated ??
            this.totalDiscountOnProductFormated,
        totalShippingCost: totalShippingCost ?? this.totalShippingCost,
        totalShippingCostFormated:
            totalShippingCostFormated ?? this.totalShippingCostFormated,
        couponDiscount: couponDiscount ?? this.couponDiscount,
        couponDiscountFormated:
            couponDiscountFormated ?? this.couponDiscountFormated,
        codCost: codCost ?? this.codCost,
        codCostFormated: codCostFormated ?? this.codCostFormated,
        hasCod: hasCod ?? this.hasCod,
        limitFree: limitFree ?? this.limitFree,
        limitFreeFormated: limitFreeFormated ?? this.limitFreeFormated,
        estimatedTax: estimatedTax ?? this.estimatedTax,
        estimatedTaxFormated: estimatedTaxFormated ?? this.estimatedTaxFormated,
        total: total ?? this.total,
        totalFormated: totalFormated ?? this.totalFormated,
        restForFreeShipping: restForFreeShipping ?? this.restForFreeShipping,
        restForFreeShippingFormatted:
            restForFreeShippingFormatted ?? this.restForFreeShippingFormatted,
        showMessageResetForShippingFree: showMessageResetForShippingFree ??
            this.showMessageResetForShippingFree,
        availablePaymentMethod:
            availablePaymentMethod ?? this.availablePaymentMethod,
        totalCash: totalCash ?? this.totalCash,
        totalCashFormated: totalCashFormated ?? this.totalCashFormated,
        cart: cart ?? this.cart,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        subTotal: json["sub_total"].toDouble(),
        subTotalFormated: json["sub_total_formated"],
        totalTax: json["total_tax"].toDouble(),
        totalTaxFormated: json["total_tax_formated"],
        totalDiscountOnProduct: json["total_discount_on_product"].toDouble(),
        totalDiscountOnProductFormated:
            json["total_discount_on_product_formated"],
        totalShippingCost: json["total_shipping_cost"].toDouble(),
        totalShippingCostFormated: json["total_shipping_cost_formated"],
        couponDiscount: json["coupon_discount"].toDouble(),
        couponDiscountFormated: json["coupon_discount_formated"],
        codCost: json["cod_cost"].toDouble(),
        codCostFormated: json["cod_cost_formated"],
        hasCod: json["has_cod"],
        limitFree: json["limitFree"].toDouble(),
        limitFreeFormated: json["limitFree_formated"],
        estimatedTax: json["estimated_tax"].toDouble(),
        estimatedTaxFormated: json["estimated_tax_formated"],
        total: json["total"].toDouble(),
        totalFormated: json["total_formated"],
        restForFreeShipping: json["rest_for_free_shipping"].toDouble(),
        restForFreeShippingFormatted: json["rest_for_free_shipping_formatted"],
        showMessageResetForShippingFree:
            json["show_message_reset_for_shipping_free"],
        availablePaymentMethod: json["available_payment_method"] == null
            ? []
            : List<String>.from(
                json["available_payment_method"]!.map((x) => x)),
        totalCash: json["total_cash"].toDouble(),
        totalCashFormated: json["total_cash_formated"],
        cart: json["cart"] == null
            ? []
            : List<Cart>.from(json["cart"]!.map((x) => Cart.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "sub_total": subTotal,
        "sub_total_formated": subTotalFormated,
        "total_tax": totalTax,
        "total_tax_formated": totalTaxFormated,
        "total_discount_on_product": totalDiscountOnProduct,
        "total_discount_on_product_formated": totalDiscountOnProductFormated,
        "total_shipping_cost": totalShippingCost,
        "total_shipping_cost_formated": totalShippingCostFormated,
        "coupon_discount": couponDiscount,
        "coupon_discount_formated": couponDiscountFormated,
        "cod_cost": codCost,
        "cod_cost_formated": codCostFormated,
        "has_cod": hasCod,
        "limitFree": limitFree,
        "limitFree_formated": limitFreeFormated,
        "estimated_tax": estimatedTax,
        "estimated_tax_formated": estimatedTaxFormated,
        "total": total,
        "total_formated": totalFormated,
        "rest_for_free_shipping": restForFreeShipping,
        "rest_for_free_shipping_formatted": restForFreeShippingFormatted,
        "show_message_reset_for_shipping_free": showMessageResetForShippingFree,
        "available_payment_method": availablePaymentMethod == null
            ? []
            : List<dynamic>.from(availablePaymentMethod!.map((x) => x)),
        "total_cash": totalCash,
        "total_cash_formated": totalCashFormated,
        "cart": cart == null
            ? []
            : List<dynamic>.from(cart!.map((x) => x.toJson())),
      };
}

class Cart {
  final int? id;
  final int? customerId;
  final String? cartGroupId;
  final String? image;
  final int? productId;
  final List<Choice>? choices;
  final List<VariationCart>? variations;
  final String? variant;
  final int? availableQuantity;
  final String? maxAllowedQty;
  final String? vendorName;
  final int? quantity;
  final double? price;

  final double? offerPrice;
  final String? offerPriceFormatted;
  final int? tax;
  final double? discount;
  final String? slug;
  final String? name;
  final Shop? shop;
  final CartBrand? brand;
  final BoutiquesCart? boutique;
  final String? thumbnail;
  final DateTime? createdAt;
  final dynamic flashDealDetails;
  final dynamic flashDealMaxAllowedQuantity;

  Cart({
    this.id,
    this.customerId,
    this.cartGroupId,
    this.productId,
    this.image,
    this.choices,
    this.variations,
    this.variant,
    this.availableQuantity,
    this.maxAllowedQty,
    this.vendorName,
    this.quantity,
    this.price,
    this.offerPrice,
    this.offerPriceFormatted,
    this.tax,
    this.discount,
    this.slug,
    this.name,
    this.shop,
    this.brand,
    this.boutique,
    this.thumbnail,
    this.createdAt,
    this.flashDealDetails,
    this.flashDealMaxAllowedQuantity,
  });

  Cart copyWith({
    int? id,
    int? customerId,
    String? cartGroupId,
    int? productId,
    List<Choice>? choices,
    List<VariationCart>? variations,
    String? variant,
    int? availableQuantity,
    String? maxAllowedQty,
    String? image,
    String? vendorName,
    int? quantity,
    double? price,
    double? offerPrice,
    String? offerPriceFormatted,
    int? tax,
    double? discount,
    String? slug,
    String? name,
    Shop? shop,
    CartBrand? brand,
    BoutiquesCart? boutique,
    String? thumbnail,
    DateTime? createdAt,
    dynamic flashDealDetails,
    dynamic flashDealMaxAllowedQuantity,
  }) =>
      Cart(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        cartGroupId: cartGroupId ?? this.cartGroupId,
        productId: productId ?? this.productId,
        choices: choices ?? this.choices,
        image: image ?? this.image,
        variations: variations ?? this.variations,
        variant: variant ?? this.variant,
        availableQuantity: availableQuantity ?? this.availableQuantity,
        maxAllowedQty: maxAllowedQty ?? this.maxAllowedQty,
        vendorName: vendorName ?? this.vendorName,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
        offerPrice: offerPrice ?? this.offerPrice,
        offerPriceFormatted: offerPriceFormatted ?? this.offerPriceFormatted,
        tax: tax ?? this.tax,
        discount: discount ?? this.discount,
        slug: slug ?? this.slug,
        name: name ?? this.name,
        shop: shop ?? this.shop,
        brand: brand ?? this.brand,
        boutique: boutique ?? this.boutique,
        thumbnail: thumbnail ?? this.thumbnail,
        createdAt: createdAt ?? this.createdAt,
        flashDealDetails: flashDealDetails ?? this.flashDealDetails,
        flashDealMaxAllowedQuantity:
            flashDealMaxAllowedQuantity ?? this.flashDealMaxAllowedQuantity,
      );

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
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
        availableQuantity: json["available_quantity"],
        maxAllowedQty: json["max_allowed_qty"],
        vendorName: json["vendor_name"],
        quantity: json["quantity"],
        image: json["image"],
        price: json["price"].toDouble(),
        offerPrice: json["offer_price"]?.toDouble(),
        offerPriceFormatted: json["offer_price_formatted"],
        tax: json["tax"],
        discount: json["discount"]?.toDouble(),
        slug: json["slug"],
        name: json["name"],
        shop: json["shop"] == null ? null : Shop.fromJson(json["shop"]),
        brand: json["brand"] == null ? null : CartBrand.fromJson(json["brand"]),
        boutique: json["boutique"] == null
            ? null
            : BoutiquesCart.fromJson(json["boutique"]),
        thumbnail: json["thumbnail"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        flashDealDetails: json["flash_deal_details"],
        flashDealMaxAllowedQuantity: json["flash_deal_max_allowed_quantity"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
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
        "price": price,
        "offer_price": offerPrice,
        "offer_price_formatted": offerPriceFormatted,
        "tax": tax,
        "discount": discount,
        "slug": slug,
        "name": name,
        "shop": shop?.toJson(),
        "brand": brand?.toJson(),
        "boutique": boutique?.toJson(),
        "thumbnail": thumbnail,
        "created_at": createdAt?.toIso8601String(),
        "flash_deal_details": flashDealDetails,
        "flash_deal_max_allowed_quantity": flashDealMaxAllowedQuantity,
      };
}

class BoutiquesCart {
  final int? id;
  final IconCart? icon;

  BoutiquesCart({
    this.id,
    this.icon,
  });

  BoutiquesCart copyWith({
    int? id,
    IconCart? icon,
  }) =>
      BoutiquesCart(
        id: id ?? this.id,
        icon: icon ?? this.icon,
      );

  factory BoutiquesCart.fromJson(Map<String, dynamic> json) => BoutiquesCart(
        id: json["id"],
        icon: json["icon"] == null ? null : IconCart.fromJson(json["icon"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "icon": icon?.toJson(),
      };
}

class IconCart {
  final String? filePath;
  final String? originalWidth;
  final String? originalHeight;

  IconCart({
    this.filePath,
    this.originalWidth,
    this.originalHeight,
  });

  IconCart copyWith({
    String? filePath,
    String? originalWidth,
    String? originalHeight,
  }) =>
      IconCart(
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
  final String? name;
  final String? image;

  CartBrand({
    this.id,
    this.name,
    this.image,
  });

  CartBrand copyWith({
    int? id,
    String? name,
    String? image,
  }) =>
      CartBrand(
        id: id ?? this.id,
        name: name ?? this.name,
        image: image ?? this.image,
      );

  factory CartBrand.fromJson(Map<String, dynamic> json) => CartBrand(
        id: json["id"],
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
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

class VariationCart {
  final String? size;
  final String? color;

  VariationCart({
    this.size,
    this.color,
  });

  VariationCart copyWith({
    String? size,
    String? color,
  }) =>
      VariationCart(
        size: size ?? this.size,
        color: color ?? this.color,
      );

  factory VariationCart.fromJson(Map<String, dynamic> json) => VariationCart(
        size: json["Size"],
        color: json["color"],
      );

  Map<String, dynamic> toJson() => {
        "Size": size,
        "color": color,
      };
}
