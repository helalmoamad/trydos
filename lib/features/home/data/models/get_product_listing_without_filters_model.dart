// To parse this JSON data, do
//
//     final getProductListingWithoutFiltersModel = getProductListingWithoutFiltersModelFromJson(jsonString);

import 'dart:convert';

GetProductListingWithoutFiltersModel
    getProductListingWithoutFiltersModelFromJson(String str) =>
        GetProductListingWithoutFiltersModel.fromJson(json.decode(str));

String getProductListingWithoutFiltersModelToJson(
        GetProductListingWithoutFiltersModel data) =>
    json.encode(data.toJson());

class GetProductListingWithoutFiltersModel {
  final String? message;
  final Data? data;

  GetProductListingWithoutFiltersModel({
    this.message,
    this.data,
  });

  GetProductListingWithoutFiltersModel copyWith({
    String? message,
    Data? data,
  }) =>
      GetProductListingWithoutFiltersModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory GetProductListingWithoutFiltersModel.fromJson(
          Map<String, dynamic> json) =>
      GetProductListingWithoutFiltersModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final int? totalSize;
  final int? limit;
  final int? offset;
  final List<Products>? products;
  final String? categoryParentParent;
  final String? categoryParent;
  final ChildCategoryClass? category;
  final String? categorySeoDescription;
  final String? categoryTitle;
  final dynamic categoryH1;
  final List<ChildCategoryClass>? childCategories;
  final String? resultFor;
  final String? boutiqueSlug;

  Data({
    this.totalSize,
    this.limit,
    this.offset,
    this.products,
    this.categoryParentParent,
    this.categoryParent,
    this.category,
    this.categorySeoDescription,
    this.categoryTitle,
    this.categoryH1,
    this.childCategories,
    this.resultFor,
    this.boutiqueSlug,
  });

  Data copyWith({
    int? totalSize,
    int? limit,
    int? offset,
    List<Products>? products,
    String? categoryParentParent,
    String? categoryParent,
    ChildCategoryClass? category,
    String? categorySeoDescription,
    String? categoryTitle,
    dynamic categoryH1,
    List<ChildCategoryClass>? childCategories,
    String? resultFor,
    String? boutiqueSlug,
  }) =>
      Data(
        totalSize: totalSize ?? this.totalSize,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        products: products ?? this.products,
        categoryParentParent: categoryParentParent ?? this.categoryParentParent,
        categoryParent: categoryParent ?? this.categoryParent,
        category: category ?? this.category,
        categorySeoDescription:
            categorySeoDescription ?? this.categorySeoDescription,
        categoryTitle: categoryTitle ?? this.categoryTitle,
        categoryH1: categoryH1 ?? this.categoryH1,
        childCategories: childCategories ?? this.childCategories,
        resultFor: resultFor ?? this.resultFor,
        boutiqueSlug: boutiqueSlug ?? this.boutiqueSlug,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalSize: json["total_size"],
        limit: json["limit"],
        offset: json["offset"],
        products: json["products"] == null
            ? []
            : List<Products>.from(
                json["products"]!.map((x) => Products.fromJson(x))),
        categoryParentParent: json["category_parent_parent"],
        categoryParent: json["category_parent"],
        category: json["category"] == null || json["category"] == ""
            ? null
            : ChildCategoryClass.fromJson(json["category"]),
        categorySeoDescription: json["category_seo_description"],
        categoryTitle: json["category_title"],
        categoryH1: json["category_h1"],
        childCategories:
            json["child_categories"] == null || json["child_categories"] == ""
                ? []
                : List<ChildCategoryClass>.from(json["child_categories"]!
                    .map((x) => ChildCategoryClass.fromJson(x))),
        resultFor: json["result_for"],
        boutiqueSlug: json["boutique_slug"],
      );

  Map<String, dynamic> toJson() => {
        "total_size": totalSize,
        "limit": limit,
        "offset": offset,
        "products": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "category_parent_parent": categoryParentParent,
        "category_parent": categoryParent,
        "category": category?.toJson(),
        "category_seo_description": categorySeoDescription,
        "category_title": categoryTitle,
        "category_h1": categoryH1,
        "child_categories": childCategories == null
            ? []
            : List<dynamic>.from(childCategories!.map((x) => x.toJson())),
        "result_for": resultFor,
        "boutique_slug": boutiqueSlug,
      };
}

class ChildCategoryClass {
  final int? id;
  final Name? name;
  final String? slug;
  final String? icon;
  final String? banner;
  final int? parentId;
  final int? position;
  final int? productsStyle;
  final int? isGift;
  final int? numAvailableProduct;
  final int? seoDescription;
  final dynamic products;

  ChildCategoryClass({
    this.id,
    this.name,
    this.slug,
    this.icon,
    this.banner,
    this.parentId,
    this.position,
    this.productsStyle,
    this.isGift,
    this.numAvailableProduct,
    this.seoDescription,
    this.products,
  });

  ChildCategoryClass copyWith({
    int? id,
    Name? name,
    String? slug,
    String? icon,
    String? banner,
    int? parentId,
    int? position,
    int? productsStyle,
    int? isGift,
    int? numAvailableProduct,
    int? seoDescription,
    dynamic products,
  }) =>
      ChildCategoryClass(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        icon: icon ?? this.icon,
        banner: banner ?? this.banner,
        parentId: parentId ?? this.parentId,
        position: position ?? this.position,
        productsStyle: productsStyle ?? this.productsStyle,
        isGift: isGift ?? this.isGift,
        numAvailableProduct: numAvailableProduct ?? this.numAvailableProduct,
        seoDescription: seoDescription ?? this.seoDescription,
        products: products ?? this.products,
      );

  factory ChildCategoryClass.fromJson(Map<String, dynamic> json) =>
      ChildCategoryClass(
        id: json["id"],
        name: nameValues.map[json["name"]],
        slug: json["slug"],
        icon: json["icon"],
        banner: json["banner"],
        parentId: json["parent_id"],
        position: json["position"],
        productsStyle: json["products_style"],
        isGift: json["is_gift"],
        numAvailableProduct: json["num_available_product"],
        seoDescription: json["seo_description"],
        products: json["products"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": nameValues.reverse[name],
        "slug": slug,
        "icon": icon,
        "banner": banner,
        "parent_id": parentId,
        "position": position,
        "products_style": productsStyle,
        "is_gift": isGift,
        "num_available_product": numAvailableProduct,
        "seo_description": seoDescription,
        "products": products,
      };
}

enum Name { CLOTHES_AND_SHOES_FOR_MEN, MEN }

final nameValues = EnumValues({
  "clothes and shoes for men": Name.CLOTHES_AND_SHOES_FOR_MEN,
  "Men": Name.MEN
});

class Products {
  final int? id;
  final String? name;
  final String? slug;
  final String? shareLink;
  final String? details;
  final String? thumbnail;
  final List<String>? images;
  final List<CategoryElement>? categories;
  final CategoryElement? category;
  final Brand? brand;
  final List<Color>? colors;
  final List<SyncColorImage>? syncColorImages;
  final int? price;
  final String? priceFormatted;
  final int? offerPrice;
  final String? offerPriceFormatted;
  final bool? isFavourite;
  final bool? inStock;
  final Rating? rating;
  final dynamic flashDealDetails;
  final dynamic flashDealMaxAllowedQuantity;

  Products({
    this.id,
    this.name,
    this.slug,
    this.shareLink,
    this.details,
    this.thumbnail,
    this.images,
    this.categories,
    this.category,
    this.brand,
    this.colors,
    this.syncColorImages,
    this.price,
    this.priceFormatted,
    this.offerPrice,
    this.offerPriceFormatted,
    this.isFavourite,
    this.inStock,
    this.rating,
    this.flashDealDetails,
    this.flashDealMaxAllowedQuantity,
  });

  Products copyWith({
    int? id,
    String? name,
    String? slug,
    String? shareLink,
    String? details,
    String? thumbnail,
    List<String>? images,
    List<CategoryElement>? categories,
    CategoryElement? category,
    Brand? brand,
    List<Color>? colors,
    List<SyncColorImage>? syncColorImages,
    int? price,
    String? priceFormatted,
    int? offerPrice,
    String? offerPriceFormatted,
    bool? isFavourite,
    bool? inStock,
    Rating? rating,
    dynamic flashDealDetails,
    dynamic flashDealMaxAllowedQuantity,
  }) =>
      Products(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        shareLink: shareLink ?? this.shareLink,
        details: details ?? this.details,
        thumbnail: thumbnail ?? this.thumbnail,
        images: images ?? this.images,
        categories: categories ?? this.categories,
        category: category ?? this.category,
        brand: brand ?? this.brand,
        colors: colors ?? this.colors,
        syncColorImages: syncColorImages ?? this.syncColorImages,
        price: price ?? this.price,
        priceFormatted: priceFormatted ?? this.priceFormatted,
        offerPrice: offerPrice ?? this.offerPrice,
        offerPriceFormatted: offerPriceFormatted ?? this.offerPriceFormatted,
        isFavourite: isFavourite ?? this.isFavourite,
        inStock: inStock ?? this.inStock,
        rating: rating ?? this.rating,
        flashDealDetails: flashDealDetails ?? this.flashDealDetails,
        flashDealMaxAllowedQuantity:
            flashDealMaxAllowedQuantity ?? this.flashDealMaxAllowedQuantity,
      );

  factory Products.fromJson(Map<String, dynamic> json) => Products(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        shareLink: json["share_link"],
        details: json["details"],
        thumbnail: json["thumbnail"],
        images: json["images"] == null
            ? []
            : List<String>.from(json["images"]!.map((x) => x)),
        categories: json["categories"] == null
            ? []
            : List<CategoryElement>.from(
                json["categories"]!.map((x) => CategoryElement.fromJson(x))),
        category: json["category"] == null
            ? null
            : CategoryElement.fromJson(json["category"]),
        brand: json["brand"] == null ? null : Brand.fromJson(json["brand"]),
        colors: json["colors"] == null
            ? []
            : List<Color>.from(json["colors"]!.map((x) => Color.fromJson(x))),
        syncColorImages: json["sync_color_images"] == null
            ? []
            : List<SyncColorImage>.from(json["sync_color_images"]!
                .map((x) => SyncColorImage.fromJson(x))),
        price: json["price"],
        priceFormatted: json["price_formatted"],
        offerPrice: json["offer_price"],
        offerPriceFormatted: json["offer_price_formatted"],
        isFavourite: json["is_favourite"],
        inStock: json["in_stock"],
        rating: json["rating"] == null ? null : Rating.fromJson(json["rating"]),
        flashDealDetails: json["flash_deal_details"],
        flashDealMaxAllowedQuantity: json["flash_deal_max_allowed_quantity"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "share_link": shareLink,
        "details": details,
        "thumbnail": thumbnail,
        "images":
            images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "category": category?.toJson(),
        "brand": brand?.toJson(),
        "colors": colors == null
            ? []
            : List<dynamic>.from(colors!.map((x) => x.toJson())),
        "sync_color_images": syncColorImages == null
            ? []
            : List<dynamic>.from(syncColorImages!.map((x) => x.toJson())),
        "price": price,
        "price_formatted": priceFormatted,
        "offer_price": offerPrice,
        "offer_price_formatted": offerPriceFormatted,
        "is_favourite": isFavourite,
        "in_stock": inStock,
        "rating": rating?.toJson(),
        "flash_deal_details": flashDealDetails,
        "flash_deal_max_allowed_quantity": flashDealMaxAllowedQuantity,
      };
}

class Brand {
  final int? id;
  final String? name;
  final String? image;

  Brand({
    this.id,
    this.name,
    this.image,
  });

  Brand copyWith({
    int? id,
    String? name,
    String? image,
  }) =>
      Brand(
        id: id ?? this.id,
        name: name ?? this.name,
        image: image ?? this.image,
      );

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json["id"],
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
      };
}

class CategoryElement {
  final int? id;
  final Name? name;
  final String? icon;

  CategoryElement({
    this.id,
    this.name,
    this.icon,
  });

  CategoryElement copyWith({
    int? id,
    Name? name,
    String? icon,
  }) =>
      CategoryElement(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
      );

  factory CategoryElement.fromJson(Map<String, dynamic> json) =>
      CategoryElement(
        id: json["id"],
        name: nameValues.map[json["name"]],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": nameValues.reverse[name],
        "icon": icon,
      };
}

class Color {
  final String? name;
  final String? color;

  Color({
    this.name,
    this.color,
  });

  Color copyWith({
    String? name,
    String? color,
  }) =>
      Color(
        name: name ?? this.name,
        color: color ?? this.color,
      );

  factory Color.fromJson(Map<String, dynamic> json) => Color(
        name: json["name"],
        color: json["color"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "color": color,
      };
}

class Rating {
  final int? overallRating;
  final int? totalRating;

  Rating({
    this.overallRating,
    this.totalRating,
  });

  Rating copyWith({
    int? overallRating,
    int? totalRating,
  }) =>
      Rating(
        overallRating: overallRating ?? this.overallRating,
        totalRating: totalRating ?? this.totalRating,
      );

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        overallRating: json["overall_rating"],
        totalRating: json["total_rating"],
      );

  Map<String, dynamic> toJson() => {
        "overall_rating": overallRating,
        "total_rating": totalRating,
      };
}

class SyncColorImage {
  final bool? colorTrend;
  final String? colorName;
  final List<String>? images;

  SyncColorImage({
    this.colorTrend,
    this.colorName,
    this.images,
  });

  SyncColorImage copyWith({
    bool? colorTrend,
    String? colorName,
    List<String>? images,
  }) =>
      SyncColorImage(
        colorTrend: colorTrend ?? this.colorTrend,
        colorName: colorName ?? this.colorName,
        images: images ?? this.images,
      );

  factory SyncColorImage.fromJson(Map<String, dynamic> json) => SyncColorImage(
        colorTrend: json["color_trend"],
        colorName: json["color_name"],
        images: json["images"] == null
            ? []
            : List<String>.from(json["images"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "color_trend": colorTrend,
        "color_name": colorName,
        "images":
            images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
