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
import 'package:mime_type/mime_type.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/story/data/models/image_detail.dart';
import 'package:trydos/features/story/data/models/upload_story_response_model.dart';
import 'package:trydos/features/story/domain/useCases/get_stories_usecase.dart';
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';
import 'package:trydos/core/domin/usecases/upload_file_cloudinary_usecase.dart';
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
  final UploadFileCloudinaryUseCase uploadFileCloudinaryUseCase;
  final UploadStoryUseCase uploadStoryUseCase;
  final GetWidthAndHeightUseCase getWidthAndHeightUseCase;

  StoryBloc(this.uploadFileCloudinaryUseCase, this.getStoryUseCase,
      this.getWidthAndHeightUseCase, this.uploadStoryUseCase)
      : super(StoryState()) {
    on<UploadStoryEvent>(_uploadStoryEvent);
    on<StoryEvent>((event, emit) {});
    on<GetStoryEvent>(_onGetStoryEvent,
        transformer: throttleDroppable(throttleDuration));
    on<LoadFailureEvent>(((event, emit) =>
        emit(state.copyWith(getStoriesStatus: GetStoriesStatus.failure))));
    on<StorySelectedEvent>(_onStorySelectedEvent);
    on<UploadStoryCloudinaryEvent>(_uploadStoryCloudinaryEvent);
  }

  _uploadStoryCloudinaryEvent(
      UploadStoryCloudinaryEvent event, Emitter emit) async {
    emit(state.copyWith(
        uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.loading));
    final response = await uploadFileCloudinaryUseCase
        (UploadFileCloudinaryParams(

        file: event.file, isWhenComplete: true,isSendProgress: true));
    // Fluttertoast.showToast(msg: 'tosss');
    response.fold((l) {
      // if l is TryAgailFailure








      emit(state.copyWith(
          uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.success));
      // Fluttertoast.showToast(
      //     msg: l.message,
      //     textColor: Colors.white,
      //     toastLength: Toast.LENGTH_LONG);
    }, (r) {
      String fileName = event.file.path.split('/').last;
      String mimeType = mime(fileName) ?? '';
      String mimee = mimeType.split('/')[0];
      bool checkWitherImageOrNot;
      bool checkWitherVideoOrNot;

      if (mimee == 'image') {
        checkWitherImageOrNot = true;
        checkWitherVideoOrNot = false;
      } else {
        checkWitherImageOrNot = false;
        checkWitherVideoOrNot = true;
      }

      Story story = Story(
          isSeen: false,
          userId: GetIt.I<PrefsRepository>().myStoriesId,
          height: r.height,
          width: r.width,
          isVideo: checkWitherVideoOrNot ? 1 : 0,
          isPhoto: checkWitherImageOrNot ? 1 : 0,
          photoPath: checkWitherImageOrNot ? r.secureUrl : null,
          fullVideoPath: checkWitherVideoOrNot ? r.secureUrl : null);

      // Fluttertoast.showToast(
      //     msg: story.userId.toString(), toastLength: Toast.LENGTH_LONG);
      // Fluttertoast.showToast(
      //     msg: story.photoPath.toString(), toastLength: Toast.LENGTH_LONG);
      // Fluttertoast.showToast(
      //     msg: story.isPhoto.toString(), toastLength: Toast.LENGTH_LONG);
      // Fluttertoast.showToast(
      //     msg: story.isVideo.toString(), toastLength: Toast.LENGTH_LONG);
      // Fluttertoast.showToast(
      //     msg: story.fullVideoPath.toString(), toastLength: Toast.LENGTH_LONG);

      if (GetIt.I<PrefsRepository>().myStoriesId ==
          state.stories.first.stories![0].userId) {
        List<Story> currentUserStories = List.of(state.stories.first.stories!);
        currentUserStories.insert(currentUserStories.length, story);
//      //todo check if the use exist in the array and the story to it's stories
        state.stories.first.stories = currentUserStories;
        emit(state.copyWith(
            stories: state.stories,
            uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.success));
      } else {
        print('object222');
        state.stories.insert(0, Datum(stories: [story]));
        print('upload 22 ');
        emit(state.copyWith(
            stories: state.stories,
            uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.success));
      }
    });
  }

  _onFailureVideoEvent(FailureVideoEvent event, Emitter<StoryState> emit) {
    emit(state.copyWith(selectedVideoStatus: SelectedVideoStatus.failure));
  }

  _uploadStoryEvent(UploadStoryEvent event, Emitter<StoryState> emit) async {
    print('uplaod22ss');
    emit(state.copyWith(uploadStoryStatus: UploadStoryStatus.loading));

    final response =
        await uploadStoryUseCase.call(UploadStoryParams(file: event.file));

    response.fold((l) {
      emit(state.copyWith(uploadStoryStatus: UploadStoryStatus.failure));
    }, (r) {
      if (GetIt.I<PrefsRepository>().myStoriesId ==
          state.stories.first.stories![0].userId) {
        List<Story> currentUserStories = List.of(state.stories.first.stories!);
        currentUserStories.insert(currentUserStories.length, r.data!);
//      //todo check if the use exist in the array and the story to it's stories
        state.stories.first.stories = currentUserStories;
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
    state.stories[event.selected].stories![event.initialStory].isSeen = true;
    emit(state.copyWith(
      selectedStoriesStatus: SelectedStoriesStatus.loading,
      selectedStory: event.selected,
      initialStory: event.initialStory,
    ));
    var initialStory =
        state.stories[event.selected].stories![event.initialStory];
    if (initialStory.isPhoto == 1) {
//todo debug
      //todo bring the real width and height for selected photo
      final response = await getWidthAndHeightUseCase(
          widthAndHeightParams(url: initialStory.photoPath!));
      response.fold((l) {
        emit(state.copyWith(
            selectedStoriesStatus: SelectedStoriesStatus.failure));
      }, (r) {
        //todo debug
//todo make the story seen

//todo debug
        emit(state.copyWith(
            selectedStoriesStatus: SelectedStoriesStatus.success,
            // stories: state.stories,
            // initialStory: event.initialStory,
            // selectedStory: event.selected,
            imageDetail: r));
      });
    } else {
      //todo it's a video all what i will do is make it seen
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
