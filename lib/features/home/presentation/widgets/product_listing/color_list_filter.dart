import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../../common/test_utils/test_var.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../data/models/get_product_filters_model.dart';
import '../../manager/homeBloc/home_bloc.dart';
import '../../manager/homeBloc/home_event.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import 'package:get_it/get_it.dart';

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
  Timer? debounce;
  String key = '';
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    scrollController.addListener(() {
      try {
        if (debounce?.isActive ?? false) {
          debounce!.cancel();
        }
        debounce = Timer(Duration(milliseconds: 600), () {
          if (scrollController.offset >=
              (scrollController.position.maxScrollExtent * 0.6)) {
            BlocProvider.of<BoutiqueBloc>(context)
                .add(GetFiltersWithPaginatioEvent(
              fromHomePageSearch: true,
              searchText: widget.searchText,
              category: widget.category,
              boutiqueSlug: widget.boutiqueSlug,
            ));
          }
        });
      } catch (e) {}
    });
    key = widget.boutiqueSlug + (widget.category ?? '');
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

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
                  '${LocaleKeys.filter_by_color.tr()}',
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
                BlocBuilder<BoutiqueBloc, BoutiqueState>(
                    builder: (context, state) {
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
                  controller: scrollController,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    BoutiqueBloc boutiqueBloc =
                        BlocProvider.of<BoutiqueBloc>(context);
                    bool isSelected = widget.hideTitle
                        ? (boutiqueBloc.state.appliedFiltersByUser[key]?.filters
                                ?.colors
                                ?.any((element) =>
                                    element == widget.colors[index]) ??
                            false)
                        : (boutiqueBloc.state.choosedFiltersByUser[key]?.filters
                                ?.colors
                                ?.any((element) =>
                                    element == widget.colors[index]) ??
                            false);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          key: TestVariables.kTestMode == false
                              ? null
                              : Key(
                                  '${WidgetsKeys.colorCircleProductListingFilterKey}$index'),
                          onTap: () {
                            String color = widget.colors[index];
                            Filter? prevChoosedOrAppliedFilterToAddToIt =
                                widget.hideTitle
                                    ? boutiqueBloc.state
                                        .appliedFiltersByUser[key]?.filters
                                    : boutiqueBloc.state
                                        .choosedFiltersByUser[key]?.filters;
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
                                          searchText: widget.searchText,
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
                                searchText: widget.searchText,
                                prices:
                                    prevChoosedOrAppliedFilterToAddToIt.prices,
                              );
                            }
                            if (widget.hideTitle) {
                              print(
                                  "........................................ddddddddddddddddd${widget.colors[index]}ddddddddddddddddddddddddddddddddddddddddd");

                              boutiqueBloc.add(ChangeAppliedFiltersEvent(
                                category: widget.category,
                                boutiqueSlug: widget.boutiqueSlug,
                                filtersAppliedByUser: GetProductFiltersModel(
                                    filters:
                                        prevChoosedOrAppliedFilterToAddToIt),
                              ));
                              boutiqueBloc.add(GetProductsWithFiltersEvent(
                                  fromSearch: widget.fromHomeSearch,
                                  searchText: widget.searchText,
                                  boutiqueSlug: widget.boutiqueSlug,
                                  category: widget.category,
                                  offset: 1));
                            } else {
                              boutiqueBloc.add(ChangeSelectedFiltersEvent(
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
