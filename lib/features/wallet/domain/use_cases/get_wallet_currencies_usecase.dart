import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';

import '../../data/models/wallet_balance_model.dart';
import '../repositories/wallet_repository.dart';

/// العملات التي تحملها المحفظة، ومنها معرّف كلِّ عملة.
@injectable
class GetWalletCurrenciesUseCase
    extends UseCase<List<WalletBalanceModel>, NoParams> {
  GetWalletCurrenciesUseCase(this.repository);

  final WalletRepository repository;

  @override
  Future<Either<Failure, List<WalletBalanceModel>>> call(NoParams params) {
    return repository.getCurrencies();
  }
}
