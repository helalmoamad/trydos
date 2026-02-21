// To parse this JSON data, do
//
//     final getUserRolesModel = getUserRolesModelFromJson(jsonString);

import 'dart:convert';

GetUserRolesModel getUserRolesModelFromJson(String str) =>
    GetUserRolesModel.fromJson(json.decode(str));

String getUserRolesModelToJson(GetUserRolesModel data) =>
    json.encode(data.toJson());

class GetUserRolesModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  GetUserRolesModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GetUserRolesModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) => GetUserRolesModel(
    isSuccessful: isSuccessful ?? this.isSuccessful,
    hasContent: hasContent ?? this.hasContent,
    code: code ?? this.code,
    message: message ?? this.message,
    detailedError: detailedError ?? this.detailedError,
    data: data ?? this.data,
  );

  factory GetUserRolesModel.fromJson(Map<String, dynamic> json) =>
      GetUserRolesModel(
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
  final List<ShopRole>? shopRoles;
  final Meta? meta;

  Data({this.shopRoles, this.meta});

  Data copyWith({List<ShopRole>? shopRoles, Meta? meta}) =>
      Data(shopRoles: shopRoles ?? this.shopRoles, meta: meta ?? this.meta);

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    shopRoles: json["shop_roles"] == null
        ? []
        : List<ShopRole>.from(
            json["shop_roles"]!.map((x) => ShopRole.fromJson(x)),
          ),
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "shop_roles": shopRoles == null
        ? []
        : List<dynamic>.from(shopRoles!.map((x) => x.toJson())),
    "meta": meta?.toJson(),
  };
}

class Meta {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final int? from;
  final int? to;
  final bool? hasMorePages;
  final String? nextPageUrl;
  final dynamic prevPageUrl;

  Meta({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.from,
    this.to,
    this.hasMorePages,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  Meta copyWith({
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
    int? from,
    int? to,
    bool? hasMorePages,
    String? nextPageUrl,
    dynamic prevPageUrl,
  }) => Meta(
    currentPage: currentPage ?? this.currentPage,
    lastPage: lastPage ?? this.lastPage,
    perPage: perPage ?? this.perPage,
    total: total ?? this.total,
    from: from ?? this.from,
    to: to ?? this.to,
    hasMorePages: hasMorePages ?? this.hasMorePages,
    nextPageUrl: nextPageUrl ?? this.nextPageUrl,
    prevPageUrl: prevPageUrl ?? this.prevPageUrl,
  );

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
    from: json["from"],
    to: json["to"],
    hasMorePages: json["has_more_pages"],
    nextPageUrl: json["next_page_url"],
    prevPageUrl: json["prev_page_url"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
    "from": from,
    "to": to,
    "has_more_pages": hasMorePages,
    "next_page_url": nextPageUrl,
    "prev_page_url": prevPageUrl,
  };
}

class ShopRole {
  final int? id;
  final String? name;
  final String? description;

  ShopRole({this.id, this.name, this.description});

  ShopRole copyWith({int? id, String? name, String? description}) => ShopRole(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
  );

  factory ShopRole.fromJson(Map<String, dynamic> json) => ShopRole(
    id: json["id"],
    name: json["name"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
  };
}
