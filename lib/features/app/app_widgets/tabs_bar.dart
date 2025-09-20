import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart' as geminis;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mime/mime.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/gallery_and_camera_dialog_widget.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_bloc.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import 'package:trydos/features/search/presentation/widgets/search_with_image_related_gemini.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/language_service.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../common/constant/design/assets_provider.dart';
import '../../../common/constant/design/constant_design.dart';
import '../../../common/test_utils/widgets_keys.dart';
import '../../../core/utils/responsive_padding.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import '../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../home/data/models/get_product_filters_model.dart';
import '../../home/presentation/manager/homeBloc/home_bloc.dart';
import '../../home/presentation/manager/homeBloc/home_state.dart';
import '../animated_search_bar/animated_search_bar.dart';
import '../blocs/app_bloc/app_bloc.dart';
import '../blocs/app_bloc/app_event.dart';
import '../blocs/app_bloc/app_state.dart';
import '../my_text_widget.dart';

class TabsBar extends StatefulWidget {
  const TabsBar({
    Key? key,
    required this.buildSearchResult,
    required this.appearTrendingAndHistory,
    required this.controller,
  }) : super(key: key);
  final ValueNotifier<int> buildSearchResult;
  final ValueNotifier<bool> appearTrendingAndHistory;

  final TextEditingController controller;

  @override
  State<TabsBar> createState() => _TabsBarState();
}

class _TabsBarState extends State<TabsBar> {
  late AppBloc appBloc;
  late BoutiqueBloc boutiqueBloc;
  late HomeBloc homeBloc;
  Timer? debounce;
  late CategoryBloc categoryBloc;
  late final geminis.Gemini gemini;
  final SpeechToText _speechToText = SpeechToText();
  final ValueNotifier<bool> isRecordeForSearchWithMic = ValueNotifier(false);
  bool _speechEnabled = false;
  //List<String> sizesForSearch = [];
  // List<String> colorsCodeForSearch = [];
  // List<String> colorsNameForSearch = [];
  /* List<String> constWordToRemoveItFromSearch = [
    "قياس",
    "حجم",
    "لون",
    "اللون",
    "الالوان"
        "Measurement",
    "Size",
    "Color",
    "Colors"
  ];*/
  void _startListening() async {
    if (!_speechEnabled) {
      _speechEnabled = await _speechToText.initialize();
    }

    await _speechToText.listen(
      pauseFor: const Duration(seconds: 5),
      onResult: (result) async {
        if (result.recognizedWords.replaceAll(" ", "").length > 2) {
          resetSearchAfterSearchingWhileRemoveSearch = true;
          widget.controller.text = result.recognizedWords;
          //List<String>? colorsFilter = [];
          //List<String> listSearchTextWithoutConstWord =
          //    result.recognizedWords.split(" ").toList();
          String searchText = result.recognizedWords;
          //   List<String>? sizesFilter = [];

          //  List<String> listOfSearchText =
          //   result.recognizedWords.split(" ").toList();
          /*for (var i = 0; i < colorsNameForSearch.length; i++) {
            if (listOfSearchText.contains(colorsNameForSearch[i])) {
              colorsFilter.add(colorsCodeForSearch[i]);
              listSearchTextWithoutConstWord.remove(colorsNameForSearch[i]);
            }
          }*/

          /* for (var i = 0; i < sizesForSearch.length; i++) {
            if (listOfSearchText.contains(sizesForSearch[i])) {
              sizesFilter.add(sizesForSearch[i]);
              listSearchTextWithoutConstWord.remove(sizesForSearch[i]);
            }
          }*/
          /*for (var i = 0; i < constWordToRemoveItFromSearch.length; i++) {
            listSearchTextWithoutConstWord
                .remove(constWordToRemoveItFromSearch[i]);
          }*/
          // listSearchTextWithoutConstWord
          //  .forEach((element) => searchText = searchText + " " + element);
          Filter filters = BlocProvider.of<BoutiqueBloc>(context)
                  .state
                  .choosedFiltersByUser['search']
                  ?.filters ??
              Filter();
          BlocProvider.of<BoutiqueBloc>(context).add(
            ChangeSelectedFiltersEvent(
                boutiqueSlug: 'search',
                fromHomePageSearch: true,
                filtersChoosedByUser: GetProductFiltersModel(
                  filters: filters.copyWithSaveOtherField(
                    prices: filters.prices,
                    searchText: searchText,
                  ),
                )),
          );
          BlocProvider.of<BoutiqueBloc>(context).add(ChangeAppliedFiltersEvent(
            boutiqueSlug: 'search',
            filtersAppliedByUser: GetProductFiltersModel(
                filters: filters.copyWithSaveOtherField(
              prices: filters.prices,
              searchText: searchText,
            )),
          ));
          BlocProvider.of<BoutiqueBloc>(context).add(
              GetProductsWithFiltersEvent(
                  offset: 1,
                  boutiqueSlug: 'search',
                  resetChoosedFilters: false,
                  fromSearch: true,
                  searchText: searchText));
        }
      },
    );

    isRecordeForSearchWithMic.value = true;
    Future.delayed(
      const Duration(seconds: 8),
      () => isRecordeForSearchWithMic.value = false,
    );
  }

  void _stopListening() async {
    await _speechToText.stop();

    isRecordeForSearchWithMic.value = false;
  }

  final ScrollController scrollController = ScrollController();
  Timer? categoryDebounce;
  @override
  void initState() {
    categoryBloc = BlocProvider.of<CategoryBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    gemini = geminis.Gemini.instance;
    /* homeBloc.state.geColorsAndSizesForSearchModel?.data?.colors
        ?.forEach((element) {
      colorsCodeForSearch.add(element.code ?? "");
      colorsNameForSearch.add(element.name ?? "");
    });*/

    /*homeBloc.state.geColorsAndSizesForSearchModel?.data?.sizes
        ?.forEach((element) {
      sizesForSearch.add(element);
    });*/
    widget.controller.clear();
    List<String>? categorySlugs = [];
    categoryBloc.state.mainCategoriesResponseModel?.data?.mainCategories
        ?.forEach(
      (element) {
        categorySlugs.add(element.slug!);
      },
    );
    if (categoryDebounce?.isActive ?? false) {
      categoryDebounce!.cancel();
    }
    categoryDebounce = Timer(const Duration(milliseconds: 600), () {
      scrollController.addListener(() {
        if (categorySlugs.isEmpty) {
          categoryBloc.state.mainCategoriesResponseModel?.data?.mainCategories
              ?.forEach(
            (element) {
              categorySlugs.add(element.slug!);
            },
          );
          if (categorySlugs.isEmpty) return;
        }
        int lastIndexSeenByUser = max(
            0,
            (scrollController.position.pixels +
                    scrollController.position.viewportDimension -
                    55) ~/
                40);
        lastIndexSeenByUser =
            min(categorySlugs.length - 1, lastIndexSeenByUser);
        for (int i = 0; i <= lastIndexSeenByUser; i++) {
          if (categoryBloc.state.boutiquesForEveryMainCategoryThatDidPrefetch[
                  categorySlugs[i]] !=
              true) {
            categoryBloc.add(GetHomeBoutiqesEvent(
              withSemaphore: true,
              getWithPrefetchToStoreInMemory: true,
              context: context,
              categorySlug: categorySlugs[i],
              offset: "1",
            ));
          }
        }
      });
    });

    widget.appearTrendingAndHistory.value = true;
    appBloc = BlocProvider.of<AppBloc>(context);

    super.initState();
  }

  final FocusNode focusNode = FocusNode();
  bool resetSearchAfterSearchingWhileRemoveSearch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: BlocBuilder<CategoryBloc, CategoryState>(
            buildWhen: (oldState, newState) =>
                (oldState.getMainCategoriesStatus ==
                        GetMainCategoriesStatus.loading &&
                    newState.getMainCategoriesStatus ==
                        GetMainCategoriesStatus.success) ||
                oldState.sendRequestToGeminiStatus !=
                    newState.sendRequestToGeminiStatus,
            builder: (context, homeState) {
              if ((homeState.theReplyFromGemini ?? '') != "" &&
                  homeState.fromSearchForSearchWithGemini == true) {
                // List<String>? colorsFilter = [];
                //// List<String> listSearchTextWithoutConstWord =
                //   homeState.theReplyFromGemini!.split(" ").toList();
                String searchText = homeState.theReplyFromGemini!;
                /* List<String>? sizesFilter = [];
                List<String> listOfSearchText =
                    homeState.theReplyFromGemini!.split(" ").toList();*/
                /* for (var i = 0; i < colorsNameForSearch.length; i++) {
                  if (listOfSearchText.contains(colorsNameForSearch[i])) {
                    colorsFilter.add(colorsCodeForSearch[i]);
                    listSearchTextWithoutConstWord
                        .remove(colorsNameForSearch[i]);
                  }
                }*/

                /* for (var i = 0; i < sizesForSearch.length; i++) {
                  if (listOfSearchText.contains(sizesForSearch[i])) {
                    sizesFilter.add(sizesForSearch[i]);
                    listSearchTextWithoutConstWord.remove(sizesForSearch[i]);
                  }
                }
                for (var i = 0; i < constWordToRemoveItFromSearch.length; i++) {
                  listSearchTextWithoutConstWord
                      .remove(constWordToRemoveItFromSearch[i]);
                }*/
                //listSearchTextWithoutConstWord.forEach(
                //   (element) => searchText = searchText + " " + element);
                widget.controller.text = homeState.theReplyFromGemini ?? "";
                Filter filters = BlocProvider.of<BoutiqueBloc>(context)
                        .state
                        .choosedFiltersByUser['search']
                        ?.filters ??
                    Filter();
                BlocProvider.of<BoutiqueBloc>(context)
                    .add(ChangeSelectedFiltersEvent(
                        boutiqueSlug: 'search',
                        fromHomePageSearch: true,
                        filtersChoosedByUser: GetProductFiltersModel(
                            filters: filters.copyWithSaveOtherField(
                          prices: filters.prices,
                          searchText: searchText,
                        ))));
                BlocProvider.of<BoutiqueBloc>(context)
                    .add(ChangeAppliedFiltersEvent(
                  boutiqueSlug: 'search',
                  filtersAppliedByUser: GetProductFiltersModel(
                      filters: filters.copyWithSaveOtherField(
                    prices: filters.prices,
                    searchText: searchText,
                  )),
                ));
                BlocProvider.of<BoutiqueBloc>(context).add(
                    GetProductsWithFiltersEvent(
                        offset: 1,
                        boutiqueSlug: 'search',
                        resetChoosedFilters: false,
                        fromSearch: true,
                        searchText: searchText));
              }
              if (homeState.mainCategoriesResponseModel == null) {
                return Container(
                  width: 1.sw,
                  height: 60.h,
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: colorScheme.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1a000000),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                      key: TestVariables.kTestMode
                          ? const Key(WidgetsKeys.mainCategoriesTabNullKey)
                          : null,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                          5,
                          (index) => TrydosLoader(
                                size: 15.sp,
                              ))),
                );
              }
              return Container(
                  width: 1.sw,
                  height: 45 + 5.h,
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: colorScheme.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1a000000),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AnimatedSearchBar(
                              autoFocus: TestVariables.kTestMode ? false : true,
                              onFieldSubmitted: (text) {
                                if (text.replaceAll(" ", "").length > 2) {
                                  widget.buildSearchResult.value = text.length;
                                  widget.appearTrendingAndHistory.value = true;

                                  BlocProvider.of<HomeBloc>(context).add(
                                      AddSearchTextToHistoryEvent(
                                          searchTitle: text));
                                }
                              },
                              width: 1.sw,
                              height: 50,
                              onClickClose: () {
                                if (widget.controller.text.length > 0) {
                                  categoryBloc.add(ReplyFromGeminiEvent(
                                    fromSearch: true,
                                    resetTheReply: true,
                                  ));
                                  Filter filters = boutiqueBloc
                                          .state
                                          .choosedFiltersByUser['search']
                                          ?.filters ??
                                      Filter();
                                  Filter appliedFilters = boutiqueBloc
                                          .state
                                          .appliedFiltersByUser['search']
                                          ?.filters ??
                                      Filter();
                                  boutiqueBloc.add(ChangeAppliedFiltersEvent(
                                    boutiqueSlug: 'search',
                                    filtersAppliedByUser:
                                        GetProductFiltersModel(
                                            filters: appliedFilters
                                                .copyWithSaveOtherField(
                                      prices: appliedFilters.prices,
                                      colors: [],
                                      attributes: [],
                                    )),
                                  ));
                                  boutiqueBloc.add(ChangeSelectedFiltersEvent(
                                    boutiqueSlug: 'search',
                                    fromHomePageSearch: true,
                                    filtersChoosedByUser:
                                        GetProductFiltersModel(
                                            filters: filters
                                                .copyWithSaveOtherField(
                                                    colors: [],
                                                    attributes: [],
                                                    prices: filters.prices)),
                                  ));
                                  widget.buildSearchResult.value = 0;
                                  widget.controller.clear();
                                  resetSearchAfterSearchingWhileRemoveSearch =
                                      false;
                                  widget.appearTrendingAndHistory.value = true;
                                  ///////////////////////////
                                  // FirebaseAnalyticsService.logEventForSession(
                                  //   eventName:
                                  //       AnalyticsEventsConst.buttonClicked,
                                  //   executedEventName:
                                  //       AnalyticsButtonsEventNameConst
                                  //           .resetCloseIconButton,
                                  // );
                                  return true;
                                } else {
                                  appBloc.add(ChangeBasePage(0));
                                  boutiqueBloc.add(
                                      ResetAllSelectedAppliedFilterEvent());
                                  appBloc.add(HideBottomNavigationBar(false));

                                  ///////////////////////////
                                  // FirebaseAnalyticsService.logEventForSession(
                                  //   eventName:
                                  //       AnalyticsEventsConst.buttonClicked,
                                  //   executedEventName:
                                  //       AnalyticsButtonsEventNameConst
                                  //           .searchCloseIconButton,
                                  // );
                                }
                                return false;
                              },
                              textController: widget.controller,
                              focusNode: focusNode,
                              onSuffixTap: () {
                                appBloc.add(ChangeIndexForSearch(2));
                                widget.buildSearchResult.value = 1;
                                widget.appearTrendingAndHistory.value = true;
                                //////////////////////////////////
                                Future.delayed(
                                    const Duration(milliseconds: 300), () {
                                  appBloc.add(ChangeBasePage(4));
                                  appBloc.add(HideBottomNavigationBar(true));
                                });
                                ////////////////////////////////
                                // FirebaseAnalyticsService.logEventForSession(
                                //   eventName: AnalyticsEventsConst.buttonClicked,
                                //   executedEventName:
                                //       AnalyticsButtonsEventNameConst
                                //           .homeSearchButton,
                                // );
                              },
                              suffixWidget: Center(
                                key: TestVariables.kTestMode
                                    ? const Key(WidgetsKeys.homeSearchIconKey)
                                    : null,
                                child: SvgPicture.asset(
                                  AppAssets.searchOutlinedSvg,
                                  height: 20,
                                  width: 40,
                                  color: const Color(0xff388CFF),
                                ),
                              ),
                              prefixWidget: Padding(
                                padding: const EdgeInsets.only(
                                    right: 15, top: 10, bottom: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        SearchWithImageRelatedGemini
                                            .SelecteImageForSearch(
                                                fromSearch: true,
                                                context: context);
                                      },
                                      child: homeState
                                                  .sendRequestToGeminiStatus ==
                                              SendRequestToGeminiStatus.loading
                                          ? TrydosLoader(
                                              size: 18,
                                            )
                                          : SvgPicture.asset(
                                              AppAssets.realCameraSvg,
                                              height: 20,
                                              width: 20,
                                            ),
                                    ),
                                    ValueListenableBuilder<bool>(
                                      valueListenable:
                                          isRecordeForSearchWithMic,
                                      builder: (context,
                                          recordeForSearchWithMic, _) {
                                        return InkWell(
                                          onTap: () async {
                                            /*final status = await Permission
                                                .microphone
                                                .request();
                                            if (status !=
                                                PermissionStatus.granted) {
                                              return;
                                            }*/
                                            print(
                                                "**************************************//////");

                                            _speechToText.isNotListening
                                                ? _startListening()
                                                : _stopListening();
                                          },
                                          child: Container(
                                            width: 20,
                                            child: Icon(
                                                _speechToText.isNotListening ||
                                                        !recordeForSearchWithMic
                                                    ? Icons.mic_off
                                                    : Icons.mic),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              animationDurationInMilli: 400,
                              searchDecoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: focusNode.hasFocus
                                          ? const Color(0xffE6E6E6)
                                          : const Color(0xffF8F8F8),
                                      width: 0.4),
                                  borderRadius:
                                      BorderRadius.circular(kbrBorderTextField),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: focusNode.hasFocus
                                          ? const Color(0xffE6E6E6)
                                          : const Color(0xffF8F8F8),
                                      width: 0.4),
                                  borderRadius:
                                      BorderRadius.circular(kbrBorderTextField),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: focusNode.hasFocus
                                          ? const Color(0xffE6E6E6)
                                          : const Color(0xffF8F8F8),
                                      width: 0.4),
                                  borderRadius:
                                      BorderRadius.circular(kbrBorderTextField),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: focusNode.hasFocus
                                          ? const Color(0xffE6E6E6)
                                          : const Color(0xffF8F8F8),
                                      width: 0.4),
                                  borderRadius:
                                      BorderRadius.circular(kbrBorderTextField),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: context.colorScheme.error,
                                      width: 0.4),
                                  borderRadius:
                                      BorderRadius.circular(kbrBorderTextField),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: context.colorScheme.error,
                                      width: 0.4),
                                  borderRadius:
                                      BorderRadius.circular(kbrBorderTextField),
                                ),
                                filled: true,
                                fillColor: focusNode.hasFocus
                                    ? colorScheme.white
                                    : const Color(0xffF8F8F8),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 12),
                                  child: SvgPicture.asset(
                                    AppAssets.searchOutlinedSvg,
                                    height: 20,
                                    width: 40,
                                    color: const Color(0xff388CFF),
                                  ),
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15, top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          SearchWithImageRelatedGemini
                                              .SelecteImageForSearch(
                                                  fromSearch: true,
                                                  context: context);
                                          /////////////////////////////
                                          // FirebaseAnalyticsService
                                          //     .logEventForSession(
                                          //   eventName: AnalyticsEventsConst
                                          //       .buttonClicked,
                                          //   executedEventName:
                                          //       AnalyticsButtonsEventNameConst
                                          //           .searchWithImageButton,
                                          // );
                                        },
                                        child: homeState
                                                    .sendRequestToGeminiStatus ==
                                                SendRequestToGeminiStatus
                                                    .loading
                                            ? TrydosLoader(
                                                size: 18,
                                              )
                                            : SvgPicture.asset(
                                                AppAssets.realCameraSvg,
                                                height: 20,
                                                width: 20,
                                              ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      ValueListenableBuilder<bool>(
                                        valueListenable:
                                            isRecordeForSearchWithMic,
                                        builder: (context,
                                            recordeForSearchWithMic, _) {
                                          return InkWell(
                                            onTap: () async {
                                              /*  final status = await Permission
                                                  .microphone
                                                  .request();
                                              if (status !=
                                                  PermissionStatus.granted) {
                                                return;
                                              }*/

                                              if (_speechToText
                                                  .isNotListening) {
                                                _startListening();
                                                /////////////////////////////
                                                // FirebaseAnalyticsService
                                                //     .logEventForSession(
                                                //   eventName:
                                                //       AnalyticsEventsConst
                                                //           .buttonClicked,
                                                //   executedEventName:
                                                //       AnalyticsButtonsEventNameConst
                                                //           .searchWithVoiceButton,
                                                // );
                                              } else {
                                                _stopListening();
                                              }
                                            },
                                            child: Container(
                                              width: 20,
                                              child: Icon(_speechToText
                                                          .isNotListening ||
                                                      !recordeForSearchWithMic
                                                  ? Icons.mic_off
                                                  : Icons.mic),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                //context.colorScheme.white,
                                contentPadding: HWEdgeInsetsDirectional.only(
                                    start: 20, end: 10, bottom: 12, top: 12),
                                hintText: 'Search',
                                hintStyle: context.textTheme.bodyMedium?.lq
                                    .copyWith(color: const Color(0xffC4C2C2)),
                                labelStyle: context.textTheme.titleLarge
                                    ?.copyWith(color: context.colorScheme.hint),
                              ),
                              onChanged: (String text) {
                                if (debounce?.isActive ?? false) {
                                  debounce!.cancel();
                                }
                                debounce =
                                    Timer(const Duration(seconds: 1), () {
                                  //  List<String>? colorsFilter = [];
                                  //  List<String> listSearchTextWithoutConstWord =
                                  //    text.split(" ").toList();
                                  String searchText = text;
                                  //   List<String>? sizesFilter = [];

                                  if (text.length > 2) {
                                    /* List<String> listOfSearchText =
                                        text.split(" ").toList();
                                    for (var i = 0;
                                        i < colorsNameForSearch.length;
                                        i++) {
                                      if (listOfSearchText
                                          .contains(colorsNameForSearch[i])) {
                                        colorsFilter
                                            .add(colorsCodeForSearch[i]);
                                        listSearchTextWithoutConstWord
                                            .remove(colorsNameForSearch[i]);
                                      }
                                    }*/

                                    /*  for (var i = 0;
                                        i < sizesForSearch.length;
                                        i++) {
                                      if (listOfSearchText
                                          .contains(sizesForSearch[i])) {
                                        sizesFilter.add(sizesForSearch[i]);
                                        listSearchTextWithoutConstWord
                                            .remove(sizesForSearch[i]);
                                      }
                                    }*/
                                    /*  for (var i = 0;
                                        i <
                                            constWordToRemoveItFromSearch
                                                .length;
                                        i++) {
                                      listSearchTextWithoutConstWord.remove(
                                          constWordToRemoveItFromSearch[i]);
                                    }
                                    listSearchTextWithoutConstWord.forEach(
                                        (element) => searchText =
                                            searchText + " " + element);*/

                                    resetSearchAfterSearchingWhileRemoveSearch =
                                        true;
                                    Filter filters = boutiqueBloc
                                            .state
                                            .choosedFiltersByUser['search']
                                            ?.filters ??
                                        Filter();
                                    //   print(sizesFilter.isEmpty);
                                    boutiqueBloc.add(ChangeSelectedFiltersEvent(
                                      boutiqueSlug: 'search',
                                      fromHomePageSearch: true,
                                      filtersChoosedByUser:
                                          GetProductFiltersModel(
                                              filters: filters
                                                  .copyWithSaveOtherField(
                                        prices: filters.prices,
                                        searchText: searchText,
                                      )),
                                    ));
                                    boutiqueBloc.add(
                                        GetProductsWithFiltersEvent(
                                            fromChoosed: true,
                                            offset: 1,
                                            boutiqueSlug: 'search',
                                            resetChoosedFilters: false,
                                            fromSearch: true,
                                            searchText: searchText));
                                    print(
                                        "**222222222222222-------------------------------${text}");

                                    widget.buildSearchResult.value =
                                        text.length;
                                  }
                                  if (text.length < 3) {
                                    categoryBloc.add(ReplyFromGeminiEvent(
                                      fromSearch: true,
                                      resetTheReply: true,
                                    ));
                                    Filter filters = boutiqueBloc
                                            .state
                                            .choosedFiltersByUser['search']
                                            ?.filters ??
                                        Filter();

                                    boutiqueBloc.add(ChangeSelectedFiltersEvent(
                                      boutiqueSlug: 'search',
                                      requestToUpdateFilters: false,
                                      fromHomePageSearch: true,
                                      filtersChoosedByUser:
                                          GetProductFiltersModel(
                                              filters: filters
                                                  .copyWithSaveOtherField(
                                        prices: filters.prices,
                                      )),
                                    ));
                                  }
                                  if (text.length < 3 &&
                                      resetSearchAfterSearchingWhileRemoveSearch) {
                                    resetSearchAfterSearchingWhileRemoveSearch =
                                        false;
                                    Filter filters = boutiqueBloc
                                            .state
                                            .choosedFiltersByUser['search']
                                            ?.filters ??
                                        Filter();
                                    Filter appliedFilters = boutiqueBloc
                                            .state
                                            .appliedFiltersByUser['search']
                                            ?.filters ??
                                        Filter();
                                    boutiqueBloc.add(ChangeAppliedFiltersEvent(
                                      boutiqueSlug: 'search',
                                      filtersAppliedByUser:
                                          GetProductFiltersModel(
                                              filters: appliedFilters
                                                  .copyWithSaveOtherField(
                                        prices: appliedFilters.prices,
                                        colors: [],
                                        attributes: [],
                                      )),
                                    ));
                                    boutiqueBloc.add(ChangeSelectedFiltersEvent(
                                      boutiqueSlug: 'search',
                                      fromHomePageSearch: true,
                                      filtersChoosedByUser:
                                          GetProductFiltersModel(
                                              filters: filters
                                                  .copyWithSaveOtherField(
                                        prices: filters.prices,
                                      )),
                                    ));
                                  }
                                });
                              },
                              hideTrendingAndHistory:
                                  widget.appearTrendingAndHistory,
                            ),
                            BlocBuilder<AppBloc, AppState>(
                              buildWhen: (p, c) =>
                                  p.currentIndex != c.currentIndex,
                              builder: (context, state) {
                                if (state.currentIndex != 4) {
                                  return Container(
                                    padding: EdgeInsets.only(
                                      left: LanguageService.languageCode == "ar"
                                          ? 15
                                          : 0,
                                      right:
                                          LanguageService.languageCode != "ar"
                                              ? 15
                                              : 0,
                                    ),
                                    width: 1.sw - 40,
                                    height: 80,
                                    child: ListView.builder(
                                      controller: scrollController,
                                      padding: const EdgeInsets.only(
                                        right: 15,
                                      ),
                                      key: TestVariables.kTestMode
                                          ? const Key(
                                              WidgetsKeys.mainCategoriesTabKey)
                                          : null,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: (homeState
                                              .mainCategoriesResponseModel
                                              ?.data
                                              ?.mainCategories
                                              ?.length ??
                                          0),
                                      itemBuilder: (context, index) {
                                        MainCategory mainCategory = homeState
                                            .mainCategoriesResponseModel!
                                            .data!
                                            .mainCategories![index];
                                        return Padding(
                                            key: TestVariables.kTestMode
                                                ? Key(
                                                    '${WidgetsKeys.mainCategoriesItemKey}$index')
                                                : null,
                                            padding:
                                                HWEdgeInsetsDirectional.only(
                                                    end: 15),
                                            child: BlocBuilder<BoutiqueBloc,
                                                    BoutiqueState>(
                                                buildWhen: (previous, current) =>
                                                    previous.getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]?.paginationStatus != current.getProductListingWithFiltersPaginationModels["*featured*withoutFilter"]?.paginationStatus ||
                                                    previous
                                                            .getProductListingWithFiltersPaginationModels[
                                                                "*flashDeal*withoutFilter"]
                                                            ?.paginationStatus !=
                                                        current
                                                            .getProductListingWithFiltersPaginationModels[
                                                                "*flashDeal*withoutFilter"]
                                                            ?.paginationStatus ||
                                                    previous.getProductFiltersStatus[
                                                            "*flashDeal*"] !=
                                                        current
                                                            .getProductFiltersStatus["*flashDeal*"],
                                                builder: (context, state) {
                                                  return InkWell(
                                                    onTap: () {
                                                      if (state
                                                                  .getProductListingWithFiltersPaginationModels[
                                                                      "*featured*withoutFilter"]
                                                                  ?.paginationStatus ==
                                                              PaginationStatus
                                                                  .loading ||
                                                          state
                                                                  .getProductListingWithFiltersPaginationModels[
                                                                      "*flashDeal*withoutFilter"]
                                                                  ?.paginationStatus ==
                                                              PaginationStatus
                                                                  .loading) {
                                                        return;
                                                      }
                                                      if (BlocProvider.of<
                                                                      AppBloc>(
                                                                  context)
                                                              .state
                                                              .tabIndex !=
                                                          index) {
                                                        appBloc.add(
                                                            ChangeTab(index));
                                                        ///////////////////////
                                                        categoryBloc.add(
                                                          GetHomeBoutiqesEvent(
                                                            getWithPrefetchToStoreInMemory:
                                                                false,
                                                            getWithOutPrefetchForEachBoutiques:
                                                                true,
                                                            offset: "1",
                                                            categorySlug: homeState
                                                                .mainCategoriesResponseModel!
                                                                .data!
                                                                .mainCategories![
                                                                    index]
                                                                .slug!,
                                                            context: context,
                                                          ),
                                                        );
                                                        ////////////////////////////
                                                        categoryBloc.add(
                                                          ChangeCurrentIndexForMainCategoryEvent(
                                                            index: index,
                                                          ),
                                                        );
                                                        boutiqueBloc.add(AddCurrentMainCategoryTapedEvent(
                                                            currentMainCategoryTaped:
                                                                homeState
                                                                    .mainCategoriesResponseModel!
                                                                    .data!
                                                                    .mainCategories![
                                                                        index]
                                                                    .slug!));
                                                        boutiqueBloc.add(
                                                            const GetProductWithFiltersWithoutCancelingPreviousEvents(
                                                                categorySlugs: [],
                                                                cashedOrginalBoutique:
                                                                    true,
                                                                boutiqueSlug:
                                                                    "*featured*"));
                                                        boutiqueBloc.add(
                                                            const GetProductWithFiltersWithoutCancelingPreviousEvents(
                                                                categorySlugs: [],
                                                                cashedOrginalBoutique:
                                                                    true,
                                                                boutiqueSlug:
                                                                    "*flashDeal*"));
                                                        ///////////////////////////
                                                        Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  500),
                                                          () {
                                                            Map<
                                                                    String,
                                                                    PaginationModel<
                                                                        HomeBoutiques>>
                                                                getHomeBoutiquesPaginationObjectByMainCategory =
                                                                Map.of(categoryBloc
                                                                    .state
                                                                    .getHomeBoutiquesPaginationObjectByMainCategory);

                                                            List<HomeBoutiques>
                                                                boutiques =
                                                                List.of(getHomeBoutiquesPaginationObjectByMainCategory[homeState
                                                                        .mainCategoriesResponseModel!
                                                                        .data!
                                                                        .mainCategories![
                                                                            index]
                                                                        .slug!]!
                                                                    .items);
                                                            ////////////////////////
                                                            List<
                                                                    Map<String,
                                                                        String>>
                                                                analyticsBoutiques =
                                                                [];

                                                            boutiques.forEach(
                                                              (element) {
                                                                analyticsBoutiques
                                                                    .add({
                                                                  'item_id': element
                                                                      .id
                                                                      .toString(),
                                                                  'item_name':
                                                                      element
                                                                          .name
                                                                          .toString(),
                                                                });
                                                              },
                                                            );
                                                            ///////////////////////////
                                                            FirebaseAnalyticsService
                                                                .logEventForSession(
                                                              executedEventName:
                                                                  GlobalScreenConst
                                                                      .HOME_SCREEN,
                                                              eventName:
                                                                  AnalyticsEventsConst
                                                                      .viewCategory,
                                                              extraParams: {
                                                                'category_id': homeState
                                                                    .mainCategoriesResponseModel!
                                                                    .data!
                                                                    .mainCategories![
                                                                        index]
                                                                    .id
                                                                    .toString(),
                                                                'category': homeState
                                                                    .mainCategoriesResponseModel!
                                                                    .data!
                                                                    .mainCategories![
                                                                        index]
                                                                    .name
                                                                    .toString(),
                                                                'items': boutiques
                                                                    .toString(),
                                                                'screen_name':
                                                                    GlobalScreenConst
                                                                        .HOME_SCREEN,
                                                              },
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        appBloc
                                                            .add(ChangeTab(-1));
                                                        categoryBloc.add(
                                                          GetHomeBoutiqesEvent(
                                                            getWithPrefetchToStoreInMemory:
                                                                false,
                                                            getWithOutPrefetchForEachBoutiques:
                                                                true,
                                                            context: context,
                                                            categorySlug:
                                                                "Empty",
                                                            offset: "1",
                                                          ),
                                                        );
                                                        boutiqueBloc.add(
                                                            AddCurrentMainCategoryTapedEvent(
                                                                currentMainCategoryTaped:
                                                                    "Empty"));
                                                        categoryBloc.add(
                                                          ChangeCurrentIndexForMainCategoryEvent(
                                                              index: -1),
                                                        );
                                                        boutiqueBloc.add(
                                                            const GetProductWithFiltersWithoutCancelingPreviousEvents(
                                                                categorySlugs: [],
                                                                cashedOrginalBoutique:
                                                                    true,
                                                                boutiqueSlug:
                                                                    "*featured*"));
                                                        boutiqueBloc.add(
                                                            const GetProductWithFiltersWithoutCancelingPreviousEvents(
                                                                categorySlugs: [],
                                                                cashedOrginalBoutique:
                                                                    true,
                                                                boutiqueSlug:
                                                                    "*flashDeal*"));
                                                      }
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        BlocBuilder<AppBloc,
                                                            AppState>(
                                                          buildWhen: (p, c) =>
                                                              p.tabIndex !=
                                                              c.tabIndex,
                                                          builder:
                                                              (context, state) {
                                                            return Stack(
                                                              children: [
                                                                SvgNetworkWidget(
                                                                  svgUrl: mainCategory
                                                                      .flatPhotoPath!
                                                                      .filePath
                                                                      .toString(),
                                                                  height: 24,
                                                                  // color: state.tabIndex ==
                                                                  //         index
                                                                  //     ? Colors.black
                                                                  //     : Color(
                                                                  //         0xffC4C2C2),
                                                                ),
                                                                BlocBuilder<
                                                                    AppBloc,
                                                                    AppState>(
                                                                  buildWhen: (p,
                                                                          c) =>
                                                                      p.tabIndex !=
                                                                      c.tabIndex,
                                                                  builder:
                                                                      (context,
                                                                          state) {
                                                                    return Positioned(
                                                                      top: 0,
                                                                      left: 0,
                                                                      child: Visibility(
                                                                          visible: state.tabIndex ==
                                                                              index,
                                                                          child: const FilterSelectedMark(
                                                                              width: 12,
                                                                              height: 12)),
                                                                    );
                                                                  },
                                                                )
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                        2.verticalSpace,
                                                        MyTextWidget(
                                                          mainCategory.name
                                                              .toString(),
                                                          maxLines: 1,
                                                          style: textTheme
                                                              .titleSmall?.lr
                                                              .copyWith(
                                                            letterSpacing: 0,
                                                            color: const Color(
                                                                0xff505050),
                                                            // color: state.tabIndex !=
                                                            //         index
                                                            //     ? Color(
                                                            //         0xffC4C2C2)
                                                            //     : Color(
                                                            //         0xff505050)
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }));
                                      },
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            )
                          ])));
            }));
  }
}
