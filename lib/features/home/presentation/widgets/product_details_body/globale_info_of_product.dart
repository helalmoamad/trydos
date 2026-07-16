import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/constant/countries.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';

import 'package:trydos/features/app/my_text_widget.dart';

import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/star_ratting_product.dart';

import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class GlobaleInfoProduct extends StatelessWidget {
  final String productId;
  final PanelController panelController;
  const GlobaleInfoProduct({
    super.key,
    required this.productId,
    required this.panelController,
  });

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
              c.currentSelectedColorForEveryProduct /*||
          p.getAndAddCountViewOfProductStatus[productId] !=
              c.getAndAddCountViewOfProductStatus[productId]*/,
      builder: (context, state) {
        int countOfPersonRating = 0;
        (state
            .cachedProductWithoutRelatedProductsModel[productId]
            ?.product
            ?.ratingDetails
            ?.forEach((element) {
              countOfPersonRating = countOfPersonRating + (element.count ?? 0);
            }));

        final String? rawIso = state
            .cachedProductWithoutRelatedProductsModel[productId]
            ?.product
            ?.iso;
        // TEMP DEBUG: remove after confirming the country renders.
        debugPrint('[made_in] productId=$productId rawIso=$rawIso');
        final String productIso = (rawIso ?? '').toLowerCase();
        Country newCountry = countries.firstWhere(
          (element) => element.code.toLowerCase() == productIso,

          orElse: () => const Country(
            name: '',
            flag: '',
            code: '',
            dialCode: '',
            minLength: 0,
            maxLength: 0,
          ),
        );

        return Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
          child: SizedBox(
            height: 18.h,
            width: 1.sw,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                InkWell(
                  onTap: () => panelController.open(),
                  child: StarRatingProductWidget(
                    itemHeight: 13.h,
                    itemSize: 14.sp,
                    itemWidth: 14.w,
                    widgetHeight: 14.h,
                    widgetWidth: 71.w,
                    svgWidth: 12.w,
                    isInteractive: false,
                    onRatingChanged: (p0) {},
                    initialRating:
                        state.cachedProductWithoutRelatedProductsModel[productId] ==
                            null
                        ? 0
                        : (state
                                  .cachedProductWithoutRelatedProductsModel[productId]
                                  ?.product
                                  ?.totalRating ??
                              0),
                    starColor: const Color(0xff1D1D1D),
                  ),
                ),
                const SizedBox(width: 2),
                countOfPersonRating == 0
                    ? const SizedBox.shrink()
                    : MyTextWidget(
                        "${countOfPersonRating} ",
                        style: context.textTheme.titleMedium?.bq.copyWith(
                          height: 1.45,
                          color: const Color(0xff1D1D1D),
                          fontSize: 9.sp,
                        ),
                      ),
                countOfPersonRating == 0
                    ? const SizedBox.shrink()
                    : MyTextWidget(
                        "${LocaleKeys.n_buyer_rate.tr()}  | ",
                        style: context.textTheme.titleMedium?.rq.copyWith(
                          height: 1.45,
                          color: const Color(0xff1D1D1D),
                          fontSize: 9.sp,
                        ),
                      ),
                /*state.getAndAddCountViewOfProductStatus[productId] == null ||
                        state.cachedProductWithoutRelatedProductsModel[productId] ==
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
                    :*/
                (state.cachedProductWithoutRelatedProductsModel[productId] ==
                            null
                        ? true
                        : state
                                  .cachedProductWithoutRelatedProductsModel[productId]!
                                  .product !=
                              null
                        ? state
                                  .cachedProductWithoutRelatedProductsModel[productId]!
                                  .product!
                                  .totalViews ==
                              null
                        : true)
                    ? Container(
                        width: 18.w,
                        height: 18.h,
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
                            height: 11.h,
                            // ignore: deprecated_member_use
                            color: const Color(0xff1D1D1D),
                            width: 11.w,
                          ),
                          const SizedBox(width: 2),
                          MyTextWidget(
                            (state.cachedProductWithoutRelatedProductsModel[productId] !=
                                        null
                                    ? state
                                                  .cachedProductWithoutRelatedProductsModel[productId]!
                                                  .product !=
                                              null
                                          ? state
                                                .cachedProductWithoutRelatedProductsModel[productId]!
                                                .product!
                                                .totalViews
                                                .toString()
                                          : "1"
                                    : "1") +
                                "  | ",
                            style: context.textTheme.titleMedium?.rq.copyWith(
                              height: 1.4,
                              color: const Color(0xff1D1D1D),
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                state.cachedProductWithoutRelatedProductsModel[productId] !=
                        null
                    ? state
                                  .cachedProductWithoutRelatedProductsModel[productId]!
                                  .product!
                                  .goodQualityProduct ??
                              false
                          ? SvgPicture.asset(AppAssets.goodQualitySvg)
                          : const SizedBox.shrink()
                    : const SizedBox.shrink(),
                const SizedBox(width: 2),
                state.cachedProductWithoutRelatedProductsModel[productId] !=
                        null
                    ? state
                                  .cachedProductWithoutRelatedProductsModel[productId]!
                                  .product!
                                  .goodQualityProduct ??
                              false
                          ? MyTextWidget(
                              "${LocaleKeys.good_quality.tr()} | ",
                              style: context.textTheme.titleMedium?.rq.copyWith(
                                height: 1.4,
                                color: const Color(0xff1D1D1D),
                                fontSize: 9.sp,
                              ),
                            )
                          : const SizedBox.shrink()
                    : const SizedBox.shrink(),
                (state
                            .cachedProductWithoutRelatedProductsModel[productId]
                            ?.product
                            ?.recommendationStats
                            .isNullOrEmpty ??
                        true)
                    ? const SizedBox.shrink()
                    : state
                              .cachedProductWithoutRelatedProductsModel[productId]
                              ?.product
                              ?.recommendationStats?[0]
                              .count ==
                          0
                    ? const SizedBox.shrink()
                    : SvgPicture.asset(AppAssets.recommendSvg),
                const SizedBox(width: 2),
                state
                            .cachedProductWithoutRelatedProductsModel[productId]
                            ?.product
                            ?.recommendationStats?[0]
                            .count ==
                        0
                    ? const SizedBox.shrink()
                    : MyTextWidget(
                        "${LocaleKeys.recommend_it_by.tr()}",
                        style: context.textTheme.titleMedium?.rq.copyWith(
                          height: 1.4,
                          color: const Color(0xff1D1D1D),
                          fontSize: 9.sp,
                        ),
                      ),
                state
                            .cachedProductWithoutRelatedProductsModel[productId]
                            ?.product
                            ?.recommendationStats?[0]
                            .count ==
                        0
                    ? const SizedBox.shrink()
                    : MyTextWidget(
                        " ${state.cachedProductWithoutRelatedProductsModel[productId]?.product?.recommendationStats?[0].count} ${LocaleKeys.buyer.tr()} | ",
                        style: context.textTheme.titleMedium?.rq.copyWith(
                          height: 1.4,
                          color: const Color(0xff1D1D1D),
                          fontSize: 9.sp,
                        ),
                      ),
                CountryFlag.fromCountryCode(
                  state
                          .cachedProductWithoutRelatedProductsModel[productId]
                          ?.product
                          ?.iso ??
                      '',
                  height: 10.h,
                  width: 15.w,
                  borderRadius: 4.r,
                ),
                const SizedBox(width: 2),
                (rawIso?.isNotEmpty ?? false)  ?
                MyTextWidget(
                  "${LocaleKeys.made_in.tr()} ${newCountry.name} ",
                  style: context.textTheme.titleMedium?.rq.copyWith(
                    height: 1.4,
                    color: const Color(0xff1D1D1D),
                    fontSize: 9.sp,
                  ),
                ) : const SizedBox.shrink() ,
              ],
            ),
          ),
        );
      },
    );
  }
}
