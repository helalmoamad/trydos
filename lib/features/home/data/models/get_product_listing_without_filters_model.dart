import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart';

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
  final String? resultFor;
  final String? boutiqueSlug;

  Data({
    this.totalSize,
    this.limit,
    this.offset,
    this.products,
    this.resultFor,
    this.boutiqueSlug,
  });

  Data copyWith({
    int? totalSize,
    int? limit,
    int? offset,
    List<Products>? products,
    String? resultFor,
    String? boutiqueSlug,
  }) =>
      Data(
        totalSize: totalSize ?? this.totalSize,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        products: products ?? this.products,
        resultFor: resultFor ?? this.resultFor,
        boutiqueSlug: boutiqueSlug ?? this.boutiqueSlug,
      );

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      totalSize: json["total_size"],
      limit: json["limit"],
      offset: json["offset"],
      products: json["products"] == null
          ? []
          : List<Products>.from(
              json["products"]!.map((x) => Products.fromJson(x))),
      resultFor: json["result_for"],
      boutiqueSlug: json["boutique_slug"],
    );
  }

  Map<String, dynamic> toJson() => {
        "total_size": totalSize,
        "limit": limit,
        "offset": offset,
        "products": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "result_for": resultFor,
        "boutique_slug": boutiqueSlug,
      };
}

class Products {
  final int? productId;
  final String? boutiqueId;
  final String? name;
  final String? slug;
  final String? shareLink;
  final String? maxAllowedQty;
  final String? details;
  // final Thumbnail? thumbnail;
  final List<Thumbnail>? images;
  final List<Category>? categories;
  final Category? category;
  final List<String>? labelNames;
  final String? flashDealEndDate;
  final int? collectedAfterOrdering;
  final int? flashDealStatus;
  final double? flashDealDiscount;
  final double? flashDealPrice;
  final Brand? brand;
  final List<Color>? colors;
  final List<SyncColorImage>? syncColorImages;
  final double? price;
  final String? priceFormatted;
  final double? offerPrice;
  final String? offerPriceFormatted;
  final bool? isFavourite;
  final bool? isActive;
  final Rating? rating;
  final dynamic flashDealDetails;
  final dynamic flashDealMaxAllowedQuantity;
  final String? dateNow;
  final dynamic description;
  final dynamic model;
  final dynamic features;
  final bool? shippingCostMultiplyWithQuantity;
  final double? shippingCost;
  final List<Variation>? variation;
  final bool? isRedeem;
  final double? redeemPrice;
  final List<ChoiceOption>? choiceOptions;
  final bool? countryIsRestricted;
  final bool? hasRedeemDiscount;
  final bool? hasDiscount;
  final bool? hasTax;
  final String? deliveryAt;
  final String? tax;
  final String? unitPrice;
  final String? slugEnTopic;
  final int? availableQuantity;
  final int? leftStock;
  final int? reviewsCount;
  final dynamic sellerId;
  final BoutiqueForCart? boutique;
  final Seller? seller;
  final Shop? shop;
  final bool? isFavSeller;

  final int? countOfLikes;
  final CategoryHierarchy? categoryHierarchy;
  final int? countOfPieces;
  final List<dynamic>? reviews;
  final bool? hasWholeSale;
  final dynamic wholeSaleLink;
  final int? viewsCount;
  final List<DataDescriptor>? descriptors;
  final List<Label>? labels;
  final int? shippingDays;
  final bool? isProductNotifiedForUser;

  Products({
    this.productId,
    this.boutiqueId,
    this.name,
    this.slug,
    this.shareLink,
    this.details,
    //this.thumbnail,
    this.maxAllowedQty,
    this.images,
    this.isRedeem,
    this.redeemPrice,
    this.categories,
    this.hasRedeemDiscount,
    this.categoryHierarchy,
    this.category,
    this.collectedAfterOrdering,
    this.brand,
    this.colors,
    this.syncColorImages,
    this.price,
    this.priceFormatted,
    this.offerPrice,
    this.offerPriceFormatted,
    this.isFavourite,
    this.isActive,
    this.labelNames,
    this.flashDealEndDate,
    this.rating,
    this.flashDealDetails,
    this.flashDealMaxAllowedQuantity,
    this.dateNow,
    this.description,
    this.descriptors,
    this.flashDealStatus,
    this.flashDealDiscount,
    this.flashDealPrice,
    this.model,
    this.features,
    this.countOfPieces,
    this.variation,
    this.slugEnTopic,
    this.shippingCostMultiplyWithQuantity,
    this.shippingCost,
    this.countOfLikes,
    this.choiceOptions,
    this.hasDiscount,
    this.hasTax,
    this.deliveryAt,
    this.tax,
    this.boutique,
    this.unitPrice,
    this.availableQuantity,
    this.leftStock,
    this.shippingDays,
    this.countryIsRestricted,
    this.reviewsCount,
    this.sellerId,
    this.seller,
    this.shop,
    this.isFavSeller,
    this.reviews,
    this.hasWholeSale,
    this.wholeSaleLink,
    this.viewsCount,
    this.labels,
    required this.isProductNotifiedForUser,
  });

  Products copyWith({
    int? productId,
    String? boutiqueId,
    String? name,
    String? slug,
    String? shareLink,
    bool? isRedeem,
    double? redeemPrice,
    String? details,
    Thumbnail? thumbnail,
    List<Thumbnail>? images,
    List<Category>? categories,
    Category? category,
    CategoryHierarchy? categoryHierarchy,
    Brand? brand,
    List<Color>? colors,
    List<SyncColorImage>? syncColorImages,
    double? price,
    bool? shippingCostMultiplyWithQuantity,
    bool? hasRedeemDiscount,
    double? shippingCost,
    String? priceFormatted,
    double? offerPrice,
    String? offerPriceFormatted,
    bool? isFavourite,
    String? maxAllowedQty,
    bool? isActive,
    int? collectedAfterOrdering,
    Rating? rating,
    dynamic flashDealDetails,
    dynamic flashDealMaxAllowedQuantity,
    String? date,
    dynamic description,
    dynamic model,
    dynamic features,
    String? slugEnTopic,
    List<Variation>? variation,
    List<ChoiceOption>? choiceOptions,
    int? flashDealStatus,
    double? flashDealDiscount,
    double? flashDealPrice,
    bool? hasDiscount,
    List<String>? labelNames,
    String? flashDealEndDate,
    bool? hasTax,
    String? deliveryAt,
    String? tax,
    int? countOfPieces,
    String? unitPrice,
    int? availableQuantity,
    int? leftStock,
    int? reviewsCount,
    dynamic sellerId,
    int? shippingDays,
    BoutiqueForCart? boutique,
    int? countOfLikes,
    Seller? seller,
    Shop? shop,
    bool? isFavSeller,
    List<dynamic>? reviews,
    bool? hasWholeSale,
    dynamic wholeSaleLink,
    int? viewsCount,
    List<DataDescriptor>? descriptors,
    List<Label>? labels,
    bool? isProductNotifiedForUser,
    bool? countryIsRestricted,
  }) =>
      Products(
        productId: productId ?? this.productId,
        boutiqueId: boutiqueId ?? this.boutiqueId,
        name: name ?? this.name,
        isRedeem: isRedeem ?? this.isRedeem,
        redeemPrice: redeemPrice ?? this.redeemPrice,
        slug: slug ?? this.slug,
        shareLink: shareLink ?? this.shareLink,
        details: details ?? this.details,
        //thumbnail: thumbnail ?? this.thumbnail,
        hasRedeemDiscount: hasRedeemDiscount ?? this.hasRedeemDiscount,
        images: images ?? this.images,
        categories: categories ?? this.categories,
        category: category ?? this.category,
        flashDealStatus: flashDealStatus ?? this.flashDealStatus,
        flashDealDiscount: flashDealDiscount ?? this.flashDealDiscount,
        flashDealPrice: flashDealPrice ?? this.flashDealPrice,
        brand: brand ?? this.brand,
        categoryHierarchy: categoryHierarchy ?? this.categoryHierarchy,
        colors: colors ?? this.colors,
        syncColorImages: syncColorImages ?? this.syncColorImages,
        maxAllowedQty: maxAllowedQty ?? this.maxAllowedQty,
        price: price ?? this.price,
        priceFormatted: priceFormatted ?? this.priceFormatted,
        offerPrice: offerPrice ?? this.offerPrice,
        offerPriceFormatted: offerPriceFormatted ?? this.offerPriceFormatted,
        isFavourite: isFavourite ?? this.isFavourite,
        isActive: isActive ?? this.isActive,
        rating: rating ?? this.rating,
        flashDealDetails: flashDealDetails ?? this.flashDealDetails,
        flashDealMaxAllowedQuantity:
            flashDealMaxAllowedQuantity ?? this.flashDealMaxAllowedQuantity,
        dateNow: date ?? this.dateNow,
        description: description ?? this.description,
        slugEnTopic: slugEnTopic ?? this.slugEnTopic,
        model: model ?? this.model,
        variation: variation ?? this.variation,
        features: features ?? this.features,
        choiceOptions: choiceOptions ?? this.choiceOptions,
        hasDiscount: hasDiscount ?? this.hasDiscount,
        hasTax: hasTax ?? this.hasTax,
        deliveryAt: deliveryAt ?? this.deliveryAt,
        labelNames: labelNames ?? this.labelNames,
        flashDealEndDate: flashDealEndDate ?? this.flashDealEndDate,
        tax: tax ?? this.tax,
        unitPrice: unitPrice ?? this.unitPrice,
        countryIsRestricted: countryIsRestricted ?? this.countryIsRestricted,
        shippingCostMultiplyWithQuantity: shippingCostMultiplyWithQuantity ??
            this.shippingCostMultiplyWithQuantity,
        shippingCost: shippingCost ?? this.shippingCost,
        shippingDays: shippingDays ?? this.shippingDays,
        availableQuantity: availableQuantity ?? this.availableQuantity,
        leftStock: leftStock ?? this.leftStock,
        collectedAfterOrdering:
            collectedAfterOrdering ?? this.collectedAfterOrdering,
        countOfLikes: countOfLikes ?? this.countOfLikes,
        reviewsCount: reviewsCount ?? this.reviewsCount,
        sellerId: sellerId ?? this.sellerId,
        seller: seller ?? this.seller,
        countOfPieces: countOfPieces ?? this.countOfPieces,
        shop: shop ?? this.shop,
        boutique: boutique ?? this.boutique,
        isFavSeller: isFavSeller ?? this.isFavSeller,
        reviews: reviews ?? this.reviews,
        hasWholeSale: hasWholeSale ?? this.hasWholeSale,
        wholeSaleLink: wholeSaleLink ?? this.wholeSaleLink,
        viewsCount: viewsCount ?? this.viewsCount,
        descriptors: descriptors ?? this.descriptors,
        labels: labels ?? this.labels,
        isProductNotifiedForUser:
            isProductNotifiedForUser ?? this.isProductNotifiedForUser,
      );

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
        productId: json["product_id"] != null
            ? int.tryParse(json["product_id"].toString())
            : int.tryParse(json["id"].toString()),
        boutiqueId: json["boutique_id"].toString(),
        name: json["name"],
        slug: json["slug"],
        shareLink: json["share_link"],
        isRedeem: json["is_redeem"],
        redeemPrice: (json["redeem_price"] ?? 0).toDouble(),
        details: json["details"],
        countryIsRestricted: json["is_country_restricted"],
        hasRedeemDiscount: json["has_redeem_discount"],
        shippingCostMultiplyWithQuantity:
            json["shipping_cost_multiply_with_quantity"],
        shippingCost: double.tryParse(json["shipping_cost"].toString()),
        // thumbnail: json["thumbnail"] == null
        //    ? null
        //     : Thumbnail.fromJson(json["thumbnail"]),
        flashDealStatus: json["flash_deal_status"],
        flashDealDiscount: json["flash_deal_discount"]?.toDouble(),
        flashDealPrice:
            double.tryParse((json["flash_deal_price"] ?? 0).toString()),
        images: json["images"] == null
            ? []
            : List<Thumbnail>.from(
                json["images"]!.map((x) => Thumbnail.fromJson(x))),
        categoryHierarchy: json["category_hierarchy"] == null
            ? null
            : CategoryHierarchy.fromJson(json["category_hierarchy"]),
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"]!.map((x) => Category.fromJson(x))),
        category: json["category"] == null || json["category"] == []
            ? null
            : Category.fromJson(json["category"]),
        brand: json["brand"] == null ? null : Brand.fromJson(json["brand"]),
        colors: json["colors"] == null
            ? []
            : List<Color>.from(json["colors"]!.map((x) => Color.fromJson(x))),
        syncColorImages: json["sync_color_images"] == null
            ? []
            : List<SyncColorImage>.from(json["sync_color_images"]!
                .map((x) => SyncColorImage.fromJson(x))),
        price: json["price"].toDouble(),
        priceFormatted: json["price_formatted"],
        offerPrice: json["offer_price"].toDouble(),
        maxAllowedQty: json["max_allowed_qty"],
        offerPriceFormatted: json["offer_price_formatted"],
        collectedAfterOrdering: json["collected_after_ordering"],
        isFavourite: json["is_favourite"],
        isActive: json["is_active"],
        labelNames: json["label_names"] == null
            ? []
            : List<String>.from(json["label_names"]!.map((x) => x)),
        flashDealEndDate: json["flash_deal_end_date"],
        rating: json["rating"] == null ? null : Rating.fromJson(json["rating"]),
        flashDealDetails: json["flash_deal_details"],
        flashDealMaxAllowedQuantity: json["flash_deal_max_allowed_quantity"],
        dateNow: DateTime.now().toString(),
        description: json["description"],
        countOfPieces: json["count_of_pieces"],
        model: json["model"],
        features: json["features"],
        slugEnTopic: json["slug_en_topic"],
        boutique: json["boutique"] == null
            ? null
            : BoutiqueForCart.fromJson(json["boutique"]),
        variation: json["variation"] == null
            ? []
            : List<Variation>.from(
                json["variation"]!.map((x) => Variation.fromJson(x))),
        choiceOptions: json["choice_options"] == null
            ? []
            : List<ChoiceOption>.from(
                json["choice_options"]!.map((x) => ChoiceOption.fromJson(x))),
        hasDiscount: json["has_discount"],
        hasTax: json["has_tax"],
        deliveryAt: json["delivery_at"],
        countOfLikes: json["count_of_likes"],
        tax: json["tax"].toString(),
        unitPrice: json["unit_price"].toString(),
        availableQuantity: json["available_quantity"]?.toInt(),
        leftStock: json["Left_stock"],
        // reviewsCount: json["reviews_count"],
        sellerId: json["seller_id"],
        shippingDays: json["shipping_days"],
        seller: json["seller"] == null ? null : Seller.fromJson(json["seller"]),
        shop: json["shop"] == null ? null : Shop.fromJson(json["shop"]),
        isFavSeller: json["is_fav_seller"],
        reviews: json["reviews"] == null ? [] : List<dynamic>.from(json["reviews"]!.map((x) => x)),
        hasWholeSale: json["has_whole_sale"],
        wholeSaleLink: json["whole_sale_link"],
        // viewsCount: json["views_count"],
        descriptors: json["descriptors"] == null ? [] : List<DataDescriptor>.from(json["descriptors"]!.map((x) => DataDescriptor.fromJson(x))),
        labels: json["labels"] == null ? [] : List<Label>.from(json["labels"]!.map((x) => Label.fromJson(x))),
        isProductNotifiedForUser: json['is_product_notify_for_user'] ?? false);
  }

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "boutique_id": boutiqueId.toString(),
        "name": name,
        "is_redeem": isRedeem,
        "redeem_price": redeemPrice,
        "slug": slug,
        "share_link": shareLink,
        "flash_deal_status": flashDealStatus,
        "flash_deal_discount": flashDealDiscount,
        "flash_deal_price": flashDealPrice,
        "has_redeem_discount": hasRedeemDiscount,

        "details": details,
        //"thumbnail": thumbnail?.toJson(),
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toJson())),
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "category_hierarchy": categoryHierarchy?.toJson(),
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
        "is_country_restricted": countryIsRestricted,
        "max_allowed_qty": maxAllowedQty,
        "offer_price_formatted": offerPriceFormatted,
        "is_favourite": isFavourite,
        "is_active": isActive,
        "rating": rating?.toJson(),
        "label_names": labelNames == null
            ? []
            : List<dynamic>.from(labelNames!.map((x) => x)),

        "flash_deal_end_date": flashDealEndDate,
        "shipping_cost_multiply_with_quantity":
            shippingCostMultiplyWithQuantity,
        "shipping_cost": shippingCost?.toDouble(),
        "collected_after_ordering": collectedAfterOrdering,
        "flash_deal_details": flashDealDetails,
        "flash_deal_max_allowed_quantity": flashDealMaxAllowedQuantity,
        "date_now": dateNow,
        "description": description,
        "model": model,

        "features": features,

        "boutique": boutique?.toJson(),
        "variation": variation == null
            ? []
            : List<dynamic>.from(variation!.map((x) => x.toJson())),

        "choice_options": choiceOptions == null
            ? []
            : List<dynamic>.from(choiceOptions!.map((x) => x.toJson())),
        "has_discount": hasDiscount,

        "has_tax": hasTax,
        "delivery_at": deliveryAt,
        "slug_en_topic": slugEnTopic,
        "shipping_days": shippingDays,

        "count_of_likes": countOfLikes,
        "tax": tax,
        "unit_price": unitPrice,
        "available_quantity": availableQuantity,
        "count_of_pieces": countOfPieces,
        "Left_stock": leftStock,

        // "reviews_count": reviewsCount,
        "seller_id": sellerId,
        "seller": seller?.toJson(),
        "shop": shop?.toJson(),
        "is_fav_seller": isFavSeller,
        "reviews":
            reviews == null ? [] : List<dynamic>.from(reviews!.map((x) => x)),
        "has_whole_sale": hasWholeSale,
        "whole_sale_link": wholeSaleLink,
        // "views_count": viewsCount,
        "descriptors": descriptors == null
            ? []
            : List<dynamic>.from(descriptors!.map((x) => x.toJson())),
        "labels": labels == null
            ? []
            : List<dynamic>.from(labels!.map((x) => x.toJson())),
        "is_product_notify_for_user": isProductNotifiedForUser
      };
}

class CategoryHierarchy {
  final CategoryName? mainCategory;
  final CategoryName? subCategory;
  final CategoryName? subSubCategory;

  CategoryHierarchy({
    this.mainCategory,
    this.subCategory,
    this.subSubCategory,
  });

  CategoryHierarchy copyWith({
    CategoryName? mainCategory,
    CategoryName? subCategory,
    CategoryName? subSubCategory,
  }) =>
      CategoryHierarchy(
        mainCategory: mainCategory ?? this.mainCategory,
        subCategory: subCategory ?? this.subCategory,
        subSubCategory: subSubCategory ?? this.subSubCategory,
      );

  factory CategoryHierarchy.fromJson(Map<String, dynamic> json) =>
      CategoryHierarchy(
        mainCategory: json["main_category"] == null
            ? null
            : CategoryName.fromJson(json["main_category"]),
        subCategory: json["sub_category"] == null
            ? null
            : CategoryName.fromJson(json["sub_category"]),
        subSubCategory: json["sub_sub_category"] == null
            ? null
            : CategoryName.fromJson(json["sub_sub_category"]),
      );

  Map<String, dynamic> toJson() => {
        "main_category": mainCategory?.toJson(),
        "sub_category": subCategory?.toJson(),
        "sub_sub_category": subSubCategory?.toJson(),
      };
}

class CategoryName {
  final int? id;
  final String? name;

  CategoryName({
    this.id,
    this.name,
  });

  CategoryName copyWith({
    int? id,
    String? name,
  }) =>
      CategoryName(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory CategoryName.fromJson(Map<String, dynamic> json) => CategoryName(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class Brand {
  final int? id;
  final String? slug;
  final String? name;
  final Thumbnail? icon;

  Brand({
    this.id,
    this.slug,
    this.name,
    this.icon,
  });

  Brand copyWith({
    int? id,
    String? slug,
    String? name,
    Thumbnail? icon,
  }) =>
      Brand(
        id: id ?? this.id,
        slug: slug ?? this.slug,
        name: name ?? this.name,
        icon: icon ?? this.icon,
      );

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json["id"],
        slug: json["slug"],
        name: json["name"],
        icon: json["icon"] == null ? null : Thumbnail.fromJson(json["icon"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "name": name,
        "icon": icon?.toJson(),
      };
}

class Thumbnail {
  final String? filePath;
  final String? originalWidth;
  final String? originalHeight;

  Thumbnail({
    this.filePath,
    this.originalWidth,
    this.originalHeight,
  });

  Thumbnail copyWith({
    String? filePath,
    String? originalWidth,
    String? originalHeight,
  }) =>
      Thumbnail(
        filePath: filePath ?? this.filePath,
        originalWidth: originalWidth ?? this.originalWidth,
        originalHeight: originalHeight ?? this.originalHeight,
      );

  factory Thumbnail.fromJson(Map<String, dynamic> json) => Thumbnail(
        filePath: json["file_path"]?.contains("cloudinary")
            ? json["file_path"]
            : ("${dotenv.env['Images_Url']}" + (json["file_path"])),
        originalWidth: json["original_width"] == null
            ? "0"
            : json["original_width"].replaceAll(RegExp(r'[^0-9.]'), ''),
        originalHeight: json["original_width"] == null
            ? ""
            : json["original_height"].replaceAll(RegExp(r'[^0-9.]'), ''),
      );

  Map<String, dynamic> toJson() => {
        "file_path": filePath,
        "original_width": originalWidth,
        "original_height": originalHeight,
      };
}

class Color {
  final String? name;
  final String? color;
  final String? option;

  Color({
    this.name,
    this.option,
    this.color,
  });

  Color copyWith({
    String? name,
    String? color,
    String? option,
  }) =>
      Color(
        name: name ?? this.name,
        option: option ?? this.option,
        color: color ?? this.color,
      );

  factory Color.fromJson(Map<String, dynamic> json) {
    print("12-----------------------------${json["option"]}");
    return Color(
      name: json["name"],
      color: json["color"],
      option: json["option"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "option": option,
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
  final String? colorName;
  final List<Thumbnail>? images;
  final bool? colorTrend;
  final String? colorOption;
  SyncColorImage({
    this.colorName,
    this.images,
    this.colorOption,
    this.colorTrend,
  });

  SyncColorImage copyWith({
    String? colorName,
    String? colorOption,
    List<Thumbnail>? images,
    bool? colorTrend,
  }) =>
      SyncColorImage(
        colorName: colorName ?? this.colorName,
        colorOption: colorOption ?? this.colorOption,
        images: images ?? this.images,
        colorTrend: colorTrend ?? this.colorTrend,
      );

  factory SyncColorImage.fromJson(Map<String, dynamic> json) {
    return SyncColorImage(
      colorName: json["color_name"],
      colorOption: json["color_option"],
      images: json["images"] == null
          ? []
          : List<Thumbnail>.from(
              json["images"]!.map((x) => Thumbnail.fromJson(x))),
      colorTrend: json["color_trend"] == null || json["color_trend"] == "on"
          ? false
          : json["color_trend"],
    );
  }

  Map<String, dynamic> toJson() => {
        "color_name": colorName,
        "color_option": colorOption,
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toJson())),
        "color_trend": colorTrend,
      };
}
