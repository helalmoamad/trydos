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
  @override
  // TODO: implement props
  List<Object?> get props => [];

}
class StorySelectedEvent extends StoryEvent
{
  int selected;
  int initialStory;
  StorySelectedEvent({
    required this.selected, required this.initialStory});

  @override
  // TODO: implement props
  List<Object?> get props => [selected,initialStory];
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