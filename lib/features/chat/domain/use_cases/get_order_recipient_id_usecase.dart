import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/get_order_recipient_id_model.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetOrderRecipientIdUseCase
    extends UseCase<GetOrderRecipientIdModel, GetOrderRecipientIdParams> {
  final ChatRepository repository;

  GetOrderRecipientIdUseCase(this.repository);

  @override
  Future<Either<Failure, GetOrderRecipientIdModel>> call(
      GetOrderRecipientIdParams params) {
    return repository.getOrderRecipientId(params.map);
  }
}

class GetOrderRecipientIdParams {
  final String? orderId;
  final String? originalUserId;
  const GetOrderRecipientIdParams({this.orderId, this.originalUserId});

  Map<String, dynamic> get map => {
        'order_id': orderId,
        'original_user_id': originalUserId,
      };
}
