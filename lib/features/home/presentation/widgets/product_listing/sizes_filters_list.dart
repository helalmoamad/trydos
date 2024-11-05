import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
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

class SizesFiltersList extends StatefulWidget {
  const SizesFiltersList({
    super.key,
    this.hideTitle = false,
    required this.attribute,
    required this.boutiqueSlug,
    this.category,
    this.searchText,
    required this.fromHomeSearch,
  });

  final Attribute attribute;

  final bool hideTitle;
  final String boutiqueSlug;
  final String? category;
  final bool fromHomeSearch;
  final String? searchText;

  @override
  State<SizesFiltersList> createState() => _SizesFiltersListState();
}

class _SizesFiltersListState extends State<SizesFiltersList> {
  late final ValueNotifier<int> currentIndexInSizes;
  String key = '';

  @override
  void initState() {
    key = widget.boutiqueSlug + (widget.category ?? '');
    currentIndexInSizes =
        ValueNotifier((widget.attribute.options?.length ?? 0) ~/ 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  'Filter By Size',
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
            height: 70,
            child: ValueListenableBuilder<int>(
                valueListenable: currentIndexInSizes,
                builder: (context, currentIndex, _) {
                  return ListView.separated(
                    itemCount: widget.attribute.options?.length ?? 0,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (ctx, index) => SizedBox(
                      width: 10,
                    ),
                    itemBuilder: (ctx, index) {
                      HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);
                      bool isSelected = widget.hideTitle
                          ? ((homeBloc.state.appliedFiltersByUser[key]?.filters
                                      ?.attributes?.isNullOrEmpty ??
                                  true)
                              ? false
                              : homeBloc.state.appliedFiltersByUser[key]!
                                      .filters!.attributes![0].options
                                      ?.any((element) =>
                                          element ==
                                          widget.attribute.options?[index]) ??
                                  false)
                          : ((homeBloc.state.choosedFiltersByUser[key]?.filters
                                      ?.attributes?.isNullOrEmpty ??
                                  true)
                              ? false
                              : homeBloc.state.choosedFiltersByUser[key]!
                                      .filters!.attributes![0].options
                                      ?.any((element) => element == widget.attribute.options?[index]) ??
                                  false);
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Filter? prevChoosedOrAppliedFilterToAddToIt =
                                  widget.hideTitle
                                      ? homeBloc.state.appliedFiltersByUser[key]
                                          ?.filters
                                      : homeBloc.state.choosedFiltersByUser[key]
                                          ?.filters;
                              List<Attribute>? sizes = List.of(
                                  prevChoosedOrAppliedFilterToAddToIt
                                          ?.attributes ??
                                      []);
                              if (!isSelected) {
                                FirebaseAnalyticsService.logEventForSession(
                                  eventName: AnalyticsEventsConst.buttonClicked,
                                  executedEventName:
                                      AnalyticsExecutedEventNameConst
                                          .addFilterButton,
                                );
                                //////////////////////////////
                                String size = widget.attribute.options![index];
                                if (prevChoosedOrAppliedFilterToAddToIt ==
                                    null) {
                                  prevChoosedOrAppliedFilterToAddToIt =
                                      Filter();
                                }
                                prevChoosedOrAppliedFilterToAddToIt =
                                    prevChoosedOrAppliedFilterToAddToIt
                                        .copyWithSaveOtherField(
                                  prices: prevChoosedOrAppliedFilterToAddToIt
                                      .prices,
                                  searchText:
                                      prevChoosedOrAppliedFilterToAddToIt
                                          .searchText,
                                  attributes:
                                      prevChoosedOrAppliedFilterToAddToIt
                                              .attributes.isNullOrEmpty
                                          ? [
                                              Attribute(
                                                  id: widget.attribute.id,
                                                  name: widget.attribute.name,
                                                  options: [size])
                                            ]
                                          : [
                                              prevChoosedOrAppliedFilterToAddToIt
                                                  .attributes![0]
                                                  .copyWith(options: [
                                                ...prevChoosedOrAppliedFilterToAddToIt
                                                        .attributes![0]
                                                        .options ??
                                                    [],
                                                size
                                              ])
                                            ],
                                );
                              } else {
                                print('reset size');
                                FirebaseAnalyticsService.logEventForSession(
                                  eventName: AnalyticsEventsConst.buttonClicked,
                                  executedEventName:
                                      AnalyticsExecutedEventNameConst
                                          .resetByTapOnFilterButton,
                                );
                                ////////////////////////////////////
                                List<String> options =
                                    List.of(sizes[0].options ?? []);
                                options.removeWhere(((element) =>
                                    element ==
                                    widget.attribute.options![index]));
                                sizes[0] = sizes[0].copyWith(options: options);
                                prevChoosedOrAppliedFilterToAddToIt =
                                    prevChoosedOrAppliedFilterToAddToIt!
                                        .copyWithSaveOtherField(
                                            searchText:
                                                prevChoosedOrAppliedFilterToAddToIt
                                                    .searchText,
                                            prices:
                                                prevChoosedOrAppliedFilterToAddToIt
                                                    .prices,
                                            attributes: sizes);
                                if (sizes[0].options!.length == 0) {
                                  prevChoosedOrAppliedFilterToAddToIt =
                                      prevChoosedOrAppliedFilterToAddToIt
                                          .changeAttributesAndSaveOthers(
                                              attributes: null);
                                }
                              }
                              if (widget.hideTitle) {
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
                            child: Container(
                              height: 70,
                              width: 70,
                              child: DottedBorder(
                                  radius: Radius.circular(180),
                                  borderType: BorderType.RRect,
                                  strokeCap: StrokeCap.round,
                                  strokeWidth: 0.5,
                                  color: isSelected
                                      ? Color(0xffFF5F61)
                                      : Color(0xff6B6B6B),
                                  dashPattern: [3, 3],
                                  child: Center(
                                    child: Text(
                                      widget.attribute.options![index],
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          // index == currentIndex
                                          //     ? textTheme.titleLarge?.bq.copyWith(
                                          //   height: 1.3,
                                          //   fontSize: 15.sp,
                                          //   color: const Color(0xff5D5C5D),
                                          // )
                                          //     :
                                          textTheme.titleLarge?.mq.copyWith(
                                        height: 1.3,
                                        fontSize: 15.sp,
                                        color: const Color(0xff5D5C5D),
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                          Visibility(
                              visible: isSelected,
                              child: FilterSelectedMark(width: 20, height: 20))
                        ],
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}
