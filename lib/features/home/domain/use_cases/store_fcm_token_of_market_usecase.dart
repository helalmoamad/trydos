import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class StoreFcmTokenOfMarketUseCase
    implements UseCase<String, StoreFcmTokenOfMarketUseCaseParams> {
  StoreFcmTokenOfMarketUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, String>> call(
    StoreFcmTokenOfMarketUseCaseParams params,
  ) async {
    return repository.storeFcmTokenOfMarket(params.map);
  }
}

class StoreFcmTokenOfMarketUseCaseParams {
  final String fcmToken;
  final int userId;

  StoreFcmTokenOfMarketUseCaseParams({
    required this.fcmToken,
    required this.userId,
  });

  Map<String, dynamic> get map => {
    "device_token": fcmToken,
    "user_id": userId,
    "auth_token": GetIt.I<PrefsRepository>().marketToken,
  };
}
