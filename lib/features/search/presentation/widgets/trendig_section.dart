import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/popular_search_terms_model.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../app/my_text_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class TrendingSection extends StatefulWidget {
  final List<PopularSearchTerm> popularSearchTerms;
  final TextEditingController controller;
  final ValueNotifier<int> buildSearchResult;
  final ValueNotifier<bool> appearTrendingAndHistory;
  TrendingSection(
      {required this.popularSearchTerms,
      required this.controller,
      required this.appearTrendingAndHistory,
      required this.buildSearchResult,
      super.key});

  @override
  State<TrendingSection> createState() => _TrendingSectionState();
}

class _TrendingSectionState extends State<TrendingSection> {
  final ValueNotifier<bool> changeViewMode = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 20.0, start: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: changeViewMode,
              builder: (context, value, _) {
                return SizedBox(
                  height: 28,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          changeViewMode.value = !changeViewMode.value;
                        },
                        child: SvgPicture.asset(
                          AppAssets.trendingSvg,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      if (value) ...{
                        MyTextWidget(
                          'Popular Search',
                          style: context.textTheme.titleLarge?.mq.copyWith(
                              height: 18 / 14, color: const Color(0xff505050)),
                        ),
                      } else ...{
                        Expanded(
                            child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, index) => Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: const Color(0xffF8F8F8),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  widget.controller.text =
                                      widget.popularSearchTerms[index].term ??
                                          "";
                                  widget.buildSearchResult.value = 1;
                                  //  widget.buildSearchResult.value = 1;
                                  widget.appearTrendingAndHistory.value = true;

                                  Filter filters =
                                      BlocProvider.of<BoutiqueBloc>(context)
                                              .state
                                              .choosedFiltersByUser['search']
                                              ?.filters ??
                                          Filter();
                                  BlocProvider.of<BoutiqueBloc>(context)
                                      .add(ChangeAppliedFiltersEvent(
                                    boutiqueSlug: 'search',
                                    filtersAppliedByUser:
                                        GetProductFiltersModel(
                                            filters:
                                                filters.copyWithSaveOtherField(
                                      prices: filters.prices,
                                      searchText:
                                          widget.popularSearchTerms[index].term,
                                    )),
                                  ));
                                  BlocProvider.of<BoutiqueBloc>(context).add(
                                      GetProductsWithFiltersEvent(
                                          offset: 1,
                                          boutiqueSlug: 'search',
                                          resetChoosedFilters: false,
                                          fromSearch: true,
                                          searchText: widget
                                              .popularSearchTerms[index].term));

                                  BlocProvider.of<BoutiqueBloc>(context).add(
                                      GetFiltersEvent(
                                          fromHomePageSearch: true,
                                          boutiqueSlug: 'search',
                                          searchText: widget
                                              .popularSearchTerms[index].term));
                                },
                                child: Text(
                                  widget.popularSearchTerms[index].term ?? "",
                                  style: context.textTheme.titleLarge?.rq
                                      .copyWith(
                                          height: 18 / 14,
                                          color: const Color(0xff8D8D8D)),
                                ),
                              ),
                            ),
                          ),
                          itemCount: widget.popularSearchTerms.length,
                          separatorBuilder: (ctx, index) => const SizedBox(
                            width: 5,
                          ),
                        ))
                      }
                    ],
                  ),
                );
              }),
          ValueListenableBuilder<bool>(
              valueListenable: changeViewMode,
              builder: (context, value, _) {
                return value
                    ? ScrollConfiguration(
                        behavior: const CupertinoScrollBehavior(),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.only(top: 15, right: 20),
                          itemBuilder: (ctx, index) => Container(
                            height: 40,
                            width: 1.sw,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: const Color(0xffF8F8F8),
                                borderRadius: BorderRadius.circular(10)),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () {
                                  changeViewMode.value = !changeViewMode.value;
                                  widget.controller.text =
                                      widget.popularSearchTerms[index].term ??
                                          "";
                                  widget.buildSearchResult.value = 1;
                                  //  widget.buildSearchResult.value = 1;
                                  widget.appearTrendingAndHistory.value = true;

                                  Filter filters =
                                      BlocProvider.of<BoutiqueBloc>(context)
                                              .state
                                              .choosedFiltersByUser['search']
                                              ?.filters ??
                                          Filter();
                                  BlocProvider.of<BoutiqueBloc>(context)
                                      .add(ChangeAppliedFiltersEvent(
                                    boutiqueSlug: 'search',
                                    filtersAppliedByUser:
                                        GetProductFiltersModel(
                                            filters:
                                                filters.copyWithSaveOtherField(
                                      prices: filters.prices,
                                      searchText:
                                          widget.popularSearchTerms[index].term,
                                    )),
                                  ));
                                  BlocProvider.of<BoutiqueBloc>(context).add(
                                      GetProductsWithFiltersEvent(
                                          offset: 1,
                                          boutiqueSlug: 'search',
                                          resetChoosedFilters: false,
                                          fromSearch: true,
                                          searchText: widget
                                              .popularSearchTerms[index].term));

                                  BlocProvider.of<BoutiqueBloc>(context).add(
                                      GetFiltersEvent(
                                          fromHomePageSearch: true,
                                          boutiqueSlug: 'search',
                                          searchText: widget
                                              .popularSearchTerms[index].term));
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyTextWidget(
                                      widget.popularSearchTerms[index].term ??
                                          "",
                                      textAlign: TextAlign.start,
                                      style: context.textTheme.titleLarge?.rq
                                          .copyWith(
                                              height: 18 / 14,
                                              color: const Color(0xff8D8D8D)),
                                    ),
                                    Row(
                                      children: [
                                        MyTextWidget(
                                          widget.popularSearchTerms[index].count
                                              .toString(),
                                          textAlign: TextAlign.start,
                                          style: context
                                              .textTheme.titleSmall?.rq
                                              .copyWith(
                                                  height: 1.3,
                                                  color:
                                                      const Color(0xff8D8D8D)),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        SvgPicture.asset(
                                          AppAssets.searchOutlinedSvg,
                                          width: 13,
                                          height: 13,
                                          // ignore: deprecated_member_use
                                          color: const Color(0xff388CFF),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          itemCount: widget.popularSearchTerms.length,
                          separatorBuilder: (ctx, index) => const SizedBox(
                            height: 5,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              })
        ],
      ),
    );
  }
}
