import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../app/my_text_widget.dart';

class SearchChipBrand extends StatefulWidget {
  final String title;
  const SearchChipBrand({Key? key, required this.title}) : super(key: key);

  @override
  State<SearchChipBrand> createState() => _SearchChipBrandState();
}

class _SearchChipBrandState extends State<SearchChipBrand> {
  final ScrollController scrollController = ScrollController();
  late HomeBloc homeBloc;
  final ValueNotifier<List<int>> selectedBrand = ValueNotifier([]);
  List<String> selectedBrandSlugs = [];
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
        buildWhen: (previous, current) => previous.brands != current.brands,
        builder: (context, state) {
          if (state.brands.isNullOrEmpty) {
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
                              valueListenable: selectedBrand,
                              builder: (context, value, _) {
                                return InkWell(
                                  onTap: () {
                                    if (selectedBrand.value.contains(index)) {
                                      selectedBrandSlugs.remove(
                                          '"${state.brands![index].slug ?? ""}"');
                                      selectedBrand.value.remove(index);
                                      homeBloc.add(
                                          AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent(
                                              withBoutique: false,
                                              withBrand: true,
                                              selectedBoutiqueBrandCategorySlugsForSearch:
                                                  selectedBrandSlugs));
                                    } else {
                                      selectedBrand.value.add(index);
                                      selectedBrandSlugs.add(
                                          '"${state.brands![index].slug ?? ""}"');

                                      homeBloc.add(
                                          AddSelectedBoutiqueCategoryBrandSlugsForSearchEvent(
                                              withBoutique: false,
                                              withBrand: true,
                                              selectedBoutiqueBrandCategorySlugsForSearch:
                                                  selectedBrandSlugs));
                                    }
                                    selectedBrand.notifyListeners();
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
                                                  SvgNetworkWidget(
                                                    svgUrl: state
                                                        .brands![index].icon!,
                                                    width: 30,
                                                    height: 15,
                                                  ),
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
                          itemCount: state.brands!.length),
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
