// To parse this JSON data, do
//
//     final getHomeBoutiquesModel = getHomeBoutiquesModelFromJson(jsonString);

import 'dart:convert';

GetHomeBoutiquesModel getHomeBoutiquesModelFromJson(String str) =>
    GetHomeBoutiquesModel.fromJson(json.decode(str));

String getHomeBoutiquesModelToJson(GetHomeBoutiquesModel data) =>
    json.encode(data.toJson());

class GetHomeBoutiquesModel {
  final String? message;
  final Data? data;

  GetHomeBoutiquesModel({
    this.message,
    this.data,
  });

  GetHomeBoutiquesModel copyWith({
    String? message,
    Data? data,
  }) =>
      GetHomeBoutiquesModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetHomeBoutiquesModel.fromJson(Map<String, dynamic> json) =>
      GetHomeBoutiquesModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final int? total;
  final int? limit;
  final int? offset;
  final List<Boutique>? boutiques;

  Data({
    this.total,
    this.limit,
    this.offset,
    this.boutiques,
  });

  Data copyWith({
    int? total,
    int? limit,
    int? offset,
    List<Boutique>? boutiques,
  }) =>
      Data(
        total: total ?? this.total,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        boutiques: boutiques ?? this.boutiques,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        total: json["total"],
        limit: json["limit"],
        offset: json["offset"],
        boutiques: json["boutiques"] == null
            ? []
            : List<Boutique>.from(
                json["boutiques"]!.map((x) => Boutique.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "limit": limit,
        "offset": offset,
        "boutiques": boutiques == null
            ? []
            : List<dynamic>.from(boutiques!.map((x) => x.toJson())),
      };
}

class Boutique {
  final int? id;
  final String? name;
  final Icon? icon;
  final String? slug;
  final int? position;
  final String? description;
  final List<Icon>? banners;
  final List<MainCategoriesForProductId>? mainCategoriesForProductIds;
  final List<ChildCategoriesForProductId>? childCategoriesForProductIds;

  Boutique({
    this.id,
    this.name,
    this.icon,
    this.slug,
    this.position,
    this.description,
    this.banners,
    this.mainCategoriesForProductIds,
    this.childCategoriesForProductIds,
  });

  Boutique copyWith({
    int? id,
    String? name,
    Icon? icon,
    String? slug,
    int? position,
    String? description,
    List<Icon>? banners,
    List<MainCategoriesForProductId>? mainCategoriesForProductIds,
    List<ChildCategoriesForProductId>? childCategoriesForProductIds,
  }) =>
      Boutique(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        slug: slug ?? this.slug,
        position: position ?? this.position,
        description: description ?? this.description,
        banners: banners ?? this.banners,
        mainCategoriesForProductIds:
            mainCategoriesForProductIds ?? this.mainCategoriesForProductIds,
        childCategoriesForProductIds:
            childCategoriesForProductIds ?? this.childCategoriesForProductIds,
      );

  factory Boutique.fromJson(Map<String, dynamic> json) => Boutique(
        id: json["id"],
        name: json["name"],
        icon: json["icon"] == null ? null : Icon.fromJson(json["icon"]),
        slug: json["slug"],
        position: json["position"],
        description: json["description"],
        banners: json["banners"] == null
            ? []
            : List<Icon>.from(json["banners"]!.map((x) => Icon.fromJson(x))),
        mainCategoriesForProductIds: json["mainCategoriesForProductIds"] == null
            ? []
            : List<MainCategoriesForProductId>.from(
                json["mainCategoriesForProductIds"]!
                    .map((x) => MainCategoriesForProductId.fromJson(x))),
        childCategoriesForProductIds:
            json["childCategoriesForProductIds"] == null
                ? []
                : List<ChildCategoriesForProductId>.from(
                    json["childCategoriesForProductIds"]!
                        .map((x) => ChildCategoriesForProductId.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon?.toJson(),
        "slug": slug,
        "position": position,
        "description": description,
        "banners": banners == null
            ? []
            : List<dynamic>.from(banners!.map((x) => x.toJson())),
        "mainCategoriesForProductIds": mainCategoriesForProductIds == null
            ? []
            : List<dynamic>.from(
                mainCategoriesForProductIds!.map((x) => x.toJson())),
        "childCategoriesForProductIds": childCategoriesForProductIds == null
            ? []
            : List<dynamic>.from(
                childCategoriesForProductIds!.map((x) => x.toJson())),
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

class ChildCategoriesForProductId {
  final String? categoryId;
  final String? categorySlug;
  final String? categoryName;
  final String? productName;
  final int? countProducts;
  final String? productThumbnail;

  ChildCategoriesForProductId({
    this.categoryId,
    this.categorySlug,
    this.categoryName,
    this.productName,
    this.countProducts,
    this.productThumbnail,
  });

  ChildCategoriesForProductId copyWith({
    String? categoryId,
    String? categorySlug,
    String? categoryName,
    String? productName,
    int? countProducts,
    String? productThumbnail,
  }) =>
      ChildCategoriesForProductId(
        categoryId: categoryId ?? this.categoryId,
        categorySlug: categorySlug ?? this.categorySlug,
        categoryName: categoryName ?? this.categoryName,
        productName: productName ?? this.productName,
        countProducts: countProducts ?? this.countProducts,
        productThumbnail: productThumbnail ?? this.productThumbnail,
      );

  factory ChildCategoriesForProductId.fromJson(Map<String, dynamic> json) =>
      ChildCategoriesForProductId(
        categoryId: json["category_id"],
        categorySlug: json["category_slug"],
        categoryName: json["category_name"],
        productName: json["product_name"],
        countProducts: json["count_products"],
        productThumbnail: json["product_thumbnail"],
      );

  Map<String, dynamic> toJson() => {
        "category_id": categoryId,
        "category_slug": categorySlug,
        "category_name": categoryName,
        "product_name": productName,
        "count_products": countProducts,
        "product_thumbnail": productThumbnail,
      };
}

class MainCategoriesForProductId {
  final int? categoryId;
  final String? categorySlug;
  final String? categoryName;
  final String? categoryIcon;

  MainCategoriesForProductId({
    this.categoryId,
    this.categorySlug,
    this.categoryName,
    this.categoryIcon,
  });

  MainCategoriesForProductId copyWith({
    int? categoryId,
    String? categorySlug,
    String? categoryName,
    String? categoryIcon,
  }) =>
      MainCategoriesForProductId(
        categoryId: categoryId ?? this.categoryId,
        categorySlug: categorySlug ?? this.categorySlug,
        categoryName: categoryName ?? this.categoryName,
        categoryIcon: categoryIcon ?? this.categoryIcon,
      );

  factory MainCategoriesForProductId.fromJson(Map<String, dynamic> json) =>
      MainCategoriesForProductId(
        categoryId: json["category_id"],
        categorySlug: json["category_slug"],
        categoryName: json["category_name"],
        categoryIcon: json["category_icon"],
      );

  Map<String, dynamic> toJson() => {
        "category_id": categoryId,
        "category_slug": categorySlug,
        "category_name": categoryName,
        "category_icon": categoryIcon,
      };
}
