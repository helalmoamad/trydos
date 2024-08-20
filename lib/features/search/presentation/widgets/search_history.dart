import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/search/presentation/widgets/search_history_chip.dart';

import '../../../../common/constant/design/assets_provider.dart';

class SearchHistory extends StatefulWidget {
  final List<String> items;
  final ValueNotifier<int> buildSearchResult;
  final ValueNotifier<bool> appearTrendingAndHistory;
  final TextEditingController controller;

  const SearchHistory(
      {super.key,
      required this.items,
      required this.buildSearchResult,
      required this.appearTrendingAndHistory,
      required this.controller});

  @override
  State<SearchHistory> createState() => _SearchHistoryState();
}

class _SearchHistoryState extends State<SearchHistory> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ValueNotifier<bool> changeViewMode = ValueNotifier(false);
  List<String> _items = [];

  @override
  Widget build(BuildContext context) {
    _items = List.of(widget.items);
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 10.0, start: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: changeViewMode,
              builder: (context, value, _) {
                return _items.isNotEmpty
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              changeViewMode.value = !changeViewMode.value;
                            },
                            child: SvgPicture.asset(
                              AppAssets.searchHistorySvg,
                              width: 20,
                              height: 20,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          if (value) ...{
                            Expanded(
                              child: SizedBox(
                                height: 28,
                                child: Row(
                                  children: [
                                    MyTextWidget(
                                      'Search History',
                                      style: context.textTheme.titleLarge?.mq
                                          .copyWith(
                                              height: 18 / 14,
                                              color: Color(0xff505050)),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        BlocProvider.of<HomeBloc>(context).add(
                                            RemoveSearchTextfromHistoryEvent(
                                                clearAll: true,
                                                searchTitle: ""));
                                      },
                                      child: MyTextWidget(
                                        'Clear All',
                                        style: context.textTheme.titleLarge?.rq
                                            .copyWith(
                                                height: 18 / 14,
                                                decoration:
                                                    TextDecoration.underline,
                                                color: Color(0xff505050)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          } else ...{
                            Expanded(
                              child: SizedBox(
                                  height: 28,
                                  child: AnimatedList(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    key: _listKey,
                                    initialItemCount: _items.length,
                                    itemBuilder: (ctx, index, animation) {
                                      return buildItem(
                                          index, _items[index], animation);
                                    },
                                  )),
                            ),
                          }
                        ],
                      )
                    : const SizedBox.shrink();
              }),
          ValueListenableBuilder<bool>(
              valueListenable: changeViewMode,
              builder: (context, value, _) {
                return value && _items.isNotEmpty
                    ? ScrollConfiguration(
                        behavior: CupertinoScrollBehavior(),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          padding: EdgeInsets.only(top: 15, right: 20),
                          itemBuilder: (ctx, index) => Container(
                            height: 40,
                            width: 1.sw,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                                color: Color(0xffF8F8F8),
                                borderRadius: BorderRadius.circular(10)),
                            child: InkWell(
                              onTap: () {
                                widget.controller.text = _items[index];
                                //  widget.buildSearchResult.value = 1;
                                widget.appearTrendingAndHistory.value = true;

                                Filter filters =
                                    BlocProvider.of<HomeBloc>(context)
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
                                    searchText: _items[index],
                                  )),
                                ));
                                BlocProvider.of<HomeBloc>(context).add(
                                    GetProductsWithFiltersEvent(
                                        offset: 1,
                                        boutiqueSlug: 'search',
                                        resetChoosedFilters: false,
                                        fromSearch: true,
                                        searchText: _items[index]));

                                BlocProvider.of<HomeBloc>(context).add(
                                    GetProductFiltersEvent(
                                        fromHomePageSearch: true,
                                        boutiqueSlug: 'search',
                                        searchText: _items[index]));
                              },
                              child: MyTextWidget(
                                _items[index],
                                textAlign: TextAlign.start,
                                style: context.textTheme.titleLarge?.rq.copyWith(
                                    height: 18 / 14, color: Color(0xff8D8D8D)),
                              ),
                            ),
                          ),
                          itemCount: _items.length,
                          separatorBuilder: (ctx, index) => SizedBox(
                            height: 5,
                          ),
                        ),
                      )
                    : SizedBox.shrink();
              })
        ],
      ),
    );
  }

  Widget buildItem(int index, String text, Animation<double> animation) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..translate(0.0, 0.0, (1.0 - animation.value)),
            child: Opacity(
              opacity: animation.value,
              child: child,
            ),
          );
        },
        child: SearchHistoryChip(
          controller: widget.controller,
          buildSearchResult: widget.buildSearchResult,
          appearTrendingAndHistory: widget.appearTrendingAndHistory,
          text: text,
          onClickClose: () {
            final removedItem = _items[index];
            _items.removeAt(index);
            changeViewMode.notifyListeners();
            _listKey.currentState!.removeItem(
              index,
              (context, animation) => buildItem(index, removedItem, animation),
            );
            //removeFromHistory.value = !removeFromHistory.value;
            BlocProvider.of<HomeBloc>(context).add(
                RemoveSearchTextfromHistoryEvent(
                    clearAll: false, searchTitle: text));
          },
        ));
  }
}
