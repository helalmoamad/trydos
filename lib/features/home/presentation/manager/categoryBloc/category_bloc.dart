import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:trydos/features/app/blocs/pre_caching_image_bloc/pre_caching_image_bloc.dart';

import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';

import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';

import 'package:trydos/features/home/domain/use_cases/get_home_boutiqes_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_main_categories_usecase.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';

import 'package:trydos/features/home/presentation/manager/categoryBloc/category_event.dart';
import 'package:trydos/features/home/presentation/manager/categoryBloc/category_state.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';

import 'package:trydos/features/story/presentation/bloc/story_state.dart';

import '../../../../../core/data/model/pagination_model.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../../main.dart';

import '../../../../app/my_cached_network_image.dart';
import '../../../../chat/presentation/manager/chat_bloc.dart';
import '../../../../chat/presentation/manager/chat_event.dart';
import '../../../../story/presentation/bloc/story_bloc.dart';

const throttleDuration = Duration(minutes: 2);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@LazySingleton()
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc(
    //  this.getHomeSectionsUseCase,
    this.getMainCategoriesUseCase,
    this.getHomeBoutiqesUseCase,
  ) : super(CategoryState()) {
    on<CategoryEvent>((event, emit) {});
    on<GetHomeBoutiqesEvent>(
      _onGetHomeBoutiquesEvent,
    );
    on<ReplyFromGeminiEvent>(_onReplyFromGeminiEvent);
    on<ChangeCurrentIndexForMainCategoryEvent>(
      _onChangeCurrentIndexForMainCategoryEvent,
    );

    on<GetMainCategoriesEvent>(
      _onGetMainCategoriesEvent,
    );
  }
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final GetMainCategoriesUseCase getMainCategoriesUseCase;

  final GetHomeBoutiqesUseCase getHomeBoutiqesUseCase;

  FutureOr<void> _onGetHomeBoutiquesEvent(
    GetHomeBoutiqesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    print(event.categorySlug);
    Map<String, PaginationModel<HomeBoutiques>>
        getHomeBoutiquesPaginationObjectByMainCategory =
        !event.getWithPagination
            ? {}
            : Map.of(state.getHomeBoutiquesPaginationObjectByMainCategory);

    if (event.getWithPrefetchToStoreInMemory) {
      if ((prefsRepository
                  .getPrefechOfBoutiquesForEachMainCategoryInHomePage(
                      event.categorySlug)
                  ?.length ??
              0) >
          10) {
        return;
      }
    }
    if (!event.getWithPrefetchToStoreInMemory) {
      if (!event.getWithPagination) {
        getHomeBoutiquesPaginationObjectByMainCategory = {};
        GetHomeBoutiquesModel getHomeBoutiquesModel =
            GetHomeBoutiquesModel(data: null);
        try {
          final responseFromSharedPrefrence = jsonDecode(prefsRepository
                  .getPrefechOfBoutiquesForEachMainCategoryInHomePage(
                      event.categorySlug) ??
              "{}");
          getHomeBoutiquesModel = responseFromSharedPrefrence == {}
              ? GetHomeBoutiquesModel()
              : GetHomeBoutiquesModel.fromJson(responseFromSharedPrefrence);
        } catch (e) {}
        getHomeBoutiquesPaginationObjectByMainCategory.addAll({
          event.categorySlug: PaginationModel<HomeBoutiques>(
              hasReachedMax:
                  (getHomeBoutiquesModel.data?.boutiques?.length ?? 0) < 10,
              items: getHomeBoutiquesModel.data?.boutiques ?? [],
              offset: getHomeBoutiquesModel.data?.offset,
              page: 1,
              paginationStatus: PaginationStatus.loading)
        });
      }

      if (getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug] ==
          null) {
        getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug] =
            const PaginationModel<HomeBoutiques>.init();
      }

      if (event.getWithPagination &&
          (getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
                  .hasReachedMax ||
              getHomeBoutiquesPaginationObjectByMainCategory[
                          event.categorySlug]!
                      .paginationStatus ==
                  PaginationStatus.loading) &&
          !event.forRefresh) {
        return;
      }
      getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug] =
          getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
              .copyWith(paginationStatus: PaginationStatus.loading);

      Map<String, bool> boutiquesForEveryMainCategoryThatDidPrefetch =
          Map.of(state.boutiquesForEveryMainCategoryThatDidPrefetch);
      if (!event.getWithOutPrefetchForEachBoutiques) {
        if (boutiquesForEveryMainCategoryThatDidPrefetch[event.categorySlug] ==
            null) {
          boutiquesForEveryMainCategoryThatDidPrefetch
              .addAll({event.categorySlug: false});
        }
        if (boutiquesForEveryMainCategoryThatDidPrefetch[event.categorySlug] ==
                true &&
            event.offset == '1' &&
            !event.forRefresh) {
          return;
        }
        boutiquesForEveryMainCategoryThatDidPrefetch[event.categorySlug] = true;
      }
      emit(state.copyWith(
          boutiquesForEveryMainCategoryThatDidPrefetch:
              Map.of(boutiquesForEveryMainCategoryThatDidPrefetch),
          getHomeBoutiquesPaginationObjectByMainCategory:
              getHomeBoutiquesPaginationObjectByMainCategory));
    } else {
      Map<String, bool> boutiquesForEveryMainCategoryThatDidPrefetch =
          Map.of(state.boutiquesForEveryMainCategoryThatDidPrefetch);
      if (!event.getWithOutPrefetchForEachBoutiques) {
        if (boutiquesForEveryMainCategoryThatDidPrefetch[event.categorySlug] ==
            null) {
          boutiquesForEveryMainCategoryThatDidPrefetch
              .addAll({event.categorySlug: false});
        }
        if (boutiquesForEveryMainCategoryThatDidPrefetch[event.categorySlug] ==
                true &&
            event.offset == '1' &&
            !event.forRefresh) {
          return;
        }
        boutiquesForEveryMainCategoryThatDidPrefetch[event.categorySlug] = true;
      }
      emit(state.copyWith(
        boutiquesForEveryMainCategoryThatDidPrefetch:
            Map.of(boutiquesForEveryMainCategoryThatDidPrefetch),
      ));
    }
    /*if (event.withSemaphore ?? false) {
      await prefechMainCategory.acquire();
    }*/
    final response = await getHomeBoutiqesUseCase(GetHomeBoutiqesParams(
        page: event.getWithPagination
            ? (getHomeBoutiquesPaginationObjectByMainCategory[
                        event.categorySlug]
                    ?.page ??
                1)
            : 1,
        offset: event.offset == '1' ? null : event.offset,
        categorySlug:
            event.categorySlug == "Empty" ? null : event.categorySlug));

    response.fold((l) {
      /*  if (event.withSemaphore ?? false) {
        prefechMainCategory.release();
      }*/

      if (!event.getWithPrefetchToStoreInMemory) {
        Map<String, PaginationModel<HomeBoutiques>>
            getHomeBoutiquesPaginationObjectByMainCategory =
            Map.of(state.getHomeBoutiquesPaginationObjectByMainCategory);

        if (!isFailedTheFirstTime.contains('GetHomeBoutiqesEvent')) {
          add(
            GetHomeBoutiqesEvent(
              getWithPrefetchToStoreInMemory:
                  event.getWithPrefetchToStoreInMemory,
              getWithOutPrefetchForEachBoutiques:
                  event.getWithOutPrefetchForEachBoutiques,
              offset: event.offset,
              context: event.context,
              categorySlug: event.categorySlug,
              getWithPagination: event.getWithPagination,
            ),
          );

          isFailedTheFirstTime.add('GetHomeBoutiqesEvent');
        }
        emit(
          state.copyWith(
            getHomeBoutiquesPaginationObjectByMainCategory:
                getHomeBoutiquesPaginationObjectByMainCategory.map(
              (key, value) {
                if (key == event.categorySlug)
                  return MapEntry(
                      key,
                      value.copyWith(
                          paginationStatus: PaginationStatus.failure));
                return MapEntry(key, value);
              },
            ),
          ),
        );
      }
    }, (r) {
      /* if (event.withSemaphore ?? false) {
        prefechMainCategory.release();
      }*/
      if (!event.getWithPagination) {
        prefsRepository.setPrefechOfBoutiquesForEachMainCategoryInHomePage(
            event.categorySlug, jsonEncode(r));
      }

      if (!event.getWithPrefetchToStoreInMemory) {
        /* String url = '';
        int numOfBanners = -1;
        r.data?.boutiques?.forEach((boutique) {
          // boutique images
          numOfBanners = boutique.banners?.length ?? 0;
          boutique.banners?.forEach((banner) {
            url = addSuitableWidthAndHeightToImage(
                imageUrl: banner.filePath!,
                width: 1.sw,
                height: numOfBanners == 1 ? 135 : 155);
            prefetchImages(url, event.context, "banner", (1.sw).round(),
                numOfBanners == 1 ? 135 : 155);
          });

          // boutique categories images
          boutique.mainCategoriesForProductIds?.forEach((category) {
            url = addSuitableWidthAndHeightToImage(
                imageUrl: category.mostViewedProductThumbnail!.filePath!,
                width: 40.w,
                height: 40.w);
            prefetchImages(url, event.context, "categoryBoutique", 40, 40);
          });
        });*/

        isFailedTheFirstTime.remove('GetHomeBoutiqesEvent');

        getHomeBoutiquesPaginationObjectByMainCategory =
            Map.of(state.getHomeBoutiquesPaginationObjectByMainCategory);

        List<HomeBoutiques> boutiques = List.of(
            getHomeBoutiquesPaginationObjectByMainCategory[event.categorySlug]!
                .items);

        emit(
          state.copyWith(
            getHomeBoutiquesPaginationObjectByMainCategory:
                getHomeBoutiquesPaginationObjectByMainCategory.map(
              (key, value) {
                if (key == event.categorySlug) {
                  return MapEntry(
                    key,
                    value.copyWith(
                      hasReachedMax:
                          (r.data!.boutiques?.length ?? kPageSize) < kPageSize,
                      paginationStatus: PaginationStatus.success,
                      page: event.getWithPagination
                          ? getHomeBoutiquesPaginationObjectByMainCategory[
                                      event.categorySlug]!
                                  .page +
                              1
                          : 2,
                      offset: r.data?.offset,
                      items: !event.getWithPagination
                          ? [...r.data!.boutiques ?? []]
                          : [...boutiques, ...r.data!.boutiques ?? []],
                    ),
                  );
                } else {
                  return MapEntry(key, value);
                }
              },
            ),
          ),
        );

        if (!event.getWithPagination &&
            event.getWithOutPrefetchForEachBoutiques) {
          prefetchBoutiques(event.categorySlug, event.context, 0);
        }
      }
    });
  }

  prefetchBoutiques(String currentSlug, BuildContext context,
      int boutiqueItemsCountWithScroll) {
    int maxItemsVisible = (1.sh -
                (GetIt.I<StoryBloc>().state.getStoriesStatus !=
                        GetStoriesStatus.success
                    ? 220
                    : 0) -
                50) ~/
            235 +
        1;
    int maxItemsVisibleWithScroll =
        max(maxItemsVisible, boutiqueItemsCountWithScroll);
    int boutiqueItemsCount = state
            .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]
            ?.items
            .length ??
        -1;

    int itemsToPrefetch = min(maxItemsVisibleWithScroll, boutiqueItemsCount);

    debugPrint(
        '///////// Boutique items To Prefetch : $itemsToPrefetch /////////');
    try {
      for (int i = 0; i < itemsToPrefetch; i++) {
        String slug = state
            .getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]!
            .items[i]
            .slug
            .toString();
        List<String> categorySlugs = [];
        // state.getHomeBoutiquesPaginationObjectByMainCategory[currentSlug]!
        //     .items[i].childCategoriesForProductIds
        //     ?.forEach(
        //   (element) {
        //     categorySlugs.add(element.categorySlug ?? "");
        //   },
        // );

        GetIt.I<BoutiqueBloc>().add(
            GetProductWithFiltersWithoutCancelingPreviousEvents(
                categorySlugs: categorySlugs,
                context: context,
                cashedOrginalBoutique: true,
                fromHomePageSearch: false,
                boutiqueSlug: slug,
                category: null,
                searchText: null));
      }
    } catch (e, st) {
      print(e);
      print(st);
    }
  }

  FutureOr<void> _onReplyFromGeminiEvent(
      ReplyFromGeminiEvent event, Emitter<CategoryState> emit) async {
    if (event.sendRequestToGeminiStatus != null) {
      emit(state.copyWith(
          theReplyFromGemini:
              !event.resetTheReply ? event.theReplyFromGemini : "",
          fromSearchForSearchWithGemini: event.fromSearch,
          sendRequestToGeminiStatus: event.sendRequestToGeminiStatus));
    }

    emit(state.copyWith(
      theReplyFromGemini: !event.resetTheReply ? event.theReplyFromGemini : "",
      fromSearchForSearchWithGemini: event.fromSearch,
    ));
  }

  prefetchImages(
      String url, BuildContext context, String type, int width, int height) {
    List<String> urlHasPredeched =
        prefsRepository.getImageUrlHasPrefeched ?? [];
    if (urlHasPredeched.contains(url)) {
      return;
    }
    GetIt.I<PreCachingImageBloc>().add(CacheImageEvent(
        imageUrl: url,
        context: context,
        type: type,
        height: height,
        width: width));
  }

  FutureOr<void> _onGetMainCategoriesEvent(
      GetMainCategoriesEvent event, Emitter<CategoryState> emit) async {
    MainCategoriesResponseModel? mainCategoriesResponseModel;

    try {
      final responseFromSharedPrefrence = jsonDecode(
          prefsRepository.getPrefechOfMainCategoryInHomePage() ?? "{}");

      mainCategoriesResponseModel = responseFromSharedPrefrence == {}
          ? MainCategoriesResponseModel(data: null)
          : MainCategoriesResponseModel.fromJson(responseFromSharedPrefrence);
    } catch (e) {}

    emit(state.copyWith(
        mainCategoriesResponseModel: mainCategoriesResponseModel,
        getMainCategoriesStatus: GetMainCategoriesStatus.loading));
    add(GetHomeBoutiqesEvent(
      getWithPrefetchToStoreInMemory: false,
      getWithOutPrefetchForEachBoutiques: true,
      context: event.context ?? navigatorKey.currentContext!,
      categorySlug: 'Empty',
      offset: "1",
    ));
    /* Future.delayed(
      Duration(seconds: 50),
      () {
        if (state.getMainCategoriesStatus == GetMainCategoriesStatus.loading) {
          emit(state.copyWith(moveUrlFromElasticToMarketServer: true));

          add(GetMainCategoriesEvent(getWithPrefech: event.getWithPrefech));
        }
      },
    );
*/
    final response = await getMainCategoriesUseCase(GetMainCategoryParams());

    response.fold((l) {
      /* if (l.statusCode == 400 &&
          !isFailedTheFirstTime.contains('GetMainCategoriesEvent')) {
        emit(state.copyWith(moveUrlFromElasticToMarketServer: true));
        add(GetMainCategoriesEvent(getWithPrefech: event.getWithPrefech));
        isFailedTheFirstTime.add('GetMainCategoriesEvent');
        return;
      }*/

      if (!isFailedTheFirstTime.contains('GetMainCategoriesEvent')) {
        add(GetMainCategoriesEvent(context: event.context));
        isFailedTheFirstTime.add('GetMainCategoriesEvent');
      }
      emit(state.copyWith(
          getMainCategoriesStatus: GetMainCategoriesStatus.failure));
    }, (r) async {
      prefsRepository
          .setPrefechOfMainCategoryInHomePage(jsonEncode(r.toJson()));

      requestAPIAfterHome();

      apisMustNotToRequest.add('GetMainCategoriesEvent');
      isFailedTheFirstTime.remove('GetMainCategoriesEvent');

      emit(state.copyWith(
          mainCategoriesResponseModel: r,
          getMainCategoriesStatus: GetMainCategoriesStatus.success));
      List<String> categorySlugs = [];
      for (var i = 0; i < r.data!.mainCategories!.length; i++) {
        categorySlugs.add(r.data!.mainCategories![i].slug ?? "");
      }
      if (event.getWithPrefech) {
        Future.delayed(Duration(seconds: 10), () {
          for (var i = 0;
              i < min(categorySlugs.length, (1.sw - 55) ~/ 40);
              i++) {
            if (state.boutiquesForEveryMainCategoryThatDidPrefetch[
                    categorySlugs[i]] !=
                true) {
              add(GetHomeBoutiqesEvent(
                withSemaphore: true,
                getWithPrefetchToStoreInMemory: true,
                getWithOutPrefetchForEachBoutiques: false,
                context: event.context ?? navigatorKey.currentContext!,
                categorySlug: categorySlugs[i],
                offset: "1",
              ));
            }
          }
        });
      }
    });
  }

  FutureOr<void> _onChangeCurrentIndexForMainCategoryEvent(
      ChangeCurrentIndexForMainCategoryEvent event,
      Emitter<CategoryState> emit) async {
    emit(state.copyWith(currentIndexForMainCategory: event.index));
  }

  void requestAPIAfterHome() {
    if (prefsRepository.marketToken != null &&
        prefsRepository.marketToken != "") {
      Future.delayed(Duration(seconds: 3),
          () => GetIt.I<AuthBloc>().add(GetCustomerInfoEvent()));
    }
    GetIt.I<HomeBloc>().add(GetStartingSettingsEvent());
    if (GetIt.I<ChatBloc>().state.firstRequestForGetChats) {
      if (prefsRepository.chatToken != null) {
        GetIt.I<ChatBloc>().add(GetChatsEvent(limit: 10));
      }
    }
  }
}
