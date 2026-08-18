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
import 'package:trydos/features/home/presentation/pages/featued_products_page.dart';

import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'package:get_it/get_it.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter;

import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_item.dart';

class FeatureProductsWidget extends StatelessWidget {
  final ValueNotifier<int> tapIndexToAddProductToCart;
  final ValueNotifier<bool> finishRedeem;
  const FeatureProductsWidget({
    Key? key,
    required this.tapIndexToAddProductToCart,
    required this.finishRedeem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*  FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };*/
    List<filter.Products> products = [];

    return BlocBuilder<BoutiqueBloc, BoutiqueState>(
      buildWhen: (previous, current) =>
          previous
              .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]
              ?.paginationStatus !=
          current
              .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]
              ?.paginationStatus /* ||
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
          /*   List<filter.Products> recommendProduct =
                state.getProductListingWithFiltersPaginationModels[
                            "*recommended*withoutFilter"] ==
                        null
                    ? []
                    : state
                        .getProductListingWithFiltersPaginationModels[
                            "*recommended*withoutFilter"]!
                        .items;*/
          products =
              state.getProductListingWithFiltersPaginationModels["*featured*withoutFilter"] ==
                  null
              ? []
              : state
                    .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]!
                    .items;
          /* for (var i = 0;
                i < (recommendProduct.length > 6 ? 6 : recommendProduct.length);
                i++) {
              products.removeWhere(
                  (element) => element.slug == recommendProduct[i].slug);
            }*/
        } catch (e) {
          debugPrint('❌ Error getting featured products: $e');
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
                          AppAssets.productFeaturesSvg,
                          height: 24.h,
                        ),
                        MyTextWidget(
                          " ${LocaleKeys.feature_product.tr()}",
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            color: Colors.black,
                            fontSize: 18.sp,
                          ),
                        ),
                        const SizedBox(width: 10),
                        state
                                    .getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]
                                    ?.paginationStatus ==
                                PaginationStatus.loading
                            ? TrydosLoader(size: 16.w)
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    width: 1.sw,
                    // 360 بدل 345: شارة الاسترداد مرسومة فوق حدّ البطاقة
                    // (top: -5) وكانت تُقصّ عند حافة منفذ القائمة
                    height: 360.h,
                    child: ListView.builder(
                      addAutomaticKeepAlives: false,
                      addSemanticIndexes: false,

                      // بطاقتان مسبقاً — مشتقّ من itemExtent أدناه بدل رقم
                      // ثابت، فيبقى صحيحاً على كل عرض شاشة
                      scrollCacheExtent: ScrollCacheExtent.pixels(210.w * 2),
                      // البطاقة ثابتة العرض (200) + فاصل (10). itemExtent
                      // يجعل القائمة تحسب المواضع بدل قياس كل بطاقة أثناء
                      // التمرير — وهو سبب انسيابية قائمة البوتيكات
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
                              : _buildProductItem(context, products, index),
                        );
                      },
                      physics: const BouncingScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      // حشو علوي يزيح البطاقات للأسفل فتدخل الشارة داخل المنفذ
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
  }

  Widget _buildMoreButton(
    BuildContext context,
    List<filter.Products> products,
    int index,
    //, Tuple2<int, int> slidingMode
  ) {
    return InkWell(
      onTap: () {
        try {
          GetIt.I<BoutiqueBloc>().add(
            GetProductsWithFiltersEvent(
              limit: 10,
              cashedOrginalBoutique: true,
              boutiqueSlug: "*featured*",
              offset: 1,
            ),
          );
          Future.delayed(
            const Duration(milliseconds: 300),
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const FeaturedProductsPage()),
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
            fromHomePage: true,
            imageSource: 'features_products_widget',

            //  displayImageColors: true,
            tapIndexToAddProductToCart: tapIndexToAddProductToCart,
            key: TestVariables.kTestMode
                ? Key('*features*Product${products[index].slug}')
                : null,
            //  slidingModeItem: slidingMode,
            productItem: products[index],
            itemIndex: index,
            /* setThisEnabled: (int index, int slideMode) {
              try {
                setThisEnabledNotifier.value = Tuple2(index, slideMode);
              } catch (e) {
                debugPrint('❌ Error setting enabled state: $e');
              }
            },*/
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 0, 0, 0.4),
              borderRadius: BorderRadius.all(Radius.circular(12.r)),
            ),
            width: 200.w,
            height: 250.h,
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
    List<filter.Products> products,
    int index /*, Tuple2<int, int> slidingMode*/,
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
        finishRedeem: finishRedeem,
        fromHomePage: true,
        imageSource: 'features_products_widget',

        //  displayImageColors: true,
        tapIndexToAddProductToCart: tapIndexToAddProductToCart,
        key: TestVariables.kTestMode
            ? Key('*features*Product${products[index].slug}')
            : null,
        //  slidingModeItem: slidingMode,
        productItem: products[index],
        itemIndex: index,
        //  setThisEnabled: (int index, int slideMode) {
        //     try {
        //      setThisEnabledNotifier.value = Tuple2(index, slideMode);
        //    } catch (e) {
        //debugPrint('❌ Error setting enabled state: $e');
        //    }
        //},
      ),
    );
  }
}
