import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';

import 'package:equatable/equatable.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mime_type/mime_type.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
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
import '../../../../service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
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
    on<SetStoryLinkEvent>(_setStoryLinkEvent);
    on<AddStoryToOurServerEvent>(_AddStoryToOurServerEvent);
    on<IncreaseViewersEvent>(_IncreaseViewersEvent);
    on<ChangeStatusUploadToFailureEvent>(
      _onChangeStatusUploadToFailureEvent,
    );

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
  _onChangeStatusUploadToFailureEvent(
      ChangeStatusUploadToFailureEvent event, Emitter emit) async {
    emit(state.copyWith(
        uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.failure));
  }

  _setStoryLinkEvent(SetStoryLinkEvent event, Emitter emit) async {
    emit(state.copyWith(storyLink: event.link));
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
        emit(state.copyWith(
            uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.failure));
        if (isFailedTheFirstTime.contains('UploadStoryCloudinaryEvent')) {
          isFailedTheFirstTime.remove('UploadStoryCloudinaryEvent');
        } else {
          isFailedTheFirstTime.insert(
              isFailedTheFirstTime.length, 'UploadStoryCloudinaryEvent');
          GetIt.I<StoryBloc>().add(UploadStoryCloudinaryEvent(event.file));
        }
        ///////////////////////////
        // FirebaseAnalyticsService.logEventForSession(
        //   eventName: AnalyticsEventsConst.programmingEvent,
        //   executedEventName: AnalyticsButtonsEventNameConst.uploadStoryFailed,
        // );
        // Fluttertoast.showToast(
        //     msg: l.message,
        //     textColor: Colors.white,
        //     toastLength: Toast.LENGTH_LONG);
      },
      (r) async {
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
        //   HelperFunctions.urlToFile(r.secureUrl!).then((value) {
        add(
          AddStoryToOurServerEvent(
              path: r.secureUrl!,
              //   file: value,
              isVideo: isVideoFile ? 1 : 0,
              width: r.width,
              height: r.height),
        );
        // });

        ///////////////////////////
        // FirebaseAnalyticsService.logEventForSession(
        //   eventName: AnalyticsEventsConst.programmingEvent,
        //   executedEventName: AnalyticsButtonsEventNameConst.uploadStorySuccess,
        // );
      },
    );
  }

  _uploadStoryEvent(UploadStoryEvent event, Emitter<StoryState> emit) async {
    /*emit(state.copyWith(uploadStoryStatus: UploadStoryStatus.loading));

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
    });*/
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

  Future<void> _onGetStoryEvent(
      GetStoryEvent event, Emitter<StoryState> emit) async {
    if ((state.finishGetAllStory && event.withPaginition) ||
        (state.getStoryWithPagintionStatusLoading && event.withPaginition)) {
      return;
    }
    emit(state.copyWith(
        getStoryWithPagintionStatusLoading: true,
        finishGetAllStory:
            event.withPaginition ? state.finishGetAllStory : false,
        currentPage: event.withPaginition ? state.currentPage + 1 : 1,
        getStoriesStatus: state.getStoriesStatus == GetStoriesStatus.success
            ? state.getStoriesStatus
            : GetStoriesStatus.loading));
    final response = await getStoryUseCase(
        StoryRepositoryParams(page: state.currentPage.toString()));

    response.fold((l) {
      if (isFailedTheFirstTime.contains('GetStoryEvent')) {
        isFailedTheFirstTime.remove('GetStoryEvent');
        emit(state.copyWith(
            getStoriesStatus: GetStoriesStatus.failure,
            getStoryWithPagintionStatusLoading: false));
      } else {
        isFailedTheFirstTime.insert(
            isFailedTheFirstTime.length, 'GetStoryEvent');
        GetIt.I<StoryBloc>()
            .add(GetStoryEvent(withPaginition: event.withPaginition));
      }
    }, (r) {
      apisMustNotToRequest.add('GetStoryEvent');
      Map<int, int> currentStoryInEachCollection = {};
      int i = 0;
      List<CollectionStoryModel>? collections = r.data!.collections;
      /*  if (!(event.withPaginition)) {
        if ((collections?.length ?? 0) > 1) {
          int myStoriesIndex = collections!.indexWhere((element) =>
              GetIt.I<PrefsRepository>().myStoriesId ==
              element.stories![0].userId);
          if (myStoriesIndex != -1) {
            CollectionStoryModel collectionStoryModel =
                collections.removeAt(myStoriesIndex);

            collections.insert(
                (r.data!.collections!.length), collectionStoryModel);
          }
        }
      }*/
      r.data?.collections?.forEach((element) {
        currentStoryInEachCollection[i++] = 0;
      });
      if (event.withPaginition) {
        int i = (state.storiesCollections).length;
        r.data?.collections?.forEach((element) {
          currentStoryInEachCollection[i++] = 0;
        });
      }

      emit(state.copyWith(
          getStoryWithPagintionStatusLoading: false,
          finishGetAllStory: (r.data?.collections?.length ?? 0) < 10,
          getStoriesStatus: GetStoriesStatus.success,
          storiesCollections: event.withPaginition
              ? [...(state.storiesCollections), ...(collections ?? [])]
              : collections,
          currentStoryInEachCollection: currentStoryInEachCollection));
    });
  }

  FutureOr<void> _AddStoryToOurServerEvent(
      AddStoryToOurServerEvent event, Emitter<StoryState> emit) async {
    final response = await addStoryToOurServerUseCase.call(
        (AddStoryToOurServerParams(
            filePath: event.path,
            isVideo: event.isVideo,
            link: state.storyLink)));
    response.fold((l) {
      emit(state.copyWith(
          uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.success));

      showMessage("Faild To Add Your Story",
          foreGroundColor: Colors.white,
          backGroundColor: Colors.black,
          showInRelease: true,
          timeShowing: Toast.LENGTH_LONG);
      if (isFailedTheFirstTime.contains('AddStoryToOurServerEvent')) {
      } else {
        isFailedTheFirstTime.insert(0, 'AddStoryToOurServerEvent');
        add(AddStoryToOurServerEvent(
            path: event.path,
            isVideo: event.isVideo,
            width: event.width,
            height: event.height));
      }
    }, (r) {
      add(GetStoryEvent(withPaginition: false));
      isFailedTheFirstTime.remove('AddStoryToOurServerEvent');
      String fileName = event.path.split('/').last;
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
          oneLink: state.storyLink,
          isVideo: isVideoFile ? 1 : 0,
          isPhoto: !isVideoFile ? 1 : 0,
          photoPath: !isVideoFile ? event.path : null,
          fullVideoPath: isVideoFile ? event.path : null);
      r.fold((id) {
        if (state.storiesCollections.first.stories?[0].userId !=
            GetIt.I<PrefsRepository>().myStoriesId) {
          state.storiesCollections.insert(
              0,
              CollectionStoryModel(
                  id: GetIt.I<PrefsRepository>().myStoriesId,
                  name: GetIt.I<PrefsRepository>().myStoriesName,
                  username: GetIt.I<PrefsRepository>().myStoriesName,
                  stories: [story.copyWith(id: id)]));
        } else {
          List<Story> currentUserStories =
              List.of(state.storiesCollections.first.stories ?? []);
          currentUserStories.insert(
              currentUserStories.length, story.copyWith(id: id));
          state.storiesCollections.first.stories = currentUserStories;
        }
      }, (collection) {
        print(
            "FFFFFFFFFFFFFFFFFFFFFFFFFFFFWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW11111111111111111111111ssssssssssssssssssss");

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
    if (state.currentStoryToMakeItViewedInEachCollection
            .contains(Tuple2(event.collectionId, event.storyId)) ||
        GetIt.I<PrefsRepository>().isVerifiedPhone == false) return;
    List<Tuple2<String, String>> currentStoryToMakeItViewedInEachCollection =
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
