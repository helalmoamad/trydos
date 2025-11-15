import 'package:dartz/dartz.dart';

import 'package:injectable/injectable.dart';

import 'package:trydos/features/home/data/models/response_only_message_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpdateLikeCommentUseCase
    extends UseCase<ResponseOnlyMessageModel, UpdateLikeCommentParams> {
  final HomeRepository repository;

  UpdateLikeCommentUseCase(this.repository);

  @override
  Future<Either<Failure, ResponseOnlyMessageModel>> call(
      UpdateLikeCommentParams params) {
    return repository.updateLikeComment(params.map);
  }
}

class UpdateLikeCommentParams {
  final String? type;
  final String? productId;

  final String? commentId;

  final bool? toLike;
  UpdateLikeCommentParams({
    this.type,
    this.productId,
    this.toLike,
    this.commentId,
  });
  Map<String, dynamic> get map => {
        "target_id": commentId,
        "target_type": type,
        "product_id": productId,
        "to_like": toLike
      };
}
