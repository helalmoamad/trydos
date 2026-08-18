import 'package:easy_localization/easy_localization.dart' as tran;

import 'package:flutter/material.dart';
// ScrollCacheExtent غير مُصدَّرة عبر material.dart/widgets.dart
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_text_widget.dart';

import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

import 'package:trydos/features/home/presentation/pages/flash_deal_products_page.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'package:get_it/get_it.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter;
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_item.dart';

class FlashDealProductsWidget extends StatefulWidget {
  final ValueNotifier<int> tapIndexToAddProductToCart;
  final ValueNotifier<bool> productIsFlashDeal;
  final ValueNotifier<bool> finishRedeem;

  const FlashDealProductsWidget({
    Key? key,
    required this.tapIndexToAddProductToCart,
    required this.productIsFlashDeal,
    required this.finishRedeem,
  }) : super(key: key);

  @override
  State<FlashDealProductsWidget> createState() =>
      _FlashDealProductsWidgetState();
}

class _FlashDealProductsWidgetState extends State<FlashDealProductsWidget> {
  /// كان يُنشأ داخل build: نسخة جديدة مع كل إعادة بناء، فيفقد العدّاد
  /// المستمعَ الذي يعتمد عليه لتحديث القائمة، ولا يُتخلّص منه أبداً.
  final ValueNotifier<bool> refreshFlashDeal = ValueNotifier(false);

  ValueNotifier<int> get tapIndexToAddProductToCart =>
      widget.tapIndexToAddProductToCart;
  ValueNotifier<bool> get productIsFlashDeal => widget.productIsFlashDeal;
  ValueNotifier<bool> get finishRedeem => widget.finishRedeem;

  @override
  void dispose() {
    refreshFlashDeal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<filter.Products> products = [];
    final now = DateTime.now();

    return ValueListenableBuilder<bool>(
      valueListenable: refreshFlashDeal,
      builder: (context, _refreshFlashDeal, _) {
        return BlocBuilder<BoutiqueBloc, BoutiqueState>(
          buildWhen: (previous, current) =>
              previous
                      .getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]
                      ?.paginationStatus !=
                  current
                      .getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]
                      ?.paginationStatus ||
              previous.getProductFiltersStatus["*flashDeal*"] !=
                  current.getProductFiltersStatus["*flashDeal*"] /* ||
                previous
                        .getProductListingWithFiltersPaginationModels[
                            "*recommended*withoutFilter"]
                        ?.paginationStatus !=
                    current
                        .getProductListingWithFiltersPaginationModels[
                            "*recommended*withoutFilter"]
                        ?.paginationStatus*/,
          builder: (context, state) {
            try {
              /*  List<filter.Products> recommendProduct =
                    state.getProductListingWithFiltersPaginationModels[
                                "*recommended*withoutFilter"] ==
                            null
                        ? []
                        : state
                            .getProductListingWithFiltersPaginationModels[
                                "*recommended*withoutFilter"]!
                            .items;*/
              products =
                  state.getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"] ==
                      null
                  ? []
                  : state
                        .getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]!
                        .items;
              /*  for (var i = 0;
                    i <
                        (recommendProduct.length > 6
                            ? 6
                            : recommendProduct.length);
                    i++) {
                  products.removeWhere(
                      (element) => element.slug == recommendProduct[i].slug);
                }*/
              List<filter.Products> productWithFlashDealEndDate = [];
              products.forEach((element) {
                DateTime? endDate;
                Duration _duration = const Duration();
                endDate = element.flashDealEndDateTime;
                if (endDate != null) {
                  _duration = endDate.difference(now);
                } else {
                  return;
                }
                if (!(_duration.isNegative || _duration.inSeconds < 1)) {
                  productWithFlashDealEndDate.add(element);
                }
              });
              products = productWithFlashDealEndDate;
            } catch (e) {
              debugPrint('❌ Error getting flash deal products: $e');
              products = [];
            }

            return products.isNullOrEmpty
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        margin: EdgeInsets.symmetric(horizontal: 10.w),

                        height: 50.h,
                        decoration: BoxDecoration(
                          color: const Color(0xffF3F3F3),
                          borderRadius: BorderRadius.all(Radius.circular(15.r)),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.flashDealSvg,
                              height: 24.h,
                            ),
                            MyTextWidget(
                              " ${LocaleKeys.flash_deal.tr()}",
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                color: Colors.black,
                                fontSize: 18.sp,
                              ),
                            ),
                            const SizedBox(width: 10),
                            state
                                        .getProductListingWithFiltersPaginationModels["*flashDeal*withoutFilter"]
                                        ?.paginationStatus ==
                                    PaginationStatus.loading
                                ? TrydosLoader(size: 16)
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        width: 1.sw,
                        // 360.h بدل 345.w: شارة العرض مرسومة فوق حدّ البطاقة،
                        // وكان القياس بـ .w (عرض) بدل .h (ارتفاع) — خطأ مقياس
                        height: 360.h,
                        child: ListView.builder(
                          addAutomaticKeepAlives: false,
                          addSemanticIndexes: false,

                          // بطاقتان مسبقاً — مشتقّ من itemExtent أدناه بدل رقم
                          // ثابت، فيبقى صحيحاً على كل عرض شاشة
                          scrollCacheExtent: ScrollCacheExtent.pixels(
                            210.w * 2,
                          ),
                          // بطاقة ثابتة العرض (200) + فاصل (10)
                          itemExtent: 210.w,
                          itemBuilder: (context, index) {
                            // التحقق من صحة الفهرس
                            if (index >= products.length) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: EdgeInsetsDirectional.only(end: 10.w),
                              child: (index == 5 && products.length > 5)
                                  ? _buildMoreButton(context, products, index)
                                  : _buildProductItem(
                                      context,
                                      refreshFlashDeal,
                                      products,
                                      index,
                                    ),
                            );
                          },
                          physics: const BouncingScrollPhysics(
                            parent: ClampingScrollPhysics(),
                          ),
                          // حشو علوي يزيح البطاقات فتدخل الشارة داخل المنفذ
                          padding: EdgeInsetsDirectional.only(
                            start: 10,
                            end: 10,
                            top: 10.h,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length > 6 ? 6 : products.length,
                        ),
                      ),
                    ],
                  );
          },
        );
      },
    );
  }

  Widget _buildMoreButton(
    BuildContext context,
    List<filter.Products> products,
    int index,
  ) {
    return InkWell(
      onTap: () {
        try {
          GetIt.I<BoutiqueBloc>().add(
            GetProductsWithFiltersEvent(
              limit: 10,
              cashedOrginalBoutique: true,
              boutiqueSlug: "*flashDeal*",
              offset: 1,
            ),
          );
          Future.delayed(
            const Duration(milliseconds: 300),
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const FlashDealProductsPage(),
              ),
            ),
          );
        } catch (e) {
          debugPrint('❌ Error navigating to flash deal products: $e');
        }
      },
      child: Stack(
        children: [
          ProductItem(
            finishRedeem: finishRedeem,
            fromFlashDeal: true,
            fromHomePage: true,
            imageSource: 'flash_deal_products_widget',
            productIsFlashDeal: productIsFlashDeal,
            tapIndexToAddProductToCart: tapIndexToAddProductToCart,
            key: TestVariables.kTestMode
                ? Key('*flashDeal*Product${products[index].slug}')
                : null,
            productItem: products[index],
            itemIndex: index,
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 0, 0, 0.4),
              borderRadius: BorderRadius.all(Radius.circular(12.r)),
            ),
            width: 200.w,
            height: 300.h,
          ),
          Positioned(
            top: 100.h,
            left: 75.w,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15.r)),
              ),
              width: 60.w,
              height: 60.h,
              child: MyTextWidget(
                textAlign: TextAlign.center,
                "${LocaleKeys.more.tr()}",
                style: context.textTheme.titleLarge?.rq.copyWith(
                  color: Colors.black,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context,
    ValueNotifier<bool> refreshFlashDeal,
    List<filter.Products> products,
    int index,
  ) {
    return InkWell(
      onTap: () {
        try {
          GetIt.I<HomeBloc>().add(
            const ChangeStatusOFGetProductsDetailsToSuccessEvent(
              isStatusInitaial: true,
            ),
          );
          GetIt.I<HomeBloc>().add(
            AddCurrentSelectedColorEvent(
              currentSelectedColor: 0,
              productSlug: products[index].slug.toString(),
            ),
          );
          Future.delayed(
            const Duration(milliseconds: 300),
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) =>
                    ProductDetailsPageNew(productItem: products[index]),
              ),
            ),
          );
        } catch (e) {
          debugPrint('❌ Error navigating to product details: $e');
        }
      },
      child: ProductItem(
        refreshFlashDeal: refreshFlashDeal,
        fromFlashDeal: true,
        finishRedeem: finishRedeem,
        fromHomePage: true,
        imageSource: 'flash_deal_products_widget',
        productIsFlashDeal: productIsFlashDeal,
        tapIndexToAddProductToCart: tapIndexToAddProductToCart,
        key: TestVariables.kTestMode
            ? Key('*flashDeal*Product${products[index].slug}')
            : null,
        productItem: products[index],
        itemIndex: index,
      ),
    );
  }
}
