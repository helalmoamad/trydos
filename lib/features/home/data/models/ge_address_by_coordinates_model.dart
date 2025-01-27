// To parse this JSON data, do
//
//     final getAddressByCoordinatesModel = getAddressByCoordinatesModelFromJson(jsonString);

import 'dart:convert';

GetAddressByCoordinatesModel getAddressByCoordinatesModelFromJson(String str) =>
    GetAddressByCoordinatesModel.fromJson(json.decode(str));

String getAddressByCoordinatesModelToJson(GetAddressByCoordinatesModel data) =>
    json.encode(data.toJson());

class GetAddressByCoordinatesModel {
  final String? status;
  final Data? data;

  GetAddressByCoordinatesModel({
    this.status,
    this.data,
  });

  GetAddressByCoordinatesModel copyWith({
    String? status,
    Data? data,
  }) =>
      GetAddressByCoordinatesModel(
        status: status ?? this.status,
        data: data ?? this.data,
      );

  factory GetAddressByCoordinatesModel.fromJson(Map<String, dynamic> json) =>
      GetAddressByCoordinatesModel(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
      };
}

class Data {
  final String? country;
  final String? province;
  final String? city;
  final String? town;
  final String? street;
  final String? building;
  final Coordinates? coordinates;

  Data({
    this.country,
    this.province,
    this.city,
    this.town,
    this.street,
    this.building,
    this.coordinates,
  });

  Data copyWith({
    String? country,
    String? province,
    String? city,
    String? town,
    String? street,
    String? building,
    Coordinates? coordinates,
  }) =>
      Data(
        country: country ?? this.country,
        province: province ?? this.province,
        city: city ?? this.city,
        town: town ?? this.town,
        street: street ?? this.street,
        building: building ?? this.building,
        coordinates: coordinates ?? this.coordinates,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
