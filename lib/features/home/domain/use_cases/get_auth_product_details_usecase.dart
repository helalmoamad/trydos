import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/get_auth_product_details_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

@injectable
class GetAuthProductDetailsUseCase
    extends UseCase<GetAuthProductDetailsModel, String> {
  final HomeRepository _homeRepository;

  GetAuthProductDetailsUseCase(this._homeRepository);

  @override
  Future<Either<Failure, GetAuthProductDetailsModel>> call(String productSlug) {
    return _homeRepository.getAuthProductDetails(productSlug);
  }
}
