import 'dart:convert';

class GetUserNotificationsModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String? message;
  final dynamic detailedError;
  final GetUserNotificationsDataModel? data;

  GetUserNotificationsModel({
    this.isSuccessful,
    this.hasContent,
    this.code,
    this.message,
    this.detailedError,
    this.data,
  });

  factory GetUserNotificationsModel.fromJson(Map<String, dynamic> json) {
    return GetUserNotificationsModel(
      isSuccessful: json['isSuccessful'] ?? false,
      hasContent: json['hasContent'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      detailedError: json['detailed_error'],
      data: json['data'] == null
          ? null
          : GetUserNotificationsDataModel.fromJson(json['data']),
    );
  }

  GetUserNotificationsModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    GetUserNotificationsDataModel? data,
  }) {
    return GetUserNotificationsModel(
      isSuccessful: isSuccessful ?? this.isSuccessful,
      hasContent: hasContent ?? this.hasContent,
      code: code ?? this.code,
      message: message ?? this.message,
      detailedError: detailedError ?? this.detailedError,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() => {
        'isSuccessful': isSuccessful,
        'hasContent': hasContent,
        'code': code,
        'message': message,
        'detailed_error': detailedError,
        'data': data?.toJson(),
      };
}

class GetUserNotificationsDataModel {
  int? currentPage;
  List<NotificationItemModel>? notifications;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;

  GetUserNotificationsDataModel({
    required this.currentPage,
    required this.notifications,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
  });

  factory GetUserNotificationsDataModel.fromJson(Map<String, dynamic> json) {
    return GetUserNotificationsDataModel(
      currentPage: json['current_page'] ?? 0,
      notifications: json['data'] == null
          ? []
          : (json['data'] as List)
              .map((e) => NotificationItemModel.fromJson(e))
              .toList(),
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      lastPageUrl: json['last_page_url'] ?? '',
    );
  }

  GetUserNotificationsDataModel copyWith({
    int? currentPage,
    List<NotificationItemModel>? notifications,
    String? firstPageUrl,
    int? from,
    int? lastPage,
    String? lastPageUrl,
  }) {
    return GetUserNotificationsDataModel(
      currentPage: currentPage ?? this.currentPage,
      notifications: notifications ?? this.notifications,
      firstPageUrl: firstPageUrl ?? this.firstPageUrl,
      from: from ?? this.from,
      lastPage: lastPage ?? this.lastPage,
      lastPageUrl: lastPageUrl ?? this.lastPageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'data': notifications?.map((e) => e.toJson()).toList(),
        'first_page_url': firstPageUrl,
        'from': from,
        'last_page': lastPage,
        'last_page_url': lastPageUrl,
      };
}

class NotificationItemModel {
  int? id;
  int? userId;
  String? title;
  String? descriptionToHandleNotification;
  int? notificationTypeId;
  String? body;
  NotificationDescriptionModel? description;
  int? isWatched;
  int? isPublic;

  NotificationItemModel({
    this.id,
    this.userId,
    this.title,
    this.descriptionToHandleNotification,
    this.notificationTypeId,
    this.body,
    this.description,
    this.isWatched,
    this.isPublic,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      notificationTypeId: json['notification_type_id'] ?? 0,
      body: json['body'] ?? '',
      descriptionToHandleNotification: json['description'].toString(),
      description: json['description'] == null
          ? null
          : NotificationDescriptionModel.fromJson(
              jsonDecode(json['description'])),
      isWatched: json['is_watched'] ?? 0,
      isPublic: json['is_public'] ?? 0,
    );
  }

  NotificationItemModel copyWith({
    int? id,
    int? userId,
    String? title,
    int? notificationTypeId,
    String? descriptionToHandleNotification,
    String? body,
    NotificationDescriptionModel? description,
    int? isWatched,
    int? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      descriptionToHandleNotification: descriptionToHandleNotification ??
          this.descriptionToHandleNotification,
      title: title ?? this.title,
      notificationTypeId: notificationTypeId ?? this.notificationTypeId,
      body: body ?? this.body,
      description: description ?? this.description,
      isWatched: isWatched ?? this.isWatched,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'notification_type_id': notificationTypeId,
        'body': body,
        'description': jsonEncode(description?.toJson()),
        'is_watched': isWatched,
        "descriptionToHandleNotification": descriptionToHandleNotification,
        'is_public': isPublic,
      };
}

class Banner {
  final String? filePath;
  final String? originalWidth;
  final String? originalHeight;

  Banner({
    this.filePath,
    this.originalWidth,
    this.originalHeight,
  });

  Banner copyWith({
    String? filePath,
    String? originalWidth,
    String? originalHeight,
  }) =>
      Banner(
        filePath: filePath ?? this.filePath,
        originalWidth: originalWidth ?? this.originalWidth,
        originalHeight: originalHeight ?? this.originalHeight,
      );

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
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

class NotificationDescriptionModel {
  String? type;
  String? showedType;
  String? description;
  String? productName;
  String? productSlug;
  String? variant;
  String? image;
  String? customerName;
  int? cartId;
  int? timeLeftInMinutes;
  String? orderGroupId;
  int? userId;
  List<Banner>? banner;

  NotificationDescriptionModel({
    this.type,
    this.showedType,
    this.description,
    this.productName,
    this.productSlug,
    this.variant,
    this.image,
    this.customerName,
    this.cartId,
    this.timeLeftInMinutes,
    this.orderGroupId,
    this.banner,
    this.userId,
  });

  factory NotificationDescriptionModel.fromJson(Map<String, dynamic> json) {
    return NotificationDescriptionModel(
      type: json['type'] ?? '',
      showedType: json['showed_type'] ?? '',
      description: json['description'] ?? '',
      banner: json["banner"] == null
          ? []
          : List<Banner>.from(json["banner"]!.map((x) => Banner.fromJson(x))),
      productName: json['product_name'] ?? '',
      productSlug: json['product_slug'] ?? '',
      variant: json['variant'] ?? '',
      image: json['image'] ?? '',
      customerName: json['customer_name'] ?? '',
      cartId: json['cart_id'] ?? 0,
      timeLeftInMinutes: json['time_left_in_minutes'] ?? 0,
      orderGroupId: json['order_group_id'] ?? '',
      userId: json['user_id'] ?? 0,
    );
  }

  NotificationDescriptionModel copyWith({
    String? type,
    String? showedType,
    String? description,
    String? productName,
    String? productSlug,
    String? variant,
    String? image,
    String? customerName,
    List<Banner>? banner,
    int? cartId,
    int? timeLeftInMinutes,
    String? orderGroupId,
    int? userId,
  }) {
    return NotificationDescriptionModel(
      type: type ?? this.type,
      showedType: showedType ?? this.showedType,
      description: description ?? this.description,
      banner: banner ?? this.banner,
      productName: productName ?? this.productName,
      productSlug: productSlug ?? this.productSlug,
      variant: variant ?? this.variant,
      image: image ?? this.image,
      customerName: customerName ?? this.customerName,
      cartId: cartId ?? this.cartId,
      timeLeftInMinutes: timeLeftInMinutes ?? this.timeLeftInMinutes,
      orderGroupId: orderGroupId ?? this.orderGroupId,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'showed_type': showedType,
        'description': description,
        'product_name': productName,
        'product_slug': productSlug,
        "banner": banner == null
            ? []
            : List<dynamic>.from(banner!.map((x) => x.toJson())),
        'variant': variant,
        'image': image,
        'customer_name': customerName,
        'cart_id': cartId,
        'time_left_in_minutes': timeLeftInMinutes,
        'order_group_id': orderGroupId,
        'user_id': userId,
      };
}
