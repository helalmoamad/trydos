import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

import '../repositories/home_repository.dart';

@injectable
class SendErrorToMobileErrorLogUseCase
    implements UseCase<bool, SendErrorToMobileErrorLogParams> {
  SendErrorToMobileErrorLogUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, bool>> call(
      SendErrorToMobileErrorLogParams params) async {
    return repository.sendErrorToMobileErrorLog(params.map);
  }
}

class SendErrorToMobileErrorLogParams {
  final String errorDescription;

  SendErrorToMobileErrorLogParams({required this.errorDescription});

  Map<String, dynamic> get map => {
        "error_description": errorDescription,
      };
}
