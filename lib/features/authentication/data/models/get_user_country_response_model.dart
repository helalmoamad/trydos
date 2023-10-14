// To parse this JSON data, do
//
//     final getUserCountryResponseModel = getUserCountryResponseModelFromJson(jsonString);

import 'dart:convert';

GetUserCountryResponseModel getUserCountryResponseModelFromJson(String str) => GetUserCountryResponseModel.fromJson(json.decode(str));

String getUserCountryResponseModelToJson(GetUserCountryResponseModel data) => json.encode(data.toJson());

class GetUserCountryResponseModel {
  final String? status;
  final String? country;
  final String? countryCode;
  final String? region;
  final String? regionName;
  final String? city;
  final String? zip;
  final double? lat;
  final double? lon;
  final String? timezone;
  final String? isp;
  final String? org;
  final String? getUserCountryResponseModelAs;
  final String? query;

  GetUserCountryResponseModel({
    this.status,
    this.country,
    this.countryCode,
    this.region,
    this.regionName,
    this.city,
    this.zip,
    this.lat,
    this.lon,
    this.timezone,
    this.isp,
    this.org,
    this.getUserCountryResponseModelAs,
    this.query,
  });

  GetUserCountryResponseModel copyWith({
    String? status,
    String? country,
    String? countryCode,
    String? region,
    String? regionName,
    String? city,
    String? zip,
    double? lat,
    double? lon,
    String? timezone,
    String? isp,
    String? org,
    String? getUserCountryResponseModelAs,
    String? query,
  }) =>
      GetUserCountryResponseModel(
        status: status ?? this.status,
        country: country ?? this.country,
        countryCode: countryCode ?? this.countryCode,
        region: region ?? this.region,
        regionName: regionName ?? this.regionName,
        city: city ?? this.city,
        zip: zip ?? this.zip,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        timezone: timezone ?? this.timezone,
        isp: isp ?? this.isp,
        org: org ?? this.org,
        getUserCountryResponseModelAs: getUserCountryResponseModelAs ?? this.getUserCountryResponseModelAs,
        query: query ?? this.query,
      );

  factory GetUserCountryResponseModel.fromJson(Map<String, dynamic> json) => GetUserCountryResponseModel(
    status: json["status"],
    country: json["country"],
    countryCode: json["countryCode"],
    region: json["region"],
    regionName: json["regionName"],
    city: json["city"],
    zip: json["zip"],
    lat: json["lat"]?.toDouble(),
    lon: json["lon"]?.toDouble(),
    timezone: json["timezone"],
    isp: json["isp"],
    org: json["org"],
    getUserCountryResponseModelAs: json["as"],
    query: json["query"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "country": country,
    "countryCode": countryCode,
    "region": region,
    "regionName": regionName,
    "city": city,
    "zip": zip,
    "lat": lat,
    "lon": lon,
    "timezone": timezone,
    "isp": isp,
    "org": org,
    "as": getUserCountryResponseModelAs,
    "query": query,
  };
}
