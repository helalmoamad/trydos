// To parse this JSON data, do
//
//     final getUsersModel = getUsersModelFromJson(jsonString);

import 'dart:convert';

GetUsersModel getUsersModelFromJson(String str) =>
    GetUsersModel.fromJson(json.decode(str));

String getUsersModelToJson(GetUsersModel data) => json.encode(data.toJson());

class GetUsersModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  GetUsersModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GetUsersModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) => GetUsersModel(
    isSuccessful: isSuccessful ?? this.isSuccessful,
    hasContent: hasContent ?? this.hasContent,
    code: code ?? this.code,
    message: message ?? this.message,
    detailedError: detailedError ?? this.detailedError,
    data: data ?? this.data,
  );

  factory GetUsersModel.fromJson(Map<String, dynamic> json) => GetUsersModel(
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
  final List<User>? users;
  final Meta? meta;

  Data({this.users, this.meta});

  Data copyWith({List<User>? users, Meta? meta}) =>
      Data(users: users ?? this.users, meta: meta ?? this.meta);

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    users: json["users"] == null
        ? []
        : List<User>.from(json["users"]!.map((x) => User.fromJson(x))),
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "users": users == null
        ? []
        : List<dynamic>.from(users!.map((x) => x.toJson())),
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
  final dynamic nextPageUrl;
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
    dynamic nextPageUrl,
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

class User {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final Role? role;

  User({this.id, this.name, this.phone, this.email, this.role});

  User copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    Role? role,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    role: role ?? this.role,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    role: json["role"] == null ? null : Role.fromJson(json["role"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "email": email,
    "role": role?.toJson(),
  };
}

class Role {
  final int? id;
  final String? name;

  Role({this.id, this.name});

  Role copyWith({int? id, String? name}) =>
      Role(id: id ?? this.id, name: name ?? this.name);

  factory Role.fromJson(Map<String, dynamic> json) =>
      Role(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
