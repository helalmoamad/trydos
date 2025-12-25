// To parse this JSON data, do
//
//     final getSellerProductsModel = getSellerProductsModelFromJson(jsonString);

import 'dart:convert';

GetSellerProductsModel getSellerProductsModelFromJson(String str) =>
    GetSellerProductsModel.fromJson(json.decode(str));

String getSellerProductsModelToJson(GetSellerProductsModel data) =>
    json.encode(data.toJson());

class GetSellerProductsModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final Data? data;

  GetSellerProductsModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  GetSellerProductsModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    Data? data,
  }) => GetSellerProductsModel(
    isSuccessful: isSuccessful ?? this.isSuccessful,
    hasContent: hasContent ?? this.hasContent,
    code: code ?? this.code,
    message: message ?? this.message,
    detailedError: detailedError ?? this.detailedError,
    data: data ?? this.data,
  );

  factory GetSellerProductsModel.fromJson(Map<String, dynamic> json) =>
      GetSellerProductsModel(
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
  final List<Product>? products;
  final Meta? meta;

  Data({this.products, this.meta});

  Data copyWith({List<Product>? products, Meta? meta}) =>
      Data(products: products ?? this.products, meta: meta ?? this.meta);

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    products: json["products"] == null
        ? []
        : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "products": products == null
        ? []
        : List<dynamic>.from(products!.map((x) => x.toJson())),
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

class Product {
  final int? id;
  final String? name;
  final String? slug;
  final String? details;
  final int? status;
  final int? requestStatus;
  final String? barcode;
  final dynamic similarWords;
  final String? tagsIds;
  final int? boutiqueId;
  final int? countInCarts;
  final int? weight;
  final int? collectedAfterOrdering;
  final List<Category>? categories;
  final String? restrictedCountries;
  final int? brandId;
  final Unit? unit;
  final int? minQty;
  final List<String>? images;
  final List<dynamic>? videos;
  final int? isFeatured;
  final int? flashDeal;
  final String? colors;
  final String? syncColorImages;
  final String? choiceOptions;
  final String? variation;
  final int? unitPrice;
  final int? unitPriceInDefaultCurrency;
  final double? purchasePrice;
  final double? purchasePriceInDefaultCurrency;
  final String? discount;
  final int? currentStock;

  Product({
    this.id,
    this.name,
    this.slug,
    this.details,
    this.status,
    this.requestStatus,
    this.barcode,
    this.similarWords,
    this.tagsIds,
    this.boutiqueId,
    this.countInCarts,
    this.weight,
    this.collectedAfterOrdering,
    this.categories,
    this.restrictedCountries,
    this.brandId,
    this.unit,
    this.minQty,
    this.images,
    this.videos,
    this.isFeatured,
    this.flashDeal,
    this.colors,
    this.syncColorImages,
    this.choiceOptions,
    this.variation,
    this.unitPrice,
    this.unitPriceInDefaultCurrency,
    this.purchasePrice,
    this.purchasePriceInDefaultCurrency,
    this.discount,
    this.currentStock,
  });

  Product copyWith({
    int? id,
    String? name,
    String? slug,
    String? details,
    int? status,
    int? requestStatus,
    String? barcode,
    dynamic similarWords,
    String? tagsIds,
    int? boutiqueId,
    int? countInCarts,
    int? weight,
    int? collectedAfterOrdering,
    List<Category>? categories,
    String? restrictedCountries,
    int? brandId,
    Unit? unit,
    int? minQty,
    List<String>? images,
    List<dynamic>? videos,
    int? isFeatured,
    int? flashDeal,
    String? colors,
    String? syncColorImages,
    String? choiceOptions,
    String? variation,
    int? unitPrice,
    int? unitPriceInDefaultCurrency,
    double? purchasePrice,
    double? purchasePriceInDefaultCurrency,
    String? discount,
    int? currentStock,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    slug: slug ?? this.slug,
    details: details ?? this.details,
    status: status ?? this.status,
    requestStatus: requestStatus ?? this.requestStatus,
    barcode: barcode ?? this.barcode,
    similarWords: similarWords ?? this.similarWords,
    tagsIds: tagsIds ?? this.tagsIds,
    boutiqueId: boutiqueId ?? this.boutiqueId,
    countInCarts: countInCarts ?? this.countInCarts,
    weight: weight ?? this.weight,
    collectedAfterOrdering:
        collectedAfterOrdering ?? this.collectedAfterOrdering,
    categories: categories ?? this.categories,
    restrictedCountries: restrictedCountries ?? this.restrictedCountries,
    brandId: brandId ?? this.brandId,
    unit: unit ?? this.unit,
    minQty: minQty ?? this.minQty,
    images: images ?? this.images,
    videos: videos ?? this.videos,
    isFeatured: isFeatured ?? this.isFeatured,
    flashDeal: flashDeal ?? this.flashDeal,
    colors: colors ?? this.colors,
    syncColorImages: syncColorImages ?? this.syncColorImages,
    choiceOptions: choiceOptions ?? this.choiceOptions,
    variation: variation ?? this.variation,
    unitPrice: unitPrice ?? this.unitPrice,
    unitPriceInDefaultCurrency:
        unitPriceInDefaultCurrency ?? this.unitPriceInDefaultCurrency,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    purchasePriceInDefaultCurrency:
        purchasePriceInDefaultCurrency ?? this.purchasePriceInDefaultCurrency,
    discount: discount ?? this.discount,
    currentStock: currentStock ?? this.currentStock,
  );

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    details: json["details"],
    status: json["status"],
    requestStatus: json["request_status"],
    barcode: json["barcode"],
    similarWords: json["similar_words"],
    tagsIds: json["tags_ids"],
    boutiqueId: json["boutique_id"],
    countInCarts: json["count_in_carts"],
    weight: json["weight"],
    collectedAfterOrdering: json["collected_after_ordering"],
    categories: json["categories"] == null
        ? []
        : List<Category>.from(
            json["categories"]!.map((x) => Category.fromJson(x)),
          ),
    restrictedCountries: json["restricted_countries"],
    brandId: json["brand_id"],
    unit: unitValues.map[json["unit"]]!,
    minQty: json["min_qty"],
    images: json["images"] == null
        ? []
        : List<String>.from(json["images"]!.map((x) => x)),
    videos: json["videos"] == null
        ? []
        : List<dynamic>.from(json["videos"]!.map((x) => x)),
    isFeatured: json["is_featured"],
    flashDeal: json["flash_deal"],
    colors: json["colors"],
    syncColorImages: json["sync_color_images"],
    choiceOptions: json["choice_options"],
    variation: json["variation"],
    unitPrice: json["unit_price"],
    unitPriceInDefaultCurrency: json["unit_price_in_default_currency"],
    purchasePrice: json["purchase_price"]?.toDouble(),
    purchasePriceInDefaultCurrency: json["purchase_price_in_default_currency"]
        ?.toDouble(),
    discount: json["discount"],
    currentStock: json["current_stock"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "details": details,
    "status": status,
    "request_status": requestStatus,
    "barcode": barcode,
    "similar_words": similarWords,
    "tags_ids": tagsIds,
    "boutique_id": boutiqueId,
    "count_in_carts": countInCarts,
    "weight": weight,
    "collected_after_ordering": collectedAfterOrdering,
    "categories": categories == null
        ? []
        : List<dynamic>.from(categories!.map((x) => x.toJson())),
    "restricted_countries": restrictedCountries,
    "brand_id": brandId,
    "unit": unitValues.reverse[unit],
    "min_qty": minQty,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    "videos": videos == null ? [] : List<dynamic>.from(videos!.map((x) => x)),
    "is_featured": isFeatured,
    "flash_deal": flashDeal,
    "colors": colors,
    "sync_color_images": syncColorImages,
    "choice_options": choiceOptions,
    "variation": variation,
    "unit_price": unitPrice,
    "unit_price_in_default_currency": unitPriceInDefaultCurrency,
    "purchase_price": purchasePrice,
    "purchase_price_in_default_currency": purchasePriceInDefaultCurrency,
    "discount": discount,
    "current_stock": currentStock,
  };
}

class Category {
  final int? id;
  final String? name;
  final String? icon;
  final int? position;

  Category({this.id, this.name, this.icon, this.position});

  Category copyWith({int? id, String? name, String? icon, int? position}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        position: position ?? this.position,
      );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    icon: json["icon"],
    position: json["position"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "icon": icon,
    "position": position,
  };
}

enum Unit { PC }

final unitValues = EnumValues({"pc": Unit.PC});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
