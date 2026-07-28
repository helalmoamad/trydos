import 'get_orders_model.dart' show OrderStatus, ShippingAddressData;

/// Response model for `GET /customer/order/getHiddenOrders`.
///
/// The backend returns a flat list of orders (each may be a hidden order or an
/// order that merely contains hidden products). Grouping by [HiddenOrderModel.orderGroupId]
/// is done in the UI so the cards match the main Orders page design.
class GetHiddenOrdersModel {
  final List<HiddenOrderModel>? data;

  GetHiddenOrdersModel({this.data});

  factory GetHiddenOrdersModel.fromJson(Map<String, dynamic> json) =>
      GetHiddenOrdersModel(
        data: json["data"] == null
            ? <HiddenOrderModel>[]
            : List<HiddenOrderModel>.from(
                (json["data"] as List).map((x) => HiddenOrderModel.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "data": data?.map((x) => x.toJson()).toList(),
  };
}

class HiddenOrderModel {
  final int? id;
  final OrderStatus? orderStatus;
  final OrderStatus? orderGroupStatus;
  final OrderStatus? paymentMethod;
  final double? orderAmount;
  final ShippingAddressData? shippingAddressData;
  final String? orderGroupId;
  final String? createdAt;
  final bool? isHidden;
  final List<HiddenOrderDetailModel>? details;

  HiddenOrderModel({
    this.id,
    this.orderStatus,
    this.orderGroupStatus,
    this.paymentMethod,
    this.orderAmount,
    this.shippingAddressData,
    this.orderGroupId,
    this.createdAt,
    this.isHidden,
    this.details,
  });

  factory HiddenOrderModel.fromJson(Map<String, dynamic> json) =>
      HiddenOrderModel(
        id: json["id"],
        orderStatus: json["order_status"] == null
            ? null
            : OrderStatus.fromJson(json["order_status"]),
        orderGroupStatus: json["order_group_status"] == null
            ? null
            : OrderStatus.fromJson(json["order_group_status"]),
        paymentMethod: json["payment_method"] == null
            ? null
            : OrderStatus.fromJson(json["payment_method"]),
        orderAmount: json["order_amount"] == null
            ? 0
            : double.tryParse(json["order_amount"].toString()) ?? 0,
        shippingAddressData: json["shipping_address_data"] == null
            ? null
            : ShippingAddressData.fromJson(json["shipping_address_data"]),
        orderGroupId: json["order_group_id"],
        createdAt: json["created_at"],
        isHidden: json["is_hidden"] == true,
        details: json["details"] == null
            ? <HiddenOrderDetailModel>[]
            : List<HiddenOrderDetailModel>.from(
                (json["details"] as List).map(
                  (x) => HiddenOrderDetailModel.fromJson(x),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_status": orderStatus?.toJson(),
    "order_group_status": orderGroupStatus?.toJson(),
    "payment_method": paymentMethod?.toJson(),
    "order_amount": orderAmount,
    "shipping_address_data": shippingAddressData?.toJson(),
    "order_group_id": orderGroupId,
    "created_at": createdAt,
    "is_hidden": isHidden,
    "details": details?.map((x) => x.toJson()).toList(),
  };
}

class HiddenOrderDetailModel {
  final int? id;
  final String? image;
  final bool? isHidden;

  HiddenOrderDetailModel({this.id, this.image, this.isHidden});

  factory HiddenOrderDetailModel.fromJson(Map<String, dynamic> json) =>
      HiddenOrderDetailModel(
        id: json["id"],
        image: json["image"],
        isHidden: json["is_hidden"] == true,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "is_hidden": isHidden,
  };
}
