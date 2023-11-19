// To parse this JSON data, do
//
//     final mainCategoriesResponseModel = mainCategoriesResponseModelFromJson(jsonString);

import 'dart:convert';

MainCategoriesResponseModel mainCategoriesResponseModelFromJson(String str) => MainCategoriesResponseModel.fromJson(json.decode(str));

String mainCategoriesResponseModelToJson(MainCategoriesResponseModel data) => json.encode(data.toJson());

class MainCategoriesResponseModel {
  final String? message;
  final Data? data;

  MainCategoriesResponseModel({
    this.message,
    this.data,
  });

  MainCategoriesResponseModel copyWith({
    String? message,
    Data? data,
  }) =>
      MainCategoriesResponseModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory MainCategoriesResponseModel.fromJson(Map<String, dynamic> json) => MainCategoriesResponseModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  final List<MainCategory>? mainCategories;

  Data({
    this.mainCategories,
  });

  Data copyWith({
    List<MainCategory>? mainCategories,
  }) =>
      Data(
        mainCategories: mainCategories ?? this.mainCategories,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    mainCategories: json["mainCategories"] == null ? [] : List<MainCategory>.from(json["mainCategories"]!.map((x) => MainCategory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "mainCategories": mainCategories == null ? [] : List<dynamic>.from(mainCategories!.map((x) => x.toJson())),
  };
}

class MainCategory {
  final int? id;
  final String? categoryFrontColor;
  final String? categoryBackColor;
  final String? name;
  final String? slug;
  final String? icon;
  final int? totalProduct;

  MainCategory({
    this.id,
    this.categoryFrontColor,
    this.categoryBackColor,
    this.name,
    this.slug,
    this.icon,
    this.totalProduct,
  });

  MainCategory copyWith({
    int? id,
    String? categoryFrontColor,
    String? categoryBackColor,
    String? name,
    String? slug,
    String? icon,
    int? totalProduct,
  }) =>
      MainCategory(
        id: id ?? this.id,
        categoryFrontColor: categoryFrontColor ?? this.categoryFrontColor,
        categoryBackColor: categoryBackColor ?? this.categoryBackColor,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        icon: icon ?? this.icon,
        totalProduct: totalProduct ?? this.totalProduct,
      );

  factory MainCategory.fromJson(Map<String, dynamic> json) => MainCategory(
    id: json["id"],
    categoryFrontColor: json["category_front_color"],
    categoryBackColor: json["category_back_color"],
    name: json["name"],
    slug: json["slug"],
    icon: json["icon"],
    totalProduct: json["total_product"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_front_color": categoryFrontColor,
    "category_back_color": categoryBackColor,
    "name": name,
    "slug": slug,
    "icon": icon,
    "total_product": totalProduct,
  };
}
