import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/core/api/api.dart';
import 'package:trydos/core/error/failures.dart';

import '../../domain/repositories/wallet_repository.dart';
import '../data_sources/wallet_remote_data_source.dart';
import '../models/wallet_balance_model.dart';
import '../models/wallet_entry_model.dart';

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl extends WalletRepository
    with HandlingExceptionRequest {
  WalletRepositoryImpl(this.dataSource);

  final WalletRemoteDataSource dataSource;

  @override
  Future<Either<Failure, List<WalletBalanceModel>>> getCurrencies() {
    return handlingExceptionRequest(tryCall: dataSource.getCurrencies);
  }

  @override
  Future<Either<Failure, WalletBalanceModel>> getBalance(String assetId) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getBalance(assetId),
    );
  }

  @override
  Future<Either<Failure, List<WalletEntryModel>>> getEntries(String assetId) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.getEntries(assetId),
    );
  }
}
