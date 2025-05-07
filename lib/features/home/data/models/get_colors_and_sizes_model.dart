// To parse this JSON data, do
//
//     final geColorsAndSizesForSearchModel = geColorsAndSizesForSearchModelFromJson(jsonString);

import 'dart:convert';

GeColorsAndSizesForSearchModel geColorsAndSizesForSearchModelFromJson(
        String str) =>
    GeColorsAndSizesForSearchModel.fromJson(json.decode(str));

String geColorsAndSizesForSearchModelToJson(
        GeColorsAndSizesForSearchModel data) =>
    json.encode(data.toJson());

class GeColorsAndSizesForSearchModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  GeColorsAndSizesForSearchModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GeColorsAndSizesForSearchModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) =>
      GeColorsAndSizesForSearchModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory GeColorsAndSizesForSearchModel.fromJson(Map<String, dynamic> json) =>
      GeColorsAndSizesForSearchModel(
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
  final List<Color>? colors;
  final List<String>? sizes;

  Data({
    this.colors,
    this.sizes,
  });

  Data copyWith({
    List<Color>? colors,
    List<String>? sizes,
  }) =>
      Data(
        colors: colors ?? this.colors,
        sizes: sizes ?? this.sizes,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        colors: json["colors"] == null
            ? []
            : List<Color>.from(json["colors"]!.map((x) => Color.fromJson(x))),
        sizes: json["sizes"] == null
            ? []
            : List<String>.from(json["sizes"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "colors": colors == null
            ? []
            : List<dynamic>.from(colors!.map((x) => x.toJson())),
        "sizes": sizes == null ? [] : List<dynamic>.from(sizes!.map((x) => x)),
      };
}

class Color {
  final String? name;
  final String? code;

  Color({
    this.name,
    this.code,
  });

  Color copyWith({
    String? name,
    String? code,
  }) =>
      Color(
        name: name ?? this.name,
        code: code ?? this.code,
      );

  factory Color.fromJson(Map<String, dynamic> json) => Color(
        name: json["name"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "code": code,
      };
}
