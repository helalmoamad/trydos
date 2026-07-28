// To parse this JSON data, do
//
//     final getOldCartModel = getOldCartModelFromJson(jsonString);

import 'dart:convert';

import 'package:trydos/features/home/data/models/get_cart_item_model.dart';

GetOldCartModel getOldCartModelFromJson(String str) =>
    GetOldCartModel.fromJson(json.decode(str));

String getOldCartModelToJson(GetOldCartModel data) =>
    json.encode(data.toJson());

class GetOldCartModel {
  final String? message;
  final OriginalData? data;

  GetOldCartModel({this.message, this.data});

  GetOldCartModel copyWith({String? message, OriginalData? data}) =>
      GetOldCartModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetOldCartModel.fromJson(Map<String, dynamic> json) =>
      GetOldCartModel(
        message: json["message"],
        data: json["data"] == null ? null : OriginalData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class OriginalData {
  final List<OldCart>? oldCart;

  OriginalData({this.oldCart});

  OriginalData copyWith({List<OldCart>? oldCart}) =>
      OriginalData(oldCart: oldCart ?? this.oldCart);

  factory OriginalData.fromJson(Map<String, dynamic> json) => OriginalData(
    oldCart: json["oldCart"] == null
        ? []
        : List<OldCart>.from(json["oldCart"]!.map((x) => OldCart.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "oldCart": oldCart == null
        ? []
        : List<dynamic>.from(oldCart!.map((x) => x.toJson())),
  };
}

class OldCart {
  final int? id;
  final int? productId;
  final VariationCart? variations;
  final int? quantity;
  final String? slug;
  final String? name;
  final dynamic countOfPieces;
  final Shop? shop;
  final Brand? brand;
  final BoutiquesCart? boutique;
  final String? thumbnail;
  final String? image;
  final DateTime? createdAt;
  final int? shippingDays;
  final double? offerPrice;

  OldCart({
    this.id,
    this.offerPrice,
    this.productId,
    this.variations,
    this.quantity,
    this.slug,
    this.name,
    this.countOfPieces,
    this.shop,
    this.brand,
    this.boutique,
    this.thumbnail,
    this.image,
    this.createdAt,
    this.shippingDays,
  });

  OldCart copyWith({
    int? id,
    int? productId,
    double? offerPrice,
    VariationCart? variations,
    int? quantity,

    String? slug,
    String? name,
    dynamic countOfPieces,
    Shop? shop,
    Brand? brand,
    BoutiquesCart? boutique,
    String? thumbnail,
    String? image,
    DateTime? createdAt,
    int? shippingDays,
  }) => OldCart(
    id: id ?? this.id,

    productId: productId ?? this.productId,

    variations: variations ?? this.variations,
    offerPrice: offerPrice ?? this.offerPrice,
    quantity: quantity ?? this.quantity,

    slug: slug ?? this.slug,
    name: name ?? this.name,
    countOfPieces: countOfPieces ?? this.countOfPieces,
    shop: shop ?? this.shop,
    brand: brand ?? this.brand,
    shippingDays: shippingDays ?? this.shippingDays,

    boutique: boutique ?? this.boutique,
    thumbnail: thumbnail ?? this.thumbnail,
    image: image ?? this.image,
    createdAt: createdAt ?? this.createdAt,
  );

  factory OldCart.fromJson(Map<String, dynamic> json) {
    return OldCart(
      id: json["id"],
      offerPrice: json["offer_price"]?.toDouble(),
      productId: json["product_id"],
      shippingDays: json["shipping_days"],

      variations: json["variations"] == null
          ? null
          : json["variations"] is List
          ? json["variations"].isEmpty
                ? null
                : VariationCart.fromJson(json["variations"][0])
          : VariationCart.fromJson(json["variations"]),

      quantity: double.tryParse(json["quantity"].toString())!.round(),

      slug: json["slug"],
      name: json["name"],
      countOfPieces: json["count_of_pieces"],
      shop: json["shop"] == null ? null : Shop.fromJson(json["shop"]),
      brand: json["brand"] == null ? null : Brand.fromJson(json["brand"]),
      boutique: json["boutique"] == null
          ? null
          : BoutiquesCart.fromJson(json["boutique"]),
      thumbnail: json["thumbnail"],
      image: json["image"],
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,

    "product_id": productId,

    "variations": variations,

    "shipping_days": shippingDays,

    "offer_price": offerPrice,
    "quantity": quantity,

    "slug": slug,
    "name": name,
    "count_of_pieces": countOfPieces,
    "shop": shop?.toJson(),
    "brand": brand?.toJson(),
    "boutique": boutique?.toJson(),
    "thumbnail": thumbnail,
    "image": image,
    "created_at": createdAt?.toIso8601String(),
  };
}

class Boutique {
  final int? id;
  final Icon? icon;

  Boutique({this.id, this.icon});

  Boutique copyWith({int? id, Icon? icon}) =>
      Boutique(id: id ?? this.id, icon: icon ?? this.icon);

  factory Boutique.fromJson(Map<String, dynamic> json) => Boutique(
    id: json["id"],
    icon: json["icon"] == null ? null : Icon.fromJson(json["icon"]),
  );

  Map<String, dynamic> toJson() => {"id": id, "icon": icon?.toJson()};
}

class Icon {
  final String? filePath;
  final String? originalWidth;
  final String? originalHeight;

  Icon({this.filePath, this.originalWidth, this.originalHeight});

  Icon copyWith({
    String? filePath,
    String? originalWidth,
    String? originalHeight,
  }) => Icon(
    filePath: filePath ?? this.filePath,
    originalWidth: originalWidth ?? this.originalWidth,
    originalHeight: originalHeight ?? this.originalHeight,
  );

  factory Icon.fromJson(Map<String, dynamic> json) => Icon(
    filePath: json["file_path"],
    originalWidth: json["original_width"],
    originalHeight: json["original_height"],
  );

  Map<String, dynamic> toJson() => {
    "file_path": filePath,
    "original_width": originalWidth,
    "original_height": originalHeight,
  };
}

class Brand {
  final int? id;
  final String? slug;
  final String? name;
  final Icon? icon;

  Brand({this.id, this.slug, this.name, this.icon});

  Brand copyWith({int? id, String? slug, String? name, Icon? icon}) => Brand(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    name: name ?? this.name,
    icon: icon ?? this.icon,
  );

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
    id: json["id"],
    slug: json["slug"],
    name: json["name"],
    icon: json["icon"] == null
        ? null
        : json["icon"] is Map
        ? Icon.fromJson(json["icon"])
        : Icon.fromJson({"file_path": json["icon"]}),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "name": name,
    "icon": icon?.toJson(),
  };
}

class Choice {
  final String? choice1;

  Choice({this.choice1});

  Choice copyWith({String? choice1}) =>
      Choice(choice1: choice1 ?? this.choice1);

  factory Choice.fromJson(Map<String, dynamic> json) =>
      Choice(choice1: json["choice_1"]);

  Map<String, dynamic> toJson() => {"choice_1": choice1};
}

class Shop {
  final String? image;
  final String? name;

  Shop({this.image, this.name});

  Shop copyWith({String? image, String? name}) =>
      Shop(image: image ?? this.image, name: name ?? this.name);

  factory Shop.fromJson(Map<String, dynamic> json) =>
      Shop(image: json["image"], name: json["name"]);

  Map<String, dynamic> toJson() => {"image": image, "name": name};
}
