import 'dart:convert';

GetChecklistModel getChecklistModelFromJson(String str) =>
    GetChecklistModel.fromJson(json.decode(str));

String getChecklistModelToJson(GetChecklistModel data) =>
    json.encode(data.toJson());

class GetChecklistModel {
  final bool? isSuccessful;
  final int? code;
  final bool? hasContent;
  final String? message;
  final String? detailedError;
  final ChecklistPageData? data;

  GetChecklistModel({
    this.isSuccessful,
    this.code,
    this.hasContent,
    this.message,
    this.detailedError,
    this.data,
  });

  GetChecklistModel copyWith({
    bool? isSuccessful,
    int? code,
    bool? hasContent,
    String? message,
    String? detailedError,
    ChecklistPageData? data,
  }) => GetChecklistModel(
    isSuccessful: isSuccessful ?? this.isSuccessful,
    code: code ?? this.code,
    hasContent: hasContent ?? this.hasContent,
    message: message ?? this.message,
    detailedError: detailedError ?? this.detailedError,
    data: data ?? this.data,
  );

  factory GetChecklistModel.fromJson(Map<String, dynamic> json) =>
      GetChecklistModel(
        isSuccessful: json["isSuccessful"],
        code: json["code"],
        hasContent: json["hasContent"],
        message: json["message"],
        detailedError: json["detailed_error"]?.toString(),
        data: json["data"] == null
            ? null
            : ChecklistPageData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "isSuccessful": isSuccessful,
    "code": code,
    "hasContent": hasContent,
    "message": message,
    "detailed_error": detailedError,
    "data": data?.toJson(),
  };
}

class ChecklistPageData {
  final int? currentPage;
  final List<ChecklistItemModel>? items;
  final String? firstPageUrl;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final String? lastPageUrl;
  final int? lastPage;
  final int? perPage;
  final int? from;
  final int? to;
  final int? total;

  ChecklistPageData({
    this.currentPage,
    this.items,
    this.firstPageUrl,
    this.nextPageUrl,
    this.prevPageUrl,
    this.lastPageUrl,
    this.lastPage,
    this.perPage,
    this.from,
    this.to,
    this.total,
  });

  ChecklistPageData copyWith({
    int? currentPage,
    List<ChecklistItemModel>? items,
    String? firstPageUrl,
    String? nextPageUrl,
    String? prevPageUrl,
    String? lastPageUrl,
    int? lastPage,
    int? perPage,
    int? from,
    int? to,
    int? total,
  }) => ChecklistPageData(
    currentPage: currentPage ?? this.currentPage,
    items: items ?? this.items,
    firstPageUrl: firstPageUrl ?? this.firstPageUrl,
    nextPageUrl: nextPageUrl ?? this.nextPageUrl,
    prevPageUrl: prevPageUrl ?? this.prevPageUrl,
    lastPageUrl: lastPageUrl ?? this.lastPageUrl,
    lastPage: lastPage ?? this.lastPage,
    perPage: perPage ?? this.perPage,
    from: from ?? this.from,
    to: to ?? this.to,
    total: total ?? this.total,
  );

  factory ChecklistPageData.fromJson(Map<String, dynamic> json) =>
      ChecklistPageData(
        currentPage: json["current_page"],
        items: json["data"] == null
            ? []
            : List<ChecklistItemModel>.from(
                json["data"]!.map((x) => ChecklistItemModel.fromJson(x)),
              ),
        firstPageUrl: json["first_page_url"],
        nextPageUrl: json["next_page_url"],
        prevPageUrl: json["prev_page_url"],
        lastPageUrl: json["last_page_url"],
        lastPage: json["last_page"],
        perPage: json["per_page"],
        from: json["from"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": items == null
        ? []
        : List<dynamic>.from(items!.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "next_page_url": nextPageUrl,
    "prev_page_url": prevPageUrl,
    "last_page_url": lastPageUrl,
    "last_page": lastPage,
    "per_page": perPage,
    "from": from,
    "to": to,
    "total": total,
  };

  bool get hasNextPage => nextPageUrl != null;

  bool get hasPrevPage => prevPageUrl != null;
}

class ChecklistItemModel {
  final int? id;
  final String? name;
  final String? slug;
  final String? image;

  ChecklistItemModel({this.id, this.name, this.slug, this.image});

  ChecklistItemModel copyWith({
    int? id,
    String? name,
    String? slug,
    String? image,
  }) => ChecklistItemModel(
    id: id ?? this.id,
    name: name ?? this.name,
    slug: slug ?? this.slug,
    image: image ?? this.image,
  );

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) =>
      ChecklistItemModel(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "image": image,
  };
}
