import 'package:json_annotation/json_annotation.dart';
part 'pre_caching_image_state.g.dart';

@JsonSerializable(explicitToJson: true)
class PreCachingImageState {
  final Map<String, bool> cachedImages;
  final Map<String, bool> cachehSvgs;
  const PreCachingImageState(
      {this.cachedImages = const {}, this.cachehSvgs = const {}});

  /// تحديث خريطة واحدة مع الإبقاء على الأخرى.
  ///
  /// كانت الانبعاثات تُنشئ الحالة مباشرةً بخريطة واحدة
  /// (`PreCachingImageState(cachedImages: ...)`)، فتأخذ الأخرى قيمتها
  /// الافتراضية `const {}` — أي أن **كل انبعاث كان يمحو الخريطة المقابلة**.
  /// وبذلك تفشل حرّاس منع التكرار (`state.cachedImages[url] == true`) ويُعاد
  /// التخزين المسبق للأصول نفسها مراراً.
  PreCachingImageState copyWith({
    Map<String, bool>? cachedImages,
    Map<String, bool>? cachehSvgs,
  }) =>
      PreCachingImageState(
        cachedImages: cachedImages ?? this.cachedImages,
        cachehSvgs: cachehSvgs ?? this.cachehSvgs,
      );

  factory PreCachingImageState.fromJson(Map<String, dynamic> data) =>
      _$PreCachingImageStateFromJson(data);

  Map<String, dynamic> toJson() => _$PreCachingImageStateToJson(this);
}
