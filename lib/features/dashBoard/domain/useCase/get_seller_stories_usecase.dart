import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/seller_story_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetSellerStoriesUseCase
    extends UseCase<List<SellerStoryModel>, NoParams> {
  final DashBoardRepository repository;

  GetSellerStoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<SellerStoryModel>>> call(NoParams params) {
    return repository.getSellerStories();
  }
}
