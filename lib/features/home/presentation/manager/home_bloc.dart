import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/domain/use_cases/get_home_sections_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_main_categories_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/get_starting_settings_usecase.dart';

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
      this.getStartingSettingsUseCase)
      : super(HomeState()) {
    on<HomeEvent>((event, emit) {});
    on<GetHomeSectionsEvent>(_onGetHomeSectionsEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetStartingSettingsEvent>(_onGetStartingSettingsEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetMainCategoriesEvent>(_onGetMainCategoriesEvent,
        transformer: throttleDroppable(throttleDuration));
  }

  final GetStartingSettingsUseCase getStartingSettingsUseCase;
  final GetHomeSectionsUseCase getHomeSectionsUseCase;
  final GetMainCategoriesUseCase getMainCategoriesUseCase;

  FutureOr<void> _onGetHomeSectionsEvent(
      GetHomeSectionsEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(getHomeSectionsStatus: GetHomeSectionsStatus.loading));
    final response =
        await getHomeSectionsUseCase(GetHomeSectionsParams(event.categorySlug));

    response.fold(
        (l) => emit(state.copyWith(
            getHomeSectionsStatus: GetHomeSectionsStatus.failure)),
        (r) => emit(state.copyWith(
            getHomeSectionsStatus: GetHomeSectionsStatus.success)));
  }

  FutureOr<void> _onGetStartingSettingsEvent(
      GetStartingSettingsEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getStartingSettingsStatus: GetStartingSettingsStatus.loading));
    final response = await getStartingSettingsUseCase(NoParams());

    response.fold(
        (l) => emit(state.copyWith(
            getStartingSettingsStatus: GetStartingSettingsStatus.failure)),
        (r) => emit(state.copyWith(
            getStartingSettingsStatus: GetStartingSettingsStatus.success)));
  }

  FutureOr<void> _onGetMainCategoriesEvent(
      GetMainCategoriesEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        getMainCategoriesStatus: GetMainCategoriesStatus.loading));
    final response = await getMainCategoriesUseCase(NoParams());

    response.fold(
        (l) => emit(state.copyWith(
            getMainCategoriesStatus: GetMainCategoriesStatus.failure)),
        (r) => emit(state.copyWith(
            getMainCategoriesStatus: GetMainCategoriesStatus.success)));
  }
}
