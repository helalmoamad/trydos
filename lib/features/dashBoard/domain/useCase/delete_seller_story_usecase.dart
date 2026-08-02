import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// `POST {STORIES_API}/api/v1/stories/delete-seller-story`
class DeleteSellerStoryParams {
  /// The logged-in user id (NOT the shop id).
  final int userId;

  /// The shop the story belongs to.
  final int sellerId;
  final int storyId;

  const DeleteSellerStoryParams({
    required this.userId,
    required this.sellerId,
    required this.storyId,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'seller_id': sellerId,
    'story_id': storyId,
  };
}

@injectable
class DeleteSellerStoryUseCase extends UseCase<bool, DeleteSellerStoryParams> {
  final DashBoardRepository repository;

  DeleteSellerStoryUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteSellerStoryParams params) {
    return repository.deleteSellerStory(params.toJson());
  }
}
