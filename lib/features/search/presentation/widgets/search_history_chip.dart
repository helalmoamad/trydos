import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/search/presentation/widgets/close_circle.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import 'package:get_it/get_it.dart';

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
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
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
                  Filter filters = BlocProvider.of<BoutiqueBloc>(context)
                          .state
                          .choosedFiltersByUser['search']
                          ?.filters ??
                      Filter();
                  BlocProvider.of<BoutiqueBloc>(context)
                      .add(ChangeAppliedFiltersEvent(
                    boutiqueSlug: 'search',
                    filtersAppliedByUser: GetProductFiltersModel(
                        filters: filters.copyWithSaveOtherField(
                      prices: filters.prices,
                      searchText: text,
                    )),
                  ));
                  BlocProvider.of<BoutiqueBloc>(context).add(
                      GetProductsWithFiltersEvent(
                          offset: 1,
                          boutiqueSlug: 'search',
                          resetChoosedFilters: false,
                          fromSearch: true,
                          searchText: text));

                  BlocProvider.of<BoutiqueBloc>(context).add(GetFiltersEvent(
                      fromHomePageSearch: true,
                      boutiqueSlug: 'search',
                      searchText: text));
                },
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: const Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      text,
                      style: context.textTheme.titleLarge?.rq.copyWith(
                          height: 18 / 14, color: const Color(0xff8D8D8D)),
                    ),
                  ),
                ),
              ),
              const SizedBox(
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
              child: const Align(
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
