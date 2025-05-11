import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/pages/featued_products_page.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:tuple/tuple.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter;
import 'dart:ui' as ui;

import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_item.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';

class FeatureProductsWidget extends StatelessWidget {
  final ValueNotifier<int> tapIndexToAddProductToCart;
  const FeatureProductsWidget(
      {Key? key, required this.tapIndexToAddProductToCart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController =
        ScrollController(initialScrollOffset: 75.w);
    final ValueNotifier<Tuple2<int, int>> setThisEnabledNotifier =
        ValueNotifier(Tuple2(-1, -1));
    List<filter.Products> products = [];
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
      print(error.toString());
    };
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
          products = state.getProductListingWithFiltersPaginationModels[
                      "*featured*withoutFilter"] ==
                  null
              ? []
              : state
                  .getProductListingWithFiltersPaginationModels[
                      "*featured*withoutFilter"]!
                  .items;
          return products.isNullOrEmpty
              ? SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*  Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: 250,
                      height: 25,
                      child: MyTextWidget(
                        "${LocaleKeys.feature_product.tr()}",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),*/
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      width: 1.sw,
                      height: 320,
                      child: ScrollConfiguration(
                          behavior: const CupertinoScrollBehavior(),
                          child: ValueListenableBuilder<Tuple2<int, int>>(
                              valueListenable: setThisEnabledNotifier,
                              builder: (context, slidingMode, _) {
                                return Directionality(
                                  textDirection: ui.TextDirection.ltr,
                                  child: ListView.separated(
                                      controller: scrollController,
                                      itemBuilder: (context, index) {
                                        if (index == 5) {
                                          return InkWell(
                                            onTap: () {
                                              GetIt.I<BoutiqueBloc>().add(
                                                  GetProductsWithFiltersEvent(
                                                      context: context,
                                                      fromNotification: false,
                                                      limit: 10,
                                                      cashedOrginalBoutique:
                                                          true,
                                                      boutiqueSlug:
                                                          "*featured*",
                                                      getWithPagination: false,
                                                      offset: 1));
                                              Future.delayed(
                                                  Duration(milliseconds: 300),
                                                  () => Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (ctx) =>
                                                              FeaturedProductsPage(),
                                                        ),
                                                      ));
                                            },
                                            child: Stack(
                                              children: [
                                                ProductItem(
                                                  fromHomePage: true,
                                                  displayImageColors: true,
                                                  tapIndexToAddProductToCart:
                                                      tapIndexToAddProductToCart,
                                                  key: TestVariables.kTestMode
                                                      ? Key(
                                                          'featuresProduct$index')
                                                      : null,
                                                  slidingModeItem: slidingMode,
                                                  productItem: products[index],
                                                  itemIndex: index,
                                                  setThisEnabled: (int index,
                                                      int slideMode) {
                                                    setThisEnabledNotifier
                                                            .value =
                                                        Tuple2(
                                                            index, slideMode);
                                                  },
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 0.4),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12))),
                                                  width: 200,
                                                  height: 320,
                                                ),
                                                Positioned(
                                                  top: 100,
                                                  left: 75,
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    30))),
                                                    width: 60,
                                                    height: 60,
                                                    child: MyTextWidget(
                                                      textAlign:
                                                          TextAlign.center,
                                                      "${LocaleKeys.more.tr()}",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        }
                                        return InkWell(
                                          onTap: () {
                                            GetIt.I<HomeBloc>().add(
                                                ChangeStatusOFGetProductsDetailsToSuccessEvent(
                                                    isStatusInitaial: true));

                                            Future.delayed(
                                                Duration(milliseconds: 300),
                                                () =>
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (ctx) =>
                                                            ProductDetailsPage(
                                                          productItem:
                                                              products[index],
                                                        ),
                                                      ),
                                                    ));
                                          },
                                          child: ProductItem(
                                            fromHomePage: true,
                                            displayImageColors: true,
                                            tapIndexToAddProductToCart:
                                                tapIndexToAddProductToCart,
                                            key: TestVariables.kTestMode
                                                ? Key('"featuresPtoduct"$index')
                                                : null,
                                            slidingModeItem: slidingMode,
                                            productItem: products[index],
                                            itemIndex: index,
                                            setThisEnabled:
                                                (int index, int slideMode) {
                                              setThisEnabledNotifier.value =
                                                  Tuple2(index, slideMode);
                                            },
                                          ),
                                        );
                                      },
                                      physics: const ClampingScrollPhysics(),
                                      padding: EdgeInsetsDirectional.symmetric(
                                          horizontal: 10),
                                      scrollDirection: Axis.horizontal,
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                            width: 15,
                                          ),
                                      itemCount: products.length > 6
                                          ? 6
                                          : products.length),
                                );
                              })),
                    ),
                  ],
                );
        });
  }
}
