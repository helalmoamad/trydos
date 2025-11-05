import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/response_only_message_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class DeleteOrderCommentRatingUseCase
    extends UseCase<ResponseOnlyMessageModel, DeleteOrderCommentRatingParams> {
  final HomeRepository repository;

  DeleteOrderCommentRatingUseCase(this.repository);

  @override
  Future<Either<Failure, ResponseOnlyMessageModel>> call(
      DeleteOrderCommentRatingParams params) {
    return repository.deleteOrderCommentRating(params.map);
  }
}

class DeleteOrderCommentRatingParams {
  final String? commentId;

  DeleteOrderCommentRatingParams({
    this.commentId,
  });
  Map<String, dynamic> get map => {"id": commentId};
}
