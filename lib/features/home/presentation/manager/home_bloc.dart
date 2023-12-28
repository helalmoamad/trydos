import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import 'package:trydos/features/home/domain/use_cases/get_home_sections_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_main_categories_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_products_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_starting_settings_usecase.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../main.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';
import '../../../chat/presentation/manager/chat_event.dart';
import 'home_event.dart';

part 'home_state.dart';

const throttleDuration = Duration(milliseconds: 1000);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@LazySingleton()
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this.getHomeSectionsUseCase, this.getMainCategoriesUseCase,
      this.getStartingSettingsUseCase, this.getProductsWithoutFiltersUseCase)
      : super(HomeState()) {
    on<HomeEvent>((event, emit) {});
    on<GetHomeSectionsEvent>(_onGetHomeSectionsEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetStartingSettingsEvent>(_onGetStartingSettingsEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetMainCategoriesEvent>(_onGetMainCategoriesEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetProductsWithoutFiltersEvent>(_onGetProductsWithoutFiltersEvent,
        transformer: throttleDroppable(throttleDuration));
  }

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final GetStartingSettingsUseCase getStartingSettingsUseCase;
  final GetHomeSectionsUseCase getHomeSectionsUseCase;
  final GetMainCategoriesUseCase getMainCategoriesUseCase;
  final GetProductsWithoutFiltersUseCase getProductsWithoutFiltersUseCase;
  //final Smartlook smartLook = Smartlook.instance;

  FutureOr<void> _onGetHomeSectionsEvent(
      GetHomeSectionsEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(getHomeSectionsStatus: GetHomeSectionsStatus.loading));
    final response =
        await getHomeSectionsUseCase(GetHomeSectionsParams(event.categorySlug));

    response.fold(
        (l) {
          if (!isFailedTheFirstTime.contains('GetHomeSectionsEvent')) {
            add(GetHomeSectionsEvent(event.categorySlug));
            isFailedTheFirstTime.add('GetHomeSectionsEvent');
          }
          emit(state.copyWith(
              getHomeSectionsStatus: GetHomeSectionsStatus.failure));
        }, (r) {
      isFailedTheFirstTime.remove('GetHomeSectionsEvent');
      if (state.getMainCategoriesStatus == GetMainCategoriesStatus.success) {
        requestAPIAfterHome();
      }
      emit(
          state.copyWith(getHomeSectionsStatus: GetHomeSectionsStatus.success));
    });
  }

  FutureOr<void> _onGetStartingSettingsEvent(
      GetStartingSettingsEvent event, Emitter<HomeState> emit) async {
    if (state.getStartingSettingsStatus != GetStartingSettingsStatus.init)
      return;
    emit(state.copyWith(
        getStartingSettingsStatus: GetStartingSettingsStatus.loading));
    final response = await getStartingSettingsUseCase(NoParams());

    response.fold(
        (l) {
          if (!isFailedTheFirstTime.contains('GetStartingSettingsEvent')) {
            add(GetStartingSettingsEvent());
            isFailedTheFirstTime.add('GetStartingSettingsEvent');
          }
          emit(state.copyWith(
              getStartingSettingsStatus: GetStartingSettingsStatus.failure));
        },
        (r) {
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

    response.fold(
        (l) {
          if (!isFailedTheFirstTime.contains('GetMainCategoriesEvent')) {
            add(GetMainCategoriesEvent());
            isFailedTheFirstTime.add('GetMainCategoriesEvent');
          }
          emit(state.copyWith(
              getMainCategoriesStatus: GetMainCategoriesStatus.failure));
        }, (r) {
      isFailedTheFirstTime.remove('GetMainCategoriesEvent');
      if (state.getHomeSectionsStatus == GetHomeSectionsStatus.success) {
        requestAPIAfterHome();
      }
      emit(state.copyWith(
          getMainCategoriesStatus: GetMainCategoriesStatus.success));
    });
  }

  void requestAPIAfterHome() {
    if (prefsRepository.marketToken != null) {
      GetIt.I<AuthBloc>().add(GetCustomerInfoEvent());
    }
    add(GetStartingSettingsEvent());
    if (prefsRepository.chatToken != null) {
      GetIt.I<ChatBloc>().add(GetChatsEvent());
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

  FutureOr<void> _onGetProductsWithoutFiltersEvent(
      GetProductsWithoutFiltersEvent event, Emitter<HomeState> emit) async {
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

    response.fold(
        (l) {
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
}
