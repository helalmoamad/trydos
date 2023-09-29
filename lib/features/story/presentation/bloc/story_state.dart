part of 'story_bloc.dart';

enum GetStoriesStatus { init, loading, success, failure }
enum SelectedStoriesStatus { init, loading, success, failure }

class StoryState {
   GetStoriesStatus getStoriesStatus;
   SelectedStoriesStatus selectedStoriesStatus;
  List<Datum> stories;
  int? selectedStory;
  int? initialStory;

  ImageDetail? imageDetail;

  StoryState(
      {this.selectedStoriesStatus=SelectedStoriesStatus.init,
        this.imageDetail,
        this.getStoriesStatus = GetStoriesStatus.init,
      this.stories = const [],
      this.initialStory,
      this.selectedStory});

  StoryState copyWith(
      {
        SelectedStoriesStatus? selectedStoriesStatus,
        GetStoriesStatus? getStoriesStatus,
      List<Datum>? stories,
      int? initialStory,
      int? selectedStory,
      ImageDetail? imageDetail
      }) {
    return StoryState(
      selectedStoriesStatus: selectedStoriesStatus??this.selectedStoriesStatus,
      imageDetail: imageDetail??this.imageDetail,
        getStoriesStatus: getStoriesStatus ?? this.getStoriesStatus,
        stories: stories ?? this.stories,
        initialStory: initialStory ?? this.initialStory,
        selectedStory: selectedStory ?? this.selectedStory);
  }
}
