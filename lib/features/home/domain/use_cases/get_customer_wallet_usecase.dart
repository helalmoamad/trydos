import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/customer_wallet_model.dart';
import '../repositories/home_repository.dart';

@injectable
class GetCustomerWalletUseCase
    implements UseCase<CustomerWalletModel, CustomerWalletParams> {
  GetCustomerWalletUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, CustomerWalletModel>> call(
    CustomerWalletParams params,
  ) async {
    return repository.getCustomerWallet(
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class CustomerWalletParams {
  final int limit;
  final int offset;

  CustomerWalletParams({required this.limit, required this.offset});
}
