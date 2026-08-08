import 'package:easy_localization/easy_localization.dart' as tran;

import 'package:flutter/material.dart';

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

import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/features/home/presentation/pages/recommend_products_page.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'package:get_it/get_it.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter;

import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_item.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'dart:io';

class RecommendProductsWidget extends StatelessWidget {
  final ValueNotifier<int> tapIndexToAddProductToCart;
  final ValueNotifier<bool> finishRedeem;
  final ValueNotifier<bool> productIsRecommend;
  const RecommendProductsWidget({
    Key? key,
    required this.tapIndexToAddProductToCart,
    required this.productIsRecommend,
    required this.finishRedeem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /* FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };*/
    List<filter.Products> products = [];

    return BlocBuilder<BoutiqueBloc, BoutiqueState>(
      buildWhen: (previous, current) =>
          previous
              .getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]
              ?.paginationStatus !=
          current
              .getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]
              ?.paginationStatus,
      builder: (context, state) {
        try {
          products =
              state.getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"] ==
                  null
              ? []
              : state
                    .getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]!
                    .items;
        } catch (e) {
          debugPrint('❌ Error getting recommended products: $e');
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
                          AppAssets.productRecommendSvg,
                          height: 24.h,
                        ),
                        MyTextWidget(
                          " ${LocaleKeys.recommend_products.tr()}",
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            color: Colors.black,
                            fontSize: 18.sp,
                          ),
                        ),
                        const SizedBox(width: 10),
                        state
                                    .getProductListingWithFiltersPaginationModels["*recommended*withoutFilter"]
                                    ?.paginationStatus ==
                                PaginationStatus.loading
                            ? TrydosLoader(size: 16.h)
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    width: 1.sw,
                    height: 345.h,
                    child: ListView.builder(
                      addAutomaticKeepAlives: false,

                      addSemanticIndexes: false,
                      cacheExtent: 400, // بناء العناصر قبل دخولها الشاشة لمنع ظهورها المفاجئ
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
                              : _buildProductItem(context, products, index),
                        );
                      },
                      physics: const BouncingScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 10,
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
              boutiqueSlug: "*recommended*",
              offset: 1,
            ),
          );
          Future.delayed(
            const Duration(milliseconds: 300),
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const RecommendProductsPage(),
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
            fromFlashDeal: false,
            fromRecommend: true,
            productIsRecommend: productIsRecommend,
            fromHomePage: true,
            imageSource: 'recommend_products_widget',

            //  displayImageColors: true,
            tapIndexToAddProductToCart: tapIndexToAddProductToCart,
            key: TestVariables.kTestMode
                ? Key('*recommend*Product${products[index].slug}')
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
            decoration: const BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.4),
              borderRadius: BorderRadius.all(Radius.circular(12)),
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
    List<filter.Products> products,
    int index /*, Tuple2<int, int> slidingMode*/,
  ) {
    return InkWell(
      onTap: () {
        try {
          // Log recommended product selection event
          final product = products[index];
          final categoryIds = product.categories
              ?.map((cat) => cat.id?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .toList();

          FirebaseAnalyticsService.logEventForSession(
            eventName: AnalyticsEventsConst.RECOMENDED,
            executedEventName:
                AnalyticsButtonsEventNameConst.LATER_TAKE_LOOK_BUTTON,
            extraParams: {
              'recommended_item_select': product.productId.toString(),
              'product_id': product.productId.toString(),
              'product_name': product.name ?? '',
              'product_category': categoryIds != null
                  ? categoryIds.toString()
                  : '',
              'screen_name': GlobalScreenConst.HOME_PAGE,
              'screen_path': '',
              'device_type': Platform.isIOS || Platform.isAndroid
                  ? 'mobile'
                  : 'desktop',
              'operating_system': Platform.isIOS
                  ? 'ios'
                  : Platform.isAndroid
                  ? 'Android'
                  : Platform.isWindows
                  ? 'Windows'
                  : Platform.isMacOS
                  ? 'Macintosh'
                  : Platform.isLinux
                  ? 'Linux'
                  : 'Unknown',
            },
          );

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
        fromFlashDeal: false,
        fromRecommend: true,
        productIsRecommend: productIsRecommend,
        imageSource: 'recommend_products_widget',

        //  displayImageColors: true,
        tapIndexToAddProductToCart: tapIndexToAddProductToCart,
        key: TestVariables.kTestMode
            ? Key('*recommend*Product${products[index].slug}')
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
