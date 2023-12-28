// To parse this JSON data, do
//
//     final getProductListingWithoutFiltersModel = getProductListingWithoutFiltersModelFromJson(jsonString);

import 'dart:convert';

GetProductListingWithoutFiltersModel getProductListingWithoutFiltersModelFromJson(String str) => GetProductListingWithoutFiltersModel.fromJson(json.decode(str));

String getProductListingWithoutFiltersModelToJson(GetProductListingWithoutFiltersModel data) => json.encode(data.toJson());

class GetProductListingWithoutFiltersModel {
  final String? message;
  final Data? data;

  GetProductListingWithoutFiltersModel({
    this.message,
    this.data,
  });

  GetProductListingWithoutFiltersModel copyWith({
    String? message,
    Data? data,
  }) =>
      GetProductListingWithoutFiltersModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetProductListingWithoutFiltersModel.fromJson(Map<String, dynamic> json) => GetProductListingWithoutFiltersModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  final int? totalSize;
  final int? limit;
  final int? offset;
  final List<Product>? products;
  final String? categoryParentParent;
  final String? categoryParent;
  final String? category;
  final String? categorySeoDescription;
  final String? categoryTitle;
  final String? categoryH1;
  final String? childCategories;
  final String? resultFor;

  Data({
    this.totalSize,
    this.limit,
    this.offset,
    this.products,
    this.categoryParentParent,
    this.categoryParent,
    this.category,
    this.categorySeoDescription,
    this.categoryTitle,
    this.categoryH1,
    this.childCategories,
    this.resultFor,
  });

  Data copyWith({
    int? totalSize,
    int? limit,
    int? offset,
    List<Product>? products,
    String? categoryParentParent,
    String? categoryParent,
    String? category,
    String? categorySeoDescription,
    String? categoryTitle,
    String? categoryH1,
    String? childCategories,
    String? resultFor,
  }) =>
      Data(
        totalSize: totalSize ?? this.totalSize,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        products: products ?? this.products,
        categoryParentParent: categoryParentParent ?? this.categoryParentParent,
        categoryParent: categoryParent ?? this.categoryParent,
        category: category ?? this.category,
        categorySeoDescription: categorySeoDescription ?? this.categorySeoDescription,
        categoryTitle: categoryTitle ?? this.categoryTitle,
        categoryH1: categoryH1 ?? this.categoryH1,
        childCategories: childCategories ?? this.childCategories,
        resultFor: resultFor ?? this.resultFor,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalSize: json["total_size"],
    limit: json["limit"],
    offset: json["offset"],
    products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
    categoryParentParent: json["category_parent_parent"],
    categoryParent: json["category_parent"],
    category: json["category"],
    categorySeoDescription: json["category_seo_description"],
    categoryTitle: json["category_title"],
    categoryH1: json["category_h1"],
    childCategories: json["child_categories"],
    resultFor: json["result_for"],
  );

  Map<String, dynamic> toJson() => {
    "total_size": totalSize,
    "limit": limit,
    "offset": offset,
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
    "category_parent_parent": categoryParentParent,
    "category_parent": categoryParent,
    "category": category,
    "category_seo_description": categorySeoDescription,
    "category_title": categoryTitle,
    "category_h1": categoryH1,
    "child_categories": childCategories,
    "result_for": resultFor,
  };
}

class Product {
  final int? id;
  final String? name;
  final String? slug;
  final String? shareLink;
  final String? details;
  final String? thumbnail;
  final List<String>? images;
  final List<Color>? colors;
  final List<SyncColorImage>? syncColorImages;
  final double? price;
  final String? priceFormatted;
  final double? offerPrice;
  final String? offerPriceFormatted;
  final bool? isFavourite;
  final bool? inStock;
  final Rating? rating;
  final dynamic flashDealDetails;
  final dynamic flashDealMaxAllowedQuantity;

  Product({
    this.id,
    this.name,
    this.slug,
    this.shareLink,
    this.details,
    this.thumbnail,
    this.images,
    this.colors,
    this.syncColorImages,
    this.price,
    this.priceFormatted,
    this.offerPrice,
    this.offerPriceFormatted,
    this.isFavourite,
    this.inStock,
    this.rating,
    this.flashDealDetails,
    this.flashDealMaxAllowedQuantity,
  });

  Product copyWith({
    int? id,
    String? name,
    String? slug,
    String? shareLink,
    String? details,
    String? thumbnail,
    List<String>? images,
    List<Color>? colors,
    List<SyncColorImage>? syncColorImages,
    double? price,
    String? priceFormatted,
    double? offerPrice,
    String? offerPriceFormatted,
    bool? isFavourite,
    bool? inStock,
    Rating? rating,
    dynamic flashDealDetails,
    dynamic flashDealMaxAllowedQuantity,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        shareLink: shareLink ?? this.shareLink,
        details: details ?? this.details,
        thumbnail: thumbnail ?? this.thumbnail,
        images: images ?? this.images,
        colors: colors ?? this.colors,
        syncColorImages: syncColorImages ?? this.syncColorImages,
        price: price ?? this.price,
        priceFormatted: priceFormatted ?? this.priceFormatted,
        offerPrice: offerPrice ?? this.offerPrice,
        offerPriceFormatted: offerPriceFormatted ?? this.offerPriceFormatted,
        isFavourite: isFavourite ?? this.isFavourite,
        inStock: inStock ?? this.inStock,
        rating: rating ?? this.rating,
        flashDealDetails: flashDealDetails ?? this.flashDealDetails,
        flashDealMaxAllowedQuantity: flashDealMaxAllowedQuantity ?? this.flashDealMaxAllowedQuantity,
      );

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    shareLink: json["share_link"],
    details: json["details"],
    thumbnail: json["thumbnail"],
    images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
    colors: json["colors"] == null ? [] : List<Color>.from(json["colors"]!.map((x) => Color.fromJson(x))),
    syncColorImages: json["sync_color_images"] == null ? [] : List<SyncColorImage>.from(json["sync_color_images"]!.map((x) => SyncColorImage.fromJson(x))),
    price: json["price"]?.toDouble(),
    priceFormatted: json["price_formatted"],
    offerPrice: json["offer_price"]?.toDouble(),
    offerPriceFormatted: json["offer_price_formatted"],
    isFavourite: json["is_favourite"],
    inStock: json["in_stock"],
    rating: json["rating"] == null ? null : Rating.fromJson(json["rating"]),
    flashDealDetails: json["flash_deal_details"],
    flashDealMaxAllowedQuantity: json["flash_deal_max_allowed_quantity"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "share_link": shareLink,
    "details": details,
    "thumbnail": thumbnail,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    "colors": colors == null ? [] : List<dynamic>.from(colors!.map((x) => x.toJson())),
    "sync_color_images": syncColorImages == null ? [] : List<dynamic>.from(syncColorImages!.map((x) => x.toJson())),
    "price": price,
    "price_formatted": priceFormatted,
    "offer_price": offerPrice,
    "offer_price_formatted": offerPriceFormatted,
    "is_favourite": isFavourite,
    "in_stock": inStock,
    "rating": rating?.toJson(),
    "flash_deal_details": flashDealDetails,
    "flash_deal_max_allowed_quantity": flashDealMaxAllowedQuantity,
  };
}

class Color {
  final String? name;
  final String? color;

  Color({
    this.name,
    this.color,
  });

  Color copyWith({
    String? name,
    String? color,
  }) =>
      Color(
        name: name ?? this.name,
        color: color ?? this.color,
      );

  factory Color.fromJson(Map<String, dynamic> json) => Color(
    name: json["name"],
    color: json["color"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "color": color,
  };
}

class Rating {
  final int? overallRating;
  final int? totalRating;

  Rating({
    this.overallRating,
    this.totalRating,
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
    overallRating: json["overall_rating"],
    totalRating: json["total_rating"],
  );

  Map<String, dynamic> toJson() => {
    "overall_rating": overallRating,
    "total_rating": totalRating,
  };
}

class SyncColorImage {
  final String? colorName;
  final List<String>? images;

  SyncColorImage({
    this.colorName,
    this.images,
  });

  SyncColorImage copyWith({
    String? colorName,
    List<String>? images,
  }) =>
      SyncColorImage(
        colorName: colorName ?? this.colorName,
        images: images ?? this.images,
      );

  factory SyncColorImage.fromJson(Map<String, dynamic> json) => SyncColorImage(
    colorName: json["color_name"],
    images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "color_name": colorName,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
  };
}
