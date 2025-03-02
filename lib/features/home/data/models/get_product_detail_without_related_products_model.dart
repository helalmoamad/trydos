// To parse this JSON data, do
//
//     final getProductDetailWithoutRelatedProductsModel = getProductDetailWithoutRelatedProductsModelFromJson(jsonString);

import 'dart:convert';

GetProductDetailWithoutRelatedProductsModel
    getProductDetailWithoutRelatedProductsModelFromJson(String str) =>
        GetProductDetailWithoutRelatedProductsModel.fromJson(json.decode(str));

String getProductDetailWithoutRelatedProductsModelToJson(
        GetProductDetailWithoutRelatedProductsModel data) =>
    json.encode(data.toJson());

class GetProductDetailWithoutRelatedProductsModel {
  final String? message;
  final Product? product;

  GetProductDetailWithoutRelatedProductsModel({
    this.message,
    this.product,
  });

  GetProductDetailWithoutRelatedProductsModel copyWith({
    String? message,
    Product? data,
  }) =>
      GetProductDetailWithoutRelatedProductsModel(
        message: message ?? this.message,
        product: data ?? this.product,
      );

  factory GetProductDetailWithoutRelatedProductsModel.fromJson(
          Map<String, dynamic> json) =>
      GetProductDetailWithoutRelatedProductsModel(
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

  final bool? inStock;
  final List<Variation>? variation;
  final List<ChoiceOption>? choiceOptions;
  final String? maxAllowedQty;
  final bool? hasDiscount;

  final String? deliveryAt;

  final String? slugEnTopic;
  final int? currentStock;
  final int? leftStock;
  final int? reviewsCount;
  final bool? shippingCostMultiplyWithQuantity;
  final double? shippingCost;
  final BoutiqueForCart? boutique;

  final bool? isLiked;
  final int? countOfLikes;
  final int? collectedAfterOrdering;
  final int? countOfPieces;

  final int? viewsCount;
  final List<DataDescriptor>? descriptors;
  final List<Label>? labels;
  final int? shippingDays;
  final bool isProductNotifiedForUser;
  Product({
    this.id,
    this.description,
    this.descriptors,
    this.inStock,
    this.collectedAfterOrdering,
    this.countOfPieces,
    this.variation,
    this.isLiked,
    this.slugEnTopic,
    this.shippingCostMultiplyWithQuantity,
    this.shippingCost,
    this.countOfLikes,
    this.choiceOptions,
    this.hasDiscount,
    this.maxAllowedQty,
    this.deliveryAt,
    this.boutique,
    this.currentStock,
    this.leftStock,
    this.shippingDays,
    this.reviewsCount,
    this.viewsCount,
    this.labels,
    required this.isProductNotifiedForUser,
  });

  Product copyWith({
    int? id,
    dynamic description,
    dynamic model,
    dynamic features,
    String? slugEnTopic,
    bool? inStock,
    List<Variation>? variation,
    List<ChoiceOption>? choiceOptions,
    bool? hasDiscount,
    bool? hasTax,
    String? deliveryAt,
    int? collectedAfterOrdering,
    String? tax,
    int? countOfPieces,
    String? unitPrice,
    int? currentStock,
    int? leftStock,
    int? reviewsCount,
    dynamic sellerId,
    int? shippingDays,
    BoutiqueForCart? boutique,
    bool? isLiked,
    int? countOfLikes,
    Seller? seller,
    Shop? shop,
    bool? isFavSeller,
    bool? shippingCostMultiplyWithQuantity,
    double? shippingCost,
    List<dynamic>? reviews,
    bool? hasWholeSale,
    dynamic wholeSaleLink,
    int? viewsCount,
    String? maxAllowedQty,
    List<DataDescriptor>? descriptors,
    List<Label>? labels,
    bool? isProductNotifiedForUser,
  }) =>
      Product(
        id: id ?? this.id,
        description: description ?? this.description,
        slugEnTopic: slugEnTopic ?? this.slugEnTopic,
        inStock: inStock ?? this.inStock,
        variation: variation ?? this.variation,
        choiceOptions: choiceOptions ?? this.choiceOptions,
        hasDiscount: hasDiscount ?? this.hasDiscount,
        maxAllowedQty: maxAllowedQty ?? this.maxAllowedQty,
        deliveryAt: deliveryAt ?? this.deliveryAt,
        shippingDays: shippingDays ?? this.shippingDays,
        currentStock: currentStock ?? this.currentStock,
        leftStock: leftStock ?? this.leftStock,
        isLiked: isLiked ?? this.isLiked,
        shippingCostMultiplyWithQuantity: shippingCostMultiplyWithQuantity ??
            this.shippingCostMultiplyWithQuantity,
        shippingCost: shippingCost ?? this.shippingCost,
        collectedAfterOrdering:
            collectedAfterOrdering ?? this.collectedAfterOrdering,
        countOfLikes: countOfLikes ?? this.countOfLikes,
        reviewsCount: reviewsCount ?? this.reviewsCount,
        countOfPieces: countOfPieces ?? this.countOfPieces,
        boutique: boutique ?? this.boutique,
        viewsCount: viewsCount ?? this.viewsCount,
        descriptors: descriptors ?? this.descriptors,
        labels: labels ?? this.labels,
        isProductNotifiedForUser:
            isProductNotifiedForUser ?? this.isProductNotifiedForUser,
      );

  factory Product.fromJson(Map<String, dynamic> json) => Product(
      id: json["id"],
      description: json["description"],
      countOfPieces: json["count_of_pieces"],
      slugEnTopic: json["slug_en_topic"],
      shippingCostMultiplyWithQuantity:
          json["shipping_cost_multiply_with_quantity"],
      shippingCost: double.tryParse(json["shipping_cost"].toString()),
      boutique: json["boutique"] == null
          ? null
          : BoutiqueForCart.fromJson(json["boutique"]),
      collectedAfterOrdering: json["collected_after_ordering"],
      maxAllowedQty: json["max_allowed_qty"].toString(),
      inStock: json["in_stock"],
      variation: json["variation"] == null
          ? []
          : List<Variation>.from(
              json["variation"]!.map((x) => Variation.fromJson(x))),
      choiceOptions: json["choice_options"] == null
          ? []
          : List<ChoiceOption>.from(
              json["choice_options"]!.map((x) => ChoiceOption.fromJson(x))),
      hasDiscount: json["has_discount"],
      deliveryAt: json["delivery_at"],
      isLiked: json["is_liked"],
      countOfLikes: json["count_of_likes"],
      currentStock: json["current_stock"]?.toInt(),
      leftStock: json["Left_stock"],
      // reviewsCount: json["reviews_count"],
      shippingDays: json["shipping_days"],
      // viewsCount: json["views_count"],
      descriptors: json["descriptors"] == null
          ? []
          : List<DataDescriptor>.from(
              json["descriptors"]!.map((x) => DataDescriptor.fromJson(x))),
      labels: json["labels"] == null
          ? []
          : List<Label>.from(json["labels"]!.map((x) => Label.fromJson(x))),
      isProductNotifiedForUser: json['is_product_notify_for_user'] ?? false);

  Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "in_stock": inStock,
        "boutique": boutique?.toJson(),
        "variation": variation == null
            ? []
            : List<dynamic>.from(variation!.map((x) => x.toJson())),
        "choice_options": choiceOptions == null
            ? []
            : List<dynamic>.from(choiceOptions!.map((x) => x.toJson())),
        "has_discount": hasDiscount,
        "collected_after_ordering": collectedAfterOrdering,
        "delivery_at": deliveryAt,
        "slug_en_topic": slugEnTopic,
        "shipping_days": shippingDays,
        "is_liked": isLiked,
        "count_of_likes": countOfLikes,
        "current_stock": currentStock,
        "count_of_pieces": countOfPieces,
        "Left_stock": leftStock,
        "shipping_cost_multiply_with_quantity":
            shippingCostMultiplyWithQuantity,
        "shipping_cost": shippingCost?.toDouble(),
        "max_allowed_qty": maxAllowedQty,
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

class ChoiceOption {
  final String? name;
  final String? title;
  final List<Option>? options;

  ChoiceOption({
    this.name,
    this.title,
    this.options,
  });

  ChoiceOption copyWith({
    String? name,
    String? title,
    List<Option>? options,
  }) =>
      ChoiceOption(
        name: name ?? this.name,
        title: title ?? this.title,
        options: options ?? this.options,
      );

  factory ChoiceOption.fromJson(Map<String, dynamic> json) => ChoiceOption(
        name: json["name"],
        title: json["title"],
        options: json["options"] == null
            ? []
            : List<Option>.from(
                json["options"]!.map((x) => Option.fromJson(x))),
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

  Icon({
    this.filePath,
    this.originalWidth,
    this.originalHeight,
  });

  Icon copyWith({
    String? filePath,
    String? originalWidth,
    String? originalHeight,
  }) =>
      Icon(
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

class BoutiqueForCart {
  final int? id;
  final Icon? icon;

  BoutiqueForCart({
    this.id,
    this.icon,
  });

  BoutiqueForCart copyWith({
    int? id,
    Icon? icon,
  }) =>
      BoutiqueForCart(
        id: id ?? this.id,
        icon: icon ?? this.icon,
      );

  factory BoutiqueForCart.fromJson(Map<String, dynamic> json) =>
      BoutiqueForCart(
        id: json["id"],
        icon: json["icon"] == null ? null : Icon.fromJson(json["icon"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "icon": icon?.toJson(),
      };
}

class Label {
  final String? label;
  final Icon? icon;

  Label({
    this.label,
    this.icon,
  });

  Label copyWith({
    String? label,
    Icon? icon,
  }) =>
      Label(
        label: label ?? this.label,
        icon: icon ?? this.icon,
      );

  factory Label.fromJson(Map<String, dynamic> json) => Label(
        label: json["label"],
        icon: json["icon"] == null ? null : Icon.fromJson(json["icon"]),
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "icon": icon?.toJson(),
      };
}

class Option {
  final String? name;
  final String? option;

  Option({
    this.name,
    this.option,
  });

  Option copyWith({
    String? name,
    String? option,
  }) =>
      Option(
        name: name ?? this.name,
        option: option ?? this.option,
      );

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        name: json["name"],
        option: json["option"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "option": option,
      };
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
  }) =>
      Seller(
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

class Shop {
  final String? image;
  final String? name;

  Shop({
    this.image,
    this.name,
  });

  Shop copyWith({
    String? image,
    String? name,
  }) =>
      Shop(
        image: image ?? this.image,
        name: name ?? this.name,
      );

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        image: json["image"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "name": name,
      };
}

class Variation {
  final bool variantNotifyForUser;
  final String? type;
  final double? price;
  final String? priceFormated;
  final double? offerPrice;
  final String? offerPriceFormated;
  final String? sku;
  final int? qty;

  Variation({
    required this.variantNotifyForUser,
    this.type,
    this.price,
    this.priceFormated,
    this.offerPrice,
    this.offerPriceFormated,
    this.sku,
    this.qty,
  });

  Variation copyWith({
    bool? variantNotifyForUser,
    String? type,
    double? price,
    String? priceFormated,
    double? offerPrice,
    String? offerPriceFormated,
    String? sku,
    int? qty,
  }) =>
      Variation(
        variantNotifyForUser: variantNotifyForUser ?? this.variantNotifyForUser,
        type: type ?? this.type,
        price: price ?? this.price,
        priceFormated: priceFormated ?? this.priceFormated,
        offerPrice: offerPrice ?? this.offerPrice,
        offerPriceFormated: offerPriceFormated ?? this.offerPriceFormated,
        sku: sku ?? this.sku,
        qty: qty ?? this.qty,
      );

  factory Variation.fromJson(Map<String, dynamic> json) => Variation(
        variantNotifyForUser: json["variant_notify_for_user"] ?? false,
        type: json["type"],
        price: json["price"]?.toDouble(),
        priceFormated: json["price_formated"],
        offerPrice: json["offer_price"]?.toDouble(),
        offerPriceFormated: json["offer_price_formated"],
        sku: json["sku"],
        qty: json["qty"],
      );

  Map<String, dynamic> toJson() => {
        "variant_notify_for_user": variantNotifyForUser,
        "type": type,
        "price": price,
        "price_formated": priceFormated,
        "offer_price": offerPrice,
        "offer_price_formated": offerPriceFormated,
        "sku": sku,
        "qty": qty,
      };
}

class DataDescriptor {
  final DescriptorGroupClass? descriptorGroup;
  final List<PurpleDescriptor>? descriptors;

  DataDescriptor({
    this.descriptorGroup,
    this.descriptors,
  });

  DataDescriptor copyWith({
    DescriptorGroupClass? descriptorGroup,
    List<PurpleDescriptor>? descriptors,
  }) =>
      DataDescriptor(
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
                json["descriptors"]!.map((x) => PurpleDescriptor.fromJson(x))),
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

  DescriptorGroupClass({
    this.name,
    this.icon,
    this.description,
  });

  DescriptorGroupClass copyWith({
    String? name,
    String? icon,
    String? description,
  }) =>
      DescriptorGroupClass(
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

  PurpleDescriptor({
    this.descriptor,
    this.value,
  });

  PurpleDescriptor copyWith({
    DescriptorGroupClass? descriptor,
    String? value,
  }) =>
      PurpleDescriptor(
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
