/*import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';

import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import 'package:trydos/core/utils/extensions/list.dart';

import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';

import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter_products;

import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';

import 'package:trydos/service/language_service.dart';
import 'package:tuple/tuple.dart';

import '../../../../core/data/model/pagination_model.dart';

import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';

import '../../data/models/get_home_boutiqes_model.dart';

import '../manager/home_bloc.dart';
import '../widgets/product_listing/product_item.dart';

class ProductListingSearchPage extends StatefulWidget {
  const ProductListingSearchPage({
    super.key,
  });

  @override
  State<ProductListingSearchPage> createState() =>
      _ProductListingSearchPageState();
}

class _ProductListingSearchPageState extends State<ProductListingSearchPage> {
  late AppBloc appBloc;
  late HomeBloc homeBloc;

  final FocusNode focusNode = FocusNode();
  final ValueNotifier<int> buildSearchResult = ValueNotifier(0);
  final ValueNotifier<bool> hideTrendingAndHistory = ValueNotifier(false);
  final ValueNotifier<bool> searchVisible = ValueNotifier(true);

  final TextEditingController controller = TextEditingController();
  Timer? timerForDisplayFilterSectionTitle;
  final GlobalKey htmlDescriptionKey = GlobalKey();
  final ValueNotifier<double> htmlDescriptionHeight = ValueNotifier(0);

  final ScrollController scrollController = ScrollController();
  final ValueNotifier<Tuple2<int, int>> setThisEnabledNotifier =
      ValueNotifier(Tuple2(-1, -1));
  final ValueNotifier<String?> showTitleForFilterList = ValueNotifier(null);
  final ValueNotifier<bool> displayBoutiqueIconInAppBar = ValueNotifier(false);
  final ValueNotifier<bool> filterPageExpanded = ValueNotifier(false);
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void initState() {
    Timer.periodic(Duration(milliseconds: 100), postFrameCallback);
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);

    scrollController.addListener(() {
      if (filterPageExpanded.value) return;
      if (scrollController.position.pixels <= 80) {
        debugPrint(scrollController.position.pixels.toString());
        appBloc.add(ShowOrHideBars(true));
      }
      // else if(filterPageExpanded.value){
      //   scrollController.jumpTo(80);
      // }
      if (setThisEnabledNotifier.value.item1 != -1) {
        setThisEnabledNotifier.value = Tuple2(-1, -1);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    appBloc.add(ShowOrHideBars(true));
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        hideTrendingAndHistory.value =
            controller.text.length > 0 ? true : false;
      }
    });
    super.didChangeDependencies();
  }

  Key gridViewKeyForRendering = UniqueKey();

  void postFrameCallback(timer) {
    var context = htmlDescriptionKey.currentContext;
    if (context == null || htmlDescriptionHeight.value > 0) return;
    timer.cancel();
    htmlDescriptionHeight.value = context.size!.height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
          return CustomScrollView(
              controller: scrollController,
              physics: ClampingScrollPhysics(),
              slivers: [
                BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (p, c) {
                    return p.searchResultModel != c.searchResultModel ||
                        p.getSearchResultStatus != c.getSearchResultStatus;
                  },
                  builder: (context, state) {
                    if (state.getSearchResultStatus !=
                        GetSearchResultStatus.success) {
                      return SliverPadding(
                        padding: const EdgeInsets.only(top: 10),
                        sliver: SliverGrid(
                          key: gridViewKeyForRendering,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 200.w / 350,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 15,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            childCount: 4,
                            (BuildContext context, int index) {
                              return Container(
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[200]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      color: Color(0xffF8F8F8),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                            Color.fromARGB(255, 234, 236, 238),
                                        width: 0.3),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(5),
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(5),
                                    ),
                                  ));
                            },
                          ),
                        ),
                      );
                    }
                    List<filter_products.Products> products;

                    products = state.searchResultModel!.data!.products ?? [];

                    return SliverPadding(
                      padding: const EdgeInsets.only(top: 10),
                      sliver: SliverGrid(
                        key: gridViewKeyForRendering,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 200.w / 350,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 15,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          childCount: products.length,
                          (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () async {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => ProductDetailsPage(
                                          productItem: products[index],
                                        )));
                              },
                              child: ProductItem(
                                slidingModeItem: setThisEnabledNotifier.value,
                                productItem: products[index],
                                itemIndex: index,
                                setThisEnabled: (int index, int slideMode) {
                                  setThisEnabledNotifier.value =
                                      Tuple2(index, slideMode);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                )
              ]);
        }));
  }
}
*/