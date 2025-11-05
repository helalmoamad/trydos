import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/data/models/get_buyers_comments_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';

import 'package:trydos/features/home/presentation/widgets/product_details_body/star_ratting_product.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

import '../../../../../common/constant/design/assets_provider.dart';

import '../../../../app/my_text_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class BuyersCommentsPanel extends StatelessWidget {
  const BuyersCommentsPanel(
      {super.key,
      required this.panelController,
      required this.currentFilterForCommend,
      required this.productFirstId});
  final ValueNotifier<String> currentFilterForCommend;
  final PanelController panelController;
  final String productFirstId;
  @override
  Widget build(BuildContext context) {
    String productId = productFirstId;
    ScrollController? _currentScrollController;

    void _handleAttachScrollController(ScrollController controller) {
      if (_currentScrollController != controller) {
        _currentScrollController?.removeListener(() {
          if (_currentScrollController!.offset >=
              (_currentScrollController!.position.maxScrollExtent * 0.6)) {
            GetIt.I<HomeBloc>().add(GetBuyersCommentsEvent(
                productId: productId,
                currentFilter: currentFilterForCommend.value,
                getWithPagination: true));
          }
        });
        _currentScrollController = controller;
        _currentScrollController?.addListener(
          () {
            if (_currentScrollController!.offset >=
                (_currentScrollController!.position.maxScrollExtent * 0.6)) {
              GetIt.I<HomeBloc>().add(GetBuyersCommentsEvent(
                  productId: productId,
                  currentFilter: currentFilterForCommend.value,
                  getWithPagination: true));
            }
          },
        );
      }
    }

    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    List<Map<String, String>> filter = [
      {LocaleKeys.size.tr(): "size"},
      {LocaleKeys.quality.tr(): "quality"},
      {LocaleKeys.color.tr(): "color"},
      {LocaleKeys.shipping.tr(): "shipping"},
      {LocaleKeys.complaint.tr(): "complaint"},
      {LocaleKeys.recommendation.tr(): "recommend"},
    ];
    return SlidingUpPanel(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        minHeight: 0,
        controller: panelController,
        maxHeight: 1.sh - 70,
        onPanelClosed: () {
          currentFilterForCommend.value = "all";
        },
        backdropEnabled: true,
        panelBuilder: (scrollController) {
          _handleAttachScrollController(scrollController);
          return ValueListenableBuilder<String>(
              valueListenable: currentFilterForCommend,
              builder: (context, _currentFilterForCommend, _) {
                return BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (previous, current) =>
                        previous
                                .getBuyersCommentsPaginationModel?[
                                    _currentFilterForCommend]
                                ?.paginationStatus !=
                            current
                                .getBuyersCommentsPaginationModel?[
                                    _currentFilterForCommend]
                                ?.paginationStatus ||
                        previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                            current
                                .getProductDetailWithoutSimilarRelatedProductsStatus ||
                        previous.getFullProductDetailsStatus !=
                            current.getFullProductDetailsStatus,
                    builder: (context, state) {
                      productId == ""
                          ? (productId = state
                              .productContentForStatusOfOpeningProductDetailsDirectly!
                              .productId
                              .toString())
                          : productId = productId;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
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
                                  horizontal: (1.sw / 2) - 40, vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: const Color(0xffC4C2C2)),
                              height: 2,
                              width: 40,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Padding(
                                padding: const EdgeInsetsGeometry.symmetric(
                                    horizontal: 10),
                                child: SvgPicture.asset(
                                  AppAssets.buyersCommentSvg,
                                  height: 30,
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                                padding: const EdgeInsetsGeometry.symmetric(
                                    horizontal: 10),
                                child: MyTextWidget(
                                  '${LocaleKeys.buyers_comment.tr()}',
                                  style: context.textTheme.titleLarge?.rr
                                      .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          fontSize: 13),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                                padding: const EdgeInsetsGeometry.symmetric(
                                    horizontal: 10),
                                child: MyTextWidget(
                                  LocaleKeys
                                      .all_comments_are_genuine_from_customers_who_purchased_and_actually
                                      .tr(),
                                  style: context.textTheme.titleLarge?.rr
                                      .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          fontSize: 11),
                                )),
                            Padding(
                                padding: const EdgeInsetsGeometry.symmetric(
                                    horizontal: 10),
                                child: Row(
                                  children: [
                                    MyTextWidget(
                                      '${LocaleKeys.received_the_product_through.tr()} ',
                                      style: context.textTheme.titleLarge?.rr
                                          .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              fontSize: 11),
                                    ),
                                    MyTextWidget(
                                      'trydos  ',
                                      style: context.textTheme.titleLarge?.br
                                          .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              fontSize: 11),
                                    ),
                                  ],
                                )),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xffD3D3D3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              height: 0.5,
                              width: 1.sw,
                            ),
                            SizedBox(
                              height: 32,
                              width: 1.sw,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                        onTap: () {
                                          if (_currentFilterForCommend ==
                                              filter[index].values.first) {
                                            currentFilterForCommend.value =
                                                "all";
                                            return;
                                          }
                                          currentFilterForCommend.value =
                                              filter[index].values.first;
                                          GetIt.I<HomeBloc>()
                                              .add(GetBuyersCommentsEvent(
                                            productId: productId,
                                            currentFilter:
                                                currentFilterForCommend.value,
                                          ));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: LanguageService
                                                          .languageCode ==
                                                      "ar"
                                                  ? 5
                                                  : 0,
                                              right: LanguageService
                                                          .languageCode !=
                                                      "ar"
                                                  ? 5
                                                  : 0),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7),
                                          alignment: Alignment.center,
                                          height: 32,
                                          decoration: BoxDecoration(
                                              color: const Color(0xffF8F8F8),
                                              border: Border.all(
                                                  color:
                                                      _currentFilterForCommend ==
                                                              filter[index]
                                                                  .values
                                                                  .first
                                                          ? Colors.blueAccent
                                                          : const Color(
                                                              0xffF8F8F8)),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: MyTextWidget(
                                            filter[index].keys.first,
                                            style: context
                                                .textTheme.titleLarge?.rr
                                                .copyWith(
                                                    color:
                                                        const Color(0xff505050),
                                                    fontSize: 11),
                                          ),
                                        )),
                                itemCount: filter.length,
                              ),
                            ),
                            Expanded(
                                child: ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              itemBuilder: (context, index) {
                                if (state.getBuyersCommentsPaginationModel?[
                                        _currentFilterForCommend] ==
                                    null) {
                                  return TrydosLoader(
                                    size: 16,
                                  );
                                }
                                if (state
                                        .getBuyersCommentsPaginationModel![
                                            _currentFilterForCommend]!
                                        .items
                                        .isEmpty &&
                                    state
                                            .getBuyersCommentsPaginationModel![
                                                _currentFilterForCommend]!
                                            .paginationStatus ==
                                        PaginationStatus.success) {
                                  return Center(
                                      child: Text(
                                          LocaleKeys.no_commends_found.tr(),
                                          style: context
                                              .textTheme.titleLarge?.rr
                                              .copyWith(
                                                  color:
                                                      const Color(0xff1D1D1D),
                                                  fontSize: 11)));
                                }
                                return (index ==
                                        (state
                                                .getBuyersCommentsPaginationModel?[
                                                    _currentFilterForCommend]
                                                ?.items
                                                .length ??
                                            0))
                                    ? SizedBox(
                                        width: 30,
                                        height: 50,
                                        child: state
                                                    .getBuyersCommentsPaginationModel?[
                                                        _currentFilterForCommend]
                                                    ?.paginationStatus ==
                                                PaginationStatus.loading
                                            ? TrydosLoader(
                                                size: 20,
                                              )
                                            : const SizedBox.shrink())
                                    : _commentWidget(
                                        context,
                                        state
                                            .getBuyersCommentsPaginationModel![
                                                _currentFilterForCommend]!
                                            .items[index]);
                              },
                              itemCount: (state
                                          .getBuyersCommentsPaginationModel?[
                                              _currentFilterForCommend]
                                          ?.items
                                          .length ??
                                      0) +
                                  1,
                            ))
                          ],
                        ),
                      );
                    });
              });
        });
  }

  Widget _commentWidget(BuildContext context, BuyersComment buyersComment) {
    String extractInitialsAndAppendXXX(String text) {
      final words = text.trim().split(RegExp(r'\s+'));
      final result =
          words.where((w) => w.isNotEmpty).map((w) => '${w[0]}xxx').join(' ');
      return result;
    }

    String formatDateByLocale(DateTime isoDate, String locale) {
      final date = isoDate;
      // صيغة "day short_month" مثل "18 Feb" أو "20 Oct"
      final format =
          DateFormat('d MMM', locale); // locale مثال "en", "ar", "fr", "tr" ...
      return format.format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: 388.w,
      height: 115,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
            width: 1.sw,
            child: Row(
              children: [
                MyCachedNetworkImage(
                    imageUrl: (buyersComment.customer?.image ?? "")
                            .contains("cloudinary")
                        ? buyersComment.customer?.image ?? ""
                        : '${dotenv.env['Images_Url']}${buyersComment.customer?.image}',
                    width: 20,
                    imageFit: BoxFit.cover,
                    height: 20),
                const SizedBox(width: 10),
                MyTextWidget(
                  extractInitialsAndAppendXXX(
                      buyersComment.customer?.name ?? ""),
                  style: context.textTheme.titleLarge?.rr
                      .copyWith(color: const Color(0xff1D1D1D), fontSize: 9),
                ),
                const Spacer(),
                MyTextWidget(
                  formatDateByLocale(buyersComment.createdAt!,
                      GetIt.I<PrefsRepository>().language ?? "en"),
                  style: context.textTheme.titleLarge?.rr
                      .copyWith(color: const Color(0xff8D8D8D), fontSize: 9),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          MyTextWidget(
            buyersComment.variant ?? "",
            style: context.textTheme.titleLarge?.mr
                .copyWith(color: const Color(0xff1D1D1D), fontSize: 9),
          ),
          const SizedBox(height: 10),
          MyTextWidget(
            buyersComment.comment ?? "",
            maxLines: 10,
            style: context.textTheme.titleLarge?.rr
                .copyWith(color: const Color(0xff1D1D1D), fontSize: 11),
          ),
          const Spacer(),
          Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.favoriteActiveSvg,
                    width: 12,
                  ),
                  MyTextWidget(
                    '  110k',
                    style: context.textTheme.titleLarge?.rr
                        .copyWith(color: const Color(0xff1D1D1D), fontSize: 9),
                  ),
                  const Spacer(),
                  MyTextWidget(
                    '${LocaleKeys.true_size.tr()} | ',
                    style: context.textTheme.titleLarge?.rr
                        .copyWith(color: const Color(0xff1D1D1D), fontSize: 9),
                  ),
                  !(buyersComment.recommendation ?? false)
                      ? const SizedBox.shrink()
                      : SvgPicture.asset(
                          AppAssets.recommendSvg,
                          // ignore: deprecated_member_use
                          color: const Color(0xff068D06),
                          width: 12,
                        ),
                  !(buyersComment.recommendation ?? false)
                      ? const SizedBox.shrink()
                      : MyTextWidget(
                          ' ${LocaleKeys.recommend_it.tr()} | ',
                          style: context.textTheme.titleLarge?.rr.copyWith(
                              color: const Color(0xff1D1D1D), fontSize: 9),
                        ),
                  MyTextWidget(
                    '${LocaleKeys.good_quality.tr()} ',
                    style: context.textTheme.titleLarge?.rr
                        .copyWith(color: const Color(0xff1D1D1D), fontSize: 9),
                  ),
                  StarRatingProductWidget(
                    itemHeight: 13,
                    itemSize: 14,
                    itemWidth: 14,
                    widgetHeight: 14,
                    widgetWidth: 71,
                    svgWidth: 12,
                    onRatingChanged: (p0) {},
                    starColor: const Color(0xff1D1D1D),
                    initialRating: (buyersComment.starRating ?? 0).toDouble(),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
