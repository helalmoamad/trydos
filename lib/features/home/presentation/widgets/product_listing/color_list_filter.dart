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

import '../../../data/models/get_product_filters_model.dart';
import '../../manager/home_bloc.dart';
import '../../manager/home_event.dart';

class ColorsListFilter extends StatefulWidget {
  const ColorsListFilter(
      {super.key,
      this.hideTitle = false,
      required this.searchText,
      required this.colors,
      required this.fromSearch,
      required this.boutiqueSlug,
      this.category});

  final List<String> colors;
  final bool hideTitle;
  final bool fromSearch;
  final String boutiqueSlug;
  final String? category;
  final String? searchText;

  @override
  State<ColorsListFilter> createState() => _ColorsListFilterState();
}

class _ColorsListFilterState extends State<ColorsListFilter> {
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
                  style: context.textTheme.caption?.rq
                      .copyWith(color: Color(0xff505050), height: 15 / 12),
                ),
                SizedBox(
                  width: 5,
                ),
                SvgPicture.asset(
                  AppAssets.registerInfoSvg,
                  color: Color(0xffD3D3D3),
                )
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
                        ? false
                        : (homeBloc.state.choosedFiltersByUser?.filters?.colors
                                ?.any((element) =>
                                    element == widget.colors[index]) ??
                            false);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            String color = widget.colors[index];
                            Filter? prevChoosedOrAppliedFilterToAddToIt = widget
                                    .hideTitle
                                ? homeBloc.state.appliedFiltersByUser?.filters
                                : homeBloc.state.choosedFiltersByUser?.filters;
                            if (widget.hideTitle || !isSelected) {
                              if (prevChoosedOrAppliedFilterToAddToIt == null) {
                                prevChoosedOrAppliedFilterToAddToIt = Filter();
                              }
                              prevChoosedOrAppliedFilterToAddToIt =
                                  prevChoosedOrAppliedFilterToAddToIt
                                      .copyWithSaveOtherField(
                                          colors:
                                              prevChoosedOrAppliedFilterToAddToIt
                                                      .colors.isNullOrEmpty
                                                  ? [color]
                                                  : [
                                                      ...prevChoosedOrAppliedFilterToAddToIt
                                                          .colors!,
                                                      color
                                                    ]);
                              if (widget.hideTitle) {
                                homeBloc.add(GetProductsWithFiltersEvent(
                                    fromSearch: widget.fromSearch,
                                    searchText: widget.searchText,
                                    boutiqueSlug: widget.boutiqueSlug,
                                    filtersAppliedByUser: GetProductFiltersModel(
                                        filters:
                                            prevChoosedOrAppliedFilterToAddToIt),
                                    category: widget.category,
                                    offset: 1));
                              } else {
                                homeBloc.add(ChangeSelectedFiltersEvent(
                                  filtersChoosedByUser: GetProductFiltersModel(
                                      filters:
                                          prevChoosedOrAppliedFilterToAddToIt),
                                ));
                              }
                            } else {
                              prevChoosedOrAppliedFilterToAddToIt!.colors!
                                  .removeWhere(((element) =>
                                      element == widget.colors[index]));
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
