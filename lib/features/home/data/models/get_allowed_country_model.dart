// To parse this JSON data, do
//
//     final getAllowesdCountriesModel = getAllowesdCountriesModelFromJson(jsonString);

import 'dart:convert';

GetAllowedCountriesModel getAllowesdCountriesModelFromJson(String str) =>
    GetAllowedCountriesModel.fromJson(json.decode(str));

String getAllowesdCountriesModelToJson(GetAllowedCountriesModel data) =>
    json.encode(data.toJson());

class GetAllowedCountriesModel {
  final String? message;
  final Data? data;

  GetAllowedCountriesModel({
    this.message,
    this.data,
  });

  GetAllowedCountriesModel copyWith({
    String? message,
    Data? data,
  }) =>
      GetAllowedCountriesModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetAllowedCountriesModel.fromJson(Map<String, dynamic> json) =>
      GetAllowedCountriesModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final List<Country>? countries;

  Data({
    this.countries,
  });

  Data copyWith({
    List<Country>? countries,
  }) =>
      Data(
        countries: countries ?? this.countries,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        countries: json["countries"] == null
            ? []
            : List<Country>.from(
                json["countries"]!.map((x) => Country.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "countries": countries == null
            ? []
            : List<dynamic>.from(countries!.map((x) => x.toJson())),
      };
}

class Country {
  final int? id;
  final int? phonecode;
  final String? iso;
  final String? name;
  final String? longitude;
  final String? latitude;

  Country({
    this.id,
    this.phonecode,
    this.iso,
    this.name,
    this.longitude,
    this.latitude,
  });

  Country copyWith({
    int? id,
    int? phonecode,
    String? iso,
    String? name,
    String? longitude,
    String? latitude,
  }) =>
      Country(
        id: id ?? this.id,
        phonecode: phonecode ?? this.phonecode,
        iso: iso ?? this.iso,
        name: name ?? this.name,
        longitude: longitude ?? this.longitude,
        latitude: latitude ?? this.latitude,
      );

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json["id"],
        phonecode: json["phonecode"],
        iso: json["iso"],
        name: json["name"],
        longitude: json["longitude"],
        latitude: json["latitude"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "phonecode": phonecode,
        "iso": iso,
        "name": name,
        "longitude": longitude,
        "latitude": latitude,
      };
}
