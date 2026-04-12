// To parse this JSON data, do
//
//     final getHomeBoutiquesModel = getHomeBoutiquesModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trydos/main.dart';

GetHomeBoutiquesModel getHomeBoutiquesModelFromJson(String str) =>
    GetHomeBoutiquesModel.fromJson(json.decode(str));

String getHomeBoutiquesModelToJson(GetHomeBoutiquesModel data) =>
    json.encode(data.toJson());

class GetHomeBoutiquesModel {
  final String? message;
  final Data? data;

  GetHomeBoutiquesModel({this.message, this.data});

  GetHomeBoutiquesModel copyWith({String? message, Data? data}) =>
      GetHomeBoutiquesModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetHomeBoutiquesModel.fromJson(Map<String, dynamic> json) =>
      GetHomeBoutiquesModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  final int? total;
  final int? limit;
  final String? offset;
  final List<HomeBoutiques>? boutiques;

  Data({this.total, this.limit, this.offset, this.boutiques});

  Data copyWith({
    int? total,
    int? limit,
    String? offset,
    List<HomeBoutiques>? boutiques,
  }) => Data(
    total: total ?? this.total,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
    boutiques: boutiques ?? this.boutiques,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    total: json["total"],
    limit: json["limit"],
    offset: json["offset"].toString(),
    boutiques: json["boutiques"] == null
        ? []
        : List<HomeBoutiques>.from(
            json["boutiques"]!.map((x) => HomeBoutiques.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "limit": limit,
    "offset": offset.toString(),
    "boutiques": boutiques == null
        ? []
        : List<dynamic>.from(boutiques!.map((x) => x.toJson())),
  };
}

class HomeBoutiques {
  final int? id;
  final String? name;
  final BunnerBoutique? icon;
  final String? slug;
  final String? position;
  final String? description;
  final List<BunnerBoutique>? banners;
  final List<MainCategoriesForProductId>? mainCategoriesForProductIds;
  final List<ChildCategoriesForProductId>? childCategoriesForProductIds;

  HomeBoutiques({
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

  HomeBoutiques copyWith({
    int? id,
    String? name,
    BunnerBoutique? icon,
    String? slug,
    String? position,
    String? description,
    List<BunnerBoutique>? banners,
    List<MainCategoriesForProductId>? mainCategoriesForProductIds,
    List<ChildCategoriesForProductId>? childCategoriesForProductIds,
  }) => HomeBoutiques(
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

  factory HomeBoutiques.fromJson(Map<String, dynamic> json) => HomeBoutiques(
    id: json["id"],
    name: json["name"],
    icon: json["icon"] == null ? null : BunnerBoutique.fromJson(json["icon"]),
    slug: json["slug"],
    position: json["position"].toString(),
    description: json["description"],
    banners: json["banners"] == null
        ? []
        : List<BunnerBoutique>.from(
            json["banners"]!.map((x) => BunnerBoutique.fromJson(x)),
          ),
    mainCategoriesForProductIds: json["mainCategoriesForProductIds"] == null
        ? []
        : List<MainCategoriesForProductId>.from(
            json["mainCategoriesForProductIds"]!.map(
              (x) => MainCategoriesForProductId.fromJson(x),
            ),
          ),
    childCategoriesForProductIds: json["childCategoriesForProductIds"] == null
        ? []
        : List<ChildCategoriesForProductId>.from(
            json["childCategoriesForProductIds"]!.map(
              (x) => ChildCategoriesForProductId.fromJson(x),
            ),
          ),
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
            mainCategoriesForProductIds!.map((x) => x.toJson()),
          ),
    "childCategoriesForProductIds": childCategoriesForProductIds == null
        ? []
        : List<dynamic>.from(
            childCategoriesForProductIds!.map((x) => x.toJson()),
          ),
  };
}

class BunnerBoutique {
  final String? filePath;
  final String? originalWidth;
  final String? originalHeight;

  BunnerBoutique({this.filePath, this.originalWidth, this.originalHeight});

  BunnerBoutique copyWith({
    String? filePath,
    String? originalWidth,
    String? originalHeight,
  }) => BunnerBoutique(
    filePath: filePath ?? this.filePath,
    originalWidth: originalWidth ?? this.originalWidth,
    originalHeight: originalHeight ?? this.originalHeight,
  );

  factory BunnerBoutique.fromJson(Map<String, dynamic> json) => BunnerBoutique(
    filePath: mediaServerIsS3
        ? (json["file_path"]?.contains("media_server")
              ? json["file_path"]
              : "${dotenv.env['Media_S3_Server']}${json["file_path"]}")
        : (json["file_path"]?.contains("cloudinary")
              ? json["file_path"]
              : ("${dotenv.env['Images_Url']}" + (json["file_path"]))),
    originalWidth: (json["original_width"] ?? "").toString().replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    ),
    originalHeight: (json["original_height"] ?? "").toString().replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    ),
  );

  Map<String, dynamic> toJson() => {
    "file_path": filePath,
    "original_width": originalWidth,
    "original_height": originalHeight,
  };
}

class ChildCategoriesForProductId {
  final int? categoryId;
  final String? categorySlug;
  final String? categoryName;
  final String? productName;
  final int? countProducts;
  final BunnerBoutique? mostViewedProductThumbnail;
  final BunnerBoutique? flatPhotoPath;

  ChildCategoriesForProductId({
    this.categoryId,
    this.categorySlug,
    this.categoryName,
    this.productName,
    this.countProducts,
    this.flatPhotoPath,
    this.mostViewedProductThumbnail,
  });

  ChildCategoriesForProductId copyWith({
    int? categoryId,
    String? categorySlug,
    String? categoryName,
    BunnerBoutique? flatPhotoPath,
    String? productName,
    int? countProducts,
    BunnerBoutique? mostViewedProductThumbnail,
  }) => ChildCategoriesForProductId(
    categoryId: categoryId ?? this.categoryId,
    categorySlug: categorySlug ?? this.categorySlug,
    flatPhotoPath: flatPhotoPath ?? this.flatPhotoPath,
    categoryName: categoryName ?? this.categoryName,
    productName: productName ?? this.productName,
    countProducts: countProducts ?? this.countProducts,
    mostViewedProductThumbnail:
        mostViewedProductThumbnail ?? this.mostViewedProductThumbnail,
  );

  factory ChildCategoriesForProductId.fromJson(Map<String, dynamic> json) =>
      ChildCategoriesForProductId(
        categoryId: json["id"],
        categorySlug: json["slug"],
        categoryName: json["name"],
        productName: json["most_viewed_product_name"],
        flatPhotoPath: json["flat_photo_path"] == null
            ? null
            : BunnerBoutique.fromJson(json["flat_photo_path"]),
        countProducts: json["num_available_product"],
        mostViewedProductThumbnail:
            json["most_viewed_product_thumbnail"] == null
            ? null
            : BunnerBoutique.fromJson(json["most_viewed_product_thumbnail"]),
      );

  Map<String, dynamic> toJson() => {
    "id": categoryId,
    "slug": categorySlug,
    "flat_photo_path": flatPhotoPath?.toJson(),
    "name": categoryName,
    "most_viewed_product_name": productName,
    "num_available_product": countProducts,
    "most_viewed_product_thumbnail": mostViewedProductThumbnail?.toJson(),
  };
}

class MainCategoriesForProductId {
  final int? categoryId;
  final String? productName;
  final int? countProducts;
  final String? mostViewedProductThumbnail;
  final String? categorySlug;
  final String? categoryName;
  final bool? isProduct;
  final BunnerBoutique? flatPhotoPath;
  final bool? mostViews;

  MainCategoriesForProductId({
    this.categoryId,
    this.categorySlug,
    this.productName,
    this.countProducts,
    this.mostViews,
    this.mostViewedProductThumbnail,
    this.categoryName,
    this.flatPhotoPath,
    this.isProduct,
  });

  MainCategoriesForProductId copyWith({
    int? categoryId,
    String? categorySlug,
    String? categoryName,
    String? productName,
    int? countProducts,
    bool? isProduct,
    bool? mostViews,
    String? mostViewedProductThumbnail,
    BunnerBoutique? flatPhotoPath,
  }) => MainCategoriesForProductId(
    categoryId: categoryId ?? this.categoryId,
    mostViews: mostViews ?? this.mostViews,
    categorySlug: categorySlug ?? this.categorySlug,
    categoryName: categoryName ?? this.categoryName,
    productName: productName ?? this.productName,
    isProduct: isProduct ?? this.isProduct,
    countProducts: countProducts ?? this.countProducts,
    mostViewedProductThumbnail:
        mostViewedProductThumbnail ?? this.mostViewedProductThumbnail,
    flatPhotoPath: flatPhotoPath ?? this.flatPhotoPath,
  );

  factory MainCategoriesForProductId.fromJson(
    Map<String, dynamic> json,
  ) => MainCategoriesForProductId(
    categoryId: json["id"],
    categorySlug: json["slug"],
    isProduct: json["is_product"],
    mostViews: json["most_views"],
    categoryName: json["name"],
    productName: json["most_viewed_product_name"],
    countProducts: json["num_available_product"],
    mostViewedProductThumbnail: mediaServerIsS3
        ? (json["most_viewed_product_thumbnail"].toString().contains(
                "media_server",
              )
              ? json["most_viewed_product_thumbnail"]
              : "${dotenv.env['Media_S3_Server']}${json["most_viewed_product_thumbnail"]}")
        : (json["most_viewed_product_thumbnail"].toString().contains(
                "cloudinary",
              )
              ? json["most_viewed_product_thumbnail"]
              : "${dotenv.env['Images_Url']}${json["most_viewed_product_thumbnail"]}"),
    flatPhotoPath: json["flat_photo_path"] == null
        ? null
        : BunnerBoutique.fromJson(json["flat_photo_path"]),
  );

  Map<String, dynamic> toJson() => {
    "id": categoryId,
    "most_views": mostViews,
    "slug": categorySlug,
    "name": categoryName,
    "is_product": isProduct,
    "flat_photo_path": flatPhotoPath?.toJson(),
    "most_viewed_product_name": productName,
    "num_available_product": countProducts,
    "most_viewed_product_thumbnail": mostViewedProductThumbnail,
  };
}
