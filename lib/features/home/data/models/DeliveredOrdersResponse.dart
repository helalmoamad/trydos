class DeliveredOrdersResponse {
  final bool isSuccessful;
  final bool hasContent;
  final int code;
  final String message;
  final String? detailedError;
  final DeliveredOrdersData data;

  DeliveredOrdersResponse({
    required this.isSuccessful,
    required this.hasContent,
    required this.code,
    required this.message,
    required this.detailedError,
    required this.data,
  });

  factory DeliveredOrdersResponse.fromJson(Map<String, dynamic> json) {
    return DeliveredOrdersResponse(
      isSuccessful: json['isSuccessful'] ?? false,
      hasContent: json['hasContent'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      detailedError: json['detailed_error'],
      data: DeliveredOrdersData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccessful': isSuccessful,
      'hasContent': hasContent,
      'code': code,
      'message': message,
      'detailed_error': detailedError,
      'data': data.toJson(),
    };
  }
}

class DeliveredOrdersData {
  final List<DeliveredOrder> deliveredOrders;

  DeliveredOrdersData({
    required this.deliveredOrders,
  });

  factory DeliveredOrdersData.fromJson(Map<String, dynamic> json) {
    return DeliveredOrdersData(
      deliveredOrders: (json['delivered_orders'] as List<dynamic>? ?? [])
          .map((e) => DeliveredOrder.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivered_orders': deliveredOrders.map((e) => e.toJson()).toList(),
    };
  }
}

class DeliveredOrder {
  final int daysCount;
  final int ordersCount;

  DeliveredOrder({
    required this.daysCount,
    required this.ordersCount,
  });

  factory DeliveredOrder.fromJson(Map<String, dynamic> json) {
    return DeliveredOrder(
      daysCount: json['days_count'] ?? 0,
      ordersCount: json['orders_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days_count': daysCount,
      'orders_count': ordersCount,
    };
  }
}