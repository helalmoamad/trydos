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
  final int? parentId;
  final int? position;
  final String? iso;
  final String? name;
  final String? nicename;
  final String? iso3;
  final int? numcode;
  final int? phonecode;
  final dynamic flatPhotoPath;
  final dynamic outlinePhotoPath;
  final dynamic flagPhotoPath;
  final dynamic mapPhotoPath;
  final int? status;
  final int? isAccess;
  final int? otpByWhatsapp;
  final int? otpBySms;
  final dynamic createdAt;
  final DateTime? updatedAt;

  Country({
    this.id,
    this.parentId,
    this.position,
    this.iso,
    this.name,
    this.nicename,
    this.iso3,
    this.numcode,
    this.phonecode,
    this.flatPhotoPath,
    this.outlinePhotoPath,
    this.flagPhotoPath,
    this.mapPhotoPath,
    this.status,
    this.isAccess,
    this.otpByWhatsapp,
    this.otpBySms,
    this.createdAt,
    this.updatedAt,
  });

  Country copyWith({
    int? id,
    int? parentId,
    int? position,
    String? iso,
    String? name,
    String? nicename,
    String? iso3,
    int? numcode,
    int? phonecode,
    dynamic flatPhotoPath,
    dynamic outlinePhotoPath,
    dynamic flagPhotoPath,
    dynamic mapPhotoPath,
    int? status,
    int? isAccess,
    int? otpByWhatsapp,
    int? otpBySms,
    dynamic createdAt,
    DateTime? updatedAt,
  }) =>
      Country(
        id: id ?? this.id,
        parentId: parentId ?? this.parentId,
        position: position ?? this.position,
        iso: iso ?? this.iso,
        name: name ?? this.name,
        nicename: nicename ?? this.nicename,
        iso3: iso3 ?? this.iso3,
        numcode: numcode ?? this.numcode,
        phonecode: phonecode ?? this.phonecode,
        flatPhotoPath: flatPhotoPath ?? this.flatPhotoPath,
        outlinePhotoPath: outlinePhotoPath ?? this.outlinePhotoPath,
        flagPhotoPath: flagPhotoPath ?? this.flagPhotoPath,
        mapPhotoPath: mapPhotoPath ?? this.mapPhotoPath,
        status: status ?? this.status,
        isAccess: isAccess ?? this.isAccess,
        otpByWhatsapp: otpByWhatsapp ?? this.otpByWhatsapp,
        otpBySms: otpBySms ?? this.otpBySms,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json["id"],
        parentId: json["parent_id"],
        position: json["position"],
        iso: json["iso"],
        name: json["name"],
        nicename: json["nicename"],
        iso3: json["iso3"],
        numcode: json["numcode"],
        phonecode: json["phonecode"],
        flatPhotoPath: json["flat_photo_path"],
        outlinePhotoPath: json["outline_photo_path"],
        flagPhotoPath: json["flag_photo_path"],
        mapPhotoPath: json["map_photo_path"],
        status: json["status"],
        isAccess: json["isAccess"],
        otpByWhatsapp: json["otp_by_whatsapp"],
        otpBySms: json["otp_by_sms"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "parent_id": parentId,
        "position": position,
        "iso": iso,
        "name": name,
        "nicename": nicename,
        "iso3": iso3,
        "numcode": numcode,
        "phonecode": phonecode,
        "flat_photo_path": flatPhotoPath,
        "outline_photo_path": outlinePhotoPath,
        "flag_photo_path": flagPhotoPath,
        "map_photo_path": mapPhotoPath,
        "status": status,
        "isAccess": isAccess,
        "otp_by_whatsapp": otpByWhatsapp,
        "otp_by_sms": otpBySms,
        "created_at": createdAt,
        "updated_at": updatedAt?.toIso8601String(),
      };
}
