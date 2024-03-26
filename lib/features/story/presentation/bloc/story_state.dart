import 'package:dartz/dartz.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/get_stories_model.dart';
import '../../data/models/image_detail.dart';

part 'story_state.g.dart';

enum GetStoriesStatus { init, loading, success, failure }

enum SelectedVideoStatus { init, loading, success, failure }

enum UploadStoryStatus { init, loading, success, failure }

enum UploadStoryCloudinaryStatus { init, loading, success, failure }

@JsonSerializable(explicitToJson: true)
@EntryConverter.instance
class StoryState {
  UploadStoryStatus uploadStoryStatus;
  UploadStoryCloudinaryStatus uploadStoryCloudinaryStatus;
  GetStoriesStatus getStoriesStatus;
  SelectedVideoStatus selectedVideoStatus;
  List<CollectionStoryModel> storiesCollections;
  int currentPage;
  int? selectedCollection;
  Map<int , int?> currentStoryInEachCollection;
  List<Tuple2<String , String>> currentStoryToMakeItViewedInEachCollection;


  StoryState(
      {this.uploadStoryCloudinaryStatus = UploadStoryCloudinaryStatus.init,
      this.uploadStoryStatus = UploadStoryStatus.init,
      this.selectedVideoStatus = SelectedVideoStatus.init,
      this.getStoriesStatus = GetStoriesStatus.init,
      this.storiesCollections = const [],
      this.currentStoryToMakeItViewedInEachCollection = const [],
      this.currentPage = 0,
      this.currentStoryInEachCollection = const {},
      this.selectedCollection});

  StoryState copyWith(
      {UploadStoryCloudinaryStatus? uploadStoryCloudinaryStatus,
      UploadStoryStatus? uploadStoryStatus,
      SelectedVideoStatus? selectedVideoStatus,
      List<Tuple2<String, String>>?
          currentStoryToMakeItViewedInEachCollection,
      GetStoriesStatus? getStoriesStatus,
      List<CollectionStoryModel>? storiesCollections,
      Map<int, int?>? currentStoryInEachCollection,
      int? selectedCollection,
      int? currentPage,
      ImageDetail? imageDetail}) {
    return StoryState(
        uploadStoryCloudinaryStatus:
            uploadStoryCloudinaryStatus ?? this.uploadStoryCloudinaryStatus,
        ////    currentStoryToMakeItViewedInEachCollection:
        //       currentStoryToMakeItViewedInEachCollection ??
//this.currentStoryToMakeItViewedInEachCollection,
        uploadStoryStatus: uploadStoryStatus ?? this.uploadStoryStatus,
        selectedVideoStatus: selectedVideoStatus ?? this.selectedVideoStatus,
        getStoriesStatus: getStoriesStatus ?? this.getStoriesStatus,
        storiesCollections: storiesCollections ?? this.storiesCollections,
        currentPage: currentPage ?? this.currentPage,
        currentStoryInEachCollection:
            currentStoryInEachCollection ?? this.currentStoryInEachCollection,
        selectedCollection: selectedCollection ?? this.selectedCollection);
  }

  factory StoryState.fromJson(Map<String, dynamic> data) =>
      _$StoryStateFromJson(data);

  Map<String, dynamic> toJson() => _$StoryStateToJson(this);
}


class EntryConverter implements JsonConverter<Tuple2<String , String>, List<dynamic>> {
  static const instance = EntryConverter();

  const EntryConverter();

  @override
  Tuple2<String , String> fromJson(dynamic json) {
    return Tuple2(json[0], json[1]);
  }

  @override
  List<dynamic> toJson(Tuple2<String , String> entry) {
    return [entry.value1, entry.value2];
  }
}