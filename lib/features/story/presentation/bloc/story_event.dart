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
  // TODO: implement props
  List<Object?> get props => [collectionId];

}
class StorySelectedEvent extends StoryEvent
{
  int selected;
  int initialStory;
  int currentPage;
  StorySelectedEvent({
    required this.selected, required this.initialStory, required this.currentPage});

  @override
  // TODO: implement props
  List<Object?> get props => [selected,initialStory,currentPage];
}

class LoadingVideoEvent extends StoryEvent
{
  @override
  // TODO: implement props
  List<Object?> get props => [];


}

class UploadStoryEvent extends StoryEvent
{
File file;


UploadStoryEvent(this.file);

  @override
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
  // TODO: implement props
  List<Object?> get props => [filePath , isVideo , width , height];



}

class UploadStoryCloudinaryEvent extends StoryEvent
{
  File file;


  UploadStoryCloudinaryEvent(this.file);

  @override
  // TODO: implement props
  List<Object?> get props => [];



}
class FailureVideoEvent extends StoryEvent
{
  @override
  // TODO: implement props
  List<Object?> get props => [];


}