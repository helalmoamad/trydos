import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../app/my_text_widget.dart';

class SearchChipcategory extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final ValueNotifier<List<int>> selectedCategory;

  const SearchChipcategory(
      {Key? key,
      required this.title,
      required this.selectedCategory,
      required this.controller})
      : super(key: key);

  @override
  State<SearchChipcategory> createState() => _SearchChipcategoryState();
}

class _SearchChipcategoryState extends State<SearchChipcategory> {
  final ScrollController scrollController = ScrollController();
  late HomeBloc homeBloc;

  List<String> selectedCategorySlugs = [];

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    /*scrollController.addListener(() {
      if (scrollController.offset >=
          (scrollController.position.maxScrollExtent *
              0.7 *
              (homeBloc
                  .state
                  .getHomeBoutiquesPaginationObjectByMainCategory["Empty"]!
                  .page))) {
        homeBloc.add(GetHomeBoutiqesEvent(
            categorySlug: "Empty",
            offset: homeBloc.state
                .getHomeBoutiquesPaginationObjectByMainCategory["Empty"]!.page
                .toString(),
            getWithPagination: true));
      }
    });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color(0xffC4C2C2), width: 0.3)),
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.categories != current.categories ||
            previous.getProductFiltersStatus != current.getProductFiltersStatus,
        builder: (context, state) {
          selectedCategorySlugs =
              state.selectedBoutiqueBrandCategorySlugsForSearch["category"] ??
                  [];
          if (state.categories.isNullOrEmpty) {
            return SizedBox.shrink();
          }
          /*  selectedCategorySlugs =
              state.selectedBoutiqueBrandCategorySlugsForSearch["category"] ??
                  [];

          selectedCategorySlugs.forEach((e) {
            if (state.categories!.any((element) => '"${element.slug}"' == e)) {
              selectedCategory.value.add(state.categories!.indexOf(state
                  .categories!
                  .firstWhere((element) => '"${element.slug}"' == e)));
            }
          });

          selectedCategory.value.removeWhere((element) => element == -1);
**/
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyTextWidget(
                      widget.title,
                      style: context.textTheme.caption?.rq
                          .copyWith(color: Color(0xff505050), height: 15 / 12),
                    ),
                    SvgPicture.asset(
                      AppAssets.backArrowArabic,
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
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      ListView.separated(
                          controller: scrollController,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return ValueListenableBuilder(
                              valueListenable: widget.selectedCategory,
                              builder: (context, value, _) {
                                if (value.isNullOrEmpty) {
                                  selectedCategorySlugs = [];
                                  homeBloc.add(
                                      AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent(
                                          withBoutique: false,
                                          withBrand: false,
                                          selectedBoutiqueBrandCategorySlugsForSearch:
                                              selectedCategorySlugs));
                                }
                                return InkWell(
                                  onTap: () {
                                    if (state.categories![index].isSelected) {
                                      selectedCategorySlugs.remove(
                                          '"${state.categories![index].slug ?? ""}"');
                                      widget.selectedCategory.value
                                          .remove(index);
                                      homeBloc.add(
                                          AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent(
                                              withBoutique: false,
                                              withBrand: false,
                                              selectedBoutiqueBrandCategorySlugsForSearch:
                                                  selectedCategorySlugs));
                                    } else {
                                      widget.selectedCategory.value.add(index);
                                      selectedCategorySlugs.add(
                                          '"${state.categories![index].slug ?? ""}"');

                                      homeBloc.add(
                                          AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent(
                                              withBoutique: false,
                                              withBrand: false,
                                              selectedBoutiqueBrandCategorySlugsForSearch:
                                                  selectedCategorySlugs));
                                    }
                                    widget.selectedCategory.notifyListeners();
                                    homeBloc.add(GetProductFiltersEvent(
                                        fromSearch: true,
                                        searchText: widget.controller.text));
                                  },
                                  child: Stack(
                                    children: [
                                      AnimatedScale(
                                          curve: Curves.fastEaseInToSlowEaseOut,
                                          scale: state
                                                  .categories![index].isSelected
                                              ? 1
                                              : 0.94,
                                          duration: Duration(milliseconds: 100),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Color(0xffF8F8F8),
                                                border: Border.all(
                                                    color: state
                                                            .categories![index]
                                                            .isSelected
                                                        ? Color(0xffFF5F61)
                                                        : Color(0xffF8F8F8))),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 10),
                                            child: Center(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  MyCachedNetworkImage(
                                                    imageUrl: state
                                                        .categories![index]
                                                        .mostViewedProductThumbnail!
                                                        .filePath!,
                                                    imageFit: BoxFit.cover,
                                                    width: 15,
                                                    height: 15,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  MyTextWidget(
                                                    state.categories![index]
                                                        .name!,
                                                    style: context
                                                        .textTheme.bodyText2?.rq
                                                        .copyWith(
                                                            height: 18 / 14,
                                                            color: Color(
                                                                0xff8D8D8D)),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )),
                                      Visibility(
                                          visible: state
                                              .categories![index].isSelected,
                                          child: FilterSelectedMark(
                                              width: 12, height: 12))
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              width: 10,
                            );
                          },
                          itemCount: state.categories!.length),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
