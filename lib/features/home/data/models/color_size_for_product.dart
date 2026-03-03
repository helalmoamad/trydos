// To parse this JSON data, do
//
//     final colorSizeForProductModel = colorSizeForProductModelFromJson(jsonString);

import 'dart:convert';

ColorSizeForProductModel colorSizeForProductModelFromJson(String str) =>
    ColorSizeForProductModel.fromJson(json.decode(str));

String colorSizeForProductModelToJson(ColorSizeForProductModel data) =>
    json.encode(data.toJson());

class ColorSizeForProductModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  ColorSizeForProductModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  ColorSizeForProductModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) => ColorSizeForProductModel(
    isSuccessful: isSuccessful ?? this.isSuccessful,
    hasContent: hasContent ?? this.hasContent,
    code: code ?? this.code,
    message: message ?? this.message,
    detailedError: detailedError ?? this.detailedError,
    data: data ?? this.data,
  );

  factory ColorSizeForProductModel.fromJson(Map<String, dynamic> json) =>
      ColorSizeForProductModel(
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"],
        detailedError: json["detailed_error"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "isSuccessful": isSuccessful,
    "hasContent": hasContent,
    "code": code,
    "message": message,
    "detailed_error": detailedError,
    "data": data?.toJson(),
  };
}

class Data {
  final List<ProductChoiceOption>? choiceOptions;
  final List<ProductColor>? colors;
  final List<ProductSyncColorImage>? syncColorImages;
  final List<Variation>? variation;
  final int? collectedAfterOrdering;

  Data({
    this.choiceOptions,
    this.colors,
    this.variation,
    this.syncColorImages,
    this.collectedAfterOrdering,
  });

  Data copyWith({
    List<ProductChoiceOption>? choiceOptions,
    List<Variation>? variation,
    List<ProductColor>? colors,
    List<ProductSyncColorImage>? syncColorImages,
    int? collectedAfterOrdering,
  }) => Data(
    choiceOptions: choiceOptions ?? this.choiceOptions,
    colors: colors ?? this.colors,
    variation: variation ?? this.variation,
    syncColorImages: syncColorImages ?? this.syncColorImages,
    collectedAfterOrdering:
        collectedAfterOrdering ?? this.collectedAfterOrdering,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    variation: json["variation"] == null
        ? []
        : List<Variation>.from(
            json["variation"]!.map((x) => Variation.fromJson(x)),
          ),
    choiceOptions: json["sizes"] == null
        ? []
        : List<ProductChoiceOption>.from(
            json["sizes"]!.map((x) => ProductChoiceOption.fromJson(x)),
          ),
    colors: json["colors"] == null
        ? []
        : List<ProductColor>.from(
            json["colors"]!.map((x) => ProductColor.fromJson(x)),
          ),
    syncColorImages: json["sync_color_images"] == null
        ? []
        : List<ProductSyncColorImage>.from(
            json["sync_color_images"]!.map(
              (x) => ProductSyncColorImage.fromJson(x),
            ),
          ),
    collectedAfterOrdering: json["collected_after_ordering"],
  );

  Map<String, dynamic> toJson() => {
    "variation": variation == null
        ? []
        : List<dynamic>.from(variation!.map((x) => x.toJson())),
    "sizes": choiceOptions == null
        ? []
        : List<dynamic>.from(choiceOptions!.map((x) => x.toJson())),
    "colors": colors == null
        ? []
        : List<dynamic>.from(colors!.map((x) => x.toJson())),
    "sync_color_images": syncColorImages == null
        ? []
        : List<dynamic>.from(syncColorImages!.map((x) => x.toJson())),
    "collected_after_ordering": collectedAfterOrdering,
  };
}

class Variation {
  final String? type;
  final int? qty;
  final double? offerPrice;
  Variation({this.type, this.qty, this.offerPrice});

  Variation copyWith({String? type, int? qty, double? offerPrice}) => Variation(
    type: type ?? this.type,
    qty: qty ?? this.qty,
    offerPrice: offerPrice ?? this.offerPrice,
  );

  factory Variation.fromJson(Map<String, dynamic> json) => Variation(
    type: json["type"] == null ? null : json["type"],
    qty: json["qty"],
    offerPrice: json["offer_price"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "qty": qty,
    "offer_price": offerPrice,
  };
}

class ProductChoiceOption {
  final String? name;
  final String? title;
  final String? options;

  ProductChoiceOption({this.name, this.title, this.options});

  ProductChoiceOption copyWith({
    String? name,
    String? title,
    String? options,
  }) => ProductChoiceOption(
    name: name ?? this.name,
    title: title ?? this.title,
    options: options ?? this.options,
  );

  factory ProductChoiceOption.fromJson(Map<String, dynamic> json) =>
      ProductChoiceOption(
        name: json["option"],
        title: json["title"],
        options: json["option"],
      );

  Map<String, dynamic> toJson() => {
    //"option": name,
    "title": title,
    "option": options,
  };
}

class ProductColor {
  final String? name;
  final String? color;
  final String? option;

  ProductColor({this.name, this.color, this.option});

  ProductColor copyWith({String? name, String? color, String? option}) =>
      ProductColor(
        name: name ?? this.name,
        color: color ?? this.color,
        option: option ?? this.option,
      );

  factory ProductColor.fromJson(Map<String, dynamic> json) => ProductColor(
    name: json["name"],
    color: json["color_code"],
    option: json["option"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "color_code": color,
    "option": option,
  };
}

class ProductSyncColorImage {
  final String? colorName;
  final List<String>? images;
  final String? colorTrend;
  final String? colorOption;

  ProductSyncColorImage({
    this.colorName,
    this.images,
    this.colorTrend,
    this.colorOption,
  });

  ProductSyncColorImage copyWith({
    String? colorName,
    List<String>? images,

    String? colorOption,
  }) => ProductSyncColorImage(
    colorName: colorName ?? this.colorName,
    images: images ?? this.images,

    colorOption: colorOption ?? this.colorOption,
  );

  factory ProductSyncColorImage.fromJson(Map<String, dynamic> json) =>
      ProductSyncColorImage(
        colorName: json["color_name"],
        images: json["images"] == null
            ? []
            : List<String>.from(json["images"]!.map((x) => x)),

        colorOption: json["color_option"],
      );

  Map<String, dynamic> toJson() => {
    "color_name": colorName,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),

    "color_option": colorOption,
  };
}
