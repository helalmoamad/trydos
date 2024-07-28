// To parse this JSON data, do
//
//     final getCategoryModel = getCategoryModelFromJson(jsonString);

/*import 'dart:convert';
import 'dart:developer';

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
  final MostViewedProductThumbnail? mostViewedProductThumbnail;
  final bool isSubCategory;
  final List<SubCategory>? subCategories;

  Category({
    this.id,
    this.name,
    this.isSubCategory = false,
    this.slug,
    this.mostViewedProductThumbnail,
    this.subCategories,
  });

  Category copyWith({
    int? id,
    String? name,
    String? slug,
    MostViewedProductThumbnail? mostViewedProductThumbnail,
    List<SubCategory>? subCategories,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        mostViewedProductThumbnail:
            mostViewedProductThumbnail ?? this.mostViewedProductThumbnail,
        subCategories: subCategories ?? this.subCategories,
      );

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"],
      name: json["name"],
      slug: json["slug"],
      mostViewedProductThumbnail: json["most_viewed_product_thumbnail"] == null
          ? null
          : MostViewedProductThumbnail.fromJson(
          json["most_viewed_product_thumbnail"]),
      subCategories: json["childes"] == null
          ? []
          : List<SubCategory>.from(
          json["childes"]!.map((x) => SubCategory.fromJson(x['category']))),
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "most_viewed_product_thumbnail": mostViewedProductThumbnail?.toJson(),
        "childes": subCategories == null
            ? []
            : List<dynamic>.from(subCategories!.map((x) => x.toJson())),
      };
}


class SubCategory {
  final int? id;
  final String? name;
  final String? slug;
  final MostViewedProductThumbnail? mostViewedProductThumbnail;

  SubCategory({
    this.id,
    this.name,
    this.slug,
    this.mostViewedProductThumbnail,
  });

  SubCategory copyWith({
    int? id,
    String? name,
    String? slug,
    MostViewedProductThumbnail? mostViewedProductThumbnail,
  }) =>
      SubCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        mostViewedProductThumbnail:
        mostViewedProductThumbnail ?? this.mostViewedProductThumbnail,
      );

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    mostViewedProductThumbnail: json["most_viewed_product_thumbnail"] == null
        ? null
        : MostViewedProductThumbnail.fromJson(
        json["most_viewed_product_thumbnail"]),
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "most_viewed_product_thumbnail": mostViewedProductThumbnail?.toJson(),
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
*/