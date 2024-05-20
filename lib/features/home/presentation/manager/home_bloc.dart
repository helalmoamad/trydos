import 'dart:async';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/widgets/phone_form_fields.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/get_story_for_product_model.dart';
import 'package:trydos/features/home/data/models/home_sections_response_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/domain/use_cases/get_home_boutiqes_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_home_sections_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_main_categories_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_product_detail_without_related_products_uswcase.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_starting_settings_usecase.dart';
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../main.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';
import '../../../chat/presentation/manager/chat_event.dart';
import '../../domain/use_cases/get_stories_for_product_usecase.dart';
import 'home_event.dart';
import 'dart:convert' as convert;

import 'home_state.dart';

const throttleDuration = Duration(milliseconds: 1000);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@LazySingleton()
class HomeBloc extends HydratedBloc<HomeEvent, HomeState> {
  HomeBloc(
      //  this.getHomeSectionsUseCase,
      this.getMainCategoriesUseCase,
      this.getStoryUseCase,
      this.getHomeBoutiqesUseCase,
      this.getWidthAndHeightUseCase,
      this.getProductDetailWithoutRelatedProductsUseCase,
      this.getStartingSettingsUseCase,
      this.getProductsWithoutFiltersUseCase)
      : super(HomeState()) {
    on<HomeEvent>((event, emit) {});
    on<StorySelectEvent>(_onStorySelectedEvent);
    on<AddCurrentSelectedColorEvent>(_onAddCurrentSelectedColorEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetHomeBoutiqesEvent>(_onGetHomeSectionsEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetStartingSettingsEvent>(_onGetStartingSettingsEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetMainCategoriesEvent>(_onGetMainCategoriesEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetProductsWithoutFiltersEvent>(_onGetProductsWithoutFiltersEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetStoryForProductEvent>(
      _onGetStoryEvent,
      // transformer: throttleDroppable(throttleDuration)
    );

    on<LoadFailureEvent>(((event, emit) => emit(state.copyWith(
            storiesCollections: state.storiesCollections.map((e) {
          if (e.id == event.collectionId) {
            return e.copyWith(
                selectedStoriesStatusForCollection:
                    SelectedStoriesStatus.failure);
          }
          return e;
        }).toList()))));
    on<GetProductDatailsWithoutRelatedProductsEvent>(
      _onGetProductDatailsWithoutRelatedProductsEvent,
    );
  }

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final GetStartingSettingsUseCase getStartingSettingsUseCase;
  final GetWidthAndHeightUseCase getWidthAndHeightUseCase;
  final GetHomeBoutiqesUseCase getHomeBoutiqesUseCase;
  final GetStoryForProductUseCase getStoryUseCase;
  final GetProductDetailWithoutRelatedProductsUseCase
      getProductDetailWithoutRelatedProductsUseCase;

  final GetMainCategoriesUseCase getMainCategoriesUseCase;
  final GetProductsWithoutFiltersUseCase getProductsWithoutFiltersUseCase;

  //final Smartlook smartLook = Smartlook.instance;

  FutureOr<void> _onGetHomeSectionsEvent(
      GetHomeBoutiqesEvent event, Emitter<HomeState> emit) async {
    PaginationModel<Boutique>? getHomeBoutiqesPaginationObject =
        state.getHomeBoutiqesPaginationObject;
    if (getHomeBoutiqesPaginationObject == null) {
      getHomeBoutiqesPaginationObject = PaginationModel<Boutique>.init();
    }

    getHomeBoutiqesPaginationObject = getHomeBoutiqesPaginationObject.copyWith(
        paginationStatus: PaginationStatus.loading);
    emit(state.copyWith(
        getHomeBoutiqesPaginationObject: getHomeBoutiqesPaginationObject));
    final response = await getHomeBoutiqesUseCase(
        GetHomeBoutiqesParams(offset: event.offset));
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetHomeSectionsEvent')) {
        add(GetHomeBoutiqesEvent(
            offset: event.offset, getWithPagination: event.getWithPagination));
        isFailedTheFirstTime.add('GetHomeBoutiqesEvent');
      }
      getHomeBoutiqesPaginationObject = getHomeBoutiqesPaginationObject!
          .copyWith(paginationStatus: PaginationStatus.failure);
      emit(state.copyWith(
          getHomeBoutiqesPaginationObject: getHomeBoutiqesPaginationObject));
    }, (r) {
      isFailedTheFirstTime.remove('GetHomeBoutiqesEvent');
      if (state.getMainCategoriesStatus == GetMainCategoriesStatus.success) {
        requestAPIAfterHome();
      }
      getHomeBoutiqesPaginationObject = getHomeBoutiqesPaginationObject!
          .copyWith(
              paginationStatus: PaginationStatus.success,
              page: !event.getWithPagination
                  ? 2
                  : getHomeBoutiqesPaginationObject!.page + 1,
              hasReachedMax: r.data!.boutiques!.length >= kPageSize,
              items: (!event.getWithPagination &&
                      (getHomeBoutiqesPaginationObject!.items.length > 0))
                  ? [
                      ...getHomeBoutiqesPaginationObject!.items,
                    ]
                  : [
                      ...getHomeBoutiqesPaginationObject!.items,
                      ...r.data!.boutiques!
                    ]);
      emit(state.copyWith(
          getHomeBoutiqesPaginationObject: getHomeBoutiqesPaginationObject));
    });
  }

  FutureOr<void> _onGetStartingSettingsEvent(
      GetStartingSettingsEvent event, Emitter<HomeState> emit) async {
    if (apisMustNotToRequest.contains('GetStartingSettingsEvent')) return;
    emit(state.copyWith(
        getStartingSettingsStatus: GetStartingSettingsStatus.loading));
    final response = await getStartingSettingsUseCase(NoParams());

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetStartingSettingsEvent')) {
        add(GetStartingSettingsEvent());
        isFailedTheFirstTime.add('GetStartingSettingsEvent');
      }
      emit(state.copyWith(
          getStartingSettingsStatus: GetStartingSettingsStatus.failure));
    }, (r) {
      apisMustNotToRequest.add('GetStartingSettingsEvent');
      isFailedTheFirstTime.remove('GetStartingSettingsEvent');
      // if (r.data!.startingSetting!.smartLook ?? false) {
      //   Logger(printer: PrettyPrinter(methodCount: 0)).i('SMARTLOOK STARTED!');
      //   initializeSmartLook();
      // }
      emit(state.copyWith(
          startingSetting: r.data!.startingSetting,
          getStartingSettingsStatus: GetStartingSettingsStatus.success));
    });
  }

  FutureOr<void> _onGetMainCategoriesEvent(
      GetMainCategoriesEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getMainCategoriesStatus: GetMainCategoriesStatus.loading));
    final response = await getMainCategoriesUseCase(NoParams());

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetMainCategoriesEvent')) {
        add(GetMainCategoriesEvent());
        isFailedTheFirstTime.add('GetMainCategoriesEvent');
      }
      emit(state.copyWith(
          getMainCategoriesStatus: GetMainCategoriesStatus.failure));
    }, (r) {
      apisMustNotToRequest.add('GetMainCategoriesEvent');
      isFailedTheFirstTime.remove('GetMainCategoriesEvent');

      if (state.getHomeBoutiqesPaginationObject!.paginationStatus ==
          PaginationStatus.success) {
        requestAPIAfterHome();
      }
      emit(state.copyWith(
          mainCategoriesResponseModel: r,
          getMainCategoriesStatus: GetMainCategoriesStatus.success));
    });
  }

  void requestAPIAfterHome() {
    if (prefsRepository.marketToken != null) {
      GetIt.I<AuthBloc>().add(GetCustomerInfoEvent());
    }
    add(GetStartingSettingsEvent());
    if (prefsRepository.chatToken != null) {
      GetIt.I<ChatBloc>().add(GetChatsEvent(limit: 10));
    }
  }

  // initializeSmartLook() async {
  //   String deviceId = (await HelperFunctions.getDeviceId()).toString();
  //   await smartLook.preferences
  //       .setProjectKey('db8b1330aa8b622827ae6092023f88bf4e56be53');
  //   await smartLook.preferences.setFrameRate(2);
  //   await smartLook.user.setIdentifier(deviceId);
  //   await smartLook.user
  //       .setName(GetIt.I<PrefsRepository>().myChatName ?? 'No_Name');
  //   await smartLook.start();
  // }

  _onAddCurrentSelectedColorEvent(
      AddCurrentSelectedColorEvent event, Emitter<HomeState> emit) {
    Map<String, int> currentSelectedColorForEveryProduct =
        Map.of(state.currentSelectedColorForEveryProduct);
    currentSelectedColorForEveryProduct[event.productId] =
        event.currentSelectedColor;
    emit(state.copyWith(
        currentSelectedColorForEveryProduct:
            currentSelectedColorForEveryProduct));
  }

  _onStorySelectedEvent(StorySelectEvent event, Emitter<HomeState> emit) async {
    //todo make the story seen when he press to show it

    Map<int, int?> currentStoryInEachCollection =
        Map.of(state.currentStoryInEachCollection);
    currentStoryInEachCollection[event.collectionIndex] =
        event.selectedStoryIndexInCollection == -1
            ? currentStoryInEachCollection[event.collectionIndex]
            : event.selectedStoryIndexInCollection;
    //todo make  the state loading
    emit(state.copyWith(
      //selectedStoriesStatus: SelectedStoriesStatus.loading,
      currentPage:
          event.currentPage == -1 ? state.currentPage : event.currentPage,
      selectedCollection: event.collectionIndex,
      currentStoryInEachCollection: currentStoryInEachCollection,
    ));

    var currentStoryInSelectedCollection =
        state.storiesCollections[event.collectionIndex].stories![max(
            state.currentStoryInEachCollection[event.collectionIndex]!,
            event.selectedStoryIndexInCollection)];
    if (currentStoryInSelectedCollection.isPhoto == 1) {
//todo debug
      //todo bring the real width and height for selected photo
      final response = await getWidthAndHeightUseCase(widthAndHeightParams(
          url: currentStoryInSelectedCollection.photoPath!,
          collectionId: state.storiesCollections[event.collectionIndex].id!));
      response.fold((l) {
        if (isFailedTheFirstTime.contains('StorySelectedEvent')) {
          isFailedTheFirstTime.remove('StorySelectedEvent');
          emit(state.copyWith(
              storiesCollections: state.storiesCollections.map((e) {
            if (e.id == state.storiesCollections[event.collectionIndex].id) {
              return e.copyWith(
                  selectedStoriesStatusForCollection:
                      SelectedStoriesStatus.failure);
            }
            return e;
          }).toList()));
        } else {
          isFailedTheFirstTime.insert(
              isFailedTheFirstTime.length, 'StorySelectedEvent');
          GetIt.I<HomeBloc>().add(StorySelectEvent(
              collectionIndex: event.collectionIndex,
              selectedStoryIndexInCollection:
                  event.selectedStoryIndexInCollection,
              currentPage: event.currentPage));
        }
      }, (r) {
//todo just make the state success with the width and height for the image and in the emitter above you changed the initial  story
        emit(state.copyWith(
            storiesCollections: state.storiesCollections.map((e) {
          if (e.id == state.storiesCollections[event.collectionIndex].id) {
            return e.copyWith(
                selectedStoriesStatusForCollection:
                    SelectedStoriesStatus.success,
                imageDetail: r);
          }
          return e;
        }).toList()));
      });
    } else {
      //todo it's a video all what i will do is make it seen
      emit(state.copyWith(
        storiesCollections: state.storiesCollections.map((e) {
          if (e.id == state.storiesCollections[event.collectionIndex].id) {
            return e.copyWith(
              selectedStoriesStatusForCollection: SelectedStoriesStatus.success,
            );
          }
          return e;
        }).toList(),
        currentStoryInEachCollection: currentStoryInEachCollection,
        selectedCollection: event.collectionIndex,
      ));
    }
  }

  Future<void> _onGetStoryEvent(
      GetStoryForProductEvent, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getStoriesForProductStatus: GetStoriesForProductStatus.loading));
    final response = await getStoryUseCase(NoParams());

    response.fold((l) {
      if (isFailedTheFirstTime.contains('GetStoryEvent')) {
        isFailedTheFirstTime.remove('GetStoryEvent');
        emit(state.copyWith(
            getStoriesForProductStatus: GetStoriesForProductStatus.failure));
      } else {
        isFailedTheFirstTime.insert(
            isFailedTheFirstTime.length, 'GetStoryEvent');
        GetIt.I<HomeBloc>().add(GetStoryForProductEvent);
      }
    }, (r) {
      apisMustNotToRequest.add('GetStoryEvent');
      Map<int, int> currentStoryInEachCollection = {};
      int i = 0;
      r.data?.collections?.forEach((element) {
        currentStoryInEachCollection[i++] = 0;
      });
      emit(state.copyWith(
          getStoriesForProductStatus: GetStoriesForProductStatus.success,
          storiesCollections: r.data!.collections,
          currentStoryInEachCollection: currentStoryInEachCollection));
    });
  }

  /* Map<String, PaginationModel<HomeSectionDataObject>>
        getHomeSectionsPaginationObject =
        Map.of(state.getHomeSectionsPaginationObject);
    if (getHomeSectionsPaginationObject[event.categorySlug] == null) {
      getHomeSectionsPaginationObject[event.categorySlug] =
          const PaginationModel<HomeSectionDataObject>.init();
    }
    if (!event.getWithPagination &&
        (getHomeSectionsPaginationObject[event.categorySlug]!
                .items
                .isNotEmpty ||
            getHomeSectionsPaginationObject[event.categorySlug]!
                    .paginationStatus ==
                PaginationStatus.loading)) {
      print('zzzzzzzzzzzzzzzz');
      print('$getHomeSectionsPaginationObject');
      print('${!event.getWithPagination}');
      print(
          '${getHomeSectionsPaginationObject[event.categorySlug]!.items.isNotEmpty}');
      print(
          '${getHomeSectionsPaginationObject[event.categorySlug]!.paginationStatus == PaginationStatus.loading}');
      return;
    }
    getHomeSectionsPaginationObject[event.categorySlug] =
        getHomeSectionsPaginationObject[event.categorySlug]!
            .copyWith(paginationStatus: PaginationStatus.loading);
    emit(state.copyWith(
        getHomeSectionsPaginationObject: getHomeSectionsPaginationObject));
    final response =
        await getHomeSectionsUseCase(GetHomeSectionsParams(event.categorySlug));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetHomeSectionsEvent')) {
        add(GetHomeSectionsEvent(event.categorySlug));
        isFailedTheFirstTime.add('GetHomeSectionsEvent');
      }
      getHomeSectionsPaginationObject[event.categorySlug] =
          getHomeSectionsPaginationObject[event.categorySlug]!
              .copyWith(paginationStatus: PaginationStatus.failure);
      emit(state.copyWith(
          getHomeSectionsPaginationObject: getHomeSectionsPaginationObject));
    }, (r) {
      isFailedTheFirstTime.remove('GetHomeSectionsEvent');
      if (state.getMainCategoriesStatus == GetMainCategoriesStatus.success) {
        requestAPIAfterHome();
      }
      getHomeSectionsPaginationObject[event.categorySlug] =
          getHomeSectionsPaginationObject[event.categorySlug]!.copyWith(
              paginationStatus: PaginationStatus.success,
              page:
                  getHomeSectionsPaginationObject[event.categorySlug]!.page + 1,
              hasReachedMax: r.data!.length >= kPageSize,
              items: [
            ...getHomeSectionsPaginationObject[event.categorySlug]!.items,
            ...r.data!
          ]);
      emit(state.copyWith(
          getHomeSectionsPaginationObject: getHomeSectionsPaginationObject));
    });
  }
  */

  FutureOr<void> _onGetProductsWithoutFiltersEvent(
      GetProductsWithoutFiltersEvent event, Emitter<HomeState> emit) async {
    if (state.getProductListingWithoutFiltersModel != null &&
        state.getProductsWithoutFiltersStatus !=
            GetProductsWithoutFiltersStatus.init) {
      return;
    }
    emit(state.copyWith(
        getProductsWithoutFiltersStatus:
            GetProductsWithoutFiltersStatus.loading));
    final response = await getProductsWithoutFiltersUseCase(
        GetProductsWithoutFiltersParams(
            offset: event.offset,
            attributes: event.attributes,
            brands: event.brands,
            category: event.category,
            limit: event.limit,
            prices: event.prices,
            searchText: event.searchText));

    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetProductsWithoutFiltersEvent')) {
        add(GetProductsWithoutFiltersEvent(
            offset: event.offset,
            attributes: event.attributes,
            brands: event.brands,
            category: event.category,
            limit: event.limit,
            prices: event.prices,
            searchText: event.searchText));
        isFailedTheFirstTime.add('GetProductsWithoutFiltersEvent');
      }
      emit(state.copyWith(
          getProductsWithoutFiltersStatus:
              GetProductsWithoutFiltersStatus.failure));
    }, (r) {
      isFailedTheFirstTime.remove('GetProductsWithoutFiltersEvent');
      emit(state.copyWith(
          getProductListingWithoutFiltersModel: r,
          getProductsWithoutFiltersStatus:
              GetProductsWithoutFiltersStatus.success));
    });
  }

  FutureOr<void> _onGetProductDatailsWithoutRelatedProductsEvent(
      GetProductDatailsWithoutRelatedProductsEvent event,
      Emitter<HomeState> emit) async {
    if (state.cachedProductWithoutRelatedProductsModel
        .containsKey(event.productId)) return;
    emit(state.copyWith(
        getProductDetailWithoutSimilarRelatedProductsStatus:
            GetProductDetailWithoutSimilarRelatedProductsStatus.loading));
    final response =
        await getProductDetailWithoutRelatedProductsUseCase(event.productId!);

    response.fold((l) {
      if (!isFailedTheFirstTime
          .contains('GetProductDatailsWithoutRelatedProductsEvent')) {
        add(const GetProductDatailsWithoutRelatedProductsEvent());
        isFailedTheFirstTime
            .add('GetProductDatailsWithoutRelatedProductsEvent');
      }
      emit(state.copyWith(
          getProductDetailWithoutSimilarRelatedProductsStatus:
              GetProductDetailWithoutSimilarRelatedProductsStatus.failure));
    }, (r) {
      apisMustNotToRequest.add('GetProductDatailsWithoutRelatedProductsEvent');
      isFailedTheFirstTime
          .remove('GetProductDatailsWithoutRelatedProductsEvent');
      Map<String, GetProductDetailWithoutRelatedProductsModel> newCached =
          Map.of(state.cachedProductWithoutRelatedProductsModel);
      newCached[event.productId!] = r;
      emit(state.copyWith(
          cachedProductWithoutRelatedProductsModel: newCached,
          getProductDetailWithoutSimilarRelatedProductsStatus:
              GetProductDetailWithoutSimilarRelatedProductsStatus.success));
    });
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) {
    return HomeState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(HomeState state) {
    return state
        .copyWith(
          getMainCategoriesStatus: GetMainCategoriesStatus.init,
          getProductsWithoutFiltersStatus: GetProductsWithoutFiltersStatus.init,
          getStartingSettingsStatus: GetStartingSettingsStatus.init,
        )
        .toJson();
  }
}
