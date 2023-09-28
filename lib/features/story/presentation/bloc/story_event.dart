part of 'story_bloc.dart';


abstract class StoryEvent {
  const StoryEvent();

}
class GetStoryEvent extends StoryEvent
{
  const GetStoryEvent();

}
class LoadFailureEvent extends StoryEvent
{

}
class StorySelectedEvent extends StoryEvent
{
  int selected;
  int initialStory;
  StorySelectedEvent({required this.selected, required this.initialStory});
}