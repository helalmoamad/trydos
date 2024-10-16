import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/media_count.dart';
import 'package:trydos/features/chat/data/models/shared_product_count_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class GetSharedProductCountUseCase
    extends UseCase<GetSharedProductCountModel, GetSharedProductCountParams> {
  final ChatRepository repository;

  GetSharedProductCountUseCase(this.repository);

  @override
  Future<Either<Failure, GetSharedProductCountModel>> call(
      GetSharedProductCountParams params) {
    return repository.getSharedProductCount(params.map);
  }
}

class GetSharedProductCountParams {
  final String productId;

  const GetSharedProductCountParams({required this.productId});
  Map<String, dynamic> get map => {
        "id": productId,
      };
}
