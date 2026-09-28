import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// `POST /api/seller/comments/reply` — create a reply on a FAQ comment.
///
/// Used only when the comment's `has_reply` is `false`. When it is `true` the
/// edit use case is the correct one; that choice is made from the flag, never
/// from anything the member picks (AC-22).
class ReplyToCommentParams {
  final String sellerId;
  final String commentId;
  final String replyText;

  const ReplyToCommentParams({
    required this.sellerId,
    required this.commentId,
    required this.replyText,
  });
}

@injectable
class ReplyToCommentUseCase
    extends UseCase<ReadOnlyMessageFromApiModel, ReplyToCommentParams> {
  final DashBoardRepository repository;

  ReplyToCommentUseCase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
    ReplyToCommentParams params,
  ) {
    return repository.replyToSellerComment(
      sellerId: params.sellerId,
      commentId: params.commentId,
      replyText: params.replyText,
    );
  }
}
