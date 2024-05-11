// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryState _$StoryStateFromJson(Map<String, dynamic> json) => StoryState(
      uploadStoryCloudinaryStatus: $enumDecodeNullable(
              _$UploadStoryCloudinaryStatusEnumMap,
              json['uploadStoryCloudinaryStatus']) ??
          UploadStoryCloudinaryStatus.init,
      uploadStoryStatus: $enumDecodeNullable(
              _$UploadStoryStatusEnumMap, json['uploadStoryStatus']) ??
          UploadStoryStatus.init,
      selectedVideoStatus: $enumDecodeNullable(
              _$SelectedVideoStatusEnumMap, json['selectedVideoStatus']) ??
          SelectedVideoStatus.init,
      getStoriesStatus: $enumDecodeNullable(
              _$GetStoriesStatusEnumMap, json['getStoriesStatus']) ??
          GetStoriesStatus.init,
      storiesCollections: (json['storiesCollections'] as List<dynamic>?)
              ?.map((e) =>
                  CollectionStoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentStoryToMakeItViewedInEachCollection:
          (json['currentStoryToMakeItViewedInEachCollection'] as List<dynamic>?)
                  ?.map((e) => EntryConverter.instance.fromJson(e as List))
                  .toList() ??
              const [],
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      currentStoryInEachCollection:
          (json['currentStoryInEachCollection'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(int.parse(k), (e as num?)?.toInt()),
              ) ??
              const {},
      selectedCollection: (json['selectedCollection'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StoryStateToJson(StoryState instance) =>
    <String, dynamic>{
      'uploadStoryStatus':
          _$UploadStoryStatusEnumMap[instance.uploadStoryStatus]!,
      'uploadStoryCloudinaryStatus': _$UploadStoryCloudinaryStatusEnumMap[
          instance.uploadStoryCloudinaryStatus]!,
      'getStoriesStatus': _$GetStoriesStatusEnumMap[instance.getStoriesStatus]!,
      'selectedVideoStatus':
          _$SelectedVideoStatusEnumMap[instance.selectedVideoStatus]!,
      'storiesCollections':
          instance.storiesCollections.map((e) => e.toJson()).toList(),
      'currentPage': instance.currentPage,
      'selectedCollection': instance.selectedCollection,
      'currentStoryInEachCollection': instance.currentStoryInEachCollection
          .map((k, e) => MapEntry(k.toString(), e)),
      'currentStoryToMakeItViewedInEachCollection': instance
          .currentStoryToMakeItViewedInEachCollection
          .map(EntryConverter.instance.toJson)
          .toList(),
    };

const _$UploadStoryCloudinaryStatusEnumMap = {
  UploadStoryCloudinaryStatus.init: 'init',
  UploadStoryCloudinaryStatus.loading: 'loading',
  UploadStoryCloudinaryStatus.success: 'success',
  UploadStoryCloudinaryStatus.failure: 'failure',
};

const _$UploadStoryStatusEnumMap = {
  UploadStoryStatus.init: 'init',
  UploadStoryStatus.loading: 'loading',
  UploadStoryStatus.success: 'success',
  UploadStoryStatus.failure: 'failure',
};

const _$SelectedVideoStatusEnumMap = {
  SelectedVideoStatus.init: 'init',
  SelectedVideoStatus.loading: 'loading',
  SelectedVideoStatus.success: 'success',
  SelectedVideoStatus.failure: 'failure',
};

const _$GetStoriesStatusEnumMap = {
  GetStoriesStatus.init: 'init',
  GetStoriesStatus.loading: 'loading',
  GetStoriesStatus.success: 'success',
  GetStoriesStatus.failure: 'failure',
};
