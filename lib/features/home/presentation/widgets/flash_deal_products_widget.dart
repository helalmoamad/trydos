import 'package:easy_localization/easy_localization.dart' as tran;

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';

import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';

import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

import 'package:trydos/features/home/presentation/pages/flash_deal_products_page.dart';
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

class FlashDealProductsWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final ValueNotifier<bool> refreshFlashDeal = ValueNotifier(false);
    List<filter.Products> products = [];

    return ValueListenableBuilder<bool>(
        valueListenable: refreshFlashDeal,
        builder: (context, _refreshFlashDeal, _) {
          return BlocBuilder<BoutiqueBloc, BoutiqueState>(
            buildWhen: (previous, current) =>
                previous
                    .getProductListingWithFiltersPaginationModels[
                        "*flashDeal*withoutFilter"]
                    ?.paginationStatus !=
                current
                    .getProductListingWithFiltersPaginationModels[
                        "*flashDeal*withoutFilter"]
                    ?.paginationStatus,
            builder: (context, state) {
              try {
                products = state.getProductListingWithFiltersPaginationModels[
                            "*flashDeal*withoutFilter"] ==
                        null
                    ? []
                    : state
                        .getProductListingWithFiltersPaginationModels[
                            "*flashDeal*withoutFilter"]!
                        .items;
                List<filter.Products> productWithFlashDealEndDate = [];
                products.forEach((element) {
                  DateTime endDate;
                  Duration _duration = Duration();
                  final now = DateTime.now();
                  try {
                    endDate = tran.DateFormat('MM/dd/yyyy', 'en_US')
                        .parse(element.flashDealEndDate ?? "");
                    endDate = endDate.add(Duration(days: 1));
                  } catch (e) {
                    endDate = DateTime.now();
                    print('Error parsing date: $e');
                  }
                  _duration = endDate.difference(now);
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
                  ? SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: 250,
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                AppAssets.flashDealSvg,
                                height: 18,
                              ),
                              MyTextWidget(
                                " ${LocaleKeys.flash_deal.tr()}",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 5),
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
                                      return SizedBox.shrink();
                                    }

                                    if (index == 5 && products.length > 5) {
                                      return _buildMoreButton(
                                          context, products, index);
                                    }
                                    return _buildProductItem(context,
                                        refreshFlashDeal, products, index);
                                  },
                                  physics: const BouncingScrollPhysics(
                                    parent: ClampingScrollPhysics(),
                                  ),
                                  padding: EdgeInsetsDirectional.symmetric(
                                      horizontal: 10),
                                  scrollDirection: Axis.horizontal,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(width: 15),
                                  itemCount: products.length > 6
                                      ? 6
                                      : products.length),
                            ))
                      ],
                    );
            },
          );
        });
  }

  Widget _buildMoreButton(
      BuildContext context, List<filter.Products> products, int index) {
    return InkWell(
      onTap: () {
        try {
          GetIt.I<BoutiqueBloc>().add(GetProductsWithFiltersEvent(
              context: context,
              fromNotification: false,
              limit: 10,
              cashedOrginalBoutique: true,
              boutiqueSlug: "*flashDeal*",
              getWithPagination: false,
              offset: 1));
          Future.delayed(
              Duration(milliseconds: 300),
              () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => FlashDealProductsPage(),
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
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              width: 60,
              height: 60,
              child: MyTextWidget(
                textAlign: TextAlign.center,
                "${LocaleKeys.more.tr()}",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductItem(
      BuildContext context,
      ValueNotifier<bool> refreshFlashDeal,
      List<filter.Products> products,
      int index) {
    return InkWell(
      onTap: () {
        try {
          GetIt.I<HomeBloc>().add(
              ChangeStatusOFGetProductsDetailsToSuccessEvent(
                  isStatusInitaial: true));
          GetIt.I<HomeBloc>().add(AddCurrentSelectedColorEvent(
              currentSelectedColor: 0,
              productSlug: products[index].slug.toString()));
          Future.delayed(
              Duration(milliseconds: 300),
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
