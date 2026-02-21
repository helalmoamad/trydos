// To parse this JSON data, do
//
//     final getProvincesByIsoModel = getProvincesByIsoModelFromJson(jsonString);

import 'dart:convert';

GetProvincesByIsoModel getProvincesByIsoModelFromJson(String str) =>
    GetProvincesByIsoModel.fromJson(json.decode(str));

String getProvincesByIsoModelToJson(GetProvincesByIsoModel data) =>
    json.encode(data.toJson());

class GetProvincesByIsoModel {
  final String? status;
  final List<String>? data;

  GetProvincesByIsoModel({
    this.status,
    this.data,
  });

  GetProvincesByIsoModel copyWith({
    String? status,
    List<String>? data,
  }) =>
      GetProvincesByIsoModel(
        status: status ?? this.status,
        data: data ?? this.data,
      );

  factory GetProvincesByIsoModel.fromJson(Map<String, dynamic> json) =>
      GetProvincesByIsoModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<String>.from(json["data"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x)),
      };
}
