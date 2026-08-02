import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/seller_story_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// `GET {STORIES_API}/api/v1/stories/seller-stories`
///
/// [userId] is the logged-in user, [sellerId] is the shop — two different ids,
/// both required by the backend.
class GetSellerStoriesParams {
  final int userId;
  final int sellerId;
  final int page;
  final int perPage;

  const GetSellerStoriesParams({
    required this.userId,
    required this.sellerId,
    this.page = 1,
    this.perPage = 20,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'seller_id': sellerId,
    'page': page,
    'perPage': perPage,
  };
}

@injectable
class GetSellerStoriesUseCase
    extends UseCase<List<SellerStoryModel>, GetSellerStoriesParams> {
  final DashBoardRepository repository;

  GetSellerStoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<SellerStoryModel>>> call(
    GetSellerStoriesParams params,
  ) {
    return repository.getSellerStories(params.toJson());
  }
}
