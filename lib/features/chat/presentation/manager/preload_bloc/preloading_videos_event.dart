
import 'package:equatable/equatable.dart';

abstract class PreloadingVideosEvent extends Equatable{
  const PreloadingVideosEvent();
}

class PreloadInitialization extends PreloadingVideosEvent{
  const PreloadInitialization();
  @override
  // TODO: implement props
  List<Object?> get props => [];

}

class PreloadPreviousOrNext extends PreloadingVideosEvent{
  final int index ;
  const PreloadPreviousOrNext({required this.index});
  @override
  // TODO: implement props
  List<Object?> get props => [index];

}