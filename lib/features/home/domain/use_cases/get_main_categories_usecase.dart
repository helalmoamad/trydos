import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetMainCategoriesUseCase
    implements UseCase<MainCategoriesResponseModel, GetMainCategoryParams> {
  GetMainCategoriesUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, MainCategoriesResponseModel>> call(
      GetMainCategoryParams params) async {
    return repository.getMainCategories(params.map);
  }
}

class GetMainCategoryParams {
  //final bool fromMarket;

  GetMainCategoryParams(//{required this.fromMarket}
      );

  Map<String, dynamic> get map => {/*"fromMarket": "$fromMarket"*/};
}
