part of 'story_bloc.dart';


abstract class StoryEvent extends Equatable{
  const StoryEvent();

}
class GetStoryEvent extends StoryEvent
{
  const GetStoryEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];

}
class LoadFailureEvent extends StoryEvent
{
  final int collectionId;
  const LoadFailureEvent({required this.collectionId});
  @override
  List<Object?> get props => [collectionId];

}
class StorySelectedEvent extends StoryEvent
{
  final int collectionIndex;
  final int selectedStoryIndexInCollection;
  final int currentPage;
  const StorySelectedEvent({
    required this.collectionIndex, required this.selectedStoryIndexInCollection, required this.currentPage});

  @override
  List<Object?> get props => [collectionIndex,selectedStoryIndexInCollection,currentPage];
}

class LoadingVideoEvent extends StoryEvent
{
  @override
  List<Object?> get props => [];
}

class UploadStoryEvent extends StoryEvent
{
final File file;


const UploadStoryEvent(this.file);

  // TODO: implement props
  List<Object?> get props => [];



}

class AddStoryToOurServerEvent extends StoryEvent
{
  final String filePath;
  final int isVideo;
  final int? width;
  final int? height;


  const AddStoryToOurServerEvent({required this.filePath , required this.isVideo , this.width , this.height});

  @override
  List<Object?> get props => [filePath , isVideo , width , height];



}

class UploadStoryCloudinaryEvent extends StoryEvent
{
  final File file;


  const UploadStoryCloudinaryEvent(this.file);

  @override
  List<Object?> get props => [];



}
class FailureVideoEvent extends StoryEvent
{
  @override
  List<Object?> get props => [];


}

class IncreaseViewersEvent extends StoryEvent{
  const IncreaseViewersEvent({required this.collectionId , required this.storyId});

  final String storyId;
  final String collectionId;

  @override
  List<Object?> get props => [];

}

class UpdateNameForUserInCollectionIfExistEvent extends StoryEvent{
  const UpdateNameForUserInCollectionIfExistEvent({required this.name });

  final String name;

  @override
  List<Object?> get props => [name];

}