import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../app/my_text_widget.dart';

class SearchChipBrand extends StatefulWidget {
  final String title;
  final bool isLoading;
  final TextEditingController controller;

  const SearchChipBrand(
      {Key? key,
      required this.title,
      required this.controller,
      required this.isLoading})
      : super(key: key);

  @override
  State<SearchChipBrand> createState() => _SearchChipBrandState();
}

class _SearchChipBrandState extends State<SearchChipBrand> {
  final ScrollController scrollController = ScrollController();
  late HomeBloc homeBloc;

  List<String> selectedBrandSlugs = [];

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        String key = 'search';
        Filter filters = state.getProductFiltersModel[key]?.filters ?? Filter();
        int visible = filters.brands?.length ?? 0;
        return visible > 0
            ? Container(
                margin:
                    EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 10),
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Color(0xffC4C2C2), width: 0.3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          MyTextWidget(
                            widget.title,
                            style: context.textTheme.titleMedium?.rq.copyWith(
                                color: Color(0xff505050), height: 15 / 12),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          widget.isLoading
                              ? Container(
                                  width: 15,
                                  height: 15,
                                  child: Center(
                                    child: TrydosLoader(
                                      color: Colors.black,
                                      size: 15,
                                    ),
                                  ))
                              : SizedBox.shrink(),
                          Spacer(),
                          SvgPicture.asset(
                            AppAssets.backArrowArabic,
                            matchTextDirection: true,
                            color: Color(0xffC4C2C2),
                            width: 10,
                            height: 10,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 30,
                      child: ScrollConfiguration(
                        behavior: CupertinoScrollBehavior(),
                        child: ListView.separated(
                            controller: scrollController,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              bool isSelected = homeBloc
                                      .state
                                      .choosedFiltersByUser[key]
                                      ?.filters
                                      ?.brands
                                      ?.any((element) =>
                                          element.id ==
                                          filters.brands?[index].id) ??
                                  false;
                              return InkWell(
                                onTap: () {
                                  Filter? prevChoosedFilterToAddToIt = homeBloc
                                      .state.choosedFiltersByUser[key]?.filters;
                                  if (prevChoosedFilterToAddToIt == null) {
                                    prevChoosedFilterToAddToIt = Filter();
                                  }
                                  if (isSelected) {
                                    List<Brand> brands =
                                        prevChoosedFilterToAddToIt.brands ?? [];
                                    brands.removeWhere((element) =>
                                        element.id ==
                                        filters.brands![index].id);
                                    prevChoosedFilterToAddToIt =
                                        prevChoosedFilterToAddToIt
                                            .copyWithSaveOtherField(
                                      searchText:
                                          widget.controller.text.length > 2
                                              ? widget.controller.text
                                              : null,
                                      brands: brands,
                                    );
                                  } else {
                                    prevChoosedFilterToAddToIt =
                                        prevChoosedFilterToAddToIt
                                            .copyWithSaveOtherField(
                                                searchText: widget.controller
                                                            .text.length >
                                                        2
                                                    ? widget.controller.text
                                                    : null,
                                                brands: [
                                          ...prevChoosedFilterToAddToIt
                                                  .brands ??
                                              [],
                                          filters.brands![index]
                                        ]);
                                  }
                                  homeBloc.add(ChangeSelectedFiltersEvent(
                                      fromHomePageSearch: true,
                                      boutiqueSlug: key,
                                      filtersChoosedByUser:
                                          GetProductFiltersModel(
                                              filters:
                                                  prevChoosedFilterToAddToIt)));
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Color(0xffF8F8F8),
                                          border: Border.all(
                                              color: isSelected
                                                  ? Color(0xffFF5F61)
                                                  : Color(0xffF8F8F8))),
                                      child: Center(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            filters.brands![index].icon != null
                                                ? filters.brands![index].icon!
                                                            .filePath !=
                                                        null
                                                    ? SvgNetworkWidget(
                                                        svgUrl: filters
                                                            .brands![index]
                                                            .icon!
                                                            .filePath!,
                                                        height: 20,
                                                      )
                                                    : SizedBox.shrink()
                                                : SizedBox.shrink(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                        visible: isSelected,
                                        child: FilterSelectedMark(
                                            width: 12, height: 12))
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                width: 10,
                              );
                            },
                            itemCount: filters.brands?.length ?? 0),
                      ),
                    ),
                  ],
                ))
            : SizedBox.shrink();
      },
    );
  }
}
