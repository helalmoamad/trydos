import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/starting_settings_response_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';
@injectable
class GetStartingSettingsUseCase implements UseCase<StartingSettingsResponseModel, NoParams> {
  GetStartingSettingsUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, StartingSettingsResponseModel>> call(
      NoParams params) async {
    return repository.getStartingSettings();
  }
}
