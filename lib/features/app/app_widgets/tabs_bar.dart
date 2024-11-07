import 'dart:io';
import 'dart:math';
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
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/gallery_and_camera_dialog_widget.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';
import 'package:trydos/features/search/presentation/widgets/search_with_image_related_gemini.dart';
import 'package:trydos/service/language_service.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../common/constant/design/assets_provider.dart';
import '../../../common/constant/design/constant_design.dart';
import '../../../common/test_utils/widgets_keys.dart';
import '../../../core/utils/responsive_padding.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../home/data/models/get_product_filters_model.dart';
import '../../home/presentation/manager/home_bloc.dart';
import '../../home/presentation/manager/home_state.dart';
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
  late HomeBloc homeBloc;

  late final geminis.Gemini gemini;
  SpeechToText _speechToText = SpeechToText();
  final ValueNotifier<bool> isRecordeForSearchWithMic = ValueNotifier(false);
  bool _speechEnabled = false;

  void _startListening() async {
    if (!_speechEnabled) {
      _speechEnabled = await _speechToText.initialize();
    }

    await _speechToText.listen(
      listenFor: Duration(seconds: 7),
      onResult: (result) async {
        if (result.recognizedWords.replaceAll(" ", "").length > 2) {
          widget.controller.text = result.recognizedWords;
          Filter filters = BlocProvider.of<HomeBloc>(context)
                  .state
                  .choosedFiltersByUser['search']
                  ?.filters ??
              Filter();
          BlocProvider.of<HomeBloc>(context).add(
            ChangeSelectedFiltersEvent(
                boutiqueSlug: 'search',
                fromHomePageSearch: true,
                filtersChoosedByUser: GetProductFiltersModel(
                  filters: filters.copyWithSaveOtherField(
                    prices: filters.prices,
                    searchText: result.recognizedWords,
                  ),
                )),
          );
          BlocProvider.of<HomeBloc>(context).add(ChangeAppliedFiltersEvent(
            boutiqueSlug: 'search',
            filtersAppliedByUser: GetProductFiltersModel(
                filters: filters.copyWithSaveOtherField(
              prices: filters.prices,
              searchText: result.recognizedWords,
            )),
          ));
          BlocProvider.of<HomeBloc>(context).add(GetProductsWithFiltersEvent(
              offset: 1,
              boutiqueSlug: 'search',
              resetChoosedFilters: false,
              fromSearch: true,
              searchText: result.recognizedWords));
          _stopListening();

          return;
        }
      },
    );

    isRecordeForSearchWithMic.value = true;
    Future.delayed(
      Duration(seconds: 5),
      () => isRecordeForSearchWithMic.value = false,
    );
  }

  void _stopListening() async {
    await _speechToText.stop();

    isRecordeForSearchWithMic.value = false;
  }

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    gemini = geminis.Gemini.instance;

    widget.controller.clear();
    List<String>? categorySlugs = [];
    homeBloc.state.mainCategoriesResponseModel?.data?.mainCategories?.forEach(
      (element) {
        categorySlugs.add(element.slug!);
      },
    );
    scrollController.addListener(() {
      if (categorySlugs.isEmpty) {
        homeBloc.state.mainCategoriesResponseModel?.data?.mainCategories
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
      lastIndexSeenByUser = min(categorySlugs.length - 1, lastIndexSeenByUser);
      for (int i = 0; i <= lastIndexSeenByUser; i++) {
        if (homeBloc.state.boutiquesForEveryMainCategoryThatDidPrefetch[
                categorySlugs[i]] !=
            true) {
          homeBloc.add(GetHomeBoutiqesEvent(
            getWithPrefetchForBoutiques: false,
            context: context,
            categorySlug: categorySlugs[i],
            offset: "1",
          ));
        }
      }
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
        child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (oldState, newState) =>
                (oldState.getMainCategoriesStatus ==
                        GetMainCategoriesStatus.loading &&
                    newState.getMainCategoriesStatus ==
                        GetMainCategoriesStatus.success) ||
                ((oldState.sendRequestToGeminiStatus !=
                        newState.sendRequestToGeminiStatus ||
                    oldState.theReplyFromGemini !=
                            newState.theReplyFromGemini &&
                        newState.fromSearchForSearchWithGemini == true)),
            builder: (context, homeState) {
              print(
                  "////////////////////////fffffffffffffffffffffffffffffffffffffffffffffffffffffff/////////////////////////");
              if (homeState.theReplyFromGemini != "" &&
                  homeState.fromSearchForSearchWithGemini == true) {
                widget.controller.text = homeState.theReplyFromGemini ?? "";
                Filter filters = BlocProvider.of<HomeBloc>(context)
                        .state
                        .choosedFiltersByUser['search']
                        ?.filters ??
                    Filter();
                BlocProvider.of<HomeBloc>(context)
                    .add(ChangeSelectedFiltersEvent(
                        boutiqueSlug: 'search',
                        fromHomePageSearch: true,
                        filtersChoosedByUser: GetProductFiltersModel(
                            filters: filters.copyWithSaveOtherField(
                          prices: filters.prices,
                          searchText: homeState.theReplyFromGemini,
                        ))));
                BlocProvider.of<HomeBloc>(context)
                    .add(ChangeAppliedFiltersEvent(
                  boutiqueSlug: 'search',
                  filtersAppliedByUser: GetProductFiltersModel(
                      filters: filters.copyWithSaveOtherField(
                    prices: filters.prices,
                    searchText: homeState.theReplyFromGemini,
                  )),
                ));
                BlocProvider.of<HomeBloc>(context).add(
                    GetProductsWithFiltersEvent(
                        offset: 1,
                        boutiqueSlug: 'search',
                        resetChoosedFilters: false,
                        fromSearch: true,
                        searchText: homeState.theReplyFromGemini));
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
                        offset: Offset(0, 0),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                      key: TestVariables.kTestMode
                          ? Key(WidgetsKey.mainCategoriesTabNullKey)
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
                  height: 40 + 5.h,
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: colorScheme.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1a000000),
                        offset: Offset(0, 0),
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

                                  homeBloc.add(AddSearchTextToHistoryEvent(
                                      searchTitle: text));
                                }
                              },
                              width: 1.sw,
                              height: 40,
                              onClickClose: () {
                                if (widget.controller.text.length > 0) {
                                  homeBloc.add(ReplyFromGeminiEvent(
                                      fromSearch: true,
                                      resetTheReply: true,
                                      theReplyFromGemini: ""));
                                  Filter filters = homeBloc
                                          .state
                                          .choosedFiltersByUser['search']
                                          ?.filters ??
                                      Filter();
                                  Filter appliedFilters = homeBloc
                                          .state
                                          .appliedFiltersByUser['search']
                                          ?.filters ??
                                      Filter();
                                  homeBloc.add(ChangeAppliedFiltersEvent(
                                    boutiqueSlug: 'search',
                                    filtersAppliedByUser:
                                        GetProductFiltersModel(
                                            filters: appliedFilters
                                                .copyWithSaveOtherField(
                                      prices: appliedFilters.prices,
                                      searchText: null,
                                    )),
                                  ));
                                  homeBloc.add(ChangeSelectedFiltersEvent(
                                    boutiqueSlug: 'search',
                                    fromHomePageSearch: true,
                                    filtersChoosedByUser:
                                        GetProductFiltersModel(
                                            filters:
                                                filters.copyWithSaveOtherField(
                                                    prices: filters.prices,
                                                    searchText: null)),
                                  ));
                                  widget.buildSearchResult.value = 0;
                                  widget.controller.clear();
                                  resetSearchAfterSearchingWhileRemoveSearch =
                                      false;
                                  widget.appearTrendingAndHistory.value = true;
                                  ///////////////////////////
                                  FirebaseAnalyticsService.logEventForSession(
                                    eventName:
                                        AnalyticsEventsConst.buttonClicked,
                                    executedEventName:
                                        AnalyticsExecutedEventNameConst
                                            .resetCloseIconButton,
                                  );
                                  return true;
                                } else {
                                  appBloc.add(ChangeBasePage(0));
                                  homeBloc.add(
                                      ResetAllSelectedAppliedFilterEvent());
                                  appBloc.add(HideBottomNavigationBar(false));

                                  ///////////////////////////
                                  FirebaseAnalyticsService.logEventForSession(
                                    eventName:
                                        AnalyticsEventsConst.buttonClicked,
                                    executedEventName:
                                        AnalyticsExecutedEventNameConst
                                            .searchCloseIconButton,
                                  );
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
                                Future.delayed(Duration(milliseconds: 300), () {
                                  appBloc.add(ChangeBasePage(4));
                                  appBloc.add(HideBottomNavigationBar(true));
                                });
                                ////////////////////////////////
                                FirebaseAnalyticsService.logEventForSession(
                                  eventName: AnalyticsEventsConst.buttonClicked,
                                  executedEventName:
                                      AnalyticsExecutedEventNameConst
                                          .homeSearchButton,
                                );
                              },
                              suffixWidget: Center(
                                key: TestVariables.kTestMode
                                    ? Key(WidgetsKey.homeSearchIconKey)
                                    : null,
                                child: SvgPicture.asset(
                                  AppAssets.searchOutlinedSvg,
                                  height: 20,
                                  width: 40,
                                  color: Color(0xff388CFF),
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
                                          ? Color(0xffE6E6E6)
                                          : Color(0xffF8F8F8),
                                      width: 0.4),
                                  borderRadius:
                                      BorderRadius.circular(kbrBorderTextField),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: focusNode.hasFocus
                                          ? Color(0xffE6E6E6)
                                          : Color(0xffF8F8F8),
                                      width: 0.4),
                                  borderRadius:
                                      BorderRadius.circular(kbrBorderTextField),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: focusNode.hasFocus
                                          ? Color(0xffE6E6E6)
                                          : Color(0xffF8F8F8),
                                      width: 0.4),
                                  borderRadius:
                                      BorderRadius.circular(kbrBorderTextField),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: focusNode.hasFocus
                                          ? Color(0xffE6E6E6)
                                          : Color(0xffF8F8F8),
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
                                    : Color(0xffF8F8F8),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 12),
                                  child: SvgPicture.asset(
                                    AppAssets.searchOutlinedSvg,
                                    height: 20,
                                    width: 40,
                                    color: Color(0xff388CFF),
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
                                          FirebaseAnalyticsService
                                              .logEventForSession(
                                            eventName: AnalyticsEventsConst
                                                .buttonClicked,
                                            executedEventName:
                                                AnalyticsExecutedEventNameConst
                                                    .searchWithImageButton,
                                          );
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
                                      SizedBox(
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
                                                FirebaseAnalyticsService
                                                    .logEventForSession(
                                                  eventName:
                                                      AnalyticsEventsConst
                                                          .buttonClicked,
                                                  executedEventName:
                                                      AnalyticsExecutedEventNameConst
                                                          .searchWithVoiceButton,
                                                );
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
                                    .copyWith(color: Color(0xffC4C2C2)),
                                labelStyle: context.textTheme.titleLarge
                                    ?.copyWith(color: context.colorScheme.hint),
                              ),
                              onChanged: (String text) {
                                if (text.length > 2) {
                                  resetSearchAfterSearchingWhileRemoveSearch =
                                      true;
                                  Filter filters = homeBloc
                                          .state
                                          .choosedFiltersByUser['search']
                                          ?.filters ??
                                      Filter();
                                  print(
                                      "**1111111111111111-------------------------------${text}");
                                  homeBloc.add(ChangeSelectedFiltersEvent(
                                    boutiqueSlug: 'search',
                                    requestToUpdateFilters: true,
                                    fromHomePageSearch: true,
                                    filtersChoosedByUser:
                                        GetProductFiltersModel(
                                            filters:
                                                filters.copyWithSaveOtherField(
                                      prices: filters.prices,
                                      searchText: text,
                                    )),
                                  ));
                                  homeBloc.add(GetProductsWithFiltersEvent(
                                      fromChoosed: true,
                                      offset: 1,
                                      boutiqueSlug: 'search',
                                      resetChoosedFilters: false,
                                      fromSearch: true,
                                      searchText: text));
                                  print(
                                      "**222222222222222-------------------------------${text}");

                                  widget.buildSearchResult.value = text.length;
                                }
                                if (text.length < 3) {
                                  homeBloc.add(ReplyFromGeminiEvent(
                                      fromSearch: true,
                                      resetTheReply: true,
                                      theReplyFromGemini: ""));
                                  Filter filters = homeBloc
                                          .state
                                          .choosedFiltersByUser['search']
                                          ?.filters ??
                                      Filter();
                                  homeBloc.add(ChangeSelectedFiltersEvent(
                                    boutiqueSlug: 'search',
                                    requestToUpdateFilters: false,
                                    fromHomePageSearch: true,
                                    filtersChoosedByUser:
                                        GetProductFiltersModel(
                                            filters:
                                                filters.copyWithSaveOtherField(
                                      prices: filters.prices,
                                      searchText: null,
                                    )),
                                  ));
                                }
                                if (text.length < 1 &&
                                    resetSearchAfterSearchingWhileRemoveSearch) {
                                  homeBloc.add(ReplyFromGeminiEvent(
                                      fromSearch: true,
                                      resetTheReply: true,
                                      theReplyFromGemini: ""));
                                  resetSearchAfterSearchingWhileRemoveSearch =
                                      false;
                                  Filter filters = homeBloc
                                          .state
                                          .choosedFiltersByUser['search']
                                          ?.filters ??
                                      Filter();
                                  homeBloc.add(ChangeSelectedFiltersEvent(
                                    boutiqueSlug: 'search',
                                    requestToUpdateFilters: true,
                                    fromHomePageSearch: true,
                                    filtersChoosedByUser:
                                        GetProductFiltersModel(
                                            filters:
                                                filters.copyWithSaveOtherField(
                                      prices: filters.prices,
                                      searchText: null,
                                    )),
                                  ));
                                }
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
                                      left: 15,
                                    ),
                                    width: 1.sw - 40,
                                    height: 80,
                                    child: ListView.builder(
                                      controller: scrollController,
                                      padding: EdgeInsets.only(
                                        right: 15,
                                      ),
                                      key: TestVariables.kTestMode
                                          ? Key(WidgetsKey.mainCategoriesTabKey)
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
                                            padding:
                                                HWEdgeInsetsDirectional.only(
                                                    end: 6),
                                            child: InkWell(
                                              onTap: () {
                                                if (BlocProvider.of<AppBloc>(
                                                            context)
                                                        .state
                                                        .tabIndex !=
                                                    index) {
                                                  appBloc.add(ChangeTab(index));
                                                  ///////////////////////
                                                  homeBloc.add(
                                                    GetHomeBoutiqesEvent(
                                                      getWithPrefetchForBoutiques:
                                                          true,
                                                      getWithPagination: false,
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
                                                  homeBloc.add(
                                                    ChangeCurrentIndexForMainCategoryEvent(
                                                      index: index,
                                                    ),
                                                  );
                                                  ///////////////////////////
                                                  FirebaseAnalyticsService
                                                      .logEventForSession(
                                                    eventName:
                                                        AnalyticsEventsConst
                                                            .buttonClicked,
                                                    executedEventName:
                                                        AnalyticsExecutedEventNameConst
                                                            .chooseCategoryButton,
                                                  );
                                                } else {
                                                  appBloc.add(ChangeTab(-1));
                                                  homeBloc.add(
                                                    GetHomeBoutiqesEvent(
                                                      getWithPrefetchForBoutiques:
                                                          true,
                                                      context: context,
                                                      categorySlug: "Empty",
                                                      offset: "1",
                                                      getWithPagination: false,
                                                    ),
                                                  );
                                                  homeBloc.add(
                                                    ChangeCurrentIndexForMainCategoryEvent(
                                                        index: -1),
                                                  );
                                                }
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  BlocBuilder<AppBloc,
                                                      AppState>(
                                                    buildWhen: (p, c) =>
                                                        p.tabIndex !=
                                                        c.tabIndex,
                                                    builder: (context, state) {
                                                      return Stack(
                                                        children: [
                                                          SvgNetworkWidget(
                                                            svgUrl: mainCategory
                                                                .flatPhotoPath!
                                                                .filePath
                                                                .toString(),
                                                            height: 20,
                                                            // color: state.tabIndex ==
                                                            //         index
                                                            //     ? Colors.black
                                                            //     : Color(
                                                            //         0xffC4C2C2),
                                                          ),
                                                          BlocBuilder<AppBloc,
                                                              AppState>(
                                                            buildWhen: (p, c) =>
                                                                p.tabIndex !=
                                                                c.tabIndex,
                                                            builder: (context,
                                                                state) {
                                                              return Positioned(
                                                                top: 0,
                                                                left: 0,
                                                                child: Visibility(
                                                                    visible: state
                                                                            .tabIndex ==
                                                                        index,
                                                                    child: FilterSelectedMark(
                                                                        width:
                                                                            12,
                                                                        height:
                                                                            12)),
                                                              );
                                                            },
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  4.verticalSpace,
                                                  MyTextWidget(
                                                    mainCategory.name
                                                        .toString(),
                                                    maxLines: 1,
                                                    style: textTheme
                                                        .titleSmall?.lr
                                                        .copyWith(
                                                      letterSpacing: 0,
                                                      color: Color(0xff505050),
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
                                            ));
                                      },
                                    ),
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            )
                          ])));
            }));
  }
}
