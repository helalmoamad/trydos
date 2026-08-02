import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_products_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'pagination_widget.dart';

class ProductsGridWidget extends StatelessWidget {
  final List<Product> products;
  final Meta? meta;
  final VoidCallback? onAddProduct;
  final Function(int page)? onPageChanged;

  const ProductsGridWidget({
    Key? key,
    required this.products,
    this.meta,
    this.onAddProduct,
    this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Products Grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.58, // زيادة الارتفاع
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
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
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isActive = product.status == 1;
    final String imageUrl = product.images?.isNotEmpty == true
        ? product.images!.first
        : '';
    final String category = product.categories?.isNotEmpty == true
        ? product.categories!.first.name ?? ''
        : 'Food healthy';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to product details
          if (kDebugMode) print('Product tapped: ${product.name}');
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: imageUrl.isNotEmpty
                        ? MyCachedNetworkImage(
                            imageUrl: "$imageUrl",
                            width: 200.w,
                            imageFit: BoxFit.contain,
                            height: 200.h,
                          )
                        : Icon(
                            Icons.image_outlined,
                            size: 48.sp,
                            color: Colors.grey.shade400,
                          ),
                  ),
                ),
              ),

              // Product Details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Product Name
                      Text(
                        product.name ?? 'Product',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4.h),

                      // Category
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Price and Stock Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Text(
                            '${product.unitPrice?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFE8F5E9)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // Stock
                      Text(
                        '${LocaleKeys.stock.tr()}: ${product.currentStock ?? 0}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
