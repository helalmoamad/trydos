import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/story/data/models/image_detail.dart';
import 'package:trydos/features/story/domain/useCases/get_stories_usecase.dart';
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';

import '../../data/models/get_stories_model.dart';

part 'story_event.dart';

part 'story_state.dart';

const throttleDuration = Duration(milliseconds: 1000);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@LazySingleton()
class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final GetStoryUseCase getStoryUseCase;
  final GetWidthAndHeightUseCase getWidthAndHeightUseCase;

  StoryBloc(this.getStoryUseCase, this.getWidthAndHeightUseCase)
      : super(StoryState()) {
    on<StoryEvent>((event, emit) {});
    on<GetStoryEvent>(_onGetStoryEvent,
        transformer: throttleDroppable(throttleDuration));
    on<LoadFailureEvent>(((event, emit) =>
        emit(state.copyWith(getStoriesStatus: GetStoriesStatus.failure))));
    on<StorySelectedEvent>(_onStorySelectedEvent);
  }

  _onStorySelectedEvent(
      StorySelectedEvent event, Emitter<StoryState> emit) async {
    emit(state.copyWith(selectedStoriesStatus: SelectedStoriesStatus.loading));
    var initialStory =
        state.stories[event.selected].stories![event.initialStory];
    if (initialStory.isPhoto == 1) {
      Fluttertoast.showToast(msg: 'msg');
      //todo bring the real width and height for selected photo
      final response = await getWidthAndHeightUseCase(
          widthAndHeightParams(url: initialStory.photoPath!));
      response.fold((l) {
        emit(state.copyWith(selectedStoriesStatus: SelectedStoriesStatus.failure));
      }, (r) {
        Fluttertoast.showToast(msg: '${r.width}');

        state.stories[state.selectedStory!].stories![state.initialStory!]
            .isSeen = true;

         emit(state.copyWith(
             selectedStoriesStatus: SelectedStoriesStatus.success,
            stories: state.stories,
            imageDetail: r));
      });
    } else {
      //todo it's a video all what i will do is make it seen
      state.stories[state.selectedStory!].stories![state.initialStory!].isSeen =true;
      emit(state.copyWith(selectedStoriesStatus: SelectedStoriesStatus.success, stories: state.stories));
    }
  }

  Future<void> _onGetStoryEvent(GetStoryEvent, Emitter<StoryState> emit) async {
    emit(state.copyWith(getStoriesStatus: GetStoriesStatus.loading));
    final response = await getStoryUseCase(NoParams());
    log(response.toString());
    response.fold(
        (l) => emit(state.copyWith(getStoriesStatus: GetStoriesStatus.failure)),
        (r) {
      emit(state.copyWith(
          getStoriesStatus: GetStoriesStatus.success, stories: r.data!.data));
    });
  }
}
