import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/search/presentation/widgets/close_circle.dart';

class SearchHistoryChip extends StatelessWidget {
  final ValueNotifier<int> buildSearchResult;
  final ValueNotifier<bool> appearTrendingAndHistory;
  final TextEditingController controller;

  const SearchHistoryChip(
      {super.key,
      required this.text,
      required this.onClickClose,
      required this.buildSearchResult,
      required this.appearTrendingAndHistory,
      required this.controller});

  final String text;
  final void Function() onClickClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  controller.text = text;
                  buildSearchResult.value = 1;
                  appearTrendingAndHistory.value = true;
                  Filter filters = BlocProvider.of<HomeBloc>(context)
                          .state
                          .choosedFiltersByUser['search']
                          ?.filters ??
                      Filter();
                  BlocProvider.of<HomeBloc>(context)
                      .add(ChangeAppliedFiltersEvent(
                    boutiqueSlug: 'search',
                    filtersAppliedByUser: GetProductFiltersModel(
                        filters: filters.copyWithSaveOtherField(
                      prices: filters.prices,
                      searchText: text,
                    )),
                  ));
                  BlocProvider.of<HomeBloc>(context).add(
                      GetProductsWithFiltersEvent(
                          offset: 1,
                          boutiqueSlug: 'search',
                          resetChoosedFilters: false,
                          fromSearch: true,
                          searchText: text));

                  BlocProvider.of<HomeBloc>(context).add(GetProductFiltersEvent(
                      fromHomePageSearch: true,
                      boutiqueSlug: 'search',
                      searchText: text));
                },
                child: Container(
                  height: 28,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      text,
                      style: context.textTheme.titleLarge?.rq
                          .copyWith(height: 18 / 14, color: Color(0xff8D8D8D)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              )
            ],
          ),
          GestureDetector(
            onTap: onClickClose,
            child: Container(
              width: 12,
              height: 12,
              color: Colors.transparent, // don't remove it
              child: Align(
                alignment: Alignment.centerRight,
                child: CloseCircle(
                    width: 12,
                    height: 12,
                    borderColor: Color(0xffC4C2C2),
                    closeSvgColor: Color(0xffFF5F61)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
