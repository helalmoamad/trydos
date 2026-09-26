import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// `PUT /api/seller/comments/reply` — change an existing reply.
///
/// Editing does not change the reply's creation time; the backend keeps it
/// (EC-12), so nothing here sends one.
class EditCommentReplyParams {
  final String sellerId;
  final String commentId;
  final String replyText;

  const EditCommentReplyParams({
    required this.sellerId,
    required this.commentId,
    required this.replyText,
  });
}

@injectable
class EditCommentReplyUseCase
    extends UseCase<ReadOnlyMessageFromApiModel, EditCommentReplyParams> {
  final DashBoardRepository repository;

  EditCommentReplyUseCase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
    EditCommentReplyParams params,
  ) {
    return repository.editSellerCommentReply(
      sellerId: params.sellerId,
      commentId: params.commentId,
      replyText: params.replyText,
    );
  }
}
