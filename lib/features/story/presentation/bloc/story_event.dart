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