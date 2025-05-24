// To parse this JSON data, do
//
//     final countryBoundaryByIsoModel = countryBoundaryByIsoModelFromJson(jsonString);

import 'dart:convert';

CountryBoundaryByIsoModel countryBoundaryByIsoModelFromJson(String str) =>
    CountryBoundaryByIsoModel.fromJson(json.decode(str));

String countryBoundaryByIsoModelToJson(CountryBoundaryByIsoModel data) =>
    json.encode(data.toJson());

class CountryBoundaryByIsoModel {
  final String? status;
  final Country? country;

  CountryBoundaryByIsoModel({
    this.status,
    this.country,
  });

  CountryBoundaryByIsoModel copyWith({
    String? status,
    Country? country,
  }) =>
      CountryBoundaryByIsoModel(
        status: status ?? this.status,
        country: country ?? this.country,
      );

  factory CountryBoundaryByIsoModel.fromJson(Map<String, dynamic> json) =>
      CountryBoundaryByIsoModel(
        status: json["status"],
        country:
            json["country"] == null ? null : Country.fromJson(json["country"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "country": country?.toJson(),
      };
}

class Country {
  final String? countryIso;
  final String? countryNameEn;
  final String? countryNameAr;
  final Boundary? boundary;

  Country({
    this.countryIso,
    this.countryNameEn,
    this.countryNameAr,
    this.boundary,
  });

  Country copyWith({
    String? countryIso,
    String? countryNameEn,
    String? countryNameAr,
    Boundary? boundary,
  }) =>
      Country(
        countryIso: countryIso ?? this.countryIso,
        countryNameEn: countryNameEn ?? this.countryNameEn,
        countryNameAr: countryNameAr ?? this.countryNameAr,
        boundary: boundary ?? this.boundary,
      );

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        countryIso: json["country_iso"],
        countryNameEn: json["country_name_en"],
        countryNameAr: json["country_name_ar"],
        boundary: json["boundary"] == null
            ? null
            : Boundary.fromJson(json["boundary"]),
      );

  Map<String, dynamic> toJson() => {
        "country_iso": countryIso,
        "country_name_en": countryNameEn,
        "country_name_ar": countryNameAr,
        "boundary": boundary?.toJson(),
      };
}

class Boundary {
  final String? type;
  final List<Coordinate>? coordinates;

  Boundary({
    this.type,
    this.coordinates,
  });

  Boundary copyWith({
    String? type,
    List<Coordinate>? coordinates,
  }) =>
      Boundary(
        type: type ?? this.type,
        coordinates: coordinates ?? this.coordinates,
      );

  factory Boundary.fromJson(Map<String, dynamic> json) => Boundary(
        type: json["type"],
        coordinates: json["coordinates"] == null
            ? []
            : List<Coordinate>.from(
                json["coordinates"]!.map((x) => Coordinate.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates == null
            ? []
            : List<dynamic>.from(coordinates!.map((x) => x.toJson())),
      };
}

class Coordinate {
  final double? lat;
  final double? lon;

  Coordinate({
    this.lat,
    this.lon,
  });

  Coordinate copyWith({
    double? lat,
    double? lon,
  }) =>
      Coordinate(
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
      );

  factory Coordinate.fromJson(Map<String, dynamic> json) => Coordinate(
        lat: json["lat"]?.toDouble(),
        lon: json["lon"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lon": lon,
      };
}
