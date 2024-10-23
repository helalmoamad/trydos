import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/test_var.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../app/my_text_widget.dart';
import '../../../home/data/models/get_product_filters_model.dart';

class SearchChipBoutique extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final bool isLoading;
  const SearchChipBoutique(
      {Key? key,
      required this.title,
      required this.controller,
      required this.isLoading})
      : super(key: key);

  @override
  State<SearchChipBoutique> createState() => _SearchChipBoutiqueState();
}

class _SearchChipBoutiqueState extends State<SearchChipBoutique> {
  final ScrollController scrollController = ScrollController();
  late HomeBloc homeBloc;

  List<String> selectedBoutiqueSlugs = [];
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
        int visible = filters.boutiques?.length ?? 0;
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      height: 60,
                      key: TestVariables.kTestMode
                          ? Key(WidgetsKey.searchPageBoutiqueListKey)
                          : null,
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
                                      ?.boutiques
                                      ?.any((element) =>
                                          element.id ==
                                          filters.boutiques?[index].id) ??
                                  false;
                              return InkWell(
                                onTap: () {
                                  Filter? prevChoosedFilterToAddToIt = homeBloc
                                      .state.choosedFiltersByUser[key]?.filters;
                                  if (prevChoosedFilterToAddToIt == null) {
                                    prevChoosedFilterToAddToIt = Filter();
                                  }
                                  if (isSelected) {
                                    List<Boutique> boutiques =
                                        prevChoosedFilterToAddToIt.boutiques ??
                                            [];
                                    boutiques.removeWhere((element) =>
                                        element.id ==
                                        filters.boutiques![index].id);
                                    prevChoosedFilterToAddToIt =
                                        prevChoosedFilterToAddToIt
                                            .copyWithSaveOtherField(
                                      searchText:
                                          widget.controller.text.length > 2
                                              ? widget.controller.text
                                              : null,
                                      boutiques: boutiques,
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
                                                boutiques: [
                                          ...prevChoosedFilterToAddToIt
                                                  .boutiques ??
                                              [],
                                          filters.boutiques![index]
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
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Color(0xffF8F8F8),
                                              border: Border.all(
                                                  color: isSelected
                                                      ? Color(0xffFF5F61)
                                                      : Color(0xffF8F8F8))),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 0),
                                          child: Center(
                                            child: filters.boutiques![index]
                                                        .banner !=
                                                    null
                                                ? MyCachedNetworkImage(
                                                    imageUrl: filters
                                                        .boutiques![index]
                                                        .banner!
                                                        .filePath!,
                                                    imageFit: BoxFit.cover,
                                                    height: 40,
                                                    width: 100,
                                                    circleDimensions: 13,
                                                    logoTextHeight: 9,
                                                  )
                                                : SizedBox.shrink(),
                                          ),
                                        ),
                                        Visibility(
                                            visible: isSelected,
                                            child: FilterSelectedMark(
                                                width: 12, height: 12))
                                      ],
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Center(
                                        child: MyTextWidget(
                                      key: TestVariables.kTestMode
                                          ? Key(
                                              '${WidgetsKey.searchPageBoutiqueNameKey}$index')
                                          : null,
                                      filters.boutiques![index].name!,
                                      style: context.textTheme.titleLarge?.rq
                                          .copyWith(
                                              height: 12 / 14,
                                              color: Color(0xff8D8D8D)),
                                    ))
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                width: 10,
                              );
                            },
                            itemCount: filters.boutiques?.length ?? 0),
                      ),
                    ),
                  ],
                ))
            : SizedBox.shrink();
      },
    );
  }
}
