import 'dart:async';
import 'dart:developer';
import 'dart:io';

//import 'material';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:dartz/dartz_unsafe.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/story/data/models/image_detail.dart';
import 'package:trydos/features/story/data/models/upload_story_response_model.dart';
import 'package:trydos/features/story/domain/useCases/get_stories_usecase.dart';
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';
import 'package:trydos/features/story/domain/useCases/upload_story_usecase.dart';

import '../../../../core/error/failures.dart';
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
  final UploadStoryUseCase uploadStoryUseCase;
  final GetWidthAndHeightUseCase getWidthAndHeightUseCase;

  StoryBloc(this.getStoryUseCase, this.getWidthAndHeightUseCase,
      this.uploadStoryUseCase)
      : super(StoryState()) {
    on<UploadStoryEvent>(_uploadStoryEvent);
    on<StoryEvent>((event, emit) {});
    on<GetStoryEvent>(_onGetStoryEvent,
        transformer: throttleDroppable(throttleDuration));
    on<LoadFailureEvent>(((event, emit) =>
        emit(state.copyWith(getStoriesStatus: GetStoriesStatus.failure))));
    on<StorySelectedEvent>(_onStorySelectedEvent);
    on<LoadingVideoEvent>(_onLoadingVideoEvent);
    on<LoadedVideoEvent>(_onLoadedVideoEvent);
    on<FailureVideoEvent>(_onFailureVideoEvent);
  }

  _onLoadingVideoEvent(LoadingVideoEvent event, Emitter<StoryState> emit) {
    emit(state.copyWith(selectedVideoStatus: SelectedVideoStatus.loading));
  }

  _onLoadedVideoEvent(LoadedVideoEvent event, Emitter<StoryState> emit) {
    emit(state.copyWith(selectedVideoStatus: SelectedVideoStatus.success));
  }

  _onFailureVideoEvent(FailureVideoEvent event, Emitter<StoryState> emit) {
    emit(state.copyWith(selectedVideoStatus: SelectedVideoStatus.failure));
  }

  _uploadStoryEvent(UploadStoryEvent event, Emitter<StoryState> emit) async {
    print('uplaod22ss')
;    emit(state.copyWith(uploadStoryStatus: UploadStoryStatus.loading));
    Fluttertoast.showToast(msg: 'msg', textColor: Colors.yellow);

    final response =
    await uploadStoryUseCase.call(UploadStoryParams(file: event.file));
Fluttertoast.showToast(msg: 'msg', textColor: Colors.red);

    response.fold((l) {
      Fluttertoast.showToast(msg: l.message, textColor: Colors.white);

      print('object_failute');
//      Fluttertoast.showToast(msg: 'ssssssss',backgroundColor: Colors.amber);
      emit(state.copyWith(uploadStoryStatus: UploadStoryStatus.failure));
    }, (r) {
      print('storiesIds ${GetIt.I<PrefsRepository>().myStoriesId}');
      print('storiesIds ${state.stories.first.id}');
//      Fluttertoast.showToast(msg: 'zzzzzzzzzzzzzzzzz',backgroundColor: Colors.blue);
      if (GetIt.I<PrefsRepository>().myStoriesId == state.stories.first.id) {
        List<Story> o = List.of(state.stories.first.stories!);
        o.insert(o.length, r.data!);
//      //todo check if the use exist in the array and the story to it's stories
        state.stories.first.stories = o;
        emit(state.copyWith(
            stories: state.stories,
            uploadStoryStatus: UploadStoryStatus.success));
      } else {
        print('object222');
        state.stories.insert(0, Datum(stories: [r.data!]));
        print('upload 22 ');
        emit(state.copyWith(
            stories: state.stories,
            uploadStoryStatus: UploadStoryStatus.success));
      }
    });
  }

  _onStorySelectedEvent(
      StorySelectedEvent event, Emitter<StoryState> emit) async {
    emit(state.copyWith(selectedStoriesStatus: SelectedStoriesStatus.loading));
    var initialStory =
    state.stories[event.selected].stories![event.initialStory];
    if (initialStory.isPhoto == 1) {
//todo debug
//      Fluttertoast.showToast(msg: 'msg');
      //todo bring the real width and height for selected photo
      final response = await getWidthAndHeightUseCase(
          widthAndHeightParams(url: initialStory.photoPath!));
      response.fold((l) {
        emit(state.copyWith(
            selectedStoriesStatus: SelectedStoriesStatus.failure));
      }, (r) {
        //todo debug
//        Fluttertoast.showToast(msg: '${r.width}');
//todo make the story seen

        state.stories[event.selected].stories![event.initialStory].isSeen =
        true;
//todo debug
//        Fluttertoast.showToast(msg:state.stories.length.toString(),backgroundColor: Colors.red );
        emit(state.copyWith(
            selectedStoriesStatus: SelectedStoriesStatus.success,
            stories: state.stories,
            initialStory: event.initialStory,
            selectedStory: event.selected,
            imageDetail: r));
      });
    } else {
      //todo it's a video all what i will do is make it seen
      //todo make the story video seen
      state.stories[event.selected].stories![event.initialStory].isSeen = true;
      emit(state.copyWith(
        selectedStoriesStatus: SelectedStoriesStatus.success,
        stories: state.stories,
        initialStory: event.initialStory,
        selectedStory: event.selected,
      ));
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
