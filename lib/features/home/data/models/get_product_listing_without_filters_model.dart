// To parse this JSON data, do
//
//     final getProductListingWithoutFiltersModel = getProductListingWithoutFiltersModelFromJson(jsonString);

import 'dart:convert';

import 'get_category_model.dart';

GetProductListingWithoutFiltersModel
    getProductListingWithoutFiltersModelFromJson(String str) =>
        GetProductListingWithoutFiltersModel.fromJson(json.decode(str));

String getProductListingWithoutFiltersModelToJson(
        GetProductListingWithoutFiltersModel data) =>
    json.encode(data.toJson());

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

  factory GetProductListingWithoutFiltersModel.fromJson(
          Map<String, dynamic> json) =>
      GetProductListingWithoutFiltersModel(
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
  final List<Products>? products;
  final String? resultFor;
  final String? boutiqueSlug;

  Data({
    this.totalSize,
    this.limit,
    this.offset,
    this.products,
    this.resultFor,
    this.boutiqueSlug,
  });

  Data copyWith({
    int? totalSize,
    int? limit,
    int? offset,
    List<Products>? products,
    String? resultFor,
    String? boutiqueSlug,
  }) =>
      Data(
        totalSize: totalSize ?? this.totalSize,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        products: products ?? this.products,
        resultFor: resultFor ?? this.resultFor,
        boutiqueSlug: boutiqueSlug ?? this.boutiqueSlug,
      );

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      totalSize: json["total_size"],
      limit: json["limit"],
      offset: json["offset"],
      products: json["products"] == null
          ? []
          : List<Products>.from(
              json["products"]!.map((x) => Products.fromJson(x))),
      resultFor: json["result_for"],
      boutiqueSlug: json["boutique_slug"],
    );
  }

  Map<String, dynamic> toJson() => {
        "total_size": totalSize,
        "limit": limit,
        "offset": offset,
        "products": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "result_for": resultFor,
        "boutique_slug": boutiqueSlug,
      };
}

class Products {
  final int? id;
  final String? name;
  final String? slug;
  final String? shareLink;
  final String? details;
  final Thumbnail? thumbnail;
  final List<Thumbnail>? images;
  final List<Category>? categories;
  final Category? category;
  final Brand? brand;
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

  Products({
    this.id,
    this.name,
    this.slug,
    this.shareLink,
    this.details,
    this.thumbnail,
    this.images,
    this.categories,
    this.category,
    this.brand,
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

  Products copyWith({
    int? id,
    String? name,
    String? slug,
    String? shareLink,
    String? details,
    Thumbnail? thumbnail,
    List<Thumbnail>? images,
    List<Category>? categories,
    Category? category,
    Brand? brand,
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
      Products(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        shareLink: shareLink ?? this.shareLink,
        details: details ?? this.details,
        thumbnail: thumbnail ?? this.thumbnail,
        images: images ?? this.images,
        categories: categories ?? this.categories,
        category: category ?? this.category,
        brand: brand ?? this.brand,
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
        flashDealMaxAllowedQuantity:
            flashDealMaxAllowedQuantity ?? this.flashDealMaxAllowedQuantity,
      );

  factory Products.fromJson(Map<String, dynamic> json) => Products(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        shareLink: json["share_link"],
        details: json["details"],
        thumbnail: json["thumbnail"] == null
            ? null
            : Thumbnail.fromJson(json["thumbnail"]),
        images: json["images"] == null
            ? []
            : List<Thumbnail>.from(
                json["images"]!.map((x) => Thumbnail.fromJson(x))),
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"]!.map((x) => Category.fromJson(x))),
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
        brand: json["brand"] == null ? null : Brand.fromJson(json["brand"]),
        colors: json["colors"] == null
            ? []
            : List<Color>.from(json["colors"]!.map((x) => Color.fromJson(x))),
        syncColorImages: json["sync_color_images"] == null
            ? []
            : List<SyncColorImage>.from(json["sync_color_images"]!
                .map((x) => SyncColorImage.fromJson(x))),
        price: json["price"].toDouble(),
        priceFormatted: json["price_formatted"],
        offerPrice: json["offer_price"].toDouble(),
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
        "thumbnail": thumbnail?.toJson(),
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toJson())),
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "category": category?.toJson(),
        "brand": brand?.toJson(),
        "colors": colors == null
            ? []
            : List<dynamic>.from(colors!.map((x) => x.toJson())),
        "sync_color_images": syncColorImages == null
            ? []
            : List<dynamic>.from(syncColorImages!.map((x) => x.toJson())),
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

class Brand {
  final int? id;
  final String? name;
  final String? image;

  Brand({
    this.id,
    this.name,
    this.image,
  });

  Brand copyWith({
    int? id,
    String? name,
    String? image,
  }) =>
      Brand(
        id: id ?? this.id,
        name: name ?? this.name,
        image: image ?? this.image,
      );

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
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

class Thumbnail {
  final String? filePath;
  final String? originalWidth;
  final String? originalHeight;

  Thumbnail({
    this.filePath,
    this.originalWidth,
    this.originalHeight,
  });

  Thumbnail copyWith({
    String? filePath,
    String? originalWidth,
    String? originalHeight,
  }) =>
      Thumbnail(
        filePath: filePath ?? this.filePath,
        originalWidth: originalWidth ?? this.originalWidth,
        originalHeight: originalHeight ?? this.originalHeight,
      );

  factory Thumbnail.fromJson(Map<String, dynamic> json) => Thumbnail(
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
  final List<Thumbnail>? images;
  final bool? colorTrend;

  SyncColorImage({
    this.colorName,
    this.images,
    this.colorTrend,
  });

  SyncColorImage copyWith({
    String? colorName,
    List<Thumbnail>? images,
    bool? colorTrend,
  }) =>
      SyncColorImage(
        colorName: colorName ?? this.colorName,
        images: images ?? this.images,
        colorTrend: colorTrend ?? this.colorTrend,
      );

  factory SyncColorImage.fromJson(Map<String, dynamic> json) => SyncColorImage(
        colorName: json["color_name"],
        images: json["images"] == null
            ? []
            : List<Thumbnail>.from(
                json["images"]!.map((x) => Thumbnail.fromJson(x))),
        colorTrend: json["color_trend"],
      );

  Map<String, dynamic> toJson() => {
        "color_name": colorName,
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toJson())),
        "color_trend": colorTrend,
      };
}
