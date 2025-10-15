import 'package:json_annotation/json_annotation.dart';
part 'pre_caching_image_state.g.dart';

@JsonSerializable(explicitToJson: true)
class PreCachingImageState {
  final Map<String, bool> cachedImages;
  final Map<String, bool> cachehSvgs;
  const PreCachingImageState(
      {this.cachedImages = const {}, this.cachehSvgs = const {}});

  factory PreCachingImageState.fromJson(Map<String, dynamic> data) =>
      _$PreCachingImageStateFromJson(data);

  Map<String, dynamic> toJson() => _$PreCachingImageStateToJson(this);
}
