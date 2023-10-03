part of 'story_bloc.dart';

enum GetStoriesStatus { init, loading, success, failure }
enum SelectedStoriesStatus { init, loading, success, failure }
enum SelectedVideoStatus { init, loading, success, failure }
enum UploadStoryStatus { init, loading, success, failure }

class StoryState {
  UploadStoryStatus uploadStoryStatus;

  GetStoriesStatus getStoriesStatus;
   SelectedStoriesStatus selectedStoriesStatus;
   SelectedVideoStatus selectedVideoStatus;
  List<Datum> stories;
  int? selectedStory;
  int? initialStory;

  ImageDetail? imageDetail;

  StoryState(
      {this.uploadStoryStatus=UploadStoryStatus.init,
        this.selectedVideoStatus=SelectedVideoStatus.init,
        this.selectedStoriesStatus=SelectedStoriesStatus.init,
        this.imageDetail,
        this.getStoriesStatus = GetStoriesStatus.init,
      this.stories = const [],
      this.initialStory,
      this.selectedStory});

  StoryState copyWith(
      {
        UploadStoryStatus? uploadStoryStatus,
        SelectedVideoStatus? selectedVideoStatus,
        SelectedStoriesStatus? selectedStoriesStatus,
        GetStoriesStatus? getStoriesStatus,
      List<Datum>? stories,
      int? initialStory,
      int? selectedStory,
      ImageDetail? imageDetail
      }) {
    return StoryState(
      uploadStoryStatus: uploadStoryStatus??this.uploadStoryStatus,
      selectedVideoStatus: selectedVideoStatus??this.selectedVideoStatus,
      selectedStoriesStatus: selectedStoriesStatus??this.selectedStoriesStatus,
      imageDetail: imageDetail??this.imageDetail,
        getStoriesStatus: getStoriesStatus ?? this.getStoriesStatus,
        stories: stories ?? this.stories,
        initialStory: initialStory ?? this.initialStory,
        selectedStory: selectedStory ?? this.selectedStory);
  }
}
