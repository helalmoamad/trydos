import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class SendAcceptOfNotificationsUseCase
    implements
        UseCase<
          ReadOnlyMessageFromApiModel,
          SendAcceptOfNotificationsUseCaseParams
        > {
  SendAcceptOfNotificationsUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
    SendAcceptOfNotificationsUseCaseParams params,
  ) async {
    return repository.sendAcceptOfNotificationMarket(params.map);
  }
}

class SendAcceptOfNotificationsUseCaseParams {
  final String firebaseTokenId;

  SendAcceptOfNotificationsUseCaseParams({required this.firebaseTokenId});

  Map<String, dynamic> get map => {
    "firebase_token_id": int.tryParse(firebaseTokenId),
  };
}
