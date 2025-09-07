import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import 'package:trydos/features/app/my_text_widget.dart';

import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/star_ratting_product.dart';

import 'package:trydos/generated/locale_keys.g.dart';

class GlobaleInfoProduct extends StatelessWidget {
  final String productId;
  final PanelController panelController;
  const GlobaleInfoProduct(
      {super.key, required this.productId, required this.panelController});

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (p, c) =>
            p.getProductDetailWithoutSimilarRelatedProductsStatus !=
                c.getProductDetailWithoutSimilarRelatedProductsStatus ||
            p.cachedProductWithoutRelatedProductsModel[productId] !=
                c.cachedProductWithoutRelatedProductsModel[productId] ||
            p.currentSelectedColorForEveryProduct !=
                c.currentSelectedColorForEveryProduct ||
            p.getAndAddCountViewOfProductStatus[productId] !=
                c.getAndAddCountViewOfProductStatus[productId],
        builder: (context, state) {
          return Padding(
              padding:
                  EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                  height: 14,
                  width: 1.sw,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      InkWell(
                        onTap: () => panelController.open(),
                        child: StarRatingProductWidget(
                          itemHeight: 13,
                          itemSize: 14,
                          itemWidth: 14,
                          widgetHeight: 14,
                          widgetWidth: 71,
                          svgWidth: 12,
                          isInteractive: false,
                          onRatingChanged: (p0) {},
                          initialRating: 3,
                          starColor: Color(0xff1D1D1D),
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      MyTextWidget(
                        "368 ",
                        style: context.textTheme.titleMedium?.br.copyWith(
                            height: 1.45,
                            color: Color(0xff1D1D1D),
                            fontSize: 9),
                      ),
                      MyTextWidget(
                        "${LocaleKeys.n_buyer_rate.tr()}  | ",
                        style: context.textTheme.titleMedium?.rr.copyWith(
                            height: 1.45,
                            color: Color(0xff1D1D1D),
                            fontSize: 9),
                      ),
                      state.getAndAddCountViewOfProductStatus[productId] ==
                                  null ||
                              state.cachedProductWithoutRelatedProductsModel[
                                      productId] ==
                                  null
                          ? Container(
                              width: 18,
                              height: 18,
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade400,
                                highlightColor: Colors.grey.shade100,
                                child: SvgPicture.asset(AppAssets.eyeSvg),
                              ),
                            )
                          : (state
                                          .cachedProductWithoutRelatedProductsModel[
                                              productId]!
                                          .product !=
                                      null
                                  ? state
                                          .cachedProductWithoutRelatedProductsModel[
                                              productId]!
                                          .product!
                                          .viewsCount ==
                                      null
                                  : true)
                              ? Container(
                                  width: 18,
                                  height: 18,
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade400,
                                    highlightColor: Colors.grey.shade100,
                                    child: SvgPicture.asset(AppAssets.eyeSvg),
                                  ),
                                )
                              : Row(
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.eyeSvg,
                                      height: 11,
                                      color: Color(0xff1D1D1D),
                                      width: 11,
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    MyTextWidget(
                                      (state.cachedProductWithoutRelatedProductsModel[
                                                      productId] !=
                                                  null
                                              ? state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              productId]!
                                                          .product !=
                                                      null
                                                  ? state
                                                      .cachedProductWithoutRelatedProductsModel[
                                                          productId]!
                                                      .product!
                                                      .viewsCount
                                                      .toString()
                                                  : "0"
                                              : "0") +
                                          "  | ",
                                      style: context.textTheme.titleMedium?.rr
                                          .copyWith(
                                              height: 1.4,
                                              color: Color(0xff1D1D1D),
                                              fontSize: 9),
                                    )
                                  ],
                                ),
                      SvgPicture.asset(AppAssets.goodQualitySvg),
                      SizedBox(
                        width: 2,
                      ),
                      MyTextWidget(
                        "${LocaleKeys.good_quality.tr()} | ",
                        style: context.textTheme.titleMedium?.rr.copyWith(
                            height: 1.4, color: Color(0xff1D1D1D), fontSize: 9),
                      ),
                      SvgPicture.asset(AppAssets.recommendSvg),
                      SizedBox(
                        width: 2,
                      ),
                      MyTextWidget(
                        "${LocaleKeys.recommend_it_by.tr()}",
                        style: context.textTheme.titleMedium?.rr.copyWith(
                            height: 1.4, color: Color(0xff1D1D1D), fontSize: 9),
                      ),
                      MyTextWidget(
                        " 215 ${LocaleKeys.buyer.tr()} | ",
                        style: context.textTheme.titleMedium?.rr.copyWith(
                            height: 1.4, color: Color(0xff1D1D1D), fontSize: 9),
                      ),
                      CountryFlag.fromCountryCode(
                        "TR",
                        height: 10,
                        width: 15,
                        borderRadius: 4.r,
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      MyTextWidget(
                        "${LocaleKeys.made_in.tr()} Turkey ",
                        style: context.textTheme.titleMedium?.rr.copyWith(
                            height: 1.4, color: Color(0xff1D1D1D), fontSize: 9),
                      ),
                    ],
                  )));
        });
  }
}
