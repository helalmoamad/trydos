import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/DeliveredOrdersResponse.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/home_repository.dart';

@injectable
class GetDeliveredOrdersResponseUseCase
    implements UseCase<DeliveredOrdersResponse, int> {
  GetDeliveredOrdersResponseUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, DeliveredOrdersResponse>> call(
    int productId,
  ) async {
    return repository.getDeliveredOrdersResponse(productId: productId);
  }
}


