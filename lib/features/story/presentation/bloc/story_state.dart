part of 'story_bloc.dart';

enum GetStoriesStatus { init, loading, success, failure }
enum SelectedVideoStatus { init, loading, success, failure }
enum UploadStoryStatus { init, loading, success, failure }
enum UploadStoryCloudinaryStatus { init, loading, success, failure }

class StoryState {
  UploadStoryStatus uploadStoryStatus;
  UploadStoryCloudinaryStatus uploadStoryCloudinaryStatus;
  GetStoriesStatus getStoriesStatus;
   SelectedVideoStatus selectedVideoStatus;
  List<Datum> stories;
  int currentPage;
  int? selectedStory;
  Map<int , int?> initialStory;


  StoryState(
      {

        this.uploadStoryCloudinaryStatus=UploadStoryCloudinaryStatus.init,
        this.uploadStoryStatus=UploadStoryStatus.init,
        this.selectedVideoStatus=SelectedVideoStatus.init,
        this.getStoriesStatus = GetStoriesStatus.init,
      this.stories = const [],
        this.currentPage = 0,
      this.initialStory=const {},
      this.selectedStory});

  StoryState copyWith(
      {
        UploadStoryCloudinaryStatus? uploadStoryCloudinaryStatus,

        UploadStoryStatus? uploadStoryStatus,
        SelectedVideoStatus? selectedVideoStatus,
        GetStoriesStatus? getStoriesStatus,
      List<Datum>? stories,
      Map<int ,int?>? initialStory,
      int? selectedStory,
        int? currentPage,
      ImageDetail? imageDetail
      }) {
    return StoryState(
      uploadStoryCloudinaryStatus: uploadStoryCloudinaryStatus??this.uploadStoryCloudinaryStatus,
      uploadStoryStatus: uploadStoryStatus??this.uploadStoryStatus,
      selectedVideoStatus: selectedVideoStatus??this.selectedVideoStatus,
        getStoriesStatus: getStoriesStatus ?? this.getStoriesStatus,
        stories: stories ?? this.stories,
        currentPage: currentPage ?? this.currentPage,
        initialStory: initialStory ?? this.initialStory,
        selectedStory: selectedStory ?? this.selectedStory);
  }
}
