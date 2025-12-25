import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/data/models/get_only_message_from_api_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class BlockOrDeleteBlockUserUseCase
    extends UseCase<ReadOnlyMessageFromApiModel, BlockUserParams> {
  final ChatRepository repository;

  BlockOrDeleteBlockUserUseCase(this.repository);

  @override
  Future<Either<Failure, ReadOnlyMessageFromApiModel>> call(
    BlockUserParams params,
  ) {
    return repository.blockOrDeleteBlockUser(params.map);
  }
}

class BlockUserParams {
  final String ReceiveUserId;
  final bool isBlock;
  BlockUserParams({required this.ReceiveUserId, required this.isBlock});
  Map<String, dynamic> get map => {
    "user_id": ReceiveUserId,
    "is_block": isBlock,
  };
}
