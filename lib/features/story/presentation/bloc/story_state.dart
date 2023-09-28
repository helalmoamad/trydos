part of 'story_bloc.dart';

enum GetStoriesStatus { init, loading, success, failure }

@immutable
class StoryState {
  final GetStoriesStatus getStoriesStatus;
  List<Datum> stories;
  int? selectedStory;
  int? initialStory;

  StoryState(
      {this.getStoriesStatus = GetStoriesStatus.init,
      this.stories = const [],
      this.initialStory,
      this.selectedStory});

  StoryState copyWith(
      {final GetStoriesStatus? getStoriesStatus,
      List<Datum>? stories,
      int? initialStory,
      int? selectedStory}) {
    return StoryState(
        getStoriesStatus: getStoriesStatus ?? this.getStoriesStatus,
        stories: stories ?? this.stories,
        initialStory: initialStory ?? this.initialStory,
        selectedStory: selectedStory ?? this.selectedStory);
  }
}
