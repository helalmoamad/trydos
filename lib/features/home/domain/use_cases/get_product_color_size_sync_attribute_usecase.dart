import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/color_size_for_product.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

@injectable
class GetProductColorSizeSyncAttributeUseCase
    extends UseCase<ColorSizeForProductModel, String> {
  final HomeRepository repository;

  GetProductColorSizeSyncAttributeUseCase(this.repository);

  @override
  Future<Either<Failure, ColorSizeForProductModel>> call(String id) {
    return repository.getProductColorSizeSyncAttribute(id);
  }
}
