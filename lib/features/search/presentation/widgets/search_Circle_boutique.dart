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

class SearchChipBoutique extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final ValueNotifier<List<int>> selectedBoutique;
  const SearchChipBoutique(
      {Key? key,
      required this.title,
      required this.selectedBoutique,
      required this.controller})
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color(0xffC4C2C2), width: 0.3)),
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.boutiques != current.boutiques ||
            previous.selectedBoutiqueBrandCategorySlugsForSearch["boutique"] !=
                current.selectedBoutiqueBrandCategorySlugsForSearch["boutique"],
        builder: (context, state) {
          selectedBoutiqueSlugs =
              state.selectedBoutiqueBrandCategorySlugsForSearch["boutique"] ??
                  [];
          if (state.boutiques.isNullOrEmpty) {
            return SizedBox.shrink();
          }
          /*    selectedBoutiqueSlugs =
              state.selectedBoutiqueBrandCategorySlugsForSearch["boutique"] ??
                  [];
          print(selectedBoutiqueSlugs);
          selectedBoutiqueSlugs.forEach((e) {
            if (state.boutiques!.any((element) => '"${element.slug}"' == e)) {
              selectedBoutique.value.add(state.boutiques!.indexOf(state
                  .boutiques!
                  .firstWhere((element) => '"${element.slug}"' == e)));
            }
          });
          print(selectedBoutique.value);

          selectedBoutique.value.removeWhere((element) => element == -1);*/

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
                height: 60,
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
                              valueListenable: widget.selectedBoutique,
                              builder: (context, value, _) {
                                if (value.isNullOrEmpty) {
                                  selectedBoutiqueSlugs = [];
                                  homeBloc.add(
                                      AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent(
                                          withBoutique: true,
                                          withBrand: false,
                                          selectedBoutiqueBrandCategorySlugsForSearch:
                                              selectedBoutiqueSlugs));
                                }
                                return InkWell(
                                  onTap: () {
                                    if (state.boutiques![index].isSelected ??
                                        false) {
                                      selectedBoutiqueSlugs.remove(
                                          '"${state.boutiques![index].slug ?? ""}"');
                                      widget.selectedBoutique.value
                                          .remove(index);
                                      homeBloc.add(
                                          AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent(
                                              withBoutique: true,
                                              withBrand: false,
                                              selectedBoutiqueBrandCategorySlugsForSearch:
                                                  selectedBoutiqueSlugs));
                                    } else {
                                      widget.selectedBoutique.value.add(index);
                                      selectedBoutiqueSlugs.add(
                                          '"${state.boutiques![index].slug ?? ""}"');

                                      homeBloc.add(
                                          AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent(
                                              withBoutique: true,
                                              withBrand: false,
                                              selectedBoutiqueBrandCategorySlugsForSearch:
                                                  selectedBoutiqueSlugs));
                                    }
                                    widget.selectedBoutique.notifyListeners();
                                    homeBloc.add(GetProductFiltersEvent(
                                        fromSearch: true,
                                        searchText: widget.controller.text));
                                  },
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          AnimatedScale(
                                              curve: Curves
                                                  .fastEaseInToSlowEaseOut,
                                              scale: state.boutiques![index]
                                                          .isSelected ??
                                                      false
                                                  ? 1
                                                  : 0.94,
                                              duration:
                                                  Duration(milliseconds: 100),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: Color(0xffF8F8F8),
                                                    border: Border.all(
                                                        color: state
                                                                    .boutiques![
                                                                        index]
                                                                    .isSelected ??
                                                                false
                                                            ? Color(0xffFF5F61)
                                                            : Color(
                                                                0xffF8F8F8))),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 0, horizontal: 0),
                                                child: Center(
                                                  child: state.boutiques![index]
                                                              .banner !=
                                                          null
                                                      ? MyCachedNetworkImage(
                                                          imageUrl: state
                                                                  .boutiques![
                                                                      index]
                                                                  .banner!
                                                                  .filePath ??
                                                              " okp*/kmkm",
                                                          imageFit:
                                                              BoxFit.cover,
                                                          height: 40,
                                                          width: 100,
                                                        )
                                                      : SizedBox.shrink(),
                                                ),
                                              )),
                                          Visibility(
                                              visible: state.boutiques![index]
                                                      .isSelected ??
                                                  false,
                                              child: FilterSelectedMark(
                                                  width: 12, height: 12))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Center(
                                          child: MyTextWidget(
                                        state.boutiques![index].name!,
                                        style: context.textTheme.bodyText2?.rq
                                            .copyWith(
                                                height: 12 / 14,
                                                color: Color(0xff8D8D8D)),
                                      ))
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
                          itemCount: state.boutiques!.length),
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
