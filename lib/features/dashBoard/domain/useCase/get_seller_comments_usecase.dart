import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_seller_comments_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// `GET /api/seller/comments` — one page of one tab.
///
/// [sellerId] is captured by the bloc when the request starts and travels with
/// it, so the answer can be checked against the shop that asked for it.
class GetSellerCommentsParams {
  final String sellerId;
  final SellerCommentType type;
  final int page;
  final int pageSize;

  const GetSellerCommentsParams({
    required this.sellerId,
    required this.type,
    this.page = 1,
    this.pageSize = kSellerCommentsPageSize,
  });
}

@injectable
class GetSellerCommentsUseCase
    extends UseCase<GetSellerCommentsModel, GetSellerCommentsParams> {
  final DashBoardRepository repository;

  GetSellerCommentsUseCase(this.repository);

  @override
  Future<Either<Failure, GetSellerCommentsModel>> call(
    GetSellerCommentsParams params,
  ) {
    return repository.getSellerComments(
      sellerId: params.sellerId,
      type: params.type,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}
