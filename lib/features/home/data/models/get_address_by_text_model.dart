// To parse this JSON data, do
//
//     final getAddressByTextModel = getAddressByTextModelFromJson(jsonString);

import 'dart:convert';

GetAddressByTextModel getAddressByTextModelFromJson(String str) =>
    GetAddressByTextModel.fromJson(json.decode(str));

String getAddressByTextModelToJson(GetAddressByTextModel data) =>
    json.encode(data.toJson());

class GetAddressByTextModel {
  final String? status;
  final List<ResultSearch>? results;

  GetAddressByTextModel({
    this.status,
    this.results,
  });

  GetAddressByTextModel copyWith({
    String? status,
    List<ResultSearch>? results,
  }) =>
      GetAddressByTextModel(
        status: status ?? this.status,
        results: results ?? this.results,
      );

  factory GetAddressByTextModel.fromJson(Map<String, dynamic> json) =>
      GetAddressByTextModel(
        status: json["status"],
        results: json["results"] == null
            ? []
            : List<ResultSearch>.from(
                json["results"]!.map((x) => ResultSearch.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "results": results == null
            ? []
            : List<dynamic>.from(results!.map((x) => x.toJson())),
      };
}

class ResultSearch {
  final String? country;
  final String? province;
  final String? city;
  final String? town;
  final String? street;
  final String? building;
  final Coordinates? coordinates;

  ResultSearch({
    this.country,
    this.province,
    this.city,
    this.town,
    this.street,
    this.building,
    this.coordinates,
  });

  ResultSearch copyWith({
    String? country,
    String? province,
    String? city,
    String? town,
    String? street,
    String? building,
    Coordinates? coordinates,
  }) =>
      ResultSearch(
        country: country ?? this.country,
        province: province ?? this.province,
        city: city ?? this.city,
        town: town ?? this.town,
        street: street ?? this.street,
        building: building ?? this.building,
        coordinates: coordinates ?? this.coordinates,
      );

  factory ResultSearch.fromJson(Map<String, dynamic> json) => ResultSearch(
        country: json["country"],
        province: json["province"],
        city: json["city"],
        town: json["town"],
        street: json["street"],
        building: json["building"],
        coordinates: json["coordinates"] == null
            ? null
            : Coordinates.fromJson(json["coordinates"]),
      );

  Map<String, dynamic> toJson() => {
        "country": country,
        "province": province,
        "city": city,
        "town": town,
        "street": street,
        "building": building,
        "coordinates": coordinates?.toJson(),
      };
}

class Coordinates {
  final double? lat;
  final double? lon;

  Coordinates({
    this.lat,
    this.lon,
  });

  Coordinates copyWith({
    double? lat,
    double? lon,
  }) =>
      Coordinates(
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
      );

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
        lat: json["lat"]?.toDouble(),
        lon: json["lon"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lon": lon,
      };
}
