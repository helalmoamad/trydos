import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import 'package:trydos/features/app/my_text_widget.dart';

import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/star_ratting_product.dart';

import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class GlobaleInfoProduct extends StatelessWidget {
  final String productId;
  final PanelController panelController;
  const GlobaleInfoProduct(
      {super.key, required this.productId, required this.panelController});

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (p, c) =>
            p.getProductDetailWithoutSimilarRelatedProductsStatus !=
                c.getProductDetailWithoutSimilarRelatedProductsStatus ||
            p.getFullProductDetailsStatus != c.getFullProductDetailsStatus ||
            p.cachedProductWithoutRelatedProductsModel[productId] !=
                c.cachedProductWithoutRelatedProductsModel[productId] ||
            p.currentSelectedColorForEveryProduct !=
                c.currentSelectedColorForEveryProduct ||
            p.getAndAddCountViewOfProductStatus[productId] !=
                c.getAndAddCountViewOfProductStatus[productId],
        builder: (context, state) {
          int countOfPersonRating = 0;
          (state.cachedProductWithoutRelatedProductsModel[productId]?.product
              ?.ratingDetails
              ?.forEach(
            (element) {
              countOfPersonRating = countOfPersonRating + (element.count ?? 0);
            },
          ));
          return Padding(
              padding: const EdgeInsetsGeometry.symmetric(
                  horizontal: 20, vertical: 10),
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
                          initialRating:
                              state.cachedProductWithoutRelatedProductsModel[
                                          productId] ==
                                      null
                                  ? 0
                                  : (state
                                          .cachedProductWithoutRelatedProductsModel[
                                              productId]
                                          ?.product
                                          ?.totalRating ??
                                      0),
                          starColor: const Color(0xff1D1D1D),
                        ),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      countOfPersonRating == 0
                          ? const SizedBox.shrink()
                          : MyTextWidget(
                              "${countOfPersonRating} ",
                              style: context.textTheme.titleMedium?.br.copyWith(
                                  height: 1.45,
                                  color: const Color(0xff1D1D1D),
                                  fontSize: 9),
                            ),
                      countOfPersonRating == 0
                          ? const SizedBox.shrink()
                          : MyTextWidget(
                              "${LocaleKeys.n_buyer_rate.tr()}  | ",
                              style: context.textTheme.titleMedium?.rr.copyWith(
                                  height: 1.45,
                                  color: const Color(0xff1D1D1D),
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
                                      // ignore: deprecated_member_use
                                      color: const Color(0xff1D1D1D),
                                      width: 11,
                                    ),
                                    const SizedBox(
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
                                                  : "1"
                                              : "1") +
                                          "  | ",
                                      style: context.textTheme.titleMedium?.rr
                                          .copyWith(
                                              height: 1.4,
                                              color: const Color(0xff1D1D1D),
                                              fontSize: 9),
                                    )
                                  ],
                                ),
                      SvgPicture.asset(AppAssets.goodQualitySvg),
                      const SizedBox(
                        width: 2,
                      ),
                      MyTextWidget(
                        "${LocaleKeys.good_quality.tr()} | ",
                        style: context.textTheme.titleMedium?.rr.copyWith(
                            height: 1.4,
                            color: const Color(0xff1D1D1D),
                            fontSize: 9),
                      ),
                      state.cachedProductWithoutRelatedProductsModel[productId]
                                  ?.product?.recommendationStats?[0].count ==
                              0
                          ? const SizedBox.shrink()
                          : SvgPicture.asset(AppAssets.recommendSvg),
                      const SizedBox(
                        width: 2,
                      ),
                      state.cachedProductWithoutRelatedProductsModel[productId]
                                  ?.product?.recommendationStats?[0].count ==
                              0
                          ? const SizedBox.shrink()
                          : MyTextWidget(
                              "${LocaleKeys.recommend_it_by.tr()}",
                              style: context.textTheme.titleMedium?.rr.copyWith(
                                  height: 1.4,
                                  color: const Color(0xff1D1D1D),
                                  fontSize: 9),
                            ),
                      state.cachedProductWithoutRelatedProductsModel[productId]
                                  ?.product?.recommendationStats?[0].count ==
                              0
                          ? const SizedBox.shrink()
                          : MyTextWidget(
                              " ${state.cachedProductWithoutRelatedProductsModel[productId]?.product?.recommendationStats?[0].count} ${LocaleKeys.buyer.tr()} | ",
                              style: context.textTheme.titleMedium?.rr.copyWith(
                                  height: 1.4,
                                  color: const Color(0xff1D1D1D),
                                  fontSize: 9),
                            ),
                      CountryFlag.fromCountryCode(
                        "TR",
                        height: 10,
                        width: 15,
                        borderRadius: 4.r,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      MyTextWidget(
                        "${LocaleKeys.made_in.tr()} Turkey ",
                        style: context.textTheme.titleMedium?.rr.copyWith(
                            height: 1.4,
                            color: const Color(0xff1D1D1D),
                            fontSize: 9),
                      ),
                    ],
                  )));
        });
  }
}
