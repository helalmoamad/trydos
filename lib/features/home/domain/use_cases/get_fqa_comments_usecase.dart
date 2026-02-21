import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/get_fqa_comments_model.dart';

@injectable
class GetFqaCommentsUsecase
    extends UseCase<GetFqaCommentsModel, GetFqaCommentsParams> {
  final HomeRepository repository;
  GetFqaCommentsUsecase(this.repository);
  @override
  Future<Either<Failure, GetFqaCommentsModel>> call(
    GetFqaCommentsParams params,
  ) {
    return repository.getFqaComments(params.map);
  }
}

class GetFqaCommentsParams {
  final String? offset;
  final String? productId;
  final String? filter;
  GetFqaCommentsParams({this.productId, this.offset, this.filter});
  Map<String, dynamic> get map => {
    "offset": offset,
    "product_id": productId,
    "user_id": GetIt.I<PrefsRepository>().myMarketId,
    "filter": filter,
  }..removeWhere((key, value) => value == '[]' || value == "" || value == null);
}
