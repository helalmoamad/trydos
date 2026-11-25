import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';

import '../../data/models/wallet_entry_model.dart';
import '../repositories/wallet_repository.dart';

/// كشفُ حركات عملة. لا مسار له بعد — انظر `docs/wallet-endpoints.md`.
@injectable
class GetWalletEntriesUseCase extends UseCase<List<WalletEntryModel>, String> {
  GetWalletEntriesUseCase(this.repository);

  final WalletRepository repository;

  @override
  Future<Either<Failure, List<WalletEntryModel>>> call(String assetId) {
    return repository.getEntries(assetId);
  }
}
