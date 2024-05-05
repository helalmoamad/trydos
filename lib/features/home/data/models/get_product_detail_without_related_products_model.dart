// To parse this JSON data, do
//
//     final getProductDetailWithoutRelatedProductsModel = getProductDetailWithoutRelatedProductsModelFromJson(jsonString);

import 'dart:convert';

GetProductDetailWithoutRelatedProductsModel
    getProductDetailWithoutRelatedProductsModelFromJson(String str) =>
        GetProductDetailWithoutRelatedProductsModel.fromJson(json.decode(str));

String getProductDetailWithoutRelatedProductsModelToJson(
        GetProductDetailWithoutRelatedProductsModel data) =>
    json.encode(data.toJson());

class GetProductDetailWithoutRelatedProductsModel {
  final String? message;
  final Product? product;

  GetProductDetailWithoutRelatedProductsModel({
    this.message,
    this.product,
  });

  GetProductDetailWithoutRelatedProductsModel copyWith({
    String? message,
    Product? data,
  }) =>
      GetProductDetailWithoutRelatedProductsModel(
        message: message ?? this.message,
        product: data ?? this.product,
      );

  factory GetProductDetailWithoutRelatedProductsModel.fromJson(
          Map<String, dynamic> json) =>
      GetProductDetailWithoutRelatedProductsModel(
        message: json["message"],
        product: json["data"] == null ? null : Product.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": product?.toJson(),
      };
}

class Product {
  final int? id;
  final String? description;
  final dynamic model;
  final dynamic features;
  final bool? inStock;
  final List<dynamic>? variation;
  final List<dynamic>? choiceOptions;
  final bool? hasDiscount;
  final bool? hasTax;
  final String? deliveryAt;
  final String? tax;
  final String? unitPrice;
  final int? currentStock;
  final int? leftStock;
  final int? reviewsCount;
  final dynamic sellerId;
  final Seller? seller;
  final Shop? shop;
  final bool? isFavSeller;
  final List<dynamic>? reviews;
  final bool? hasWholeSale;
  final dynamic wholeSaleLink;
  final int? viewsCount;

  Product({
    this.id,
    this.description,
    this.model,
    this.features,
    this.inStock,
    this.variation,
    this.choiceOptions,
    this.hasDiscount,
    this.hasTax,
    this.deliveryAt,
    this.tax,
    this.unitPrice,
    this.currentStock,
    this.leftStock,
    this.reviewsCount,
    this.sellerId,
    this.seller,
    this.shop,
    this.isFavSeller,
    this.reviews,
    this.hasWholeSale,
    this.wholeSaleLink,
    this.viewsCount,
  });

  Product copyWith({
    int? id,
    String? description,
    dynamic model,
    dynamic features,
    bool? inStock,
    List<dynamic>? variation,
    List<dynamic>? choiceOptions,
    bool? hasDiscount,
    bool? hasTax,
    String? deliveryAt,
    String? tax,
    String? unitPrice,
    int? currentStock,
    int? leftStock,
    int? reviewsCount,
    dynamic sellerId,
    Seller? seller,
    Shop? shop,
    bool? isFavSeller,
    List<dynamic>? reviews,
    bool? hasWholeSale,
    dynamic wholeSaleLink,
    int? viewsCount,
  }) =>
      Product(
        id: id ?? this.id,
        description: description ?? this.description,
        model: model ?? this.model,
        features: features ?? this.features,
        inStock: inStock ?? this.inStock,
        variation: variation ?? this.variation,
        choiceOptions: choiceOptions ?? this.choiceOptions,
        hasDiscount: hasDiscount ?? this.hasDiscount,
        hasTax: hasTax ?? this.hasTax,
        deliveryAt: deliveryAt ?? this.deliveryAt,
        tax: tax ?? this.tax,
        unitPrice: unitPrice ?? this.unitPrice,
        currentStock: currentStock ?? this.currentStock,
        leftStock: leftStock ?? this.leftStock,
        reviewsCount: reviewsCount ?? this.reviewsCount,
        sellerId: sellerId ?? this.sellerId,
        seller: seller ?? this.seller,
        shop: shop ?? this.shop,
        isFavSeller: isFavSeller ?? this.isFavSeller,
        reviews: reviews ?? this.reviews,
        hasWholeSale: hasWholeSale ?? this.hasWholeSale,
        wholeSaleLink: wholeSaleLink ?? this.wholeSaleLink,
        viewsCount: viewsCount ?? this.viewsCount,
      );

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        description: json["description"],
        model: json["model"],
        features: json["features"],
        inStock: json["in_stock"],
        variation: json["variation"] == null
            ? []
            : List<dynamic>.from(json["variation"]!.map((x) => x)),
        choiceOptions: json["choice_options"] == null
            ? []
            : List<dynamic>.from(json["choice_options"]!.map((x) => x)),
        hasDiscount: json["has_discount"],
        hasTax: json["has_tax"],
        deliveryAt: json["delivery_at"],
        tax: json["tax"],
        unitPrice: json["unit_price"],
        currentStock: json["current_stock"],
        leftStock: json["Left_stock"],
        reviewsCount: json["reviews_count"],
        sellerId: json["seller_id"],
        seller: json["seller"] == null ? null : Seller.fromJson(json["seller"]),
        shop: json["shop"] == null ? null : Shop.fromJson(json["shop"]),
        isFavSeller: json["is_fav_seller"],
        reviews: json["reviews"] == null
            ? []
            : List<dynamic>.from(json["reviews"]!.map((x) => x)),
        hasWholeSale: json["has_whole_sale"],
        wholeSaleLink: json["whole_sale_link"],
        viewsCount: json["views_count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "model": model,
        "features": features,
        "in_stock": inStock,
        "variation": variation == null
            ? []
            : List<dynamic>.from(variation!.map((x) => x)),
        "choice_options": choiceOptions == null
            ? []
            : List<dynamic>.from(choiceOptions!.map((x) => x)),
        "has_discount": hasDiscount,
        "has_tax": hasTax,
        "delivery_at": deliveryAt,
        "tax": tax,
        "unit_price": unitPrice,
        "current_stock": currentStock,
        "Left_stock": leftStock,
        "reviews_count": reviewsCount,
        "seller_id": sellerId,
        "seller": seller?.toJson(),
        "shop": shop?.toJson(),
        "is_fav_seller": isFavSeller,
        "reviews":
            reviews == null ? [] : List<dynamic>.from(reviews!.map((x) => x)),
        "has_whole_sale": hasWholeSale,
        "whole_sale_link": wholeSaleLink,
        "views_count": viewsCount,
      };
}

class Seller {
  final dynamic name;
  final dynamic fName;
  final dynamic lName;
  final dynamic email;
  final dynamic gender;
  final dynamic birthdate;
  final dynamic review;
  final dynamic image;

  Seller({
    this.name,
    this.fName,
    this.lName,
    this.email,
    this.gender,
    this.birthdate,
    this.review,
    this.image,
  });

  Seller copyWith({
    dynamic name,
    dynamic fName,
    dynamic lName,
    dynamic email,
    dynamic gender,
    dynamic birthdate,
    dynamic review,
    dynamic image,
  }) =>
      Seller(
        name: name ?? this.name,
        fName: fName ?? this.fName,
        lName: lName ?? this.lName,
        email: email ?? this.email,
        gender: gender ?? this.gender,
        birthdate: birthdate ?? this.birthdate,
        review: review ?? this.review,
        image: image ?? this.image,
      );

  factory Seller.fromJson(Map<String, dynamic> json) => Seller(
        name: json["name"],
        fName: json["f_name"],
        lName: json["l_name"],
        email: json["email"],
        gender: json["gender"],
        birthdate: json["birthdate"],
        review: json["review"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "f_name": fName,
        "l_name": lName,
        "email": email,
        "gender": gender,
        "birthdate": birthdate,
        "review": review,
        "image": image,
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
