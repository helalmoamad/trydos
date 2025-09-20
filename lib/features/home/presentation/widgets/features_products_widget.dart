import 'package:easy_localization/easy_localization.dart' as tran;

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/core/data/model/pagination_model.dart';

import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_text_widget.dart';

import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/pages/featued_products_page.dart';

import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
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
    List<filter.Products> products = [];

    return BlocBuilder<BoutiqueBloc, BoutiqueState>(
        buildWhen: (previous, current) =>
            previous
                .getProductListingWithFiltersPaginationModels[
                    "*featured*withoutFilter"]
                ?.paginationStatus !=
            current
                .getProductListingWithFiltersPaginationModels[
                    "*featured*withoutFilter"]
                ?.paginationStatus,
        builder: (context, state) {
          try {
            products = state.getProductListingWithFiltersPaginationModels[
                        "*featured*withoutFilter"] ==
                    null
                ? []
                : state
                    .getProductListingWithFiltersPaginationModels[
                        "*featured*withoutFilter"]!
                    .items;
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
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      width: 250,
                      height: 20,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            AppAssets.productFeaturesSvg,
                            height: 18,
                          ),
                          MyTextWidget(
                            " ${LocaleKeys.feature_product.tr()}",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 14),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          state
                                      .getProductListingWithFiltersPaginationModels[
                                          "*featured*withoutFilter"]
                                      ?.paginationStatus ==
                                  PaginationStatus.loading
                              ? TrydosLoader(
                                  size: 16,
                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          width: 1.sw,
                          height: 300,
                          child: ListView.separated(
                              addAutomaticKeepAlives: false,
                              addRepaintBoundaries: false,
                              addSemanticIndexes: false,
                              cacheExtent: 0,
                              itemBuilder: (context, index) {
                                // التحقق من صحة الفهرس
                                if (index >= products.length) {
                                  return const SizedBox.shrink();
                                }

                                if (index == 5 && products.length > 5) {
                                  return _buildMoreButton(
                                      context, products, index);
                                }
                                return _buildProductItem(
                                    context, products, index);
                              },
                              physics: const BouncingScrollPhysics(
                                parent: ClampingScrollPhysics(),
                              ),
                              padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 10),
                              scrollDirection: Axis.horizontal,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 15),
                              itemCount:
                                  products.length > 6 ? 6 : products.length),
                        ))
                  ],
                );
        });
  }

  Widget _buildMoreButton(
      BuildContext context, List<filter.Products> products, int index
      //, Tuple2<int, int> slidingMode
      ) {
    return InkWell(
      onTap: () {
        try {
          GetIt.I<BoutiqueBloc>().add(GetProductsWithFiltersEvent(
              context: context,
              limit: 10,
              cashedOrginalBoutique: true,
              boutiqueSlug: "*featured*",
              offset: 1));
          Future.delayed(
              const Duration(milliseconds: 300),
              () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const FeaturedProductsPage(),
                    ),
                  ));
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
            decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.4),
                borderRadius: BorderRadius.all(Radius.circular(12))),
            width: 200,
            height: 300,
          ),
          Positioned(
            top: 100,
            left: 75,
            child: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              width: 60,
              height: 60,
              child: MyTextWidget(
                textAlign: TextAlign.center,
                "${LocaleKeys.more.tr()}",
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, List<filter.Products> products,
      int index /*, Tuple2<int, int> slidingMode*/) {
    return InkWell(
      onTap: () {
        try {
          GetIt.I<HomeBloc>().add(
              const ChangeStatusOFGetProductsDetailsToSuccessEvent(
                  isStatusInitaial: true));
          GetIt.I<HomeBloc>().add(AddCurrentSelectedColorEvent(
              currentSelectedColor: 0,
              productSlug: products[index].slug.toString()));
          Future.delayed(
              const Duration(milliseconds: 300),
              () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => ProductDetailsPageNew(
                        productItem: products[index],
                      ),
                    ),
                  ));
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
