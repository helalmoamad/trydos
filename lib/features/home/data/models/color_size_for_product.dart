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
  }) =>
      ColorSizeForProductModel(
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

  Data({
    this.choiceOptions,
    this.colors,
    this.syncColorImages,
  });

  Data copyWith({
    List<ProductChoiceOption>? choiceOptions,
    List<ProductColor>? colors,
    List<ProductSyncColorImage>? syncColorImages,
  }) =>
      Data(
        choiceOptions: choiceOptions ?? this.choiceOptions,
        colors: colors ?? this.colors,
        syncColorImages: syncColorImages ?? this.syncColorImages,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        choiceOptions: json["choice_options"] == null
            ? []
            : List<ProductChoiceOption>.from(json["choice_options"]!
                .map((x) => ProductChoiceOption.fromJson(x))),
        colors: json["colors"] == null
            ? []
            : List<ProductColor>.from(
                json["colors"]!.map((x) => ProductColor.fromJson(x))),
        syncColorImages: json["sync_color_images"] == null
            ? []
            : List<ProductSyncColorImage>.from(json["sync_color_images"]!
                .map((x) => ProductSyncColorImage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "choice_options": choiceOptions == null
            ? []
            : List<dynamic>.from(choiceOptions!.map((x) => x.toJson())),
        "colors": colors == null
            ? []
            : List<dynamic>.from(colors!.map((x) => x.toJson())),
        "sync_color_images": syncColorImages == null
            ? []
            : List<dynamic>.from(syncColorImages!.map((x) => x.toJson())),
      };
}

class ProductChoiceOption {
  final String? name;
  final String? title;
  final List<Option>? options;

  ProductChoiceOption({
    this.name,
    this.title,
    this.options,
  });

  ProductChoiceOption copyWith({
    String? name,
    String? title,
    List<Option>? options,
  }) =>
      ProductChoiceOption(
        name: name ?? this.name,
        title: title ?? this.title,
        options: options ?? this.options,
      );

  factory ProductChoiceOption.fromJson(Map<String, dynamic> json) =>
      ProductChoiceOption(
        name: json["name"],
        title: json["title"],
        options: json["options"] == null
            ? []
            : List<Option>.from(
                json["options"]!.map((x) => Option.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "title": title,
        "options": options == null
            ? []
            : List<dynamic>.from(options!.map((x) => x.toJson())),
      };
}

class Option {
  final String? name;
  final String? option;

  Option({
    this.name,
    this.option,
  });

  Option copyWith({
    String? name,
    String? option,
  }) =>
      Option(
        name: name ?? this.name,
        option: option ?? this.option,
      );

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        name: json["name"],
        option: json["option"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "option": option,
      };
}

class ProductColor {
  final String? name;
  final String? color;
  final String? option;

  ProductColor({
    this.name,
    this.color,
    this.option,
  });

  ProductColor copyWith({
    String? name,
    String? color,
    String? option,
  }) =>
      ProductColor(
        name: name ?? this.name,
        color: color ?? this.color,
        option: option ?? this.option,
      );

  factory ProductColor.fromJson(Map<String, dynamic> json) => ProductColor(
        name: json["name"],
        color: json["color"],
        option: json["option"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "color": color,
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
    String? colorTrend,
    String? colorOption,
  }) =>
      ProductSyncColorImage(
        colorName: colorName ?? this.colorName,
        images: images ?? this.images,
        colorTrend: colorTrend ?? this.colorTrend,
        colorOption: colorOption ?? this.colorOption,
      );

  factory ProductSyncColorImage.fromJson(Map<String, dynamic> json) =>
      ProductSyncColorImage(
        colorName: json["color_name"],
        images: json["images"] == null
            ? []
            : List<String>.from(json["images"]!.map((x) => x)),
        colorTrend: json["color_trend"],
        colorOption: json["color_option"],
      );

  Map<String, dynamic> toJson() => {
        "color_name": colorName,
        "images":
            images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "color_trend": colorTrend,
        "color_option": colorOption,
      };
}
