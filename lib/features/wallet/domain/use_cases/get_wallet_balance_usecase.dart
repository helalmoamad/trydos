import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';

import '../../data/models/wallet_balance_model.dart';
import '../repositories/wallet_repository.dart';

/// رصيدُ عملةٍ بعينها.
@injectable
class GetWalletBalanceUseCase extends UseCase<WalletBalanceModel, String> {
  GetWalletBalanceUseCase(this.repository);

  final WalletRepository repository;

  @override
  Future<Either<Failure, WalletBalanceModel>> call(String assetId) {
    return repository.getBalance(assetId);
  }
}
