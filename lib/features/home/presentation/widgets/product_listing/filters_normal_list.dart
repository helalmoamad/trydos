import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../data/models/get_product_filters_model.dart';
import '../../manager/home_event.dart';
import '../../manager/home_state.dart';

class FiltersNormalList<T> extends StatefulWidget {
  const FiltersNormalList(
      {super.key,
      required this.filterListTitle,
      this.hideTitle = false,
      required this.isBrandFilter,
      required this.filters,
      this.searchText,
      required this.fromHomeSearch,
        required this.boutiqueSlug,
      this.category});

  final bool isBrandFilter;
  final String filterListTitle;
  final List<T> filters;
  final bool fromHomeSearch;
  final String? searchText;
  final bool hideTitle;
  final String boutiqueSlug;
  final String? category;

  @override
  State<FiltersNormalList> createState() => _FiltersNormalListState();
}

class _FiltersNormalListState extends State<FiltersNormalList> {

  String key = '';

  @override
  void initState() {
    key = widget.boutiqueSlug + (widget.category ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filters.isNullOrEmpty) {
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
                  widget.filterListTitle,
                  style: context.textTheme.caption?.rq
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
                        ? widget.isBrandFilter
                        ? (homeBloc
                        .state.appliedFiltersByUser[key]?.filters?.brands
                        ?.any((element) =>
                    element.id ==
                        widget.filters[index].id) ??
                        false)
                        : false
                        : widget.isBrandFilter
                            ? (homeBloc
                                    .state.choosedFiltersByUser[key]?.filters?.brands
                                    ?.any((element) =>
                                        element.id ==
                                        widget.filters[index].id) ??
                                false)
                            : false;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Filter? prevChoosedOrAppliedFilterToAddToIt = widget
                                    .hideTitle
                                ? homeBloc.state.appliedFiltersByUser[key]?.filters
                                : homeBloc.state.choosedFiltersByUser[key]?.filters;
                            if (!isSelected) {
                              dynamic item = widget.filters[index];
                              if (prevChoosedOrAppliedFilterToAddToIt == null) {
                                prevChoosedOrAppliedFilterToAddToIt = Filter();
                              }
                              prevChoosedOrAppliedFilterToAddToIt =
                                  prevChoosedOrAppliedFilterToAddToIt
                                      .copyWithSaveOtherField(
                                      prices: prevChoosedOrAppliedFilterToAddToIt.prices,
                                      searchText: prevChoosedOrAppliedFilterToAddToIt.searchText,
                                          brands: !widget.isBrandFilter
                                              ? prevChoosedOrAppliedFilterToAddToIt
                                                  .brands
                                              : prevChoosedOrAppliedFilterToAddToIt
                                                      .brands.isNullOrEmpty
                                                  ? [item]
                                                  : [
                                                      ...prevChoosedOrAppliedFilterToAddToIt
                                                          .brands!,
                                                      item
                                                    ]);
                            } else {
                              if (widget.isBrandFilter) {
                                prevChoosedOrAppliedFilterToAddToIt!.brands!
                                    .removeWhere(((element) =>
                                        element.id ==
                                        widget.filters[index].id));
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
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 3,
                                        offset: Offset(0, 3))
                                  ],
                                  border: Border.all(color: isSelected ? Color(0xffFF5F61) : Color(0xffC4C2C2),),
                                ),
                                child: Center(
                                  child: widget.isBrandFilter
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: SvgNetworkWidget(
                                            svgUrl: widget.filters[index].image,
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ),
                              ),
                              Visibility(
                                  visible: isSelected,
                                  child:
                                      FilterSelectedMark(width: 20, height: 20))
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        MyTextWidget(
                          widget.isBrandFilter
                              ? widget.filters[index].name
                              : 'T-shirt',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: context.textTheme.caption?.rq.copyWith(
                              color: Color(0xff8E8E8E),
                              letterSpacing: 0,
                              height: 1.25),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (ctx, index) => SizedBox(
                        width: 10,
                      ),
                  itemCount: widget.filters.length)),
          SizedBox(height: !widget.hideTitle ? 20 : 0),
        ],
      ),
    );
  }
}
