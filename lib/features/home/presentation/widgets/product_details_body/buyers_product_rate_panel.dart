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

    String productId = productFirstId;
    return SlidingUpPanel(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.r),
        topRight: Radius.circular(20.r),
      ),
      minHeight: 0,
      controller: panelController,
      maxHeight: 1.sh - 70.h,
      backdropEnabled: true,
      panelBuilder: (scrollController) {
        return BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                  current.getProductDetailWithoutSimilarRelatedProductsStatus ||
              previous.getFullProductDetailsStatus !=
                  current.getFullProductDetailsStatus,
          builder: (context, state) {
            if (state.getFullProductDetailsStatus ==
                GetFullProductDetailsStatus.success) {
              productId == ""
                  ? (productId = state
                        .productContentForStatusOfOpeningProductDetailsDirectly!
                        .productId
                        .toString())
                  : (productId = productId);
            }

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
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              height: 1.sh - 70.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
                color: const Color(0xffFEFEFE),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: (1.sw / 2) - 40.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.r),
                      color: const Color(0xffC4C2C2),
                    ),
                    height: 2.h,
                    width: 40.w,
                  ),
                  SizedBox(height: 10.h),
                  SvgPicture.asset(AppAssets.rateBlueSvg, height: 30.h),
                  SizedBox(height: 10.h),
                  MyTextWidget(
                    '${LocaleKeys.buyers_product_rate.tr()}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  MyTextWidget(
                    '${LocaleKeys.all_reviews_are_genuine_from_customers_who_purchased_and_actually.tr()}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      fontSize: 11.sp,
                    ),
                  ),
                  Row(
                    children: [
                      MyTextWidget(
                        '${LocaleKeys.received_the_product_through.tr()} ',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontSize: 11.sp,
                        ),
                      ),
                      MyTextWidget(
                        'trydos  ',
                        style: context.textTheme.titleLarge?.bq.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xffD3D3D3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                    height: 0.5.h,
                    width: 1.sw,
                  ),
                  StarRatingProductWidget(
                    itemHeight: 20.h,
                    itemSize: 20.h,
                    itemWidth: 26.w,
                    widgetHeight: 20.h,
                    widgetWidth: 130.w,
                    isInteractive: false,
                    svgWidth: 20.w,
                    onRatingChanged: (p0) {},
                    starColor: const Color(0xff1D1D1D),
                    initialRating:
                        (state
                            .cachedProductWithoutRelatedProductsModel[productId]
                            ?.product
                            ?.totalRating ??
                        0),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      countOfPersonRating == 0
                          ? const SizedBox.shrink()
                          : MyTextWidget(
                              countOfPersonRating.toString(),
                              style: context.textTheme.titleLarge?.bq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 11.sp,
                              ),
                            ),
                      countOfPersonRating == 0
                          ? const SizedBox.shrink()
                          : MyTextWidget(
                              ' ${LocaleKeys.buyer_rate.tr()}  |  ',
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 11.sp,
                              ),
                            ),
                      state.cachedProductWithoutRelatedProductsModel[productId] !=
                              null
                          ? state
                                        .cachedProductWithoutRelatedProductsModel[productId]!
                                        .product!
                                        .goodQualityProduct ??
                                    false
                                ? SvgPicture.asset(
                                    AppAssets.goodQualitySvg,
                                    width: 14.w,
                                  )
                                : const SizedBox.shrink()
                          : const SizedBox.shrink(),
                      state.cachedProductWithoutRelatedProductsModel[productId] !=
                              null
                          ? state
                                        .cachedProductWithoutRelatedProductsModel[productId]!
                                        .product!
                                        .goodQualityProduct ??
                                    false
                                ? MyTextWidget(
                                    ' ${LocaleKeys.overall_good_quality.tr()}  |  ',
                                    style: context.textTheme.titleLarge?.rq
                                        .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          fontSize: 11.sp,
                                        ),
                                  )
                                : const SizedBox.shrink()
                          : const SizedBox.shrink(),
                      SvgPicture.asset(
                        AppAssets.eyeSvg,
                        width: 14.w,
                        // ignore: deprecated_member_use
                        color: const Color(0xff1D1D1D),
                      ),
                      MyTextWidget(
                        ' ${LocaleKeys.views_product_with_count.tr(namedArgs: {'count': _formatViewCount(state.cachedProductWithoutRelatedProductsModel[productId]?.product?.totalViews ?? 1)})}',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 15.h,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: StarRatingProductWidget(
                            itemHeight: 16.h,
                            itemSize: 19.h,
                            itemWidth: 18.h,
                            widgetHeight: 18.h,
                            widgetWidth: 95.w,
                            isInteractive: false,
                            svgWidth: 14.w,
                            onRatingChanged: (p0) {},
                            starColor: const Color(0xff1D1D1D),
                            initialRating: 1,
                          ),
                        ),
                        SizedBox(width: 10.w),
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
                            fontSize: 11.sp,
                          ),
                        ),
                        MyTextWidget(
                          '${LocaleKeys.very_bad.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 15.h,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: StarRatingProductWidget(
                            itemHeight: 16.h,
                            itemSize: 19.h,
                            itemWidth: 18.h,
                            widgetHeight: 18.h,
                            widgetWidth: 95.w,
                            svgWidth: 14.w,
                            isInteractive: false,
                            onRatingChanged: (p0) {},
                            starColor: const Color(0xff1D1D1D),
                            initialRating: 2,
                          ),
                        ),
                        SizedBox(width: 10.w),
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
                            fontSize: 11.sp,
                          ),
                        ),
                        MyTextWidget(
                          '${LocaleKeys.bad.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 15.h,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: StarRatingProductWidget(
                            itemHeight: 16.h,
                            itemSize: 19.h,
                            itemWidth: 18.h,
                            widgetHeight: 18.h,
                            widgetWidth: 95.w,
                            isInteractive: false,
                            svgWidth: 14.w,
                            onRatingChanged: (p0) {},
                            starColor: const Color(0xff1D1D1D),
                            initialRating: 3,
                          ),
                        ),
                        SizedBox(width: 10.w),
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
                            fontSize: 11.sp,
                          ),
                        ),
                        MyTextWidget(
                          '${LocaleKeys.normal.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 15.h,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: StarRatingProductWidget(
                            itemHeight: 16.h,
                            itemSize: 19.h,
                            itemWidth: 18.h,
                            widgetHeight: 18.h,
                            widgetWidth: 95.w,
                            isInteractive: false,
                            svgWidth: 14.w,
                            onRatingChanged: (p0) {},
                            starColor: const Color(0xff1D1D1D),
                            initialRating: 4,
                          ),
                        ),
                        SizedBox(width: 10.w),
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
                            fontSize: 11.sp,
                          ),
                        ),
                        MyTextWidget(
                          '${LocaleKeys.good.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 15.h,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: StarRatingProductWidget(
                            itemHeight: 16.h,
                            itemSize: 19.h,
                            itemWidth: 18.h,
                            widgetHeight: 18.h,
                            widgetWidth: 95.w,
                            svgWidth: 14.w,
                            isInteractive: false,
                            onRatingChanged: (p0) {},
                            starColor: const Color(0xff1D1D1D),
                            initialRating: 5,
                          ),
                        ),
                        SizedBox(width: 10.w),
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
                            fontSize: 11.sp,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        MyTextWidget(
                          '${LocaleKeys.very_good.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            height: 1.45,
                            color: const Color(0xff1D1D1D),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xffD3D3D3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    height: 0.5.h,
                    width: 1.sw,
                  ),
                  MyTextWidget(
                    '${LocaleKeys.buyers_reviews_on_product_sizing.tr()}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      height: 1.45,
                      color: const Color(0xff1D1D1D),
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buyerReviewSingle(
                    "${LocaleKeys.true_label.tr()} ",
                    state.cachedProductWithoutRelatedProductsModel[productId] ==
                            null
                        ? 0
                        : state
                                  .cachedProductWithoutRelatedProductsModel[productId]
                                  ?.product
                                  ?.sizeAnalysis
                                  ?.truePercentage ??
                              0,
                    context,
                  ),
                  SizedBox(height: 10.h),
                  _buyerReviewSingle(
                    LocaleKeys.small.tr(),
                    state.cachedProductWithoutRelatedProductsModel[productId] ==
                            null
                        ? 0
                        : state
                                  .cachedProductWithoutRelatedProductsModel[productId]
                                  ?.product
                                  ?.sizeAnalysis
                                  ?.smallPercentage ??
                              0,
                    context,
                  ),
                  SizedBox(height: 10.h),
                  _buyerReviewSingle(
                    LocaleKeys.large.tr(),
                    state.cachedProductWithoutRelatedProductsModel[productId] ==
                            null
                        ? 0
                        : state
                                  .cachedProductWithoutRelatedProductsModel[productId]
                                  ?.product
                                  ?.sizeAnalysis
                                  ?.largePercentage ??
                              0,
                    context,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xffD3D3D3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    height: 0.5.h,
                    width: 1.sw,
                  ),
                  SvgPicture.asset(
                    AppAssets.recommendSvg,
                    // ignore: deprecated_member_use
                    color: const Color(0xff1D1D1D),
                    height: 30.h,
                  ),
                  SizedBox(height: 10.h),
                  MyTextWidget(
                    '${LocaleKeys.buyers_product_recommend_to_buy.tr()}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      height: 1.45,
                      color: const Color(0xff1D1D1D),
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  MyTextWidget(
                    '${LocaleKeys.all_recommendations_are_genuine_from_customers_who_purchased_and.tr()}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      height: 1.45,
                      color: const Color(0xff1D1D1D),
                      fontSize: 11.sp,
                    ),
                  ),
                  Row(
                    children: [
                      MyTextWidget(
                        '${LocaleKeys.actually_received_the_product_through.tr()} ',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          height: 1.45,
                          color: const Color(0xff1D1D1D),
                          fontSize: 11.sp,
                        ),
                      ),
                      MyTextWidget(
                        'trydos',
                        style: context.textTheme.titleLarge?.bq.copyWith(
                          height: 1.45,
                          color: const Color(0xff1D1D1D),
                          fontSize: 11.sp,
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
                          padding: EdgeInsets.only(top: 10.h),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.recommendSvg,
                                // ignore: deprecated_member_use
                                color: const Color(0xff068D06),
                                width: 12.w,
                              ),
                              MyTextWidget(
                                ' ${state.cachedProductWithoutRelatedProductsModel[productId]?.product?.recommendationStats?[0].count} ',
                                style: context.textTheme.titleLarge?.bq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      fontSize: 9.sp,
                                    ),
                              ),
                              MyTextWidget(
                                '${LocaleKeys.buyer.tr()}',
                                style: context.textTheme.titleLarge?.rq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      fontSize: 9.sp,
                                    ),
                              ),
                              const Spacer(),
                              SvgPicture.asset(
                                AppAssets.recommendSvg,
                                // ignore: deprecated_member_use
                                color: const Color(0xffFF6200),
                                width: 12.w,
                              ),
                              MyTextWidget(
                                ' ${state.cachedProductWithoutRelatedProductsModel[productId]?.product?.recommendationStats?[1].count} ',
                                style: context.textTheme.titleLarge?.bq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      fontSize: 9.sp,
                                    ),
                              ),
                              MyTextWidget(
                                '${LocaleKeys.buyer.tr()}',
                                style: context.textTheme.titleLarge?.rq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      fontSize: 9.sp,
                                    ),
                              ),
                              SizedBox(width: 38.w),
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
                            SizedBox(width: 12.w),
                            MyTextWidget(
                              ' ${LocaleKeys.recommend_it.tr()}',
                              style: context.textTheme.titleLarge?.bq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 9.sp,
                              ),
                            ),
                            const Spacer(),
                            MyTextWidget(
                              ' ${LocaleKeys.dont_recommend_it.tr()}',
                              style: context.textTheme.titleLarge?.bq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 9.sp,
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
                              margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
                              height: 4.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.r),
                                color: const Color(0xffFF6200),
                              ),
                            ),
                            Container(
                              width:
                                  (1.sw - 36.w) *
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
                              margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
                              height: 4.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.r),
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
    double numOfPercent,
    BuildContext context,
  ) {
    return SizedBox(
      width: 1.sw,
      height: 20.h,
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                height: 15.h,
                width: 284.w,
                decoration: BoxDecoration(
                  color: const Color(0xffFCFCFC),
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: const Color(0xffD3D3D3)),
                ),
              ),
              numOfPercent == 0
                  ? const SizedBox.shrink()
                  : Container(
                      height: 15.h,
                      width: (numOfPercent / 100) * 284.w,
                      decoration: BoxDecoration(
                        color: const Color(0xff1D1D1D),
                        borderRadius: BorderRadius.circular(5.r),
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
              fontSize: 11.sp,
            ),
          ),
          SizedBox(width: 18.w),
          MyTextWidget(
            text,
            style: context.textTheme.titleLarge?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 11.sp,
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
    );
  }
}
