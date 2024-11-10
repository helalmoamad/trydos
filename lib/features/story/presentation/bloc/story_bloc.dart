import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mime_type/mime_type.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/story/domain/useCases/get_stories_usecase.dart';
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';
import 'package:trydos/core/domin/usecases/upload_file_cloudinary_usecase.dart';
import 'package:trydos/features/story/domain/useCases/increase_viewers_usecase.dart';
import 'package:trydos/features/story/domain/useCases/upload_story_usecase.dart';
import 'package:trydos/features/story/presentation/bloc/story_state.dart';
import 'package:trydos/main.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../data/models/get_stories_model.dart';
import '../../domain/useCases/add_story_to_our_server_usecase.dart';

part 'story_event.dart';

const throttleDuration = Duration(minutes: 2);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@LazySingleton()
class StoryBloc extends HydratedBloc<StoryEvent, StoryState> {
  final GetStoryUseCase getStoryUseCase;
  final UploadFileCloudinaryUseCase uploadFileCloudinaryUseCase;
  final UploadStoryUseCase uploadStoryUseCase;
  final GetWidthAndHeightUseCase getWidthAndHeightUseCase;
  final AddStoryToOurServerUseCase addStoryToOurServerUseCase;
  final IncreaseViewersUseCase increaseViewersUseCase;

  StoryBloc(
      this.uploadFileCloudinaryUseCase,
      this.getStoryUseCase,
      this.getWidthAndHeightUseCase,
      this.uploadStoryUseCase,
      this.increaseViewersUseCase,
      this.addStoryToOurServerUseCase)
      : super(StoryState()) {
    on<UploadStoryEvent>(_uploadStoryEvent);
    on<AddStoryToOurServerEvent>(_AddStoryToOurServerEvent);
    on<IncreaseViewersEvent>(_IncreaseViewersEvent);
    on<UpdateNameForUserInCollectionIfExistEvent>(
        _onUpdateNameForUserInCollectionIfExistEvent);
    on<StoryEvent>((event, emit) {});
    on<GetStoryEvent>(
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
    on<StorySelectedEvent>(_onStorySelectedEvent);
    on<UploadStoryCloudinaryEvent>(_uploadStoryCloudinaryEvent);
  }

  _uploadStoryCloudinaryEvent(
      UploadStoryCloudinaryEvent event, Emitter emit) async {
    emit(state.copyWith(
        uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.loading));
    final response = await uploadFileCloudinaryUseCase(
        UploadFileCloudinaryParams(
            file: event.file,
            usingOnUploadingFinishedFunction: false,
            usingSendProgressFunction: false));
    // Fluttertoast.showToast(msg: 'tosss');
    response.fold(
      (l) {
        if (isFailedTheFirstTime.contains('UploadStoryCloudinaryEvent')) {
          isFailedTheFirstTime.remove('UploadStoryCloudinaryEvent');

          emit(state.copyWith(
              uploadStoryCloudinaryStatus:
                  UploadStoryCloudinaryStatus.failure));
        } else {
          isFailedTheFirstTime.insert(
              isFailedTheFirstTime.length, 'UploadStoryCloudinaryEvent');
          GetIt.I<StoryBloc>().add(UploadStoryCloudinaryEvent(event.file));
        }
        ///////////////////////////
        FirebaseAnalyticsService.logEventForSession(
          eventName: AnalyticsEventsConst.programmingEvent,
          executedEventName: AnalyticsExecutedEventNameConst.uploadStoryFailed,
        );
        // Fluttertoast.showToast(
        //     msg: l.message,
        //     textColor: Colors.white,
        //     toastLength: Toast.LENGTH_LONG);
      },
      (r) {
        isFailedTheFirstTime.remove('UploadStoryCloudinaryEvent');
        String fileName = event.file.path.split('/').last;
        String mimeType = mime(fileName) ?? '';
        String mimee = mimeType.split('/')[0];
        bool isVideoFile;

        if (mimee == 'image') {
          isVideoFile = false;
        } else {
          isVideoFile = true;
        }
        add(
          AddStoryToOurServerEvent(
              filePath: r.secureUrl!,
              isVideo: isVideoFile ? 1 : 0,
              width: r.width,
              height: r.height),
        );
        ///////////////////////////
        FirebaseAnalyticsService.logEventForSession(
          eventName: AnalyticsEventsConst.programmingEvent,
          executedEventName: AnalyticsExecutedEventNameConst.uploadStorySuccess,
        );
      },
    );
  }

  _uploadStoryEvent(UploadStoryEvent event, Emitter<StoryState> emit) async {
    emit(state.copyWith(uploadStoryStatus: UploadStoryStatus.loading));

    final response =
        await uploadStoryUseCase.call(UploadStoryParams(file: event.file));

    response.fold((l) {
      emit(state.copyWith(uploadStoryStatus: UploadStoryStatus.failure));
    }, (r) {
      if (GetIt.I<PrefsRepository>().myStoriesId ==
          state.storiesCollections.first.stories![0].userId) {
        List<Story> currentUserStories =
            List.of(state.storiesCollections.first.stories!);
        currentUserStories.insert(currentUserStories.length, r.data!);
//      //todo check if the use exist in the array and the story to it's stories
        state.storiesCollections.first.stories = currentUserStories;
        emit(state.copyWith(
            storiesCollections: state.storiesCollections,
            uploadStoryStatus: UploadStoryStatus.success));
      } else {
        debugPrint('object222');
        state.storiesCollections
            .insert(0, CollectionStoryModel(stories: [r.data!]));
        debugPrint('upload 22 ');
        emit(state.copyWith(
            storiesCollections: state.storiesCollections,
            uploadStoryStatus: UploadStoryStatus.success));
      }
    });
  }

  _onStorySelectedEvent(
      StorySelectedEvent event, Emitter<StoryState> emit) async {
    //todo make the story seen when he press to show it
    debugPrint(
        'currentStoryInEachCollection ${event.selectedStoryIndexInCollection}');
    debugPrint('selected ${event.collectionIndex}');
    debugPrint(
        'state.currentStoryInEachCollection ${state.currentStoryInEachCollection[event.collectionIndex]}');

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
          GetIt.I<StoryBloc>().add(StorySelectedEvent(
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

  Future<void> _onGetStoryEvent(GetStoryEvent, Emitter<StoryState> emit) async {
    /*if (apisMustNotToRequest.contains('GetStoryEvent')) {
      return;
    }*/
    emit(state.copyWith(
        getStoriesStatus: state.getStoriesStatus == GetStoriesStatus.success
            ? state.getStoriesStatus
            : GetStoriesStatus.loading));
    final response = await getStoryUseCase(NoParams());

    response.fold((l) {
      if (isFailedTheFirstTime.contains('GetStoryEvent')) {
        isFailedTheFirstTime.remove('GetStoryEvent');
        emit(state.copyWith(getStoriesStatus: GetStoriesStatus.failure));
      } else {
        isFailedTheFirstTime.insert(
            isFailedTheFirstTime.length, 'GetStoryEvent');
        GetIt.I<StoryBloc>().add(GetStoryEvent);
      }
    }, (r) {
      apisMustNotToRequest.add('GetStoryEvent');
      Map<int, int> currentStoryInEachCollection = {};
      int i = 0;
      r.data?.collections?.forEach((element) {
        currentStoryInEachCollection[i++] = 0;
      });
      emit(state.copyWith(
          getStoriesStatus: GetStoriesStatus.success,
          storiesCollections: r.data!.collections,
          currentStoryInEachCollection: currentStoryInEachCollection));
    });
  }

  FutureOr<void> _AddStoryToOurServerEvent(
      AddStoryToOurServerEvent event, Emitter<StoryState> emit) async {
    final response = await addStoryToOurServerUseCase(AddStoryToOurServerParams(
        filePath: event.filePath, isVideo: event.isVideo));
    response.fold((l) {
      if (isFailedTheFirstTime.contains('AddStoryToOurServerEvent')) {
        isFailedTheFirstTime.remove('AddStoryToOurServerEvent');

        emit(state.copyWith(
            uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.success));
      } else {
        isFailedTheFirstTime.insert(
            isFailedTheFirstTime.length, 'AddStoryToOurServerEvent');
        add(AddStoryToOurServerEvent(
            filePath: event.filePath,
            isVideo: event.isVideo,
            width: event.width,
            height: event.height));
      }
    }, (r) {
      isFailedTheFirstTime.remove('AddStoryToOurServerEvent');
      String fileName = event.filePath.split('/').last;
      String mimeType = mime(fileName) ?? '';
      String mimee = mimeType.split('/')[0];
      bool isVideoFile;
      if (mimee == 'image') {
        isVideoFile = false;
      } else {
        isVideoFile = true;
      }
      Story story = Story(
          isSeen: false,
          userId: GetIt.I<PrefsRepository>().myStoriesId,
          height: event.height,
          width: event.width,
          isVideo: isVideoFile ? 1 : 0,
          isPhoto: !isVideoFile ? 1 : 0,
          photoPath: !isVideoFile ? event.filePath : null,
          fullVideoPath: isVideoFile ? event.filePath : null);
      r.fold((id) {
        List<Story> currentUserStories =
            List.of(state.storiesCollections.first.stories!);
        currentUserStories.insert(
            currentUserStories.length, story.copyWith(id: id));
        state.storiesCollections.first.stories = currentUserStories;
      }, (collection) {
        state.storiesCollections.insert(0, collection);
      });
      // if (GetIt.I<PrefsRepository>().myStoriesId ==
      //     state.storiesCollections.first.stories![0].userId) {
      //   List<Story> currentUserStories =
      //       List.of(state.storiesCollections.first.stories!);
      //   currentUserStories.insert(currentUserStories.length, story);
      //   state.storiesCollections.first.stories = currentUserStories;
      // } else {
      //   state.storiesCollections.insert(0, r!);
      // }
      Map<int, int?> currentStoryInEachCollection =
          Map.of(state.currentStoryInEachCollection);
      if (state.storiesCollections.first
              .stories![currentStoryInEachCollection[0]!].isSeen ??
          false) {
        currentStoryInEachCollection[0] =
            state.storiesCollections.first.stories!.length - 1;
      }
      emit(state.copyWith(
          storiesCollections: state.storiesCollections,
          currentStoryInEachCollection: currentStoryInEachCollection,
          uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.success));
    });
  }

  @override
  StoryState? fromJson(Map<String, dynamic> json) {
    return StoryState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(StoryState state) {
    return state.copyWith(
        getStoriesStatus: GetStoriesStatus.init,
        selectedVideoStatus: SelectedVideoStatus.init,
        uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.init,
        uploadStoryStatus: UploadStoryStatus.init,
        currentStoryToMakeItViewedInEachCollection: []).toJson();
  }

  FutureOr<void> _IncreaseViewersEvent(
      IncreaseViewersEvent event, Emitter<StoryState> emit) async {
    /*
    if (state.currentStoryToMakeItViewedInEachCollection
        .contains(Tuple2(event.collectionId, event.storyId))) return;
    List<Tuple2<String, String>>
        currentStoryToMakeItViewedInEachCollection =
        List.of(state.currentStoryToMakeItViewedInEachCollection);
    currentStoryToMakeItViewedInEachCollection
        .add(Tuple2(event.collectionId, event.storyId));
    emit(state.copyWith(
      currentStoryToMakeItViewedInEachCollection:
          currentStoryToMakeItViewedInEachCollection,
    ));
    final response = await increaseViewersUseCase(
        IncreaseViewersParams(storyId: event.storyId));
    response.fold((l) {
      currentStoryToMakeItViewedInEachCollection
          .remove(Tuple2(event.collectionId, event.storyId));
      emit(state.copyWith(
        currentStoryToMakeItViewedInEachCollection:
            currentStoryToMakeItViewedInEachCollection,
      ));
    }, (r) {
      emit(state.copyWith(
          currentStoryToMakeItViewedInEachCollection:
              currentStoryToMakeItViewedInEachCollection,
          storiesCollections: state.storiesCollections.map((e) {
            if (e.id.toString() == event.collectionId) {
              return e.copyWith(
                  stories: e.stories?.map((e) {
                if (e.id.toString() == event.storyId)
                  return e.copyWith(isSeen: true);
                return e;
              }).toList());
            }
            return e;
          }).toList()));
    });
  */
  }

  FutureOr<void> _onUpdateNameForUserInCollectionIfExistEvent(
      UpdateNameForUserInCollectionIfExistEvent event,
      Emitter<StoryState> emit) {
    int i = 0;
    emit(state.copyWith(
        storiesCollections: state.storiesCollections.map((e) {
      if (i == 0) {
        i++;
        if (e.stories![0].userId == GetIt.I<PrefsRepository>().myStoriesId) {
          return e.copyWith(name: event.name);
        }
      }
      i++;
      return e;
    }).toList()));
  }
}
