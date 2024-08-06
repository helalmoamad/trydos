import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../app/my_text_widget.dart';
import '../../../home/data/models/get_product_filters_model.dart';
import '../../../home/data/models/get_product_listing_with_filters_model.dart'
    as product_listing;
import '../../../home/presentation/widgets/product_listing/categories_filter_list.dart';

class SearchChipCategory extends StatefulWidget {
  final String title;
  final bool isLoading;
  final TextEditingController controller;

  const SearchChipCategory(
      {Key? key,
      required this.title,
      required this.controller,
      required this.isLoading})
      : super(key: key);

  @override
  State<SearchChipCategory> createState() => _SearchChipCategoryState();
}

class _SearchChipCategoryState extends State<SearchChipCategory> {
  final ValueNotifier<bool> scaleTheTopItemInFiltersStack =
      ValueNotifier(false);
  final ValueNotifier<int> expandingFiltersStack = ValueNotifier(-1);
  final ScrollController scrollController = ScrollController();
  late HomeBloc homeBloc;

  List<String> selectedCategorySlugs = [];

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
        builder: (context, state) {
          String key = 'search';
          Filter filters =
              state.getProductFiltersModel[key]?.filters ?? Filter();
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
                height: 90,
                child: ScrollConfiguration(
                    behavior: CupertinoScrollBehavior(),
                    child: CategoriesFilterList(
                      boutiqueSlug: 'search',
                      fromSearch: true,
                      expandingFiltersStack: expandingFiltersStack,
                      scaleTheTopItemInFiltersStack:
                          scaleTheTopItemInFiltersStack,
                      workWithChoosedFilter: true,
                    )),
              ),
            ],
          );
        },
      ),
    );
  }
}
