/*import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import 'package:trydos/features/home/data/models/get_comments_from_analytics.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetCommentsFromAnalyticsUsecase extends UseCase<
    GetCommentsFromAnalyticsModel, getCommentsFromAnalyticsParams> {
  final HomeRepository repository;

  GetCommentsFromAnalyticsUsecase(this.repository);

  @override
  Future<Either<Failure, GetCommentsFromAnalyticsModel>> call(
      getCommentsFromAnalyticsParams params) {
    return repository.getCommentsFromAnalytics(params.map);
  }
}

class getCommentsFromAnalyticsParams {
  final String? offset;
  final String? productId;
  getCommentsFromAnalyticsParams({this.productId, this.offset});
  Map<String, dynamic> get map => {"offset": offset, "product_id": productId};
}
*/
