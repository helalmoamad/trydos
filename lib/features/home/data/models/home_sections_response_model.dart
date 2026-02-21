// To parse this JSON data, do
//
//     final homeSectionResponseModel = homeSectionResponseModelFromJson(jsonString);

/*import 'dart:convert';

HomeSectionResponseModel homeSectionResponseModelFromJson(String str) => HomeSectionResponseModel.fromJson(json.decode(str));

String homeSectionResponseModelToJson(HomeSectionResponseModel data) => json.encode(data.toJson());

class HomeSectionResponseModel {
  final String? message;
  final List<HomeSectionDataObject>? data;

  HomeSectionResponseModel({
    this.message,
    this.data,
  });

  HomeSectionResponseModel copyWith({
    String? message,
    List<HomeSectionDataObject>? data,
  }) =>
      HomeSectionResponseModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory HomeSectionResponseModel.fromJson(Map<String, dynamic> json) => HomeSectionResponseModel(
    message: json["message"],
    data: json["data"] == null ? [] : List<HomeSectionDataObject>.from(json["data"]!.map((x) => HomeSectionDataObject.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class HomeSectionDataObject {
  final int? total;
  final int? limit;
  final int? offset;
  final List<Section>? sections;
  final List<SubCategory>? subCategories;

  HomeSectionDataObject({
    this.total,
    this.limit,
    this.offset,
    this.sections,
    this.subCategories,
  });

  HomeSectionDataObject copyWith({
    int? total,
    int? limit,
    int? offset,
    List<Section>? sections,
    List<SubCategory>? subCategories,
  }) =>
      HomeSectionDataObject(
        total: total ?? this.total,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        sections: sections ?? this.sections,
        subCategories: subCategories ?? this.subCategories,
      );

  factory HomeSectionDataObject.fromJson(Map<String, dynamic> json) => HomeSectionDataObject(
    total: json["total"],
    limit: json["limit"],
    offset: json["offset"],
    sections: json["sections"] == null ? [] : List<Section>.from(json["sections"]!.map((x) => Section.fromJson(x))),
    subCategories: json["sub_categories"] == null ? [] : List<SubCategory>.from(json["sub_categories"]!.map((x) => SubCategory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "limit": limit,
    "offset": offset,
    "sections": sections == null ? [] : List<dynamic>.from(sections!.map((x) => x.toJson())),
    "sub_categories": subCategories == null ? [] : List<dynamic>.from(subCategories!.map((x) => x.toJson())),
  };
}

class Section {
  final int? id;
  final int? homeSectionType;
  final String? color;
  final String? resourceType;
  final String? title;
  final String? photo;
  final int? productsStyle;
  final HsBanner? hsBanner;
  final dynamic hsBanner2;
  final dynamic hsBanner3;
  final dynamic hsBanner4;
  final dynamic hsBanner5;
  final dynamic hsBanner6;
  final dynamic hsOffers;
  final List<HsProduct>? hsProducts;

  Section({
    this.id,
    this.homeSectionType,
    this.color,
    this.resourceType,
    this.title,
    this.photo,
    this.productsStyle,
    this.hsBanner,
    this.hsBanner2,
    this.hsBanner3,
    this.hsBanner4,
    this.hsBanner5,
    this.hsBanner6,
    this.hsOffers,
    this.hsProducts,
  });

  Section copyWith({
    int? id,
    int? homeSectionType,
    String? color,
    String? resourceType,
    String? title,
    String? photo,
    int? productsStyle,
    HsBanner? hsBanner,
    dynamic hsBanner2,
    dynamic hsBanner3,
    dynamic hsBanner4,
    dynamic hsBanner5,
    dynamic hsBanner6,
    dynamic hsOffers,
    List<HsProduct>? hsProducts,
  }) =>
      Section(
        id: id ?? this.id,
        homeSectionType: homeSectionType ?? this.homeSectionType,
        color: color ?? this.color,
        resourceType: resourceType ?? this.resourceType,
        title: title ?? this.title,
        photo: photo ?? this.photo,
        productsStyle: productsStyle ?? this.productsStyle,
        hsBanner: hsBanner ?? this.hsBanner,
        hsBanner2: hsBanner2 ?? this.hsBanner2,
        hsBanner3: hsBanner3 ?? this.hsBanner3,
        hsBanner4: hsBanner4 ?? this.hsBanner4,
        hsBanner5: hsBanner5 ?? this.hsBanner5,
        hsBanner6: hsBanner6 ?? this.hsBanner6,
        hsOffers: hsOffers ?? this.hsOffers,
        hsProducts: hsProducts ?? this.hsProducts,
      );

  factory Section.fromJson(Map<String, dynamic> json) => Section(
    id: json["id"],
    homeSectionType: json["home_section_type"],
    color: json["color"],
    resourceType: json["resource_type"],
    title: json["title"],
    photo: json["photo"],
    productsStyle: json["products_style"],
    hsBanner: json["hs_banner"] == null ? null : HsBanner.fromJson(json["hs_banner"]),
    hsBanner2: json["hs_banner2"],
    hsBanner3: json["hs_banner3"],
    hsBanner4: json["hs_banner4"],
    hsBanner5: json["hs_banner5"],
    hsBanner6: json["hs_banner6"],
    hsOffers: json["hs_offers"],
    hsProducts: json["hs_products"] == null ? [] : List<HsProduct>.from(json["hs_products"]!.map((x) => HsProduct.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "home_section_type": homeSectionType,
    "color": color,
    "resource_type": resourceType,
    "title": title,
    "photo": photo,
    "products_style": productsStyle,
    "hs_banner": hsBanner?.toJson(),
    "hs_banner2": hsBanner2,
    "hs_banner3": hsBanner3,
    "hs_banner4": hsBanner4,
    "hs_banner5": hsBanner5,
    "hs_banner6": hsBanner6,
    "hs_offers": hsOffers,
    "hs_products": hsProducts == null ? [] : List<dynamic>.from(hsProducts!.map((x) => x.toJson())),
  };
}

class HsBanner {
  final int? id;
  final String? photo;
  final String? desktopPhoto;
  final String? bannerType;
  final int? published;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? url;
  final String? resourceType;
  final int? resourceId;
  final dynamic name;
  final dynamic searchKeyword;
  final dynamic darkLightEffect;
  final dynamic leftBottomDescription;
  final dynamic rightBottomDescription;
  final dynamic photoAe;
  final dynamic desktopPhotoAe;
  final String? newUrl;
  final List<dynamic>? translations;

  HsBanner({
    this.id,
    this.photo,
    this.desktopPhoto,
    this.bannerType,
    this.published,
    this.createdAt,
    this.updatedAt,
    this.url,
    this.resourceType,
    this.resourceId,
    this.name,
    this.searchKeyword,
    this.darkLightEffect,
    this.leftBottomDescription,
    this.rightBottomDescription,
    this.photoAe,
    this.desktopPhotoAe,
    this.newUrl,
    this.translations,
  });

  HsBanner copyWith({
    int? id,
    String? photo,
    String? desktopPhoto,
    String? bannerType,
    int? published,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? url,
    String? resourceType,
    int? resourceId,
    dynamic name,
    dynamic searchKeyword,
    dynamic darkLightEffect,
    dynamic leftBottomDescription,
    dynamic rightBottomDescription,
    dynamic photoAe,
    dynamic desktopPhotoAe,
    String? newUrl,
    List<dynamic>? translations,
  }) =>
      HsBanner(
        id: id ?? this.id,
        photo: photo ?? this.photo,
        desktopPhoto: desktopPhoto ?? this.desktopPhoto,
        bannerType: bannerType ?? this.bannerType,
        published: published ?? this.published,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        url: url ?? this.url,
        resourceType: resourceType ?? this.resourceType,
        resourceId: resourceId ?? this.resourceId,
        name: name ?? this.name,
        searchKeyword: searchKeyword ?? this.searchKeyword,
        darkLightEffect: darkLightEffect ?? this.darkLightEffect,
        leftBottomDescription: leftBottomDescription ?? this.leftBottomDescription,
        rightBottomDescription: rightBottomDescription ?? this.rightBottomDescription,
        photoAe: photoAe ?? this.photoAe,
        desktopPhotoAe: desktopPhotoAe ?? this.desktopPhotoAe,
        newUrl: newUrl ?? this.newUrl,
        translations: translations ?? this.translations,
      );

  factory HsBanner.fromJson(Map<String, dynamic> json) => HsBanner(
    id: json["id"],
    photo: json["photo"],
    desktopPhoto: json["desktop_photo"],
    bannerType: json["banner_type"],
    published: json["published"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    url: json["url"],
    resourceType: json["resource_type"],
    resourceId: json["resource_id"],
    name: json["name"],
    searchKeyword: json["search_keyword"],
    darkLightEffect: json["dark_light_effect"],
    leftBottomDescription: json["left_bottom_description"],
    rightBottomDescription: json["right_bottom_description"],
    photoAe: json["photo_ae"],
    desktopPhotoAe: json["desktop_photo_ae"],
    newUrl: json["new_url"],
    translations: json["translations"] == null ? [] : List<dynamic>.from(json["translations"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "photo": photo,
    "desktop_photo": desktopPhoto,
    "banner_type": bannerType,
    "published": published,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "url": url,
    "resource_type": resourceType,
    "resource_id": resourceId,
    "name": name,
    "search_keyword": searchKeyword,
    "dark_light_effect": darkLightEffect,
    "left_bottom_description": leftBottomDescription,
    "right_bottom_description": rightBottomDescription,
    "photo_ae": photoAe,
    "desktop_photo_ae": desktopPhotoAe,
    "new_url": newUrl,
    "translations": translations == null ? [] : List<dynamic>.from(translations!.map((x) => x)),
  };
}

class HsProduct {
  final int? id;
  final String? name;
  final String? slug;
  final String? shareLink;
  final String? thumbnail;
  final List<String>? images;
  final int? price;
  final String? priceFormatted;
  final int? offerPrice;
  final String? offerPriceFormatted;
  final bool? isFavourite;
  final bool? inStock;
  final Rating? rating;
  final dynamic flashDealDetails;
  final dynamic flashDealMaxAllowedQuantity;

  HsProduct({
    this.id,
    this.name,
    this.slug,
    this.shareLink,
    this.thumbnail,
    this.images,
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

  HsProduct copyWith({
    int? id,
    String? name,
    String? slug,
    String? shareLink,
    String? thumbnail,
    List<String>? images,
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
      HsProduct(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        shareLink: shareLink ?? this.shareLink,
        thumbnail: thumbnail ?? this.thumbnail,
        images: images ?? this.images,
        price: price ?? this.price,
        priceFormatted: priceFormatted ?? this.priceFormatted,
        offerPrice: offerPrice ?? this.offerPrice,
        offerPriceFormatted: offerPriceFormatted ?? this.offerPriceFormatted,
        isFavourite: isFavourite ?? this.isFavourite,
        inStock: inStock ?? this.inStock,
        rating: rating ?? this.rating,
        flashDealDetails: flashDealDetails ?? this.flashDealDetails,
        flashDealMaxAllowedQuantity: flashDealMaxAllowedQuantity ?? this.flashDealMaxAllowedQuantity,
      );

  factory HsProduct.fromJson(Map<String, dynamic> json) => HsProduct(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    shareLink: json["share_link"],
    thumbnail: json["thumbnail"],
    images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
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
    "thumbnail": thumbnail,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
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

class SubCategory {
  final int? id;
  final String? name;
  final String? slug;
  final String? icon;
  final String? banner;
  final int? parentId;
  final int? position;
  final int? productsStyle;
  final int? isGift;
  final int? numAvailableProduct;
  final int? seoDescription;
  final int? title;
  final int? h1;
  final List<SubCategory>? childes;
  final dynamic products;

  SubCategory({
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
    this.title,
    this.h1,
    this.childes,
    this.products,
  });

  SubCategory copyWith({
    int? id,
    String? name,
    String? slug,
    String? icon,
    String? banner,
    int? parentId,
    int? position,
    int? productsStyle,
    int? isGift,
    int? numAvailableProduct,
    int? seoDescription,
    int? title,
    int? h1,
    List<SubCategory>? childes,
    dynamic products,
  }) =>
      SubCategory(
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
        title: title ?? this.title,
        h1: h1 ?? this.h1,
        childes: childes ?? this.childes,
        products: products ?? this.products,
      );

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    icon: json["icon"],
    banner: json["banner"],
    parentId: json["parent_id"],
    position: json["position"],
    productsStyle: json["products_style"],
    isGift: json["is_gift"],
    numAvailableProduct: json["num_available_product"],
    seoDescription: json["seo_description"],
    title: json["title"],
    h1: json["h1"],
    childes: json["childes"] == null ? [] : List<SubCategory>.from(json["childes"]!.map((x) => SubCategory.fromJson(x))),
    products: json["products"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "icon": icon,
    "banner": banner,
    "parent_id": parentId,
    "position": position,
    "products_style": productsStyle,
    "is_gift": isGift,
    "num_available_product": numAvailableProduct,
    "seo_description": seoDescription,
    "title": title,
    "h1": h1,
    "childes": childes == null ? [] : List<dynamic>.from(childes!.map((x) => x.toJson())),
    "products": products,
  };
}
*/