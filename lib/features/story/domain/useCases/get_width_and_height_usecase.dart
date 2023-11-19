import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/story/data/models/image_detail.dart';

import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_stories_model.dart';
import '../repository/story_repository.dart';

@injectable
class GetWidthAndHeightUseCase
    extends UseCase<ImageDetail, widthAndHeightParams> {
  final StoryRepository repository;

  GetWidthAndHeightUseCase(this.repository);

  @override
  Future<Either<Failure, ImageDetail>> call(widthAndHeightParams params) {
    return repository.loadWidthAndHeight(url: params.getUrl , collectionId: params.getCollectionId);
  }
}

class widthAndHeightParams {
  String url;
  int collectionId;
  widthAndHeightParams({required this.url , required this.collectionId});

  String get getUrl => url;
  int get getCollectionId => collectionId;
}
