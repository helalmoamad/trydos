import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/star_ratting_product.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../app/my_text_widget.dart';

class BuyersProductRatePanel extends StatelessWidget {
  const BuyersProductRatePanel({
    super.key,
    required this.panelController,
    required this.productFirstId,
  });

  final PanelController panelController;
  final String productFirstId;

  // Dynamic view count - can be changed to any number
  // Change this value to any number you want

  // Helper method to format view count
  String _formatViewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };

    String productId = productFirstId;
    return SlidingUpPanel(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      minHeight: 0,
      controller: panelController,
      maxHeight: 1.sh - 70,
      backdropEnabled: true,
      panelBuilder: (scrollController) {
        return BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                  current.getProductDetailWithoutSimilarRelatedProductsStatus ||
              previous.getFullProductDetailsStatus !=
                  current.getFullProductDetailsStatus,
          builder: (context, state) {
            productId == ""
                ? (productId = state
                      .productContentForStatusOfOpeningProductDetailsDirectly!
                      .productId
                      .toString())
                : (productId = productId);

            if (state.cachedProductWithoutRelatedProductsModel[productId] ==
                null) {
              return const SizedBox.shrink();
            }
            int countOfPersonRating = 0;
            (state
                .cachedProductWithoutRelatedProductsModel[productId]
                ?.product
                ?.ratingDetails
                ?.forEach((element) {
                  countOfPersonRating =
                      countOfPersonRating + (element.count ?? 0);
                }));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 1.sh - 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xffFEFEFE),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: (1.sw / 2) - 40,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: const Color(0xffC4C2C2),
                    ),
                    height: 2,
                    width: 40,
                  ),
                  const SizedBox(height: 10),
                  SvgPicture.asset(AppAssets.rateBlueSvg, height: 30),
                  const SizedBox(height: 10),
                  MyTextWidget(
                    '${LocaleKeys.buyers_product_rate.tr()}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyTextWidget(
                    '${LocaleKeys.all_reviews_are_genuine_from_customers_who_purchased_and_actually.tr()}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      fontSize: 11,
                    ),
                  ),
                  Row(
                    children: [
                      MyTextWidget(
                        '${LocaleKeys.received_the_product_through.tr()} ',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontSize: 11,
                        ),
                      ),
                      MyTextWidget(
                        'trydos  ',
                        style: context.textTheme.titleLarge?.bq.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xffD3D3D3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    height: 0.5,
                    width: 1.sw,
                  ),
                  StarRatingProductWidget(
                    itemHeight: 20,
                    itemSize: 20,
                    itemWidth: 26,
                    widgetHeight: 20,
                    widgetWidth: 130,
                    isInteractive: false,
                    svgWidth: 20,
                    onRatingChanged: (p0) {},
                    starColor: const Color(0xff1D1D1D),
                    initialRating:
                        (state
                            .cachedProductWithoutRelatedProductsModel[productId]
                            ?.product
                            ?.totalRating ??
                        0),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      countOfPersonRating == 0
                          ? const SizedBox.shrink()
                          : MyTextWidget(
                              countOfPersonRating.toString(),
                              style: context.textTheme.titleLarge?.bq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 11,
                              ),
                            ),
                      countOfPersonRating == 0
                          ? const SizedBox.shrink()
                          : MyTextWidget(
                              ' ${LocaleKeys.buyer_rate.tr()}  |  ',
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 11,
                              ),
                            ),
                      SvgPicture.asset(AppAssets.goodQualitySvg, width: 14),
                      MyTextWidget(
                        ' ${LocaleKeys.overall_good_quality.tr()}  |  ',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontSize: 11,
                        ),
                      ),
                      SvgPicture.asset(
                        AppAssets.eyeSvg,
                        width: 14,
                        // ignore: deprecated_member_use
                        color: const Color(0xff1D1D1D),
                      ),
                      MyTextWidget(
                        ' ${LocaleKeys.views_product_with_count.tr(namedArgs: {'count': _formatViewCount(state.cachedProductWithoutRelatedProductsModel[productId]?.product?.totalViews ?? 1)})}',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 15,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: StarRatingProductWidget(
                            itemHeight: 16,
                            itemSize: 19,
                            itemWidth: 18,
                            widgetHeight: 18,
                            widgetWidth: 95,
                            isInteractive: false,
                            svgWidth: 14,
                            onRatingChanged: (p0) {},
                            starColor: const Color(0xff1D1D1D),
                            initialRating: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        MyTextWidget(
                          (state
                                      .cachedProductWithoutRelatedProductsModel[productId]
                                      ?.product
                                      ?.ratingDetails
                                      ?.firstWhere(
                                        (element) => element.ratingGroup == "1",
                                        orElse: () => RatingDetail(
                                          count: 0,
                                          ratingGroup: "0",
                                        ),
                                      )
                                      .count ??
                                  0)
                              .toString(),
                          style: context.textTheme.titleLarge?.bq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11,
                          ),
                        ),
                        MyTextWidget(
                          '${LocaleKeys.very_bad.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 15,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: StarRatingProductWidget(
                            itemHeight: 16,
                            itemSize: 19,
                            itemWidth: 18,
                            widgetHeight: 18,
                            widgetWidth: 95,
                            svgWidth: 14,
                            isInteractive: false,
                            onRatingChanged: (p0) {},
                            starColor: const Color(0xff1D1D1D),
                            initialRating: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        MyTextWidget(
                          (state
                                      .cachedProductWithoutRelatedProductsModel[productId]
                                      ?.product
                                      ?.ratingDetails
                                      ?.firstWhere(
                                        (element) => element.ratingGroup == "2",
                                        orElse: () => RatingDetail(
                                          count: 0,
                                          ratingGroup: "0",
                                        ),
                                      )
                                      .count ??
                                  0)
                              .toString(),
                          style: context.textTheme.titleLarge?.bq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11,
                          ),
                        ),
                        MyTextWidget(
                          '${LocaleKeys.bad.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 15,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: StarRatingProductWidget(
                            itemHeight: 16,
                            itemSize: 19,
                            itemWidth: 18,
                            widgetHeight: 18,
                            widgetWidth: 95,
                            isInteractive: false,
                            svgWidth: 14,
                            onRatingChanged: (p0) {},
                            starColor: const Color(0xff1D1D1D),
                            initialRating: 3,
                          ),
                        ),
                        const SizedBox(width: 10),
                        MyTextWidget(
                          (state
                                      .cachedProductWithoutRelatedProductsModel[productId]
                                      ?.product
                                      ?.ratingDetails
                                      ?.firstWhere(
                                        (element) => element.ratingGroup == "3",
                                        orElse: () => RatingDetail(
                                          count: 0,
                                          ratingGroup: "0",
                                        ),
                                      )
                                      .count ??
                                  0)
                              .toString(),
                          style: context.textTheme.titleLarge?.bq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11,
                          ),
                        ),
                        MyTextWidget(
                          '${LocaleKeys.normal.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 15,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: StarRatingProductWidget(
                            itemHeight: 16,
                            itemSize: 19,
                            itemWidth: 18,
                            widgetHeight: 18,
                            widgetWidth: 95,
                            isInteractive: false,
                            svgWidth: 14,
                            onRatingChanged: (p0) {},
                            starColor: const Color(0xff1D1D1D),
                            initialRating: 4,
                          ),
                        ),
                        const SizedBox(width: 10),
                        MyTextWidget(
                          (state
                                      .cachedProductWithoutRelatedProductsModel[productId]
                                      ?.product
                                      ?.ratingDetails
                                      ?.firstWhere(
                                        (element) => element.ratingGroup == "4",
                                        orElse: () => RatingDetail(
                                          count: 0,
                                          ratingGroup: "0",
                                        ),
                                      )
                                      .count ??
                                  0)
                              .toString(),
                          style: context.textTheme.titleLarge?.bq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11,
                          ),
                        ),
                        MyTextWidget(
                          '${LocaleKeys.good.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 15,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: StarRatingProductWidget(
                            itemHeight: 16,
                            itemSize: 19,
                            itemWidth: 18,
                            widgetHeight: 18,
                            widgetWidth: 95,
                            svgWidth: 14,
                            isInteractive: false,
                            onRatingChanged: (p0) {},
                            starColor: const Color(0xff1D1D1D),
                            initialRating: 5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        MyTextWidget(
                          (state
                                      .cachedProductWithoutRelatedProductsModel[productId]
                                      ?.product
                                      ?.ratingDetails
                                      ?.firstWhere(
                                        (element) => element.ratingGroup == "5",
                                        orElse: () => RatingDetail(
                                          count: 0,
                                          ratingGroup: "0",
                                        ),
                                      )
                                      .count ??
                                  0)
                              .toString(),
                          style: context.textTheme.titleLarge?.bq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 10),
                        MyTextWidget(
                          '${LocaleKeys.very_good.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xffD3D3D3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    height: 0.5,
                    width: 1.sw,
                  ),
                  MyTextWidget(
                    '${LocaleKeys.buyers_reviews_on_product_sizing.tr()}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      height: 1.45,
                      color: const Color(0xff1D1D1D),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buyerReviewSingle(
                    "${LocaleKeys.true_label.tr()} ",
                    70,
                    context,
                  ),
                  const SizedBox(height: 10),
                  _buyerReviewSingle(LocaleKeys.small.tr(), 3, context),
                  const SizedBox(height: 10),
                  _buyerReviewSingle(LocaleKeys.large.tr(), 1, context),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xffD3D3D3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    height: 0.5,
                    width: 1.sw,
                  ),
                  SvgPicture.asset(
                    AppAssets.recommendSvg,
                    // ignore: deprecated_member_use
                    color: const Color(0xff1D1D1D),
                    height: 30,
                  ),
                  const SizedBox(height: 10),
                  MyTextWidget(
                    '${LocaleKeys.buyers_product_recommend_to_buy.tr()}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      height: 1.45,
                      color: const Color(0xff1D1D1D),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyTextWidget(
                    '${LocaleKeys.all_recommendations_are_genuine_from_customers_who_purchased_and.tr()}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      height: 1.45,
                      color: const Color(0xff1D1D1D),
                      fontSize: 11,
                    ),
                  ),
                  Row(
                    children: [
                      MyTextWidget(
                        '${LocaleKeys.actually_received_the_product_through.tr()} ',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          height: 1.45,
                          color: const Color(0xff1D1D1D),
                          fontSize: 11,
                        ),
                      ),
                      MyTextWidget(
                        'trydos',
                        style: context.textTheme.titleLarge?.bq.copyWith(
                          height: 1.45,
                          color: const Color(0xff1D1D1D),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  state
                              .cachedProductWithoutRelatedProductsModel[productId]
                              ?.product
                              ?.recommendationStats?[0]
                              .count ==
                          0
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.recommendSvg,
                                // ignore: deprecated_member_use
                                color: const Color(0xff068D06),
                                width: 12,
                              ),
                              MyTextWidget(
                                ' ${state.cachedProductWithoutRelatedProductsModel[productId]?.product?.recommendationStats?[0].count} ',
                                style: context.textTheme.titleLarge?.bq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      fontSize: 9,
                                    ),
                              ),
                              MyTextWidget(
                                '${LocaleKeys.buyer.tr()}',
                                style: context.textTheme.titleLarge?.rq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      fontSize: 9,
                                    ),
                              ),
                              const Spacer(),
                              SvgPicture.asset(
                                AppAssets.recommendSvg,
                                // ignore: deprecated_member_use
                                color: const Color(0xffFF6200),
                                width: 12,
                              ),
                              MyTextWidget(
                                ' ${state.cachedProductWithoutRelatedProductsModel[productId]?.product?.recommendationStats?[1].count} ',
                                style: context.textTheme.titleLarge?.bq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      fontSize: 9,
                                    ),
                              ),
                              MyTextWidget(
                                '${LocaleKeys.buyer.tr()}',
                                style: context.textTheme.titleLarge?.rq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      fontSize: 9,
                                    ),
                              ),
                              const SizedBox(width: 38),
                            ],
                          ),
                        ),
                  state
                              .cachedProductWithoutRelatedProductsModel[productId]
                              ?.product
                              ?.recommendationStats?[0]
                              .count ==
                          0
                      ? const SizedBox.shrink()
                      : Row(
                          children: [
                            const SizedBox(width: 12),
                            MyTextWidget(
                              ' ${LocaleKeys.recommend_it.tr()}',
                              style: context.textTheme.titleLarge?.bq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 9,
                              ),
                            ),
                            const Spacer(),
                            MyTextWidget(
                              ' ${LocaleKeys.dont_recommend_it.tr()}',
                              style: context.textTheme.titleLarge?.bq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                  state
                              .cachedProductWithoutRelatedProductsModel[productId]
                              ?.product
                              ?.recommendationStats?[0]
                              .count ==
                          0
                      ? const SizedBox.shrink()
                      : Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                top: 10,
                                bottom: 10,
                              ),
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: const Color(0xffFF6200),
                              ),
                            ),
                            Container(
                              width:
                                  (1.sw - 36) *
                                  ((double.tryParse(
                                            state
                                                    .cachedProductWithoutRelatedProductsModel[productId]
                                                    ?.product
                                                    ?.recommendationStats?[0]
                                                    .percentage ??
                                                "0",
                                          ) ??
                                          0) /
                                      100),
                              margin: const EdgeInsets.only(
                                top: 10,
                                bottom: 10,
                              ),
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: const Color(0xff068D06),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buyerReviewSingle(
    String text,
    int numOfPercent,
    BuildContext context,
  ) {
    return SizedBox(
      width: 1.sw,
      height: 20,
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                height: 15,
                width: 284.w,
                decoration: BoxDecoration(
                  color: const Color(0xffFCFCFC),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xffD3D3D3)),
                ),
              ),
              Container(
                height: 15,
                width: (numOfPercent / 100) * 284.w,
                decoration: BoxDecoration(
                  color: const Color(0xff1D1D1D),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xff1D1D1D)),
                ),
              ),
            ],
          ),
          const Spacer(),
          MyTextWidget(
            "${numOfPercent}%",
            style: context.textTheme.titleLarge?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 11,
            ),
          ),
          SizedBox(width: 18.w),
          MyTextWidget(
            text,
            style: context.textTheme.titleLarge?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 11,
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
    );
  }
}
