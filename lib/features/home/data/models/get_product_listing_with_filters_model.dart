// To parse this JSON data, do
//
//     final getProductListingWithoutFiltersModel = getProductListingWithoutFiltersModelFromJson(jsonString);

import 'dart:convert';

import 'package:trydos/features/home/data/models/get_product_filters_model.dart';

import 'get_category_model.dart';
import 'get_product_filters_model.dart' as filters;
import 'get_product_listing_without_filters_model.dart'
    as product_without_filters;

GetProductListingWithFiltersModel getProductListingWithFiltersModelFromJson(
        String str) =>
    GetProductListingWithFiltersModel.fromJson(json.decode(str));

String getProductListingWithFiltersModelToJson(
        GetProductListingWithFiltersModel data) =>
    json.encode(data.toJson());

class GetProductListingWithFiltersModel {
  final String? message;
  final Data? data;

  GetProductListingWithFiltersModel({
    this.message,
    this.data,
  });

  GetProductListingWithFiltersModel copyWith({
    String? message,
    Data? data,
  }) =>
      GetProductListingWithFiltersModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetProductListingWithFiltersModel.fromJson(
          Map<String, dynamic> json) =>
      GetProductListingWithFiltersModel(
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
  final String? offset;
  //final int? offset;
  final List<product_without_filters.Products>? products;
  final List<filters.Brand>? brands;
  final List<filters.Attribute>? attributes;
  final List<String>? colors;
  final List<Category>? categories;
  final filters.Prices? prices;
  final List<Boutique>? boutiques;
  final String? boutiqueSlug;

  Data({
    this.totalSize,
    this.limit,
    this.offset,
    this.products,
    this.brands,
    this.boutiques,
    this.attributes,
    this.categories,
    this.colors,
    this.prices,
    this.boutiqueSlug,
  });

  Data copyWith({
    int? totalSize,
    int? limit,
    String? offset,
    // int? offset,
    List<product_without_filters.Products>? products,
    List<filters.Brand>? brands,
    List<filters.Attribute>? attributes,
    List<String>? colors,
    List<Category>? categories,
    filters.Prices? prices,
    List<Boutique>? boutiques,
    String? boutiqueSlug,
  }) =>
      Data(
        totalSize: totalSize ?? this.totalSize,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        products: products ?? this.products,
        brands: brands ?? this.brands,
        attributes: attributes ?? this.attributes,
        boutiques: boutiques ?? this.boutiques,
        colors: colors ?? this.colors,
        prices: prices ?? this.prices,
        boutiqueSlug: boutiqueSlug ?? this.boutiqueSlug,
      );

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      totalSize: json["total_size"],
      limit: json["limit"],
      offset: json["offset"],
      products: json["products"] == null
          ? []
          : List<product_without_filters.Products>.from(json["products"]!
              .map((x) => product_without_filters.Products.fromJson(x))),
      brands: json["brands"] == null
          ? []
          : List<filters.Brand>.from(
              json["brands"]!.map((x) => filters.Brand.fromJson(x))),
      boutiques: json["boutiques"] == null
          ? []
          : List<Boutique>.from(
              json["boutiques"]!.map((x) => Boutique.fromJson(x))),
      attributes: json["attributes"] == null || json["attributes"] == []
          ? []
          : List<filters.Attribute>.from(
              json["attributes"]!.map((x) => filters.Attribute.fromJson(x))),
      categories: json["categories"] == null
          ? []
          : List<Category>.from(
              json["categories"]!.map((x) => Category.fromJson(x))),
      colors: json["colors"] == null
          ? []
          : List<String>.from(json["colors"]!.map((x) => x)),
      prices: json["prices"] == null
          ? null
          : filters.Prices.fromJson(json["prices"]),
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
        "brands": brands == null
            ? []
            : List<dynamic>.from(brands!.map((x) => x.toJson())),
        "boutiques": boutiques == null
            ? []
            : List<dynamic>.from(boutiques!.map((x) => x.toJson())),
        "attributes": attributes == null || attributes == []
            ? []
            : List<dynamic>.from(attributes!.map((x) => x.toJson())),
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "colors":
            colors == null ? [] : List<dynamic>.from(colors!.map((x) => x)),
        "prices": prices?.toJson(),
        "boutique_slug": boutiqueSlug,
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

class Category {
  final int? id;
  final String? slug;
  final String? name;
  final int? numAvailableProduct;
  final Banner? flatPhotoPath;

  final bool isSubCategory;
  final bool isSelected;
  Banner? mostViewedProductThumbnail;
  final List<SubCategory>? subCategories;

  Category({
    this.id,
    this.slug,
    this.name,
    this.mostViewedProductThumbnail,
    this.numAvailableProduct,
    this.flatPhotoPath,
    this.isSubCategory = false,
    this.isSelected = false,
    this.subCategories,
  });

  Category copyWith({
    int? id,
    String? slug,
    String? name,
    int? numAvailableProduct,
    Banner? flatPhotoPath,
    Banner? mostViewedProductThumbnail,
    final bool? isSelected,
    List<SubCategory>? subCategories,
  }) =>
      Category(
        id: id ?? this.id,
        slug: slug ?? this.slug,
        name: name ?? this.name,
        numAvailableProduct: numAvailableProduct ?? this.numAvailableProduct,
        flatPhotoPath: flatPhotoPath ?? this.flatPhotoPath,
        isSelected: isSelected ?? this.isSelected,
        mostViewedProductThumbnail:
            mostViewedProductThumbnail ?? this.mostViewedProductThumbnail,
        subCategories: subCategories ?? this.subCategories,
      );

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"],
      slug: json["slug"],
      name: json["name"],
      mostViewedProductThumbnail: json["most_viewed_product_thumbnail"] == null
          ? null
          : Banner.fromJson(json["most_viewed_product_thumbnail"]),
      numAvailableProduct: json["num_available_product"],
      flatPhotoPath: json["flat_photo_path"] == null
          ? null
          : Banner.fromJson(json["flat_photo_path"]),
      subCategories: json["childes"] == null || json["childes"] == []
          ? []
          : List<SubCategory>.from(
              json["childes"]!.map((x) => SubCategory.fromJson(x))),
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "name": name,
        "most_viewed_product_thumbnail": mostViewedProductThumbnail?.toJson(),
        "num_available_product": numAvailableProduct,
        "flat_photo_path": flatPhotoPath?.toJson(),
        "childes": subCategories == null
            ? []
            : List<dynamic>.from(subCategories!.map((x) => x.toJson())),
      };
}

class SubCategory {
  final int? id;
  final String? slug;
  final bool? isSubSubCategory;
  final String? name;
  Banner? mostViewedProductThumbnail;
  final int? numAvailableProduct;
  final Banner? flatPhotoPath;
  final List<SubCategory>? childes;
  SubCategory({
    this.id,
    this.slug,
    this.mostViewedProductThumbnail,
    this.name,
    this.numAvailableProduct,
    this.flatPhotoPath,
    this.isSubSubCategory,
    this.childes,
  });

  SubCategory copyWith({
    int? id,
    String? slug,
    String? name,
    bool? isSubSubCategory,
    int? numAvailableProduct,
    Banner? flatPhotoPath,
    Banner? mostViewedProductThumbnail,
    List<SubCategory>? childes,
  }) =>
      SubCategory(
        id: id ?? this.id,
        slug: slug ?? this.slug,
        mostViewedProductThumbnail:
            mostViewedProductThumbnail ?? this.mostViewedProductThumbnail,
        isSubSubCategory: isSubSubCategory ?? this.isSubSubCategory,
        name: name ?? this.name,
        numAvailableProduct: numAvailableProduct ?? this.numAvailableProduct,
        flatPhotoPath: flatPhotoPath ?? this.flatPhotoPath,
        childes: childes ?? this.childes,
      );

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
        id: json["id"],
        slug: json["slug"],
        name: json["name"],
        numAvailableProduct: json["num_available_product"],
        flatPhotoPath: json["flat_photo_path"] == null
            ? null
            : Banner.fromJson(json["flat_photo_path"]),
        mostViewedProductThumbnail:
            json["most_viewed_product_thumbnail"] == null
                ? null
                : Banner.fromJson(json["most_viewed_product_thumbnail"]),
        childes: json["childes"] == null
            ? []
            : List<SubCategory>.from(
                json["childes"]!.map((x) => SubCategory.fromJson(x))),
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "name": name,
        "most_viewed_product_thumbnail": mostViewedProductThumbnail?.toJson(),
        "num_available_product": numAvailableProduct,
        "flat_photo_path": flatPhotoPath?.toJson(),
        "childes": childes == null
            ? []
            : List<dynamic>.from(childes!.map((x) => x.toJson())),
      };
}

class MostViewedProductThumbnail {
  final String? originalHeight;
  final String? originalWidth;
  final String? filePath;

  MostViewedProductThumbnail({
    this.originalWidth,
    this.filePath,
    this.originalHeight,
  });

  MostViewedProductThumbnail copyWith({
    String? originalWidth,
    String? originalHeight,
    String? filePath,
  }) =>
      MostViewedProductThumbnail(
        originalWidth: originalWidth ?? this.originalWidth,
        originalHeight: originalHeight ?? this.originalHeight,
        filePath: filePath ?? this.filePath,
      );

  factory MostViewedProductThumbnail.fromJson(Map<String, dynamic> json) =>
      MostViewedProductThumbnail(
        filePath: json["file_path"],
        originalHeight: json["original_height"],
        originalWidth: json["original_width"],
      );

  Map<String, dynamic> toJson() => {
        "file_path": filePath,
        "original_width": originalWidth,
        "original_height": originalHeight,
      };
}
