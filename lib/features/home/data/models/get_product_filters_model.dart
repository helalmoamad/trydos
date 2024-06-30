// To parse this JSON data, do
//
//     final getProductFiltersModel = getProductFiltersModelFromJson(jsonString);

import 'dart:convert';

GetProductFiltersModel getProductFiltersModelFromJson(String str) => GetProductFiltersModel.fromJson(json.decode(str));

String getProductFiltersModelToJson(GetProductFiltersModel data) => json.encode(data.toJson());

class GetProductFiltersModel {
  final String? message;
  final Data? data;

  GetProductFiltersModel({
    this.message,
    this.data,
  });

  GetProductFiltersModel copyWith({
    String? message,
    Data? data,
  }) =>
      GetProductFiltersModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetProductFiltersModel.fromJson(Map<String, dynamic> json) => GetProductFiltersModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  final List<Brand>? brands;
  final List<Attribute>? attributes;
  final List<String>? colors;
  final Prices? prices;
  final String? boutiqueSlug;

  Data({
    this.brands,
    this.attributes,
    this.colors,
    this.prices,
    this.boutiqueSlug,
  });

  Data copyWith({
    List<Brand>? brands,
    List<Attribute>? attributes,
    List<String>? colors,
    Prices? prices,
    String? boutiqueSlug,
  }) =>
      Data(
        brands: brands ?? this.brands,
        attributes: attributes ?? this.attributes,
        colors: colors ?? this.colors,
        prices: prices ?? this.prices,
        boutiqueSlug: boutiqueSlug ?? this.boutiqueSlug,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    brands: json["brands"] == null ? [] : List<Brand>.from(json["brands"]!.map((x) => Brand.fromJson(x))),
    attributes: json["attributes"] == null ? [] : List<Attribute>.from(json["attributes"]!.map((x) => Attribute.fromJson(x))),
    colors: json["colors"] == null ? [] : List<String>.from(json["colors"]!.map((x) => x)),
    prices: json["prices"] == null ? null : Prices.fromJson(json["prices"]),
    boutiqueSlug: json["boutique_slug"],
  );

  Map<String, dynamic> toJson() => {
    "brands": brands == null ? [] : List<dynamic>.from(brands!.map((x) => x.toJson())),
    "attributes": attributes == null ? [] : List<dynamic>.from(attributes!.map((x) => x.toJson())),
    "colors": colors == null ? [] : List<dynamic>.from(colors!.map((x) => x)),
    "prices": prices?.toJson(),
    "boutique_slug": boutiqueSlug,
  };
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
    options: json["options"] == null ? [] : List<String>.from(json["options"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "options": options == null ? [] : List<dynamic>.from(options!.map((x) => x)),
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

class Prices {
  final int? minPrice;
  final int? maxPrice;
  final List<PriceRange>? priceRanges;

  Prices({
    this.minPrice,
    this.maxPrice,
    this.priceRanges,
  });

  Prices copyWith({
    int? minPrice,
    int? maxPrice,
    List<PriceRange>? priceRanges,
  }) =>
      Prices(
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        priceRanges: priceRanges ?? this.priceRanges,
      );

  factory Prices.fromJson(Map<String, dynamic> json) => Prices(
    minPrice: json["min_price"],
    maxPrice: json["max_price"],
    priceRanges: json["priceRanges"] == null ? [] : List<PriceRange>.from(json["priceRanges"]!.map((x) => PriceRange.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "min_price": minPrice,
    "max_price": maxPrice,
    "priceRanges": priceRanges == null ? [] : List<dynamic>.from(priceRanges!.map((x) => x.toJson())),
  };
}

class PriceRange {
  final int? minPrice;
  final int? maxPrice;
  final String? text;
  final int? count;

  PriceRange({
    this.minPrice,
    this.maxPrice,
    this.text,
    this.count,
  });

  PriceRange copyWith({
    int? minPrice,
    int? maxPrice,
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
    minPrice: json["min_price"],
    maxPrice: json["max_price"],
    text: json["text"],
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {
    "min_price": minPrice,
    "max_price": maxPrice,
    "text": text,
    "count": count,
  };
}
