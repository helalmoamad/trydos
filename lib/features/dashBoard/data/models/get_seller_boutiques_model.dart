// To parse this JSON data, do
//
//     final getSellerBoutiquesModel = getSellerBoutiquesModelFromJson(jsonString);

import 'dart:convert';

GetSellerBoutiquesModel getSellerBoutiquesModelFromJson(String str) =>
    GetSellerBoutiquesModel.fromJson(json.decode(str));

String getSellerBoutiquesModelToJson(GetSellerBoutiquesModel data) =>
    json.encode(data.toJson());

class GetSellerBoutiquesModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  GetSellerBoutiquesModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GetSellerBoutiquesModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) => GetSellerBoutiquesModel(
    isSuccessful: isSuccessful ?? this.isSuccessful,
    hasContent: hasContent ?? this.hasContent,
    code: code ?? this.code,
    message: message ?? this.message,
    detailedError: detailedError ?? this.detailedError,
    data: data ?? this.data,
  );

  factory GetSellerBoutiquesModel.fromJson(Map<String, dynamic> json) =>
      GetSellerBoutiquesModel(
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
  final List<Boutique>? boutiques;
  final Meta? meta;

  Data({this.boutiques, this.meta});

  Data copyWith({List<Boutique>? boutiques, Meta? meta}) =>
      Data(boutiques: boutiques ?? this.boutiques, meta: meta ?? this.meta);

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    boutiques: json["boutiques"] == null
        ? []
        : List<Boutique>.from(
            json["boutiques"]!.map((x) => Boutique.fromJson(x)),
          ),
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "boutiques": boutiques == null
        ? []
        : List<dynamic>.from(boutiques!.map((x) => x.toJson())),
    "meta": meta?.toJson(),
  };
}

class Boutique {
  final int? id;
  final String? name;
  final String? slug;
  final String? description;
  final String? bio;
  final int? position;
  final int? status;
  final int? requestStatus;
  final String? countriesIso;
  final String? icon;
  final List<List<Banner>>? banners;

  Boutique({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.bio,
    this.position,
    this.status,
    this.requestStatus,
    this.countriesIso,
    this.icon,
    this.banners,
  });

  Boutique copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? bio,
    int? position,
    int? status,
    int? requestStatus,
    String? countriesIso,
    String? icon,
    List<List<Banner>>? banners,
  }) => Boutique(
    id: id ?? this.id,
    name: name ?? this.name,
    slug: slug ?? this.slug,
    description: description ?? this.description,
    bio: bio ?? this.bio,
    position: position ?? this.position,
    status: status ?? this.status,
    requestStatus: requestStatus ?? this.requestStatus,
    countriesIso: countriesIso ?? this.countriesIso,
    icon: icon ?? this.icon,
    banners: banners ?? this.banners,
  );

  factory Boutique.fromJson(Map<String, dynamic> json) => Boutique(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    description: json["description"],
    bio: json["bio"],
    position: json["position"],
    status: json["status"],
    requestStatus: json["request_status"],
    countriesIso: json["countries_iso"],
    icon: json["icon"],
    banners: json["banners"] == null
        ? []
        : List<List<Banner>>.from(
            json["banners"]!.map(
              (x) => List<Banner>.from(x.map((x) => Banner.fromJson(x))),
            ),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "description": description,
    "bio": bio,
    "position": position,
    "status": status,
    "request_status": requestStatus,
    "countries_iso": countriesIso,
    "icon": icon,
    "banners": banners == null
        ? []
        : List<dynamic>.from(
            banners!.map((x) => List<dynamic>.from(x.map((x) => x.toJson()))),
          ),
  };
}

class Banner {
  final int? id;
  final String? filePath;

  Banner({this.id, this.filePath});

  Banner copyWith({int? id, String? filePath}) =>
      Banner(id: id ?? this.id, filePath: filePath ?? this.filePath);

  factory Banner.fromJson(Map<String, dynamic> json) =>
      Banner(id: json["id"], filePath: json["file_path"]);

  Map<String, dynamic> toJson() => {"id": id, "file_path": filePath};
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
