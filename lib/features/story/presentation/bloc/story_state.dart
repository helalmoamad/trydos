import 'package:json_annotation/json_annotation.dart';

import '../../data/models/get_stories_model.dart';
import '../../data/models/image_detail.dart';
part 'story_state.g.dart';

enum GetStoriesStatus { init, loading, success, failure }
enum SelectedVideoStatus { init, loading, success, failure }
enum UploadStoryStatus { init, loading, success, failure }
enum UploadStoryCloudinaryStatus { init, loading, success, failure }

@JsonSerializable(explicitToJson: true)
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

  factory StoryState.fromJson(Map<String,dynamic> data) => _$StoryStateFromJson(data);

  Map<String,dynamic> toJson() => _$StoryStateToJson(this);

}
