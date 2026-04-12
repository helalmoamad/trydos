import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';

import '../../../../core/utils/theme_state.dart';

class SearchResult extends StatefulWidget {
  final TextEditingController controller;
  const SearchResult({super.key, required this.controller});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends ThemeState<SearchResult> {
  final ValueNotifier<bool> appearSearchResult = ValueNotifier(false);
  @override
  void initState() {
    widget.controller.addListener(() {
      if (widget.controller.text.length > 2) {
        appearSearchResult.value = true;
      } else {
        appearSearchResult.value = false;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return ValueListenableBuilder<bool>(
      valueListenable: appearSearchResult,
      builder: (context, value, child) => BlocBuilder<BoutiqueBloc, BoutiqueState>(
        buildWhen: (p, c) =>
            p.getProductListingWithFiltersPaginationModels['search'] !=
                c.getProductListingWithFiltersPaginationModels['search'] ||
            p.getProductListingWithFiltersPaginationModels['searchwithoutFilter'] !=
                c.getProductListingWithFiltersPaginationModels['searchwithoutFilter'] ||
            p.getProductFiltersStatus != c.getProductFiltersStatus ||
            p.cashedOrginalBoutique != c.cashedOrginalBoutique,
        builder: (context, state) {
          String key =
              'search' + (state.cashedOrginalBoutique ? 'withoutFilter' : "");
          if (state
                  .getProductListingWithFiltersPaginationModels['search']
                  ?.paginationStatus ==
              PaginationStatus.loading) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 20.0),
                  child: MyTextWidget(
                    LocaleKeys.find_products.tr(),
                    style: textTheme.titleMedium?.rq.copyWith(
                      height: 15 / 12,
                      color: const Color(0xff505050),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 15.w,
                  height: 15.h,
                  child: Center(
                    child: TrydosLoader(color: Colors.black, size: 15.h),
                  ),
                ),
              ],
            );
          }
          if (state
                      .getProductListingWithFiltersPaginationModels[key]
                      ?.paginationStatus !=
                  PaginationStatus.success ||
              state.getProductListingWithFiltersPaginationModels[key] == null ||
              !value) {
            return const SizedBox.shrink();
          }
          /* Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 20.0),
                  child: MyTextWidget(
                    LocaleKeys.find_products.tr(),
                    style: textTheme.titleMedium?.rq
                        .copyWith(height: 15 / 12, color: Color(0xff505050)),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                ScrollConfiguration(
                  behavior: CupertinoScrollBehavior(),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (ctx, index) => Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        InkWell(
                          child: Container(
                              height: 50,
                              width: 1.sw,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Color(0xffF8F8F8),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 35,
                                  ),
                                  Flexible(
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey[200]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 300.0,
                                        height: 200.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                ],
                              )),
                        ),
                        Container(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[200]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 300.0,
                              height: 200.0,
                              color: Color(0xffF8F8F8),
                            ),
                          ),
                          height: 50,
                          width: 35,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Color(0xff388CFF), width: 0.3),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(5),
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                        )
                      ],
                    ),
                    itemCount: 5,
                    separatorBuilder: (ctx, index) => SizedBox(
                      height: 5,
                    ),
                  ),
                ),
              ],
            );*/

          if (state.getProductListingWithFiltersPaginationModels[key] == null) {
            return const SizedBox.shrink();
          }
          if (state
              .getProductListingWithFiltersPaginationModels[key]!
              .items
              .isNullOrEmpty) {
            return const Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: MyTextWidget(
                  "No Products Found",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.h),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 20.w),
                child: MyTextWidget(
                  LocaleKeys.find_products.tr(),
                  style: textTheme.titleMedium?.rq.copyWith(
                    fontSize: 13.sp,
                    height: 15 / 12,
                    color: const Color(0xff505050),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              ScrollConfiguration(
                behavior: const CupertinoScrollBehavior(),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  itemBuilder: (ctx, index) {
                    String filePath =
                        ((state
                                    .getProductListingWithFiltersPaginationModels[key]!
                                    .items[index]
                                    .syncColorImages
                                    ?.length ??
                                0) >
                            0)
                        ? (state
                                  .getProductListingWithFiltersPaginationModels[key]!
                                  .items[index]
                                  .syncColorImages?[0]
                                  .images?[0]
                                  .filePath) ??
                              ""
                        : state
                              .getProductListingWithFiltersPaginationModels[key]!
                              .items[index]
                              .images![0]
                              .filePath!;
                    filePath = addSuitableWidthAndHeightToImage(
                      imageUrl: filePath,
                      height: 50,
                      width: 35,
                    );

                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        InkWell(
                          onTap: () {
                            BlocProvider.of<HomeBloc>(context).add(
                              AddSearchTextToHistoryEvent(
                                searchTitle: widget.controller.text,
                              ),
                            );
                            BlocProvider.of<HomeBloc>(context).add(
                              GetFullProductDetailsEvent(
                                currentColorName:
                                    state
                                        .getProductListingWithFiltersPaginationModels[key]!
                                        .items[index]
                                        .syncColorImages
                                        .isNullOrEmpty
                                    ? null
                                    : state
                                          .getProductListingWithFiltersPaginationModels[key]!
                                          .items[index]
                                          .syncColorImages
                                          ?.first
                                          .colorName,
                                productSlug:
                                    state
                                        .getProductListingWithFiltersPaginationModels[key]!
                                        .items[index]
                                        .slug ??
                                    "",
                              ),
                            );
                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () => Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => ProductDetailsPageNew(
                                        productSlugForOpeningChatDirectly: state
                                            .getProductListingWithFiltersPaginationModels[key]!
                                            .items[index]
                                            .slug,
                                        productIdForOpeningChatDirectly: state
                                            .getProductListingWithFiltersPaginationModels[key]!
                                            .items[index]
                                            .productId
                                            .toString(),
                                      ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 54.h,
                            width: 1.sw,
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            decoration: BoxDecoration(
                              color: const Color(0xffF8F8F8),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 35.w),
                                Flexible(
                                  child: MyTextWidget(
                                    state
                                        .getProductListingWithFiltersPaginationModels[key]!
                                        .items[index]
                                        .name!,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: context.textTheme.titleLarge?.lq
                                        .copyWith(
                                          height: 15 / 12,
                                          fontSize: 13.sp,
                                          color: const Color(0xffC4C2C2),
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 54.h,
                          width: 35.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xff388CFF),
                              width: 0.3,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.r),
                              topRight: Radius.circular(5.r),
                              bottomLeft: Radius.circular(15.r),
                              bottomRight: Radius.circular(5.r),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.r),
                              topRight: Radius.circular(5.r),
                              bottomLeft: Radius.circular(15.r),
                              bottomRight: Radius.circular(5.r),
                            ),
                            child: Image.network(
                              filePath,
                              height: 54.h,
                              fit: BoxFit.contain,
                              width: 35.w,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  itemCount: state
                      .getProductListingWithFiltersPaginationModels[key]!
                      .items
                      .length,
                  separatorBuilder: (ctx, index) => const SizedBox(height: 5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
