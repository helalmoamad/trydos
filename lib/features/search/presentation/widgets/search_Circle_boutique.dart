import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../app/my_text_widget.dart';

class SearchChipBoutique extends StatefulWidget {
  final String title;
  const SearchChipBoutique({Key? key, required this.title}) : super(key: key);

  @override
  State<SearchChipBoutique> createState() => _SearchChipBoutiqueState();
}

class _SearchChipBoutiqueState extends State<SearchChipBoutique> {
  final ScrollController scrollController = ScrollController();
  late HomeBloc homeBloc;
  final ValueNotifier<List<int>> selectedBoutique = ValueNotifier([]);
  List<String> selectedBoutiqueSlugs = [];
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    scrollController.addListener(() {
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
    });
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
            previous.boutiques != current.boutiques,
        builder: (context, state) {
          if (state.boutiques.isNullOrEmpty) {
            return SizedBox.shrink();
          }
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
                              valueListenable: selectedBoutique,
                              builder: (context, value, _) {
                                return InkWell(
                                  onTap: () {
                                    if (selectedBoutique.value
                                        .contains(index)) {
                                      selectedBoutiqueSlugs.remove(
                                          '"${state.boutiques![index].slug ?? ""}"');
                                      selectedBoutique.value.remove(index);
                                      homeBloc.add(
                                          AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent(
                                              withBoutique: true,
                                              withBrand: false,
                                              selectedBoutiqueBrandCategorySlugsForSearch:
                                                  selectedBoutiqueSlugs));
                                    } else {
                                      selectedBoutique.value.add(index);
                                      selectedBoutiqueSlugs.add(
                                          '"${state.boutiques![index].slug ?? ""}"');

                                      homeBloc.add(
                                          AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent(
                                              withBoutique: true,
                                              withBrand: false,
                                              selectedBoutiqueBrandCategorySlugsForSearch:
                                                  selectedBoutiqueSlugs));
                                    }
                                    selectedBoutique.notifyListeners();
                                  },
                                  child: Stack(
                                    children: [
                                      AnimatedScale(
                                          curve: Curves.fastEaseInToSlowEaseOut,
                                          scale:
                                              value.contains(index) ? 1 : 0.94,
                                          duration: Duration(milliseconds: 100),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Color(0xffF8F8F8),
                                                border: Border.all(
                                                    color: value.contains(index)
                                                        ? Color(0xffFF5F61)
                                                        : Color(0xffF8F8F8))),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 10),
                                            child: Center(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.network(
                                                    state.boutiques![index]
                                                        .icon!.filePath!,
                                                    width: 15,
                                                    height: 15,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  MyTextWidget(
                                                    state.boutiques![index]
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
                                          visible: value.contains(index),
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
