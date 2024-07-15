// To parse this JSON data, do
//
//     final getCategoryModel = getCategoryModelFromJson(jsonString);

import 'dart:convert';

GetCategoryModel getCategoryModelFromJson(String str) =>
    GetCategoryModel.fromJson(json.decode(str));

String getCategoryModelToJson(GetCategoryModel data) =>
    json.encode(data.toJson());

class GetCategoryModel {
  final String? message;
  final Data? data;

  GetCategoryModel({
    this.message,
    this.data,
  });

  GetCategoryModel copyWith({
    String? message,
    Data? data,
  }) =>
      GetCategoryModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetCategoryModel.fromJson(Map<String, dynamic> json) =>
      GetCategoryModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final List<Category>? categories;

  Data({
    this.categories,
  });

  Data copyWith({
    List<Category>? categories,
  }) =>
      Data(
        categories: categories ?? this.categories,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"]!.map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
      };
}

class Category {
  final int? id;
  final String? name;
  final String? slug;
  final String? icon;
  final List<dynamic>? subCategory;

  Category({
    this.id,
    this.name,
    this.slug,
    this.icon,
    this.subCategory,
  });

  Category copyWith({
    int? id,
    String? name,
    String? slug,
    String? icon,
    List<dynamic>? subCategory,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        icon: icon ?? this.icon,
        subCategory: subCategory ?? this.subCategory,
      );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        icon: json["icon"],
        subCategory: json["sub_category"] == null
            ? []
            : List<dynamic>.from(json["sub_category"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "icon": icon,
        "sub_category": subCategory == null
            ? []
            : List<dynamic>.from(subCategory!.map((x) => x)),
      };
}
