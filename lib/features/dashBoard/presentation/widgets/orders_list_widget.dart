import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_orders_model.dart';
import 'package:trydos/features/dashBoard/presentation/bloc/dashBoard_bloc.dart';
import 'pagination_widget.dart';

class OrdersListWidget extends StatelessWidget {
  final List<UserOrder> orders;
  final Meta? meta;
  final UserAbilities? userAbilities;
  final Function(int page)? onPageChanged;
  final Function(int orderId, String status)? onStatusChanged;

  const OrdersListWidget({
    Key? key,
    required this.orders,
    this.meta,
    this.userAbilities,
    this.onPageChanged,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          // Orders List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                // Calculate intersection between order's availableOrderStatusChange 
                // and user's abilities
                final orderAvailableStatuses = orders[index].availableOrderStatusChange ?? [];
                final userAllowedStatuses = userAbilities?.changeOrderStatus ?? [];
                final availableStatuses = orderAvailableStatuses
                    .where((status) => userAllowedStatuses.contains(status))
                    .toList();
                
                return OrderCard(
                  order: orders[index],
                  availableStatuses: availableStatuses,
                  onStatusChanged: onStatusChanged,
                );
              },
            ),
          ),

          // Pagination
          if (meta != null && (meta!.lastPage ?? 1) > 1)
            PaginationWidget(
              currentPage: meta!.currentPage ?? 1,
              totalPages: meta!.lastPage ?? 1,
              onPrevious: () {
                if (onPageChanged != null && (meta!.currentPage ?? 1) > 1) {
                  onPageChanged!((meta!.currentPage ?? 1) - 1);
                }
              },
              onNext: () {
                if (onPageChanged != null &&
                    (meta!.currentPage ?? 1) < (meta!.lastPage ?? 1)) {
                  onPageChanged!((meta!.currentPage ?? 1) + 1);
                }
              },
            ),
        ],
      ),
    );
  }
}

class OrderCard extends StatefulWidget {
  final UserOrder order;
  final List<String> availableStatuses;
  final Function(int orderId, String status)? onStatusChanged;

  const OrderCard({
    Key? key,
    required this.order,
    required this.availableStatuses,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    // Ensure the current status is in the list, otherwise set to first item
    if (widget.availableStatuses.isNotEmpty) {
      // If current status is in available statuses, use it
      if (widget.availableStatuses.contains(widget.order.orderStatus)) {
        selectedStatus = widget.order.orderStatus;
      } else {
        // Otherwise, use first available status
        selectedStatus = widget.availableStatuses.first;
      }
    } else {
      // If no available statuses, use current status (but button will be disabled)
      selectedStatus = widget.order.orderStatus;
    }
  }

  @override
  void didUpdateWidget(OrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selectedStatus if availableStatuses changed
    if (widget.availableStatuses.isNotEmpty) {
      // If current selectedStatus is not in new availableStatuses, update it
      if (!widget.availableStatuses.contains(selectedStatus)) {
        // Try to use current order status if available
        if (widget.availableStatuses.contains(widget.order.orderStatus)) {
          selectedStatus = widget.order.orderStatus;
        } else {
          // Otherwise use first available status
          selectedStatus = widget.availableStatuses.first;
        }
      }
    } else {
      // If availableStatuses became empty, use current order status
      selectedStatus = widget.order.orderStatus;
    }
  }

  String _formatPaymentMethod(String paymentMethod) {
    // Format payment method string to be more readable
    // Convert snake_case to Title Case
    return paymentMethod
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  String _formatStatus(String status) {
    // Format status string to be more readable
    // Convert snake_case to Title Case
    return status
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return const Color(0xFFE3F2FD);
      case 'confirmed':
      case 'delivered':
        return const Color(0xFFE8F5E9);
      case 'canceled':
        return const Color(0xFFFFEBEE);
      case 'cash_on_delivery':
        return const Color(0xFFE0F2F1);
      default:
        return const Color(0xFFE3F2FD);
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return const Color(0xFF1976D2);
      case 'confirmed':
      case 'delivered':
        return const Color(0xFF4CAF50);
      case 'canceled':
        return const Color(0xFFD32F2F);
      case 'cash_on_delivery':
        return const Color(0xFF00897B);
      default:
        return const Color(0xFF1976D2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allDetails =
        widget.order.details?.expand((list) => list).toList() ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side - Order Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID: ${widget.order.id ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          if (widget.order.orderGroupId != null)
                            Text(
                              'Group: ${widget.order.orderGroupId}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Right Side - Status Badges
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Order Status Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.order.orderStatus),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            widget.order.orderStatus ?? 'unknown',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: _getStatusTextColor(
                                widget.order.orderStatus,
                              ),
                            ),
                          ),
                        ),

                        // Group Status Badge
                        if (widget.order.orderGroupStatus != null) ...[
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE7F6),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              widget.order.orderGroupStatus!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7B1FA2),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Additional Status Badges
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    if (widget.order.paymentStatus != null)
                      _buildSmallBadge(
                        widget.order.paymentStatus?.name ?? '',
                        const Color(0xFFFFF3E0),
                        const Color(0xFFE65100),
                      ),
                    if (widget.order.paymentMethod != null)
                      _buildSmallBadge(
                        _formatPaymentMethod(widget.order.paymentMethod!),
                        const Color(0xFFE0F2F1),
                        const Color(0xFF00695C),
                      ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Cart Group
                if (widget.order.cartGroupId != null)
                  Text(
                    'Cart Group: ${widget.order.cartGroupId}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

          // Order Details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Change Status Section (Moved to top)
                Text(
                  'Change status:',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value:
                                widget.availableStatuses.isNotEmpty &&
                                    selectedStatus != null &&
                                    widget.availableStatuses.contains(
                                      selectedStatus,
                                    )
                                ? selectedStatus
                                : widget.availableStatuses.isNotEmpty
                                ? widget.availableStatuses.first
                                : null,
                            isExpanded: true,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.shade700,
                            ),
                            items: widget.availableStatuses.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  _formatStatus(value),
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              );
                            }).toList(),
                            onChanged: widget.availableStatuses.isNotEmpty
                                ? (String? newValue) {
                                    if (newValue != null &&
                                        widget.availableStatuses.contains(
                                          newValue,
                                        )) {
                                      setState(() {
                                        selectedStatus = newValue;
                                      });
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    BlocBuilder<DashboardBloc, DashBoardState>(
                      buildWhen: (previous, current) =>
                          previous.changeOrderStatusStatus !=
                          current.changeOrderStatusStatus,
                      builder: (context, state) {
                        final isLoading =
                            state.changeOrderStatusStatus ==
                            ChangeOrderStatusStatus.loading;
                        final isThisOrderLoading =
                            isLoading &&
                            selectedStatus != widget.order.orderStatus;

                        // Check if selectedStatus is valid and different from current
                        final canUpdate =
                            widget.availableStatuses.isNotEmpty &&
                            selectedStatus != null &&
                            widget.onStatusChanged != null &&
                            widget.order.id != null &&
                            selectedStatus != widget.order.orderStatus &&
                            widget.availableStatuses.contains(selectedStatus);

                        return ElevatedButton(
                          onPressed: isThisOrderLoading || !canUpdate
                              ? null
                              : () {
                                  if (widget.order.id != null &&
                                      selectedStatus != null &&
                                      widget.availableStatuses.contains(
                                        selectedStatus,
                                      )) {
                                    widget.onStatusChanged!(
                                      widget.order.id!,
                                      selectedStatus!,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isThisOrderLoading || !canUpdate
                                ? Colors.grey.shade300
                                : const Color(0xFF90CAF9),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: isThisOrderLoading
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Update',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
                Divider(height: 1, color: Colors.grey.shade300),
                SizedBox(height: 16.h),

                // Financial Info
                _buildInfoRow(
                  'Amount',
                  '${widget.order.orderAmount ?? 0}',
                  isBold: true,
                ),
                SizedBox(height: 8.h),
                _buildInfoRow('Shipping', '${widget.order.shippingCost ?? 0}'),
                SizedBox(height: 8.h),
                _buildInfoRow(
                  'Discount',
                  '${widget.order.discountAmount ?? 0}',
                ),
                SizedBox(height: 8.h),
                _buildInfoRow(
                  'Delivery',
                  widget.order.deliveryType != null
                      ? widget.order.deliveryType.toString().split('.').last
                      : 'N/A',
                ),

                SizedBox(height: 12.h),
                Divider(height: 1, color: Colors.grey.shade300),
                SizedBox(height: 12.h),

                // Shipping & Transaction Info
                if (widget.order.shippingType != null)
                  _buildInfoRow(
                    'Shipping Type',
                    widget.order.shippingType.toString().split('.').last,
                  ),
                if (widget.order.transactionRef != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: _buildInfoRow(
                      'Transaction',
                      widget.order.transactionRef!,
                    ),
                  ),
                if (widget.order.canReturnOrder != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: _buildInfoRow(
                      'Return Allowed',
                      widget.order.canReturnOrder! ? 'Yes' : 'No',
                    ),
                  ),
              ],
            ),
          ),

          // Items Section
          if (allDetails.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: Colors.grey.shade50,
              child: Text(
                'Items',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              itemCount: allDetails.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 24.h, color: Colors.grey.shade300),
              itemBuilder: (context, index) {
                return OrderItemCard(item: allDetails[index]);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black87 : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final Detail item;

  const OrderItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String imageUrl = item.cartImage ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: imageUrl.isNotEmpty
                ? MyCachedNetworkImage(
                    imageUrl: imageUrl.contains("cloudinary")
                        ? imageUrl
                        : "${dotenv.env['Images_Url']}$imageUrl",
                    width: 80.w,
                    height: 80.h,
                    imageFit: BoxFit.cover,
                  )
                : Icon(
                    Icons.image_outlined,
                    size: 32.sp,
                    color: Colors.grey.shade400,
                  ),
          ),
        ),

        SizedBox(width: 12.w),

        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name (from productDetails JSON)
              Text(
                _getProductName(item.productDetails),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (item.variant != null &&
                  item.variant!.isNotEmpty &&
                  item.variant != 'N/A')
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    'Variant: ${item.variant}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              SizedBox(height: 6.h),

              // Delivery Status
              if (item.deliveryStatus != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    'Delivery: ${item.deliveryStatus.toString().split('.').last}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

              // Qty
              Row(
                children: [
                  Text(
                    'Qty: ${item.qty ?? 0}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'item',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // Price
              Text(
                'Price: ${item.price ?? 0}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
              ),

              SizedBox(height: 4.h),

              // Payment Status
              if (item.paymentStatus != null)
                Text(
                  'Payment: ${item.paymentStatus.toString().split('.').last}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getProductName(String? productDetails) {
    if (productDetails == null || productDetails.isEmpty) {
      return 'Product';
    }

    // Try to parse JSON and extract name
    try {
      // Check if it's JSON
      if (productDetails.contains('{') && productDetails.contains('}')) {
        final decoded = json.decode(productDetails);
        if (decoded is Map) {
          // Try different possible name fields
          return decoded['name'] ??
              decoded['title'] ??
              decoded['product_name'] ??
              productDetails;
        }
      }
      // If not JSON, return as is
      return productDetails;
    } catch (e) {
      // If parsing fails, return the original string
      return productDetails;
    }
  }
}
