// To parse this JSON data, do
//
//     final getProductFiltersModel = getProductFiltersModelFromJson(jsonString);

import 'dart:convert';

import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/home/data/models/get_category_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';

GetProductFiltersModel getProductFiltersModelFromJson(String str) =>
    GetProductFiltersModel.fromJson(json.decode(str));

String getProductFiltersModelToJson(GetProductFiltersModel data) =>
    json.encode(data.toJson());

class GetProductFiltersModel {
  final String? message;
  final Filter? filters;

  GetProductFiltersModel({
    this.message,
    this.filters,
  });

  GetProductFiltersModel copyWith({
    String? message,
    Filter? filters,
  }) =>
      GetProductFiltersModel(
        message: message ?? this.message,
        filters: filters ?? this.filters,
      );

  GetProductFiltersModel copyWithSendValue({
    String? message,
    Filter? filters,
  }) =>
      GetProductFiltersModel(message: message, filters: filters);

  factory GetProductFiltersModel.fromJson(Map<String, dynamic> json) =>
      GetProductFiltersModel(
        message: json["message"],
        filters: json["data"] == null ? null : Filter.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": filters?.toJson(),
      };
}

class Filter {
  final List<Brand>? brands;
  final List<Attribute>? attributes;
  final List<String>? colors;
  final Prices? prices;
  final String? boutiqueSlug;
  List<Category>? categories;

  Filter({
    this.brands,
    this.attributes,
    this.categories,
    this.colors,
    this.prices,
    this.boutiqueSlug,
  });

  Filter copyWithSaveOtherField({
    List<Brand>? brands,
    List<Attribute>? attributes,
    List<Category>? categories,
    List<String>? colors,
    Prices? prices,
    String? boutiqueSlug,
  }) =>
      Filter(
        brands: brands ?? this.brands,
        attributes: attributes ?? this.attributes,
        colors: colors ?? this.colors,
        prices: prices,
        categories: categories ?? this.categories,
        boutiqueSlug: boutiqueSlug ?? this.boutiqueSlug,
      );

  Filter copyWith({
    List<Brand>? brands,
    List<Attribute>? attributes,
    List<Category>? categories,
    List<String>? colors,
    Prices? prices,
    String? boutiqueSlug,
  }) =>
      Filter(
        brands: brands,
        attributes: attributes,
        colors: colors,
        prices: prices,
        categories: categories,
        boutiqueSlug: boutiqueSlug,
      );

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      brands: json["brands"] == null
          ? []
          : List<Brand>.from(json["brands"]!.map((x) => Brand.fromJson(x))),
      attributes: json["attributes"] == null
          ? []
          : List<Attribute>.from(
              json["attributes"]!.map((x) => Attribute.fromJson(x))),
      colors: json["colors"] == null
          ? []
          : List<String>.from(json["colors"]!.map((x) => x)),
      categories: json["categories"] == null
          ? []
          : List<Category>.from(
              json["categories"]!.map((x) => Category.fromJson(x))),
      prices: json["prices"] == null ? null : Prices.fromJson(json["prices"]),
      boutiqueSlug: json["boutique_slug"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "brands": brands == null
          ? []
          : List<dynamic>.from(brands!.map((x) => x.toJson())),
      "categories": categories.isNullOrEmpty
          ? []
          : List<dynamic>.from(categories!.map((x) => x.toJson())),
      "attributes": attributes == null
          ? []
          : List<dynamic>.from(attributes!.map((x) => x.toJson())),
      "colors": colors == null ? [] : List<dynamic>.from(colors!.map((x) => x)),
      "prices": prices?.toJson(),
      "boutique_slug": boutiqueSlug,
    };
  }
}

class Attribute {
  final int? id;
  final String? name;
  final List<String>? options;

  Attribute({
    this.id,
    this.name,
    this.options,
  });

  Attribute copyWith({
    int? id,
    String? name,
    List<String>? options,
  }) =>
      Attribute(
        id: id ?? this.id,
        name: name ?? this.name,
        options: options ?? this.options,
      );

  factory Attribute.fromJson(Map<String, dynamic> json) => Attribute(
        id: json["id"],
        name: json["name"],
        options: json["options"] == null
            ? []
            : List<String>.from(json["options"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "options":
            options == null ? [] : List<dynamic>.from(options!.map((x) => x)),
      };
}

class Brand {
  final int? id;
  final String? name;
  final String? slug;
  final String? image;
  final bool? isSelected;

  Brand({
    this.id,
    this.name,
    this.slug,
    this.isSelected = false,
    this.image,
  });

  Brand copyWith({
    int? id,
    String? name,
    String? slug,
    String? icon,
    final bool? isSelected,
  }) =>
      Brand(
        id: id ?? this.id,
        name: name ?? this.name,
        isSelected: isSelected ?? this.isSelected,
        slug: slug ?? this.slug,
        image: icon ?? this.image,
      );

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "image": image,
      };
}

class Prices {
  final double? minPrice;
  final double? maxPrice;
  final String? currencySymbol;
  final List<PriceRange>? priceRanges;

  Prices({
    this.minPrice,
    this.maxPrice,
    this.currencySymbol,
    this.priceRanges,
  });

  Prices copyWith({
    double? minPrice,
    double? maxPrice,
    String? currencySymbol,
    List<PriceRange>? priceRanges,
  }) =>
      Prices(
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        priceRanges: priceRanges ?? this.priceRanges,
      );

  factory Prices.fromJson(Map<String, dynamic> json) => Prices(
        minPrice: json["min_price"].toDouble(),
        maxPrice: json["max_price"].toDouble(),
        currencySymbol: json["currency_symbol"],
        priceRanges: json["priceRanges"] == null
            ? []
            : List<PriceRange>.from(
                json["priceRanges"]!.map((x) => PriceRange.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "min_price": minPrice,
        "max_price": maxPrice,
        "currency_symbol": currencySymbol,
        "priceRanges": priceRanges == null
            ? []
            : List<dynamic>.from(priceRanges!.map((x) => x.toJson())),
      };
}

class PriceRange {
  final double? minPrice;
  final double? maxPrice;
  final String? text;
  final int? count;

  PriceRange({
    this.minPrice,
    this.maxPrice,
    this.text,
    this.count,
  });

  PriceRange copyWith({
    double? minPrice,
    double? maxPrice,
    String? text,
    int? count,
  }) =>
      PriceRange(
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        text: text ?? this.text,
        count: count ?? this.count,
      );

  factory PriceRange.fromJson(Map<String, dynamic> json) => PriceRange(
        minPrice: json["min_price"]?.toDouble(),
        maxPrice: json["max_price"]?.toDouble(),
        text: json["text"],
        count: json["products_count"],
      );

  Map<String, dynamic> toJson() => {
        "min_price": minPrice,
        "max_price": maxPrice,
        "text": text,
        "products_count": count,
      };
}
