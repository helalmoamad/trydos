// To parse this JSON data, do
//
//     final getProductDetailWithoutRelatedProductsModel = getProductDetailWithoutRelatedProductsModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trydos/features/home/data/models/get_buyers_comments_model.dart';
import 'package:trydos/features/home/data/models/get_fqa_comments_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';

GetProductDetailWithoutRelatedProductsModel
getProductDetailWithoutRelatedProductsModelFromJson(String str) =>
    GetProductDetailWithoutRelatedProductsModel.fromJson(json.decode(str));

String getProductDetailWithoutRelatedProductsModelToJson(
  GetProductDetailWithoutRelatedProductsModel data,
) => json.encode(data.toJson());

class GetProductDetailWithoutRelatedProductsModel {
  final String? message;
  final Product? product;

  GetProductDetailWithoutRelatedProductsModel({this.message, this.product});

  GetProductDetailWithoutRelatedProductsModel copyWith({
    String? message,
    Product? data,
  }) => GetProductDetailWithoutRelatedProductsModel(
    message: message ?? this.message,
    product: data ?? this.product,
  );

  factory GetProductDetailWithoutRelatedProductsModel.fromJson(
    Map<String, dynamic> json,
  ) => GetProductDetailWithoutRelatedProductsModel(
    message: json["message"],
    product: json["data"] == null ? null : Product.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": product?.toJson(),
  };
}

class Product {
  final int? id;
  final dynamic description;
  final String? sellerId;
  final String? ownerType;
  final String? ownerId;
  final bool? isActive;
  // final List<Variation>? variation;
  final List<String>? sizes;
  final String? maxAllowedQty;
  final bool? hasDiscount;
  final Seller? seller;
  final String? deliveryAt;
  final List<String>? labelNames;
  final String? flashDealEndDate;
  final String? slug;
  final int? availableQuantity;
  final int? leftStock;
  final SizeAnalysis? sizeAnalysis;
  final bool? shippingCostMultiplyWithQuantity;
  final double? shippingCost;
  final BoutiqueForCart? boutique;
  final double? price;
  final String? priceFormatted;
  final double? offerPrice;
  final String? offerPriceFormatted;
  final int? commentsCount;
  final List<dynamic>? commentOffset;
  final int? countOfLikes;
  final int? collectedAfterOrdering;
  final int? countOfPieces;
  final bool? isFeatured;
  final bool? isLiked;
  final int? totalViews;
  final double? totalRating;
  final List<DataDescriptor>? descriptors;
  final List<Label>? labels;
  final int? shippingDays;
  final bool isProductNotifiedForUser;
  final bool? countryIsRestricted;
  final List<Thumbnail>? images;
  final List<SyncColorImageProduct>? syncColorImages;
  final bool? isRedeem;
  final double? redeemPrice;
  final BuyersCommentModel? buyersComment;
  final FqaQuestions? fqaQuestions;
  final List<RecommendationStat>? recommendationStats;
  final List<RatingDetail>? ratingDetails;
  final bool? goodQualityProduct;

  final int? sharedCount;
  //final List<comment_model.Comment>? comments;
  final List<ProductColor>? colors;
  Product({
    this.id,
    this.description,
    this.goodQualityProduct,
    this.descriptors,
    this.isActive,
    this.isRedeem,
    this.ownerType,
    this.ownerId,
    this.redeemPrice,
    this.buyersComment,
    this.seller,
    this.fqaQuestions,
    this.ratingDetails,
    this.recommendationStats,
    this.totalRating,
    this.isLiked,
    this.totalViews,
    this.sizeAnalysis,
    this.collectedAfterOrdering,
    this.countOfPieces,
    this.colors,
    this.syncColorImages,
    this.images,
    // this.variation,
    this.slug,
    this.shippingCostMultiplyWithQuantity,
    this.shippingCost,
    this.commentOffset,
    this.countOfLikes,
    this.sizes,
    this.hasDiscount,
    this.price,
    this.priceFormatted,
    this.offerPrice,
    this.offerPriceFormatted,
    this.maxAllowedQty,
    this.sharedCount,
    this.deliveryAt,
    this.boutique,
    this.availableQuantity,
    this.leftStock,
    this.labelNames,
    this.flashDealEndDate,
    this.commentsCount,
    this.shippingDays,
    this.isFeatured,
    this.sellerId,

    this.labels,
    //this.comments,
    required this.isProductNotifiedForUser,
    this.countryIsRestricted,
  });

  Product copyWith({
    int? id,
    dynamic description,
    bool? isRedeem,
    double? redeemPrice,
    dynamic model,
    dynamic features,
    String? slug,
    bool? isActive,
    List<ProductColor>? colors,
    List<Thumbnail>? images,
    List<SyncColorImageProduct>? syncColorImages,
    //   List<Variation>? variation,
    List<String>? sizes,
    bool? hasDiscount,
    bool? goodQualityProduct,
    bool? hasTax,
    String? priceFormatted,
    bool? isLiked,
    int? totalViews,
    double? totalRating,
    BuyersCommentModel? buyersComment,
    List<RatingDetail>? ratingDetails,
    List<RecommendationStat>? recommendationStats,
    SizeAnalysis? sizeAnalysis,
    FqaQuestions? fqaQuestions,
    double? price,
    double? offerPrice,
    String? offerPriceFormatted,
    String? ownerType,
    String? ownerId,
    String? deliveryAt,
    int? collectedAfterOrdering,
    String? tax,
    List<String>? labelNames,
    String? flashDealEndDate,
    int? countOfPieces,
    String? unitPrice,
    int? availableQuantity,
    int? leftStock,

    String? sellerId,
    int? shippingDays,
    BoutiqueForCart? boutique,
    List<dynamic>? commentOffset,
    int? countOfLikes,
    Seller? seller,
    Shop? shop,
    bool? isFavSeller,
    bool? shippingCostMultiplyWithQuantity,
    double? shippingCost,
    List<dynamic>? reviews,
    bool? hasWholeSale,
    dynamic wholeSaleLink,

    String? maxAllowedQty,
    List<DataDescriptor>? descriptors,
    List<Label>? labels,
    bool? isProductNotifiedForUser,
    bool? countryIsRestricted,
    // List<comment_model.Comment>? comments,
    int? commentsCount,
    int? sharedCount,
    bool? isFeatured,
  }) => Product(
    id: id ?? this.id,
    description: description ?? this.description,
    slug: slug ?? this.slug,
    isActive: isActive ?? this.isActive,
    // variation: variation ?? this.variation,
    sizes: sizes ?? this.sizes,
    hasDiscount: hasDiscount ?? this.hasDiscount,
    maxAllowedQty: maxAllowedQty ?? this.maxAllowedQty,
    buyersComment: buyersComment ?? this.buyersComment,
    fqaQuestions: fqaQuestions ?? this.fqaQuestions,
    deliveryAt: deliveryAt ?? this.deliveryAt,
    goodQualityProduct: goodQualityProduct ?? this.goodQualityProduct,
    shippingDays: shippingDays ?? this.shippingDays,
    isLiked: isLiked ?? this.isLiked,
    totalViews: totalViews ?? this.totalViews,
    sizeAnalysis: sizeAnalysis ?? this.sizeAnalysis,
    colors: colors ?? this.colors,
    isRedeem: isRedeem ?? this.isRedeem,
    redeemPrice: redeemPrice ?? this.redeemPrice,
    ratingDetails: ratingDetails ?? this.ratingDetails,
    recommendationStats: recommendationStats ?? this.recommendationStats,
    totalRating: totalRating ?? this.totalRating,
    syncColorImages: syncColorImages ?? this.syncColorImages,
    images: images ?? this.images,
    seller: seller ?? this.seller,
    availableQuantity: availableQuantity ?? this.availableQuantity,
    leftStock: leftStock ?? this.leftStock,
    shippingCostMultiplyWithQuantity:
        shippingCostMultiplyWithQuantity ??
        this.shippingCostMultiplyWithQuantity,
    shippingCost: shippingCost ?? this.shippingCost,
    price: price ?? this.price,
    priceFormatted: priceFormatted ?? this.priceFormatted,
    labelNames: labelNames ?? this.labelNames,
    sellerId: sellerId ?? this.sellerId,
    flashDealEndDate: flashDealEndDate ?? this.flashDealEndDate,
    offerPrice: offerPrice ?? this.offerPrice,
    offerPriceFormatted: offerPriceFormatted ?? this.offerPriceFormatted,
    collectedAfterOrdering:
        collectedAfterOrdering ?? this.collectedAfterOrdering,
    countOfLikes: countOfLikes ?? this.countOfLikes,

    sharedCount: sharedCount ?? this.sharedCount,
    countOfPieces: countOfPieces ?? this.countOfPieces,
    boutique: boutique ?? this.boutique,

    ownerType: ownerType ?? this.ownerType,
    ownerId: ownerId ?? this.ownerId,
    commentOffset: commentOffset ?? this.commentOffset,
    //comments: comments ?? this.comments,
    commentsCount: commentsCount ?? this.commentsCount,
    descriptors: descriptors ?? this.descriptors,
    labels: labels ?? this.labels,
    countryIsRestricted: countryIsRestricted ?? this.countryIsRestricted,
    isProductNotifiedForUser:
        isProductNotifiedForUser ?? this.isProductNotifiedForUser,
    isFeatured: isFeatured ?? this.isFeatured,
  );

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: int.tryParse(json["id"].toString()),
    description: json["description"],
    countOfPieces: json["count_of_pieces"],
    sizeAnalysis: json["size_analysis"] == null
        ? null
        : SizeAnalysis.fromJson(json["size_analysis"]),
    commentsCount: json["comments_count"],
    commentOffset: json["comment_offset"],
    seller: json["seller"] == null ? null : Seller.fromJson(json["seller"]),
    slug: json["slug"],
    shippingCostMultiplyWithQuantity:
        json["shipping_cost_multiply_with_quantity"],
    goodQualityProduct: json["good_quality_product"],
    shippingCost: double.tryParse(json["shipping_cost"].toString()),
    colors: json["colors"] == null
        ? []
        : List<ProductColor>.from(
            json["colors"]!.map((x) => ProductColor.fromJson(x)),
          ),
    syncColorImages: json["sync_color_images"] == null
        ? []
        : List<SyncColorImageProduct>.from(
            json["sync_color_images"]!.map(
              (x) => SyncColorImageProduct.fromJson(x),
            ),
          ),
    images: json["images"] == null
        ? []
        : List<Thumbnail>.from(
            json["images"]!.map(
              (x) => x is String
                  ? Thumbnail.fromJson({"file_path": x})
                  : Thumbnail.fromJson(x),
            ),
          ),
    boutique: json["boutique"] == null
        ? null
        : BoutiqueForCart.fromJson(json["boutique"]),
    collectedAfterOrdering: json["collected_after_ordering"],
    price: (json["price"] ?? 0).toDouble(),
    /*  comments: json["comments"] == null
          ? []
          : List<comment_model.Comment>.from(
              json["comments"]!.map((x) => comment_model.Comment.fromJson(x))),*/
    labelNames: json["label_names"] == null
        ? []
        : () {
            final data = json["label_names"];
            if (data is String) {
              // the API sometimes returns a JSON encoded string
              try {
                final list = (jsonDecode(data) as List<dynamic>?) ?? [];
                return list.map((x) => x.toString()).toList();
              } catch (_) {
                return <String>[];
              }
            } else if (data is List) {
              return List<String>.from(data.map((x) => x.toString()));
            }
            return <String>[];
          }(),
    flashDealEndDate: json["flash_deal_end_date"],
    priceFormatted: json["price_formatted"] ?? "",
    isLiked: json["is_liked"],
    totalViews: json["total_views"],
    offerPriceFormatted: json["offer_price_formatted"] ?? "",
    offerPrice: (json["offer_price"] ?? 0).toDouble(),
    ownerType: json["owner_type"],
    ownerId: json["owner_id"].toString(),
    sellerId: json["seller_id"] == null ? null : json["seller_id"].toString(),
    maxAllowedQty: json["max_allowed_qty"].toString(),
    countryIsRestricted: json["is_country_restricted"],
    isActive: json["is_active"],
    /* variation: json["variation"] == null
          ? []
          : List<Variation>.from(
              json["variation"]!.map((x) => Variation.fromJson(x))),*/
    sizes: json["sizes"] == null
        ? []
        : List<String>.from(json["sizes"]!.map((x) => x)),
    hasDiscount: json["has_discount"],
    isRedeem: json["is_redeem"],
    redeemPrice: (json["redeem_price"] ?? 0).toDouble(),
    deliveryAt: json["delivery_at"],
    ratingDetails: json["ratingDetails"] == null
        ? []
        : List<RatingDetail>.from(
            json["ratingDetails"]!.map((x) => RatingDetail.fromJson(x)),
          ),
    recommendationStats: json["recommendation_stats"] == null
        ? []
        : List<RecommendationStat>.from(
            json["recommendation_stats"]!.map(
              (x) => RecommendationStat.fromJson(x),
            ),
          ),
    totalRating: json["total_rating"]?.toDouble(),
    sharedCount: json["shared_count"],
    buyersComment: json["buyers_comment"] == null
        ? null
        : BuyersCommentModel.fromJson(json["buyers_comment"]),
    fqaQuestions: json["fqa_questions"] == null
        ? null
        : FqaQuestions.fromJson(json["fqa_questions"]),
    countOfLikes: json["count_of_likes"],
    availableQuantity: (json["available_quantity"] ?? 0).toInt(),
    leftStock: json["Left_stock"],
    // reviewsCount: json["reviews_count"],
    shippingDays: json["shipping_days"],
    isFeatured: json["is_featured"],

    // viewsCount: json["views_count"],
    descriptors: json["descriptors"] == null
        ? []
        : List<DataDescriptor>.from(
            json["descriptors"]!.map((x) => DataDescriptor.fromJson(x)),
          ),
    labels: json["labels"] == null
        ? []
        : List<Label>.from(json["labels"]!.map((x) => Label.fromJson(x))),
    isProductNotifiedForUser: json['is_product_notify_for_user'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "description": description,
    "is_active": isActive,
    "boutique": boutique?.toJson(),
    "is_redeem": isRedeem,
    "ratingDetails": ratingDetails == null
        ? []
        : List<dynamic>.from(ratingDetails!.map((x) => x.toJson())),
    "recommendation_stats": recommendationStats == null
        ? []
        : List<dynamic>.from(recommendationStats!.map((x) => x.toJson())),
    "total_rating": totalRating,
    "comments_count": commentsCount,
    "seller_id": sellerId,
    "buyers_comment": buyersComment?.toJson(),
    "fqa_questions": fqaQuestions?.toJson(),
    "good_quality_product": goodQualityProduct,
    "seller": seller?.toJson(),
    "redeem_price": redeemPrice,

    "sizes": sizes == null ? [] : List<dynamic>.from(sizes!.map((x) => x)),
    "has_discount": hasDiscount,
    /* "variation": variation == null
            ? []
            : List<dynamic>.from(variation!.map((x) => x.toJson())),*/
    "label_names": labelNames == null || labelNames == "[]"
        ? []
        : List<dynamic>.from(labelNames!.map((x) => x)),

    "flash_deal_end_date": flashDealEndDate,
    "collected_after_ordering": collectedAfterOrdering,
    "comment_offset": commentOffset,
    "size_analysis": sizeAnalysis?.toJson(),
    "owner_type": ownerType,
    "owner_id": ownerId,
    "delivery_at": deliveryAt,
    "slug": slug,
    "is_country_restricted": countryIsRestricted,
    "shipping_days": shippingDays,

    "count_of_likes": countOfLikes,
    "is_liked": isLiked,
    "total_views": totalViews,
    "available_quantity": availableQuantity,
    "count_of_pieces": countOfPieces,
    "price": price,
    "price_formatted": priceFormatted,
    "offer_price_formatted": offerPriceFormatted,
    "offer_price": offerPrice,
    "Left_stock": leftStock,
    /* "comments": comments == null
            ? []
            : List<dynamic>.from(comments!.map((x) => x.toJson())),*/
    "colors": colors == null
        ? []
        : List<dynamic>.from(colors!.map((x) => x.toJson())),
    "sync_color_images": syncColorImages == null
        ? []
        : List<dynamic>.from(syncColorImages!.map((x) => x.toJson())),
    "images": images == null
        ? []
        : List<dynamic>.from(images!.map((x) => x.toJson())),
    "shipping_cost_multiply_with_quantity": shippingCostMultiplyWithQuantity,

    "shipping_cost": shippingCost?.toDouble(),
    "max_allowed_qty": maxAllowedQty,
    "is_featured": isFeatured,
    "shared_count": sharedCount,

    // "views_count": viewsCount,
    "descriptors": descriptors == null
        ? []
        : List<dynamic>.from(descriptors!.map((x) => x.toJson())),
    "labels": labels == null
        ? []
        : List<dynamic>.from(labels!.map((x) => x.toJson())),
    "is_product_notify_for_user": isProductNotifiedForUser,
  };
}

class RatingDetail {
  final String? ratingGroup;
  final int? count;

  RatingDetail({this.ratingGroup, this.count});

  RatingDetail copyWith({String? ratingGroup, int? count}) => RatingDetail(
    ratingGroup: ratingGroup ?? this.ratingGroup,
    count: count ?? this.count,
  );

  factory RatingDetail.fromJson(Map<String, dynamic> json) => RatingDetail(
    ratingGroup: json["ratingGroup"].toString(),
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {"ratingGroup": ratingGroup, "count": count};
}

class BuyersCommentModel {
  final List<BuyersComment>? comments;
  final List<dynamic>? offset;
  final int? total;
  final List<String>? filtersKey;

  BuyersCommentModel({this.comments, this.offset, this.total, this.filtersKey});

  BuyersCommentModel copyWith({
    List<BuyersComment>? comments,
    List<dynamic>? offset,
    List<String>? filtersKey,
    int? total,
  }) => BuyersCommentModel(
    comments: comments ?? this.comments,
    offset: offset ?? this.offset,
    filtersKey: filtersKey ?? this.filtersKey,
    total: total ?? this.total,
  );

  factory BuyersCommentModel.fromJson(Map<String, dynamic> json) =>
      BuyersCommentModel(
        comments: json["comments"] == null
            ? []
            : List<BuyersComment>.from(
                json["comments"]!.map((x) => BuyersComment.fromJson(x)),
              ),
        offset: json["offset"],
        total: json["total"],
        filtersKey: json["filters_key"] == null
            ? []
            : List<String>.from(json["filters_key"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "comments": comments == null
        ? []
        : List<dynamic>.from(comments!.map((x) => x.toJson())),
    "offset": offset,
    "total": total,
    "filters_key": filtersKey == null
        ? []
        : List<dynamic>.from(filtersKey!.map((x) => x)),
  };
}

class SizeAnalysis {
  final double? smallPercentage;
  final double? largePercentage;
  final double? truePercentage;

  SizeAnalysis({
    this.smallPercentage,
    this.largePercentage,
    this.truePercentage,
  });

  SizeAnalysis copyWith({
    double? smallPercentage,
    double? largePercentage,
    double? truePercentage,
  }) => SizeAnalysis(
    smallPercentage: smallPercentage ?? this.smallPercentage,
    largePercentage: largePercentage ?? this.largePercentage,
    truePercentage: truePercentage ?? this.truePercentage,
  );

  factory SizeAnalysis.fromJson(Map<String, dynamic> json) => SizeAnalysis(
    smallPercentage: double.tryParse(json["small_percentage"].toString()),
    largePercentage: double.tryParse(json["large_percentage"].toString()),
    truePercentage: double.tryParse(json["true_percentage"].toString()),
  );

  Map<String, dynamic> toJson() => {
    "small_percentage": smallPercentage,
    "large_percentage": largePercentage,
    "true_percentage": truePercentage,
  };
}

class FqaQuestions {
  final List<FqaComment>? comments;
  final List<dynamic>? offset;
  final int? total;
  final List<String>? filtersKey;

  FqaQuestions({this.comments, this.offset, this.total, this.filtersKey});

  FqaQuestions copyWith({
    List<FqaComment>? comments,
    List<dynamic>? offset,
    int? total,
    List<String>? filtersKey,
  }) => FqaQuestions(
    comments: comments ?? this.comments,
    filtersKey: filtersKey ?? this.filtersKey,
    offset: offset ?? this.offset,
    total: total ?? this.total,
  );

  factory FqaQuestions.fromJson(Map<String, dynamic> json) => FqaQuestions(
    comments: json["comments"] == null
        ? []
        : List<FqaComment>.from(
            json["comments"]!.map((x) => FqaComment.fromJson(x)),
          ),
    offset: json["offset"],
    filtersKey: json["filters_key"] == null
        ? []
        : List<String>.from(json["filters_key"]!.map((x) => x)),
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "comments": comments == null
        ? []
        : List<dynamic>.from(comments!.map((x) => x.toJson())),
    "offset": offset,
    "filters_key": filtersKey == null
        ? []
        : List<dynamic>.from(filtersKey!.map((x) => x)),
    "total": total,
  };
}

class ChoiceOption {
  final String? name;
  final String? title;
  final List<Options>? options;

  ChoiceOption({this.name, this.title, this.options});

  ChoiceOption copyWith({
    String? name,
    String? title,
    List<Options>? options,
  }) => ChoiceOption(
    name: name ?? this.name,
    title: title ?? this.title,
    options: options ?? this.options,
  );

  factory ChoiceOption.fromJson(Map<String, dynamic> json) => ChoiceOption(
    name: json["name"],
    title: json["title"],
    options: json["options"] == null
        ? []
        : List<Options>.from(json["options"]!.map((x) => Options.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "title": title,
    "options": options == null
        ? []
        : List<dynamic>.from(options!.map((x) => x.toJson())),
  };
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
    filePath: json["file_path"]?.contains("cloudinary")
        ? json["file_path"]
        : ("${dotenv.env['Images_Url']}" + (json["file_path"])),
    originalWidth: json["original_width"],
    originalHeight: json["original_height"],
  );

  Map<String, dynamic> toJson() => {
    "file_path": filePath,
    "original_width": originalWidth,
    "original_height": originalHeight,
  };
}

class BoutiqueForCart {
  final int? id;
  final Icon? icon;

  BoutiqueForCart({this.id, this.icon});

  BoutiqueForCart copyWith({int? id, Icon? icon}) =>
      BoutiqueForCart(id: id ?? this.id, icon: icon ?? this.icon);

  factory BoutiqueForCart.fromJson(Map<String, dynamic> json) =>
      BoutiqueForCart(
        id: json["id"],
        icon: json["icon"] == null ? null : Icon.fromJson(json["icon"]),
      );

  Map<String, dynamic> toJson() => {"id": id, "icon": icon?.toJson()};
}

class Label {
  final String? label;
  final Icon? icon;

  Label({this.label, this.icon});

  Label copyWith({String? label, Icon? icon}) =>
      Label(label: label ?? this.label, icon: icon ?? this.icon);

  factory Label.fromJson(Map<String, dynamic> json) => Label(
    label: json["label"],
    icon: json["icon"] == null ? null : Icon.fromJson(json["icon"]),
  );

  Map<String, dynamic> toJson() => {"label": label, "icon": icon?.toJson()};
}

class Options {
  final String? name;
  final String? option;

  Options({this.name, this.option});

  Options copyWith({String? name, String? option}) =>
      Options(name: name ?? this.name, option: option ?? this.option);

  factory Options.fromJson(Map<String, dynamic> json) => Options(
    name: json["name"] == null
        ? null
        : json["name"].toString().replaceAll("-", "_"),
    option: json["option"] == null
        ? null
        : json["option"].toString().replaceAll("-", "_"),
  );

  Map<String, dynamic> toJson() => {"name": name, "option": option};
}

class Seller {
  final dynamic name;
  final dynamic fName;
  final dynamic lName;
  final dynamic email;
  final dynamic gender;
  final dynamic birthdate;
  final dynamic review;
  final dynamic image;

  Seller({
    this.name,
    this.fName,
    this.lName,
    this.email,
    this.gender,
    this.birthdate,
    this.review,
    this.image,
  });

  Seller copyWith({
    dynamic name,
    dynamic fName,
    dynamic lName,
    dynamic email,
    dynamic gender,
    dynamic birthdate,
    dynamic review,
    dynamic image,
  }) => Seller(
    name: name ?? this.name,
    fName: fName ?? this.fName,
    lName: lName ?? this.lName,
    email: email ?? this.email,
    gender: gender ?? this.gender,
    birthdate: birthdate ?? this.birthdate,
    review: review ?? this.review,
    image: image ?? this.image,
  );

  factory Seller.fromJson(Map<String, dynamic> json) => Seller(
    name: json["name"],
    fName: json["f_name"],
    lName: json["l_name"],
    email: json["email"],
    gender: json["gender"],
    birthdate: json["birthdate"],
    review: json["review"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "f_name": fName,
    "l_name": lName,
    "email": email,
    "gender": gender,
    "birthdate": birthdate,
    "review": review,
    "image": image,
  };
}

class RecommendationStat {
  final String? category;
  final int? count;
  final String? percentage;

  RecommendationStat({this.category, this.count, this.percentage});

  RecommendationStat copyWith({
    String? category,
    int? count,
    String? percentage,
  }) => RecommendationStat(
    category: category ?? this.category,
    count: count ?? this.count,
    percentage: percentage ?? this.percentage,
  );

  factory RecommendationStat.fromJson(Map<String, dynamic> json) =>
      RecommendationStat(
        category: json["category"],
        count: json["count"],
        percentage: json["percentage"],
      );

  Map<String, dynamic> toJson() => {
    "category": category,
    "count": count,
    "percentage": percentage,
  };
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

class Variation {
  final String? id;
  final String? size;
  final VariationColor? color;
  final String? type;
  final double? price;
  final double? offerPrice;
  final double? luckPrice;
  final String? sku;
  final int? qty;

  Variation({
    this.id,
    this.size,
    this.color,
    this.type,
    this.price,
    this.offerPrice,
    this.luckPrice,
    this.sku,
    this.qty,
  });

  Variation copyWith({
    String? id,
    String? size,
    VariationColor? color,
    String? type,
    double? price,
    double? offerPrice,
    double? luckPrice,
    String? sku,
    int? qty,
  }) => Variation(
    id: id ?? this.id,
    size: size ?? this.size,
    color: color ?? this.color,
    type: type ?? this.type,
    price: price ?? this.price,
    offerPrice: offerPrice ?? this.offerPrice,
    luckPrice: luckPrice ?? this.luckPrice,
    sku: sku ?? this.sku,
    qty: qty ?? this.qty,
  );

  factory Variation.fromJson(Map<String, dynamic> json) => Variation(
    id: json["id"],
    size: json["size"],
    color: json["color"] == null
        ? null
        : VariationColor.fromJson(json["color"]),
    type: json["type"],
    price: double.tryParse(json["price"].toString()),
    offerPrice: double.tryParse(json["offer_price"].toString()),
    luckPrice: double.tryParse(json["luck_price"].toString()),
    sku: json["sku"],
    qty: json["qty"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "size": size,
    "color": color?.toJson(),
    "type": type,
    "price": price,
    "offer_price": offerPrice,
    "luck_price": luckPrice,
    "sku": sku,
    "qty": qty,
  };
}

class VariationColor {
  final String? name;
  final String? code;

  VariationColor({this.name, this.code});

  VariationColor copyWith({String? name, String? code}) =>
      VariationColor(name: name ?? this.name, code: code ?? this.code);

  factory VariationColor.fromJson(Map<String, dynamic> json) =>
      VariationColor(name: json["name"], code: json["code"]);

  Map<String, dynamic> toJson() => {"name": name, "code": code};
}

class DataDescriptor {
  final DescriptorGroupClass? descriptorGroup;
  final List<PurpleDescriptor>? descriptors;

  DataDescriptor({this.descriptorGroup, this.descriptors});

  DataDescriptor copyWith({
    DescriptorGroupClass? descriptorGroup,
    List<PurpleDescriptor>? descriptors,
  }) => DataDescriptor(
    descriptorGroup: descriptorGroup ?? this.descriptorGroup,
    descriptors: descriptors ?? this.descriptors,
  );

  factory DataDescriptor.fromJson(Map<String, dynamic> json) => DataDescriptor(
    descriptorGroup: json["descriptor_group"] == null
        ? null
        : DescriptorGroupClass.fromJson(json["descriptor_group"]),
    descriptors: json["descriptors"] == null
        ? []
        : List<PurpleDescriptor>.from(
            json["descriptors"]!.map((x) => PurpleDescriptor.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "descriptor_group": descriptorGroup?.toJson(),
    "descriptors": descriptors == null
        ? []
        : List<dynamic>.from(descriptors!.map((x) => x.toJson())),
  };
}

class DescriptorGroupClass {
  final String? name;
  final String? icon;
  final String? description;

  DescriptorGroupClass({this.name, this.icon, this.description});

  DescriptorGroupClass copyWith({
    String? name,
    String? icon,
    String? description,
  }) => DescriptorGroupClass(
    name: name ?? this.name,
    icon: icon ?? this.icon,
    description: description ?? this.description,
  );

  factory DescriptorGroupClass.fromJson(Map<String, dynamic> json) =>
      DescriptorGroupClass(
        name: json["name"],
        icon: json["icon"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "icon": icon,
    "description": description,
  };
}

class PurpleDescriptor {
  final DescriptorGroupClass? descriptor;
  final String? value;

  PurpleDescriptor({this.descriptor, this.value});

  PurpleDescriptor copyWith({
    DescriptorGroupClass? descriptor,
    String? value,
  }) => PurpleDescriptor(
    descriptor: descriptor ?? this.descriptor,
    value: value ?? this.value,
  );

  factory PurpleDescriptor.fromJson(Map<String, dynamic> json) =>
      PurpleDescriptor(
        descriptor: json["descriptor"] == null
            ? null
            : DescriptorGroupClass.fromJson(json["descriptor"]),
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
    "descriptor": descriptor?.toJson(),
    "value": value,
  };
}
