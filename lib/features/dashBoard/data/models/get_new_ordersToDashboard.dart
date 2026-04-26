class NewOrdersResponse {
  final bool isSuccessful;
  final bool hasContent;
  final int code;
  final String message;
  final String? detailedError;
  final OrdersData data;

  NewOrdersResponse({
    required this.isSuccessful,
    required this.hasContent,
    required this.code,
    required this.message,
    this.detailedError,
    required this.data,
  });

  factory NewOrdersResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return NewOrdersResponse(
      isSuccessful: json['isSuccessful'] ?? false,
      hasContent: json['hasContent'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      detailedError: json['detailed_error'],
      data: rawData is Map<String, dynamic>
          ? OrdersData.fromJson(rawData)
          : OrdersData.empty(),
    );
  }
}

class OrdersData {
  final List<UserOrderNew> orders;
  final newUserAbilities userAbilities;
  final newMeta meta;

  OrdersData({
    required this.orders,
    required this.userAbilities,
    required this.meta,
  });

  factory OrdersData.empty() {
    return OrdersData(
      orders: const [],
      userAbilities: newUserAbilities.empty(),
      meta: newMeta.empty(),
    );
  }

  factory OrdersData.fromJson(Map<String, dynamic> json) {
    return OrdersData(
      orders:
          (json['orders'] as List<dynamic>?)
              ?.map((e) => UserOrderNew.fromJson(e))
              .toList() ??
          [],
      userAbilities: newUserAbilities.fromJson(json['user_abilities'] ?? {}),
      meta: newMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class UserOrderNew {
  final int id;
  final String orderStatus;
  final List<OrderDetail> details;
  final double orderAmount;
  final CreatedAt createdAt;
  final int items;
  final int remainingInMinutes;
  final List<String> availableOrderStatusChange;

  UserOrderNew({
    required this.id,
    required this.orderStatus,
    required this.details,
    required this.orderAmount,
    required this.createdAt,
    required this.items,
    required this.remainingInMinutes,
    required this.availableOrderStatusChange,
  });

  factory UserOrderNew.fromJson(Map<String, dynamic> json) {
    return UserOrderNew(
      id: json['id'] ?? 0,
      orderStatus: json['order_status'] ?? '',
      details:
          (json['details'] as List<dynamic>?)
              ?.map((e) => OrderDetail.fromJson(e))
              .toList() ??
          [],

      orderAmount: (json['order_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: CreatedAt.fromJson(json['created_at'] ?? {}),
      items: json['items'] ?? 0,
      remainingInMinutes: json['remaining_in_minutes'] ?? 0,
      availableOrderStatusChange:
          (json['available_order_status_change'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class OrderDetail {
  final int id;
  final int orderId;
  final String cartImage;
  final String brandIcon;
  final int qty;
  final double unitPrice;
  final bool isConfirm;
  final bool isPacked;
  final String productName;
  final String color;
  final String size;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.cartImage,
    required this.brandIcon,
    required this.qty,
    required this.unitPrice,
    required this.isConfirm,
    required this.isPacked,
    required this.productName,
    required this.color,
    required this.size,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      cartImage: json['cart_image'] ?? '',
      brandIcon: json['brand_icon'] ?? '',
      qty: json['qty'] ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      isConfirm: json['is_confirm'] ?? false,
      isPacked: json['is_packed'] ?? false,
      productName: json['product_name'] ?? '',
      color: json['color'] ?? '',
      size: json['size'] ?? '',
    );
  }
}

class CreatedAt {
  final String date;
  final String time;

  CreatedAt({required this.date, required this.time});

  factory CreatedAt.fromJson(Map<String, dynamic> json) {
    return CreatedAt(date: json['date'] ?? '', time: json['time'] ?? '');
  }
}

class newUserAbilities {
  final List<String> changeOrderStatus;

  newUserAbilities({required this.changeOrderStatus});

  factory newUserAbilities.empty() {
    return newUserAbilities(changeOrderStatus: const []);
  }

  factory newUserAbilities.fromJson(Map<String, dynamic> json) {
    return newUserAbilities(
      changeOrderStatus:
          (json['change_order_status'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class newMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;
  final bool hasMorePages;
  final String? nextPageUrl;
  final String? prevPageUrl;

  newMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
    required this.hasMorePages,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory newMeta.empty() {
    return newMeta(
      currentPage: 0,
      lastPage: 0,
      perPage: 0,
      total: 0,
      from: 0,
      to: 0,
      hasMorePages: false,
    );
  }

  factory newMeta.fromJson(Map<String, dynamic> json) {
    return newMeta(
      currentPage: json['current_page'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      perPage: json['per_page'] ?? 0,
      total: json['total'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
      hasMorePages: json['has_more_pages'] ?? false,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}
