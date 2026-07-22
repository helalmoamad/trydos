import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:equatable/equatable.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mime_type/mime_type.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/domin/usecases/upload_file_media_server_usecase.dart';
import 'package:trydos/core/error/error_manager.dart';
import 'package:trydos/features/story/domain/useCases/get_stories_usecase.dart';
import 'package:trydos/features/story/domain/useCases/get_width_and_height_usecase.dart';
import 'package:trydos/core/domin/usecases/upload_file_cloudinary_usecase.dart';
import 'package:trydos/features/story/domain/useCases/increase_viewers_usecase.dart';
import 'package:trydos/features/story/domain/useCases/upload_story_usecase.dart';
import 'package:trydos/features/story/domain/useCases/delete_story_usecase.dart';
import 'package:trydos/features/story/presentation/bloc/story_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/main.dart';
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
  final UploadFileMediaServerUseCase uploadFileMediaServerUseCase;
  final UploadStoryUseCase uploadStoryUseCase;
  final GetWidthAndHeightUseCase getWidthAndHeightUseCase;
  final AddStoryToOurServerUseCase addStoryToOurServerUseCase;
  final IncreaseViewersUseCase increaseViewersUseCase;
  final DeleteStoryUseCase deleteStoryUseCase;

  StoryBloc(
    this.uploadFileCloudinaryUseCase,
    this.getStoryUseCase,
    this.getWidthAndHeightUseCase,
    this.uploadStoryUseCase,
    this.increaseViewersUseCase,
    this.addStoryToOurServerUseCase,
    this.uploadFileMediaServerUseCase,
    this.deleteStoryUseCase,
  ) : super(StoryState()) {
    on<UploadStoryEvent>(_uploadStoryEvent);
    on<SetStoryLinkEvent>(_setStoryLinkEvent);
    on<AddStoryToOurServerEvent>(_AddStoryToOurServerEvent);
    on<IncreaseViewersEvent>(_IncreaseViewersEvent);
    on<ChangeStatusUploadToFailureEvent>(_onChangeStatusUploadToFailureEvent);
    on<DeleteStoryEvent>(_onDeleteStoryEvent);
    on<RemoveStoryFromCollectionEvent>(_onRemoveStoryFromCollectionEvent);

    on<UpdateNameForUserInCollectionIfExistEvent>(
      _onUpdateNameForUserInCollectionIfExistEvent,
    );
    on<StoryEvent>((event, emit) {});
    on<GetStoryEvent>(
      _onGetStoryEvent,
      // transformer: throttleDroppable(throttleDuration)
    );
    on<LoadFailureEvent>(
      ((event, emit) => emit(
        state.copyWith(
          storiesCollections: state.storiesCollections.map((e) {
            if (e.id == event.collectionId) {
              return e.copyWith(
                selectedStoriesStatusForCollection:
                    SelectedStoriesStatus.failure,
              );
            }
            return e;
          }).toList(),
        ),
      )),
    );
    on<StorySelectedEvent>(_onStorySelectedEvent);
    on<UploadStoryCloudinaryEvent>(_uploadStoryCloudinaryEvent);
  }
  _onChangeStatusUploadToFailureEvent(
    ChangeStatusUploadToFailureEvent event,
    Emitter emit,
  ) async {
    emit(
      state.copyWith(
        uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.failure,
      ),
    );
  }

  _setStoryLinkEvent(SetStoryLinkEvent event, Emitter emit) async {
    emit(state.copyWith(storyLink: event.link));
  }

  _uploadStoryCloudinaryEvent(
    UploadStoryCloudinaryEvent event,
    Emitter emit,
  ) async {
    emit(
      state.copyWith(
        uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.loading,
      ),
    );
    if (mediaServerIsS3) {
      final response = await uploadFileMediaServerUseCase(
        UploadFileMediaServerParams(
          file: event.file,
          isStory: true,
          usingOnUploadingFinishedFunction: false,
          usingSendProgressFunction: false,
        ),
      );

      response.fold(
        (l) {
          if (ErrorManager.shouldRetry(
            'UploadStoryCloudinaryEvent',
            l.statusCode,
          )) {
            ErrorManager.incrementRetry('UploadStoryCloudinaryEvent');

            GetIt.I<StoryBloc>().add(UploadStoryCloudinaryEvent(event.file));
            return;
          }
          emit(
            state.copyWith(
              uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.failure,
            ),
          );
        },
        (r) async {
          ErrorManager.resetRetry('UploadStoryCloudinaryEvent');
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
              path: r.url!,
              durationSeconds: r.durationSeconds,
              isVideo: isVideoFile ? 1 : 0,
            ),
          );
        },
      );
    } else {
      final response = await uploadFileCloudinaryUseCase(
        UploadFileCloudinaryParams(
          file: event.file,
          usingOnUploadingFinishedFunction: false,
          usingSendProgressFunction: false,
        ),
      );

      response.fold(
        (l) {
          if (ErrorManager.shouldRetry(
            'UploadStoryCloudinaryEvent',
            l.statusCode,
          )) {
            ErrorManager.incrementRetry('UploadStoryCloudinaryEvent');

            GetIt.I<StoryBloc>().add(UploadStoryCloudinaryEvent(event.file));
            return;
          }
          emit(
            state.copyWith(
              uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.failure,
            ),
          );
        },
        (r) async {
          ErrorManager.resetRetry('UploadStoryCloudinaryEvent');
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
              path: r.secureUrl!,

              isVideo: isVideoFile ? 1 : 0,
              width: r.width,
              height: r.height,
            ),
          );
        },
      );
    }
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
    StorySelectedEvent event,
    Emitter<StoryState> emit,
  ) async {
    //todo make the story seen when he press to show it
    debugPrint(
      'currentStoryInEachCollection ${event.selectedStoryIndexInCollection}',
    );
    debugPrint('selected ${event.collectionIndex}');
    debugPrint(
      'state.currentStoryInEachCollection ${state.currentStoryInEachCollection[event.collectionIndex]}',
    );

    Map<int, int?> currentStoryInEachCollection = Map.of(
      state.currentStoryInEachCollection,
    );
    currentStoryInEachCollection[event.collectionIndex] =
        event.selectedStoryIndexInCollection == -1
        ? (currentStoryInEachCollection[event.collectionIndex] ?? 0)
        : event.selectedStoryIndexInCollection;
    //todo make  the state loading
    emit(
      state.copyWith(
        //selectedStoriesStatus: SelectedStoriesStatus.loading,
        currentPage: event.currentPage == -1
            ? state.currentPage
            : event.currentPage,
        selectedCollection: event.collectionIndex,
        currentStoryInEachCollection: currentStoryInEachCollection,
      ),
    );

    var currentStoryInSelectedCollection =
        state.storiesCollections[event.collectionIndex].stories![max(
          state.currentStoryInEachCollection[event.collectionIndex] ?? 0,
          event.selectedStoryIndexInCollection,
        )];
    if (currentStoryInSelectedCollection.isPhoto == 1) {
      //todo debug
      //todo bring the real width and height for selected photo
      final response = await getWidthAndHeightUseCase(
        widthAndHeightParams(
          url: currentStoryInSelectedCollection.photoPath!,
          collectionId: state.storiesCollections[event.collectionIndex].id!,
        ),
      );
      response.fold(
        (l) {
          if (ErrorManager.shouldRetry('StorySelectedEvent', l.statusCode)) {
            ErrorManager.incrementRetry('StorySelectedEvent');

            emit(
              state.copyWith(
                storiesCollections: state.storiesCollections.map((e) {
                  if (e.id ==
                      state.storiesCollections[event.collectionIndex].id) {
                    return e.copyWith(
                      selectedStoriesStatusForCollection:
                          SelectedStoriesStatus.failure,
                    );
                  }
                  return e;
                }).toList(),
              ),
            );
          } else {
            ErrorManager.incrementRetry('StorySelectedEvent');
            GetIt.I<StoryBloc>().add(
              StorySelectedEvent(
                collectionIndex: event.collectionIndex,
                selectedStoryIndexInCollection:
                    event.selectedStoryIndexInCollection,
                currentPage: event.currentPage,
              ),
            );
          }
        },
        (r) {
          //todo just make the state success with the width and height for the image and in the emitter above you changed the initial  story
          emit(
            state.copyWith(
              storiesCollections: state.storiesCollections.map((e) {
                if (e.id ==
                    state.storiesCollections[event.collectionIndex].id) {
                  return e.copyWith(
                    selectedStoriesStatusForCollection:
                        SelectedStoriesStatus.success,
                    imageDetail: r,
                  );
                }
                return e;
              }).toList(),
            ),
          );
        },
      );
    } else {
      //todo it's a video all what i will do is make it seen
      emit(
        state.copyWith(
          storiesCollections: state.storiesCollections.map((e) {
            if (e.id == state.storiesCollections[event.collectionIndex].id) {
              return e.copyWith(
                selectedStoriesStatusForCollection:
                    SelectedStoriesStatus.success,
              );
            }
            return e;
          }).toList(),
          currentStoryInEachCollection: currentStoryInEachCollection,
          selectedCollection: event.collectionIndex,
        ),
      );
    }
  }

  Future<void> _onGetStoryEvent(
    GetStoryEvent event,
    Emitter<StoryState> emit,
  ) async {
    if ((state.finishGetAllStory && event.withPaginition) ||
        (state.getStoryWithPagintionStatusLoading && event.withPaginition)) {
      return;
    }
    emit(
      state.copyWith(
        getStoryWithPagintionStatusLoading: true,
        finishGetAllStory: event.withPaginition
            ? state.finishGetAllStory
            : false,
        currentPage: event.withPaginition ? state.currentPage + 1 : 1,
        getStoriesStatus: state.getStoriesStatus == GetStoriesStatus.success
            ? state.getStoriesStatus
            : GetStoriesStatus.loading,
      ),
    );
    final response = await getStoryUseCase(
      StoryRepositoryParams(page: state.currentPage.toString()),
    );

    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('GetStoryEvent', l.statusCode)) {
          ErrorManager.incrementRetry('GetStoryEvent');
          GetIt.I<StoryBloc>().add(
            GetStoryEvent(withPaginition: event.withPaginition),
          );
          return;
        }
        emit(
          state.copyWith(
            getStoriesStatus: GetStoriesStatus.failure,
            getStoryWithPagintionStatusLoading: false,
          ),
        );
      },
      (r) {
        List<CollectionStoryModel> storiesCollections = List.of(
          state.storiesCollections,
        );
        ErrorManager.resetRetry('GetStoryEvent');
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
        // ترقيم موحّد يطابق القائمة المدموجة [...القديمة, ...الجديدة] بلا فجوات.
        // مع الـ pagination نحتفظ بمفاتيح الصفحات السابقة ونضيف الجديدة انطلاقًا
        // من نهاية القائمة القائمة؛ بدونه نبدأ خريطة جديدة من الصفر.
        Map<int, int?> currentStoryInEachCollection = event.withPaginition
            ? Map.of(state.currentStoryInEachCollection)
            : {};
        int i = event.withPaginition ? storiesCollections.length : 0;
        r.data?.collections?.forEach((element) {
          currentStoryInEachCollection[i++] = 0;
        });

        emit(
          state.copyWith(
            getStoryWithPagintionStatusLoading: false,
            finishGetAllStory: (r.data?.collections?.length ?? 0) < 10,
            getStoriesStatus: GetStoriesStatus.success,
            storiesCollections: event.withPaginition
                ? [...(storiesCollections), ...(collections ?? [])]
                : collections,
            currentStoryInEachCollection: currentStoryInEachCollection,
          ),
        );
      },
    );
  }

  FutureOr<void> _AddStoryToOurServerEvent(
    AddStoryToOurServerEvent event,
    Emitter<StoryState> emit,
  ) async {
    final response = await addStoryToOurServerUseCase.call(
      (AddStoryToOurServerParams(
        filePath: mediaServerIsS3
            ? "${dotenv.env['MEDIA_SERVER_URL']}${event.path}"
            : event.path,

        isVideo: event.isVideo,
        link: state.storyLink,
        durationSeconds: event.durationSeconds,
      )),
    );
    response.fold(
      (l) {
        emit(
          state.copyWith(
            uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.success,
          ),
        );

        showMessage(
          LocaleKeys.failed_to_add_story.tr(),
          hasError: true,
          showInRelease: true,
        );
        if (ErrorManager.shouldRetry(
          'AddStoryToOurServerEvent',
          l.statusCode,
        )) {
        } else {
          ErrorManager.incrementRetry('AddStoryToOurServerEvent');
          add(
            AddStoryToOurServerEvent(
              path: event.path,
              isVideo: event.isVideo,
              width: event.width,
              durationSeconds: event.durationSeconds,
              height: event.height,
            ),
          );
        }
      },
      (r) {
        showMessage(
          LocaleKeys.succesfully_added_story.tr(),
          showInRelease: true,
        );
        List<CollectionStoryModel> storiesCollections = List.of(
          state.storiesCollections,
        );
        //  add(const GetStoryEvent(withPaginition: false));
        ErrorManager.resetRetry('AddStoryToOurServerEvent');
        String fileName = event.path.split('/').last;
        String mimeType = mime(fileName) ?? '';
        String mimee = mimeType.split('/')[0];
        bool isVideoFile;
        if (mimee == 'image') {
          isVideoFile = false;
        } else {
          isVideoFile = true;
        }
        DateTime now = DateTime.now().toUtc();

        // التاريخ والوقت الحالي بالتوقيت المحلي
        String formattedYear = DateFormat('yyyy-MM-dd', "en").format(now);
        String formattedDay = DateFormat('HH:mm:ss', "en").format(now);
        String formattedDate = "$formattedYear $formattedDay";

        Story story = Story(
          isSeen: false,
          userId: GetIt.I<PrefsRepository>().myStoriesId,
          height: event.height,
          width: event.width,
          createdAt: formattedDate,
          oneLink: state.storyLink,
          isVideo: isVideoFile ? 1 : 0,
          isPhoto: !isVideoFile ? 1 : 0,
          photoPath: !isVideoFile
              ? mediaServerIsS3
                    ? "${dotenv.env['MEDIA_SERVER_URL']}${event.path}"
                    : event.path
              : null,
          fullVideoPath: isVideoFile
              ? mediaServerIsS3
                    ? "${dotenv.env['MEDIA_SERVER_URL']}${event.path}"
                    : event.path
              : null,
        );
        r.fold(
          (id) {
            if (storiesCollections.first.stories?[0].userId !=
                GetIt.I<PrefsRepository>().myStoriesId) {
              storiesCollections.insert(
                0,
                CollectionStoryModel(
                  id: GetIt.I<PrefsRepository>().myStoriesId,
                  name: GetIt.I<PrefsRepository>().myStoriesName,
                  username: GetIt.I<PrefsRepository>().myStoriesName,
                  stories: [story.copyWith(id: id)],
                ),
              );
            } else {
              List<Story> currentUserStories = List.of(
                storiesCollections.first.stories ?? [],
              );
              currentUserStories.insert(
                currentUserStories.length,
                story.copyWith(id: id),
              );
              storiesCollections.first.stories = currentUserStories;
            }
          },
          (collection) {
            storiesCollections.insert(0, collection);
          },
        );
        // if (GetIt.I<PrefsRepository>().myStoriesId ==
        //     state.storiesCollections.first.stories![0].userId) {
        //   List<Story> currentUserStories =
        //       List.of(state.storiesCollections.first.stories!);
        //   currentUserStories.insert(currentUserStories.length, story);
        //   state.storiesCollections.first.stories = currentUserStories;
        // } else {
        //   state.storiesCollections.insert(0, r!);
        // }
        Map<int, int?> currentStoryInEachCollection = Map.of(
          state.currentStoryInEachCollection,
        );
        if (storiesCollections
                .first
                .stories![currentStoryInEachCollection[0]!]
                .isSeen ??
            false) {
          currentStoryInEachCollection[0] =
              storiesCollections.first.stories!.length - 1;
        }
        storiesCollections.removeLast();
        emit(
          state.copyWith(
            storiesCollections: storiesCollections,
            currentStoryInEachCollection: currentStoryInEachCollection,
            uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.success,
          ),
        );
      },
    );
  }

  @override
  StoryState? fromJson(Map<String, dynamic> json) {
    return StoryState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(StoryState state) {
    return state
        .copyWith(
          getStoriesStatus: GetStoriesStatus.init,
          selectedVideoStatus: SelectedVideoStatus.init,
          uploadStoryCloudinaryStatus: UploadStoryCloudinaryStatus.init,
          uploadStoryStatus: UploadStoryStatus.init,
          deleteStoryStatus: DeleteStoryStatus.init,
          currentStoryToMakeItViewedInEachCollection: [],
        )
        .toJson();
  }

  FutureOr<void> _IncreaseViewersEvent(
    IncreaseViewersEvent event,
    Emitter<StoryState> emit,
  ) async {
    if (state.currentStoryToMakeItViewedInEachCollection.contains(
          Tuple2(event.collectionId, event.storyId),
        ) ||
        GetIt.I<PrefsRepository>().isVerifiedPhone == false)
      return;
    List<Tuple2<String, String>> currentStoryToMakeItViewedInEachCollection =
        List.of(state.currentStoryToMakeItViewedInEachCollection);
    currentStoryToMakeItViewedInEachCollection.add(
      Tuple2(event.collectionId, event.storyId),
    );
    emit(
      state.copyWith(
        currentStoryToMakeItViewedInEachCollection:
            currentStoryToMakeItViewedInEachCollection,
      ),
    );
    final response = await increaseViewersUseCase(
      IncreaseViewersParams(storyId: event.storyId),
    );
    response.fold(
      (l) {
        currentStoryToMakeItViewedInEachCollection.remove(
          Tuple2(event.collectionId, event.storyId),
        );
        emit(
          state.copyWith(
            currentStoryToMakeItViewedInEachCollection:
                currentStoryToMakeItViewedInEachCollection,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            currentStoryToMakeItViewedInEachCollection:
                currentStoryToMakeItViewedInEachCollection,
            storiesCollections: state.storiesCollections.map((e) {
              if (e.id.toString() == event.collectionId) {
                return e.copyWith(
                  stories: e.stories?.map((e) {
                    if (e.id.toString() == event.storyId)
                      return e.copyWith(isSeen: true);
                    return e;
                  }).toList(),
                );
              }
              return e;
            }).toList(),
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateNameForUserInCollectionIfExistEvent(
    UpdateNameForUserInCollectionIfExistEvent event,
    Emitter<StoryState> emit,
  ) {
    int i = 0;
    emit(
      state.copyWith(
        storiesCollections: state.storiesCollections.map((e) {
          if (i == 0) {
            i++;
            if (e.stories![0].userId ==
                GetIt.I<PrefsRepository>().myStoriesId) {
              return e.copyWith(name: event.name);
            }
          }
          i++;
          return e;
        }).toList(),
      ),
    );
  }

  FutureOr<void> _onRemoveStoryFromCollectionEvent(
    RemoveStoryFromCollectionEvent event,
    Emitter<StoryState> emit,
  ) {
    if (event.collectionIndex < 0 ||
        event.collectionIndex >= state.storiesCollections.length) {
      return null;
    }

    final collections = List<CollectionStoryModel>.from(
      state.storiesCollections,
    );
    final collection = collections[event.collectionIndex];
    final stories = List<Story>.from(collection.stories ?? const []);

    final removeIndex = stories.indexWhere(
      (story) => story.id.toString() == event.storyId,
    );
    if (removeIndex == -1) return null;

    stories.removeAt(removeIndex);

    final updatedCurrent = Map<int, int?>.from(
      state.currentStoryInEachCollection,
    );

    // The collection is now empty -> drop it and re-key the index map so the
    // indices stay aligned with the new collections list.
    if (stories.isEmpty) {
      collections.removeAt(event.collectionIndex);

      final remapped = <int, int?>{};
      updatedCurrent.forEach((key, value) {
        if (key < event.collectionIndex) {
          remapped[key] = value;
        } else if (key > event.collectionIndex) {
          remapped[key - 1] = value;
        }
      });

      emit(
        state.copyWith(
          storiesCollections: collections,
          currentStoryInEachCollection: remapped,
        ),
      );
      return null;
    }

    // Keep the same index so the story that was *next* now occupies the current
    // slot; clamp when we removed the last story in the collection.
    int current = updatedCurrent[event.collectionIndex] ?? 0;
    if (current >= stories.length) current = stories.length - 1;
    updatedCurrent[event.collectionIndex] = current;

    collections[event.collectionIndex] = collection.copyWith(stories: stories);

    emit(
      state.copyWith(
        storiesCollections: collections,
        currentStoryInEachCollection: updatedCurrent,
      ),
    );
    return null;
  }

  FutureOr<void> _onDeleteStoryEvent(
    DeleteStoryEvent event,
    Emitter<StoryState> emit,
  ) async {
    emit(state.copyWith(deleteStoryStatus: DeleteStoryStatus.loading));

    final response = await deleteStoryUseCase(
      DeleteStoryParams(storyId: event.storyId),
    );

    response.fold(
      (l) {
        emit(state.copyWith(deleteStoryStatus: DeleteStoryStatus.failure));
        showMessage(l.message, hasError: true, showInRelease: true);
      },
      (deleteStoryModel) {
        // حذف الستوري من collection المستخدم الحالي فقط
        List<CollectionStoryModel> updatedCollections = state.storiesCollections
            .map((collection) {
              // إذا كان هذا collection المستخدم الحالي
              if (collection.stories?.isNotEmpty == true &&
                  collection.stories!.first.userId ==
                      GetIt.I<PrefsRepository>().myStoriesId) {
                // حذف الستوري المطلوب من المجموعة
                List<Story> updatedStories = collection.stories!
                    .where((story) => story.id.toString() != event.storyId)
                    .toList();

                // إذا لم يتبق ستوريز، لا تعيد المجموعة
                if (updatedStories.isEmpty) {
                  return null;
                }

                // أعد المجموعة مع الستوريز المحدثة
                return collection.copyWith(stories: updatedStories);
              }

              // إذا لم يكن collection المستخدم، أبقيه كما هو
              return collection;
            })
            .where((collection) => collection != null)
            .cast<CollectionStoryModel>()
            .toList();

        // تحديث المؤشرات بعد الحذف
        Map<int, int?> updatedCurrentStoryInEachCollection = Map.from(
          state.currentStoryInEachCollection,
        );
        int? newSelectedCollection = state.selectedCollection;

        // البحث عن collection المستخدم في القائمة المحدثة
        int userCollectionIndex = -1;
        for (int i = 0; i < updatedCollections.length; i++) {
          if (updatedCollections[i].stories?.isNotEmpty == true &&
              updatedCollections[i].stories!.first.userId ==
                  GetIt.I<PrefsRepository>().myStoriesId) {
            userCollectionIndex = i;
            break;
          }
        }

        // إذا لم يجد collection المستخدم (تم حذفه بالكامل)
        if (userCollectionIndex == -1) {
          // إذا كان هناك مجموعات أخرى، انتقل لأول مجموعة
          if (updatedCollections.isNotEmpty) {
            newSelectedCollection = 0;
            updatedCurrentStoryInEachCollection[0] =
                0; // أول ستوري في المجموعة الأولى
          } else {
            // لا توجد مجموعات، العودة للصفحة الرئيسية
            newSelectedCollection = null;
            updatedCurrentStoryInEachCollection.clear();

            showMessage(
              "تم حذف جميع الستوريز، العودة للصفحة الرئيسية",
              showInRelease: true,
            );
          }
        } else {
          // collection المستخدم موجود، تحديث المؤشر
          if (updatedCurrentStoryInEachCollection[userCollectionIndex] !=
              null) {
            int currentStoryIndex =
                updatedCurrentStoryInEachCollection[userCollectionIndex]!;
            int totalStories =
                updatedCollections[userCollectionIndex].stories!.length;

            // إذا كان المؤشر أكبر من عدد الستوريز المتبقية
            if (currentStoryIndex >= totalStories) {
              updatedCurrentStoryInEachCollection[userCollectionIndex] =
                  totalStories - 1;
            }
          }
        }

        emit(
          state.copyWith(
            storiesCollections: updatedCollections,
            currentStoryInEachCollection: updatedCurrentStoryInEachCollection,
            selectedCollection: newSelectedCollection,
            deleteStoryStatus: DeleteStoryStatus.success,
          ),
        );

        showMessage(
          deleteStoryModel.data?.message ?? "تم حذف الستوري بنجاح",
          showInRelease: true,
        );
      },
    );
  }
}
