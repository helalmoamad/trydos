import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../data/models/get_product_filters_model.dart';
import '../../manager/home_bloc.dart';
import '../../manager/home_event.dart';
import '../../manager/home_state.dart';

class ColorsListFilter extends StatefulWidget {
  const ColorsListFilter(
      {super.key,
      this.hideTitle = false,
      this.searchText,
      required this.colors,
      required this.fromHomeSearch,
      required this.boutiqueSlug,
      this.category});

  final List<String> colors;
  final bool hideTitle;
  final bool fromHomeSearch;
  final String boutiqueSlug;
  final String? category;
  final String? searchText;

  @override
  State<ColorsListFilter> createState() => _ColorsListFilterState();
}

class _ColorsListFilterState extends State<ColorsListFilter> {
  String key = '';

  @override
  void initState() {
    key = widget.boutiqueSlug + (widget.category ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.colors.isNullOrEmpty) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsetsDirectional.only(start: widget.hideTitle ? 0 : 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.hideTitle) ...{
            Row(
              children: [
                FilterSelectedMark(width: 20, height: 20),
                SizedBox(
                  width: 10,
                ),
                MyTextWidget(
                  'Filter By Color',
                  style: context.textTheme.titleMedium?.rq
                      .copyWith(color: Color(0xff505050), height: 15 / 12),
                ),
                SizedBox(
                  width: 5,
                ),
                SvgPicture.asset(
                  AppAssets.registerInfoSvg,
                  color: Color(0xffD3D3D3),
                ),
                BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
                  if (state.getProductFiltersStatus[key] ==
                      GetProductFiltersStatus.loading) {
                    return Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        TrydosLoader(
                          size: 20,
                        ),
                      ],
                    );
                  }
                  return SizedBox.shrink();
                })
              ],
            ),
            SizedBox(
              height: 10,
            ),
          },
          SizedBox(
              height: 105,
              child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);
                    bool isSelected = widget.hideTitle
                        ? (homeBloc.state.appliedFiltersByUser[key]?.filters
                                ?.colors
                                ?.any((element) =>
                                    element == widget.colors[index]) ??
                            false)
                        : (homeBloc.state.choosedFiltersByUser[key]?.filters
                                ?.colors
                                ?.any((element) =>
                                    element == widget.colors[index]) ??
                            false);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            String color = widget.colors[index];
                            Filter? prevChoosedOrAppliedFilterToAddToIt =
                                widget.hideTitle
                                    ? homeBloc.state.appliedFiltersByUser[key]
                                        ?.filters
                                    : homeBloc.state.choosedFiltersByUser[key]
                                        ?.filters;
                            List<String>? colors = List.of(
                                prevChoosedOrAppliedFilterToAddToIt?.colors ??
                                    []);
                            if (!isSelected) {
                              FirebaseAnalyticsService.logEventForSession(
                                eventName: AnalyticsEventsConst.buttonClicked,
                                executedEventName:
                                    AnalyticsExecutedEventNameConst
                                        .addFilterButton,
                              );
                              //////////////////////////////
                              if (prevChoosedOrAppliedFilterToAddToIt == null) {
                                prevChoosedOrAppliedFilterToAddToIt = Filter();
                              }
                              prevChoosedOrAppliedFilterToAddToIt =
                                  prevChoosedOrAppliedFilterToAddToIt
                                      .copyWithSaveOtherField(
                                          prices:
                                              prevChoosedOrAppliedFilterToAddToIt
                                                  .prices,
                                          searchText:
                                              prevChoosedOrAppliedFilterToAddToIt
                                                  .searchText,
                                          colors:
                                              prevChoosedOrAppliedFilterToAddToIt
                                                      .colors.isNullOrEmpty
                                                  ? [color]
                                                  : [
                                                      ...prevChoosedOrAppliedFilterToAddToIt
                                                          .colors!,
                                                      color
                                                    ]);
                            } else {
                              FirebaseAnalyticsService.logEventForSession(
                                eventName: AnalyticsEventsConst.buttonClicked,
                                executedEventName:
                                    AnalyticsExecutedEventNameConst
                                        .resetByTapOnFilterButton,
                              );
                              ////////////////////////////////
                              colors.removeWhere(((element) =>
                                  element == widget.colors[index]));
                              prevChoosedOrAppliedFilterToAddToIt =
                                  prevChoosedOrAppliedFilterToAddToIt
                                      ?.copyWithSaveOtherField(
                                colors: colors,
                                searchText: prevChoosedOrAppliedFilterToAddToIt
                                    .searchText,
                                prices:
                                    prevChoosedOrAppliedFilterToAddToIt.prices,
                              );
                            }
                            if (widget.hideTitle) {
                              print(
                                  "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");

                              homeBloc.add(ChangeAppliedFiltersEvent(
                                category: widget.category,
                                boutiqueSlug: widget.boutiqueSlug,
                                filtersAppliedByUser: GetProductFiltersModel(
                                    filters:
                                        prevChoosedOrAppliedFilterToAddToIt),
                              ));
                              homeBloc.add(GetProductsWithFiltersEvent(
                                  fromSearch: widget.fromHomeSearch,
                                  searchText: widget.searchText,
                                  boutiqueSlug: widget.boutiqueSlug,
                                  category: widget.category,
                                  offset: 1));
                            } else {
                              homeBloc.add(ChangeSelectedFiltersEvent(
                                fromHomePageSearch: widget.fromHomeSearch,
                                requestToUpdateFilters: true,
                                category: widget.category,
                                boutiqueSlug: widget.boutiqueSlug,
                                filtersChoosedByUser: GetProductFiltersModel(
                                    filters:
                                        prevChoosedOrAppliedFilterToAddToIt),
                              ));
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(int.parse(
                                      '0xff${widget.colors[index].substring(1)}')),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 3,
                                        offset: Offset(0, 3))
                                  ],
                                  border: Border.all(color: Color(0xffC4C2C2)),
                                ),
                              ),
                              Visibility(
                                  visible: isSelected,
                                  child:
                                      FilterSelectedMark(width: 20, height: 20))
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (ctx, index) => SizedBox(
                        width: 10,
                      ),
                  itemCount: widget.colors.length)),
          SizedBox(height: !widget.hideTitle ? 20 : 0),
        ],
      ),
    );
  }
}
