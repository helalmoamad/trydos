import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';

import '../../data/models/get_story_for_product_model.dart';
import '../repositories/home_repository.dart';

@injectable
class GetStoryForProductUseCase
    extends UseCase<GetStoryForProductModel, String> {
  final HomeRepository repository;

  GetStoryForProductUseCase(this.repository);

  @override
  Future<Either<Failure, GetStoryForProductModel>> call(String productId) {
    return repository.getStories(productId);
  }
}
