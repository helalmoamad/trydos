
import 'package:dartz/dartz.dart';
import 'package:trydos/features/home/data/models/home_sections_response_model.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';

import '../../../../core/error/failures.dart';

abstract class HomeRepository {
  Future<Either<Failure, StartingSettingsResponseModel>> getStartingSettings();
  Future<Either<Failure, MainCategoriesResponseModel>> getMainCategories();
  Future<Either<Failure, HomeSectionResponseModel>> getHomeSections(Map<String , dynamic> params);
}