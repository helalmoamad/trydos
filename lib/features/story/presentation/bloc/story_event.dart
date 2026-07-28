part of 'story_bloc.dart';

abstract class StoryEvent extends Equatable {
  const StoryEvent();
}

class GetStoryEvent extends StoryEvent {
  final bool withPaginition;
  const GetStoryEvent({required this.withPaginition});

  @override
  // TODO: implement props
  List<Object?> get props => [withPaginition];
}

class LoadFailureEvent extends StoryEvent {
  final int collectionId;
  const LoadFailureEvent({required this.collectionId});
  @override
  List<Object?> get props => [collectionId];
}

class StorySelectedEvent extends StoryEvent {
  final int collectionIndex;
  final int selectedStoryIndexInCollection;
  final int currentPage;
  const StorySelectedEvent({
    required this.collectionIndex,
    required this.selectedStoryIndexInCollection,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [
    collectionIndex,
    selectedStoryIndexInCollection,
    currentPage,
  ];
}

class LoadingVideoEvent extends StoryEvent {
  @override
  List<Object?> get props => [];
}

class UploadStoryEvent extends StoryEvent {
  final File file;

  const UploadStoryEvent(this.file);

  // TODO: implement props
  List<Object?> get props => [];
}

class AddStoryToOurServerEvent extends StoryEvent {
  // final File file;
  final int isVideo;
  final int? width;
  final int? height;
  final String path;
  final double? durationSeconds;

  const AddStoryToOurServerEvent({
    //required this.file,
    required this.path,
    required this.isVideo,
    this.width,
    this.durationSeconds,
    this.height,
  });

  @override
  List<Object?> get props => [isVideo, width, height, durationSeconds];
}

class UploadStoryCloudinaryEvent extends StoryEvent {
  final File file;

  const UploadStoryCloudinaryEvent(this.file);

  @override
  List<Object?> get props => [];
}

class ChangeStatusUploadToFailureEvent extends StoryEvent {
  const ChangeStatusUploadToFailureEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SetStoryLinkEvent extends StoryEvent {
  final String link;

  const SetStoryLinkEvent(this.link);

  @override
  List<Object?> get props => [];
}

class FailureVideoEvent extends StoryEvent {
  @override
  List<Object?> get props => [];
}

class IncreaseViewersEvent extends StoryEvent {
  const IncreaseViewersEvent({
    required this.collectionId,
    required this.storyId,
  });

  final String storyId;
  final String collectionId;

  @override
  List<Object?> get props => [];
}

class UpdateNameForUserInCollectionIfExistEvent extends StoryEvent {
  const UpdateNameForUserInCollectionIfExistEvent({required this.name});

  final String name;

  @override
  List<Object?> get props => [name];
}

class DeleteStoryEvent extends StoryEvent {
  final String storyId;
  const DeleteStoryEvent({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}

/// Removes a single story (e.g. after it has been reported) from a given
/// collection. If the collection becomes empty it is dropped entirely and the
/// per-collection index map is re-keyed.

