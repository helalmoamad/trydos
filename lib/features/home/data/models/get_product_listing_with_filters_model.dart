// To parse this JSON data, do
//
//     final getProductListingWithoutFiltersModel = getProductListingWithoutFiltersModelFromJson(jsonString);

import 'dart:convert';

import 'get_product_filters_model.dart' as filters;
import 'get_product_listing_without_filters_model.dart' as product_without_filters;

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
  final int? offset;
  final List<product_without_filters.Products>? products;
  final List<filters.Brand>? brands;
  final List<filters.Attribute>? attributes;
  final List<String>? colors;
  final List<filters.Category>? categories;
  final filters.Prices? prices;
  final String? categoryParentParent;
  final String? categoryParent;
  final dynamic category;
  final String? categorySeoDescription;
  final String? categoryTitle;
  final String? categoryH1;
  final dynamic childCategories;
  final String? resultFor;
  final String? boutiqueSlug;

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
    this.brands,
    this.attributes,
    this.categories,
    this.colors,
    this.prices,
    this.resultFor,
    this.boutiqueSlug,
  });

  Data copyWith({
    int? totalSize,
    int? limit,
    int? offset,
    List<product_without_filters.Products>? products,
    List<filters.Brand>? brands,
    List<filters.Attribute>? attributes,
    List<String>? colors,
    List<filters.Category>? categories,
    filters.Prices? prices,
    String? categoryParentParent,
    String? categoryParent,
    String? category,
    String? categorySeoDescription,
    String? categoryTitle,
    String? categoryH1,
    String? childCategories,
    String? resultFor,
    String? boutiqueSlug,
  }) =>
      Data(
        totalSize: totalSize ?? this.totalSize,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        products: products ?? this.products,
        categoryParentParent: categoryParentParent ?? this.categoryParentParent,
        categoryParent: categoryParent ?? this.categoryParent,
        category: category ?? this.category,
        categories: categories ?? categories,
        categorySeoDescription:
            categorySeoDescription ?? this.categorySeoDescription,
        categoryTitle: categoryTitle ?? this.categoryTitle,
        categoryH1: categoryH1 ?? this.categoryH1,
        childCategories: childCategories ?? this.childCategories,
        brands: brands ?? brands ,
        attributes: attributes ?? attributes,
        colors: colors ?? this.colors,
        prices: prices ?? prices,
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
          : List<product_without_filters.Products>.from(
              json["products"]!.map((x) => product_without_filters.Products.fromJson(x))),
      categoryParentParent: json["category_parent_parent"],
      categoryParent: json["category_parent"],
      category: json["category"] is String
          ? json["category"]
          : Category.fromJson(json["category"]),
      categorySeoDescription: json["category_seo_description"],
      categoryTitle: json["category_title"],
      categoryH1: json["category_h1"],
      childCategories: json["child_categories"] is List
          ? List<Category>.from(
              json["child_categories"]!.map((x) => Category.fromJson(x)))
          : json["child_categories"],
      brands: json["brands"] == null
          ? []
          : List<filters.Brand>.from(json["brands"]!.map((x) => filters.Brand.fromJson(x))),
      attributes: json["attributes"] == null
          ? []
          : List<filters.Attribute>.from(
              json["attributes"]!.map((x) => filters.Attribute.fromJson(x))),
      categories: json["categories"] == null
          ? []
          : List<filters.Category>.from(
              json["categories"]!.map((x) => filters.Category.fromJson(x))),
      colors: json["colors"] == null
          ? []
          : List<String>.from(json["colors"]!.map((x) => x)),
      prices: json["prices"] == null ? null : filters.Prices.fromJson(json["prices"]),
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
        "category_parent_parent": categoryParentParent,
        "category_parent": categoryParent,
        "category": category,
        "category_seo_description": categorySeoDescription,
        "category_title": categoryTitle,
        "category_h1": categoryH1,
        "child_categories": childCategories,
        "brands": brands == null
            ? []
            : List<dynamic>.from(brands!.map((x) => x.toJson())),
        "attributes": attributes == null
            ? []
            : List<dynamic>.from(attributes!.map((x) => x.toJson())),
    "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "colors":
            colors == null ? [] : List<dynamic>.from(colors!.map((x) => x)),
        "prices": prices?.toJson(),
        "result_for": resultFor,
        "boutique_slug": boutiqueSlug,
      };
}

class Category {
  final int? id;
  final String? name;
  final String? icon;

  Category({
    this.id,
    this.name,
    this.icon,
  });

  Category copyWith({
    int? id,
    String? name,
    String? icon,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
      );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon,
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
