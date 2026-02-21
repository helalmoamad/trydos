/*import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/home_sections_response_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';
@injectable
class GetHomeSectionsUseCase implements UseCase< HomeSectionResponseModel, GetHomeSectionsParams> {
  GetHomeSectionsUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, HomeSectionResponseModel>> call(
      GetHomeSectionsParams params) async {
    return repository.getHomeSections(params.map);
  }
}

class GetHomeSectionsParams{
  final String categorySlug;
  GetHomeSectionsParams(this.categorySlug);

  Map<String, dynamic> get map =>{
    "category_slug" :categorySlug,
  };
}*/