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
  final int? subTotal;
  final String? subTotalFormated;
  final int? totalTax;
  final String? totalTaxFormated;
  final int? totalDiscountOnProduct;
  final String? totalDiscountOnProductFormated;
  final int? totalShippingCost;
  final String? totalShippingCostFormated;
  final int? couponDiscount;
  final String? couponDiscountFormated;
  final int? codCost;
  final String? codCostFormated;
  final bool? hasCod;
  final int? limitFree;
  final String? limitFreeFormated;
  final int? estimatedTax;
  final String? estimatedTaxFormated;
  final int? total;
  final String? totalFormated;
  final int? restForFreeShipping;
  final String? restForFreeShippingFormatted;
  final bool? showMessageResetForShippingFree;
  final List<String>? availablePaymentMethod;
  final int? totalCash;
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
    int? subTotal,
    String? subTotalFormated,
    int? totalTax,
    String? totalTaxFormated,
    int? totalDiscountOnProduct,
    String? totalDiscountOnProductFormated,
    int? totalShippingCost,
    String? totalShippingCostFormated,
    int? couponDiscount,
    String? couponDiscountFormated,
    int? codCost,
    String? codCostFormated,
    bool? hasCod,
    int? limitFree,
    String? limitFreeFormated,
    int? estimatedTax,
    String? estimatedTaxFormated,
    int? total,
    String? totalFormated,
    int? restForFreeShipping,
    String? restForFreeShippingFormatted,
    bool? showMessageResetForShippingFree,
    List<String>? availablePaymentMethod,
    int? totalCash,
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
        subTotal: json["sub_total"],
        subTotalFormated: json["sub_total_formated"],
        totalTax: json["total_tax"],
        totalTaxFormated: json["total_tax_formated"],
        totalDiscountOnProduct: json["total_discount_on_product"],
        totalDiscountOnProductFormated:
            json["total_discount_on_product_formated"],
        totalShippingCost: json["total_shipping_cost"],
        totalShippingCostFormated: json["total_shipping_cost_formated"],
        couponDiscount: json["coupon_discount"],
        couponDiscountFormated: json["coupon_discount_formated"],
        codCost: json["cod_cost"],
        codCostFormated: json["cod_cost_formated"],
        hasCod: json["has_cod"],
        limitFree: json["limitFree"],
        limitFreeFormated: json["limitFree_formated"],
        estimatedTax: json["estimated_tax"],
        estimatedTaxFormated: json["estimated_tax_formated"],
        total: json["total"],
        totalFormated: json["total_formated"],
        restForFreeShipping: json["rest_for_free_shipping"],
        restForFreeShippingFormatted: json["rest_for_free_shipping_formatted"],
        showMessageResetForShippingFree:
            json["show_message_reset_for_shipping_free"],
        availablePaymentMethod: json["available_payment_method"] == null
            ? []
            : List<String>.from(
                json["available_payment_method"]!.map((x) => x)),
        totalCash: json["total_cash"],
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
  final int? productId;
  final dynamic choices;
  final Variations? variations;
  final String? variant;
  final int? availableQuantity;
  final String? vendorName;
  final int? quantity;
  final String? price;
  final int? priceNum;
  final int? offerPrice;
  final String? offerPriceFormatted;
  final int? tax;
  final int? discount;
  final String? slug;
  final String? name;
  final Shop? shop;
  final String? thumbnail;
  final DateTime? createdAt;
  final dynamic flashDealDetails;
  final dynamic flashDealMaxAllowedQuantity;

  Cart({
    this.id,
    this.customerId,
    this.cartGroupId,
    this.productId,
    this.choices,
    this.variations,
    this.variant,
    this.availableQuantity,
    this.vendorName,
    this.quantity,
    this.price,
    this.priceNum,
    this.offerPrice,
    this.offerPriceFormatted,
    this.tax,
    this.discount,
    this.slug,
    this.name,
    this.shop,
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
    dynamic choices,
    Variations? variations,
    String? variant,
    int? availableQuantity,
    String? vendorName,
    int? quantity,
    String? price,
    int? priceNum,
    int? offerPrice,
    String? offerPriceFormatted,
    int? tax,
    int? discount,
    String? slug,
    String? name,
    Shop? shop,
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
        variations: variations ?? this.variations,
        variant: variant ?? this.variant,
        availableQuantity: availableQuantity ?? this.availableQuantity,
        vendorName: vendorName ?? this.vendorName,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
        priceNum: priceNum ?? this.priceNum,
        offerPrice: offerPrice ?? this.offerPrice,
        offerPriceFormatted: offerPriceFormatted ?? this.offerPriceFormatted,
        tax: tax ?? this.tax,
        discount: discount ?? this.discount,
        slug: slug ?? this.slug,
        name: name ?? this.name,
        shop: shop ?? this.shop,
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
        choices: json["choices"],
        variations: json["variations"] == null
            ? null
            : Variations.fromJson(json["variations"]),
        variant: json["variant"],
        availableQuantity: json["available_quantity"],
        vendorName: json["vendor_name"],
        quantity: json["quantity"],
        price: json["price"],
        priceNum: json["price_num"],
        offerPrice: json["offer_price"],
        offerPriceFormatted: json["offer_price_formatted"],
        tax: json["tax"],
        discount: json["discount"],
        slug: json["slug"],
        name: json["name"],
        shop: json["shop"] == null ? null : Shop.fromJson(json["shop"]),
        thumbnail: json["thumbnail"],
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
        "choices": choices,
        "variations": variations?.toJson(),
        "variant": variant,
        "available_quantity": availableQuantity,
        "vendor_name": vendorName,
        "quantity": quantity,
        "price": price,
        "price_num": priceNum,
        "offer_price": offerPrice,
        "offer_price_formatted": offerPriceFormatted,
        "tax": tax,
        "discount": discount,
        "slug": slug,
        "name": name,
        "shop": shop?.toJson(),
        "thumbnail": thumbnail,
        "created_at": createdAt?.toIso8601String(),
        "flash_deal_details": flashDealDetails,
        "flash_deal_max_allowed_quantity": flashDealMaxAllowedQuantity,
      };
}

class ChoicesClass {
  final String? choice1;

  ChoicesClass({
    this.choice1,
  });

  ChoicesClass copyWith({
    String? choice1,
  }) =>
      ChoicesClass(
        choice1: choice1 ?? this.choice1,
      );

  factory ChoicesClass.fromJson(Map<String, dynamic> json) => ChoicesClass(
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

class Variations {
  final String? size;
  final String? color;

  Variations({
    this.size,
    this.color,
  });

  Variations copyWith({
    String? size,
    String? color,
  }) =>
      Variations(
        size: size ?? this.size,
        color: color ?? this.color,
      );

  factory Variations.fromJson(Map<String, dynamic> json) => Variations(
        size: json["Size"],
        color: json["color"],
      );

  Map<String, dynamic> toJson() => {
        "Size": size,
        "color": color,
      };
}
