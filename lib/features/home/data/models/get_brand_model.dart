// To parse this JSON data, do
//
//     final getBrandModel = getBrandModelFromJson(jsonString);

/*import 'dart:convert';

GetBrandModel getBrandModelFromJson(String str) =>
    GetBrandModel.fromJson(json.decode(str));

String getBrandModelToJson(GetBrandModel data) => json.encode(data.toJson());

class GetBrandModel {
  final String? message;
  final Data? data;

  GetBrandModel({
    this.message,
    this.data,
  });

  GetBrandModel copyWith({
    String? message,
    Data? data,
  }) =>
      GetBrandModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetBrandModel.fromJson(Map<String, dynamic> json) => GetBrandModel(
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

  Data({
    this.brands,
  });

  Data copyWith({
    List<Brand>? brands,
  }) =>
      Data(
        brands: brands ?? this.brands,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        brands: json["brands"] == null
            ? []
            : List<Brand>.from(json["brands"]!.map((x) => Brand.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "brands": brands == null
            ? []
            : List<dynamic>.from(brands!.map((x) => x.toJson())),
      };
}

class Brand {
  final int? id;
  final String? name;
  final String? slug;
  final String? icon;

  Brand({
    this.id,
    this.name,
    this.slug,
    this.icon,
  });

  Brand copyWith({
    int? id,
    String? name,
    String? slug,
    String? icon,
  }) =>
      Brand(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        icon: icon ?? this.icon,
      );

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "icon": icon,
      };
}
*/