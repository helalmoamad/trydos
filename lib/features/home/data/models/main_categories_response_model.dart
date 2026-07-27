// To parse this JSON data, do
//
//     final mainCategoriesResponseModel = mainCategoriesResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

MainCategoriesResponseModel mainCategoriesResponseModelFromJson(String str) =>
    MainCategoriesResponseModel.fromJson(json.decode(str));

String mainCategoriesResponseModelToJson(MainCategoriesResponseModel data) =>
    json.encode(data.toJson());

class MainCategoriesResponseModel {
  final String? message;
  final MainCategoryData? data;

  MainCategoriesResponseModel({this.message, this.data});

  MainCategoriesResponseModel copyWith({
    String? message,
    MainCategoryData? data,
  }) => MainCategoriesResponseModel(
    message: message ?? this.message,
    data: data ?? this.data,
  );

  factory MainCategoriesResponseModel.fromJson(Map<String, dynamic> json) =>
      MainCategoriesResponseModel(
        message: json["message"],
        data: json["data"] == null
            ? null
            : MainCategoryData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class MainCategoryData {
  final List<MainCategory>? mainCategories;

  MainCategoryData({this.mainCategories});

  MainCategoryData copyWith({List<MainCategory>? mainCategories}) =>
      MainCategoryData(mainCategories: mainCategories ?? this.mainCategories);

  factory MainCategoryData.fromJson(Map<String, dynamic> json) =>
      MainCategoryData(
        mainCategories: json["mainCategories"] == null
            ? []
            : List<MainCategory>.from(
                json["mainCategories"]!.map((x) => MainCategory.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "mainCategories": mainCategories == null
        ? []
        : List<dynamic>.from(mainCategories!.map((x) => x.toJson())),
  };
}

class FlatPhotoPath {
  final String? originalHeight;
  final String? originalWidth;
  final String? filePath;

  FlatPhotoPath({this.originalWidth, this.filePath, this.originalHeight});

  FlatPhotoPath copyWith({
    String? originalWidth,
    String? originalHeight,
    String? filePath,
  }) => FlatPhotoPath(
    originalWidth: originalWidth ?? this.originalWidth,
    originalHeight: originalHeight ?? this.originalHeight,
    filePath: filePath ?? this.filePath,
  );

  factory FlatPhotoPath.fromJson(Map<String, dynamic> json) => FlatPhotoPath(
    filePath: (json["file_path"].contains("media_server")
        ? json["file_path"]
        : "${dotenv.env['Media_S3_Server']}${json["file_path"]}"),
    originalHeight: json["original_height"],
    originalWidth: json["original_width"],
  );

  Map<String, dynamic> toJson() => {
    "file_path": filePath,
    "original_width": originalWidth,
    "original_height": originalHeight,
  };
}

class MainCategory {
  final int? id;
  final String? categoryFrontColor;
  final String? categoryBackColor;
  final String? name;
  final String? slug;
  final int? totalProduct;
  final FlatPhotoPath? flatPhotoPath;

  MainCategory({
    this.id,
    this.categoryFrontColor,
    this.categoryBackColor,
    this.name,
    this.slug,
    this.flatPhotoPath,
    this.totalProduct,
  });

  MainCategory copyWith({
    int? id,
    String? categoryFrontColor,
    String? categoryBackColor,
    String? name,
    String? slug,
    String? icon,
    FlatPhotoPath? flatPhotoPath,
    int? totalProduct,
  }) => MainCategory(
    id: id ?? this.id,
    categoryFrontColor: categoryFrontColor ?? this.categoryFrontColor,
    categoryBackColor: categoryBackColor ?? this.categoryBackColor,
    name: name ?? this.name,
    slug: slug ?? this.slug,
    flatPhotoPath: flatPhotoPath ?? this.flatPhotoPath,
    totalProduct: totalProduct ?? this.totalProduct,
  );

  factory MainCategory.fromJson(Map<String, dynamic> json) => MainCategory(
    id: json["id"],
    categoryFrontColor: json["category_front_color"],
    categoryBackColor: json["category_back_color"],
    name: json["name"],
    slug: json["slug"],
    flatPhotoPath: json["flat_photo_path"] == null
        ? null
        : FlatPhotoPath.fromJson(json["flat_photo_path"]),
    totalProduct: json["total_product"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_front_color": categoryFrontColor,
    "category_back_color": categoryBackColor,
    "name": name,
    "slug": slug,
    "flat_photo_path": flatPhotoPath?.toJson(),
    "total_product": totalProduct,
  };
}
