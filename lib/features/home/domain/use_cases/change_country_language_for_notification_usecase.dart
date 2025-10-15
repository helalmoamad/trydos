import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/home/data/models/firebase_setting_for_notification_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class ChangeCountryLanguageFornotificationUseCase extends UseCase<
    FirebaseSettingForNotificationModel,
    ChangeCountryLanguageFornotificationParams> {
  final HomeRepository repository;

  ChangeCountryLanguageFornotificationUseCase(this.repository);

  @override
  Future<Either<Failure, FirebaseSettingForNotificationModel>> call(
      ChangeCountryLanguageFornotificationParams params) {
    return repository.changeCountryLanguageFornotification(params.map);
  }
}

class ChangeCountryLanguageFornotificationParams {
  final String country;
  final String languageCode;
  ChangeCountryLanguageFornotificationParams(
      {required this.country, required this.languageCode});
  Map<String, dynamic> get map =>
      {"country": country, "language_code": languageCode};
}
