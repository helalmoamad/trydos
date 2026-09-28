import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// `DELETE /api/seller/comments/reply` — clear the reply, keep the comment.
///
/// The row stays in the list and returns to its unanswered form (AC-23); this
/// never removes a customer's question.
class DeleteCommentReplyParams {
  final String sellerId;
  final String commentId;

  const DeleteCommentReplyParams({
    required this.sellerId,
    required this.commentId,
  });
}

@injectable
class DeleteCommentReplyUseCase
    extends UseCase<ReadOnlyMessageFromApiModel, DeleteCommentReplyParams> {
  final DashBoardRepository repository;

  DeleteCommentReplyUseCase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
    DeleteCommentReplyParams params,
  ) {
    return repository.deleteSellerCommentReply(
      sellerId: params.sellerId,
      commentId: params.commentId,
    );
  }
}
