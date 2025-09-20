import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

class UpdateLikeSocialSharedProductParams {
  final String productId;

  UpdateLikeSocialSharedProductParams({
    required this.productId,
  });

  Map<String, dynamic> toMap() => {
        'pid': productId,
      };
}

@injectable
class UpdateLikeSocialSharedProductsUsecase extends UseCase<
    ReadOnlyMessageFromApiModel, UpdateLikeSocialSharedProductParams> {
  final HomeRepository repository;

  UpdateLikeSocialSharedProductsUsecase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
      UpdateLikeSocialSharedProductParams params) {
    return repository.updateLikeSocialSharedProducts(params.toMap());
  }
}
