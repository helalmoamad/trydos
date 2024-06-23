import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_comment_for_product_model.dart';
import '../repositories/home_repository.dart';

@injectable
class GetCommentForProductUseCase
    implements UseCase<GetCommentForProductModel, String> {
  GetCommentForProductUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, GetCommentForProductModel>> call(
      String productId) async {
    return repository.geCommentForProduct(productId);
  }
}
