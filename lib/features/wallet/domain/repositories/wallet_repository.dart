import 'package:dartz/dartz.dart';

import 'package:trydos/core/error/failures.dart';

import '../../data/models/wallet_balance_model.dart';
import '../../data/models/wallet_entry_model.dart';

/// عقدُ المحفظة.
///
/// ما له مسارٌ اليوم: [getCurrencies] و[getBalance]. وما ينتظر الباك:
/// [getEntries] — انظر `docs/wallet-endpoints.md`.
abstract class WalletRepository {
  /// العملات التي تحملها المحفظة، ومنها معرّف كلِّ عملة.
  Future<Either<Failure, List<WalletBalanceModel>>> getCurrencies();

  /// رصيدُ عملةٍ بعينها.
  Future<Either<Failure, WalletBalanceModel>> getBalance(String assetId);

  /// كشفُ حركات عملة.
  Future<Either<Failure, List<WalletEntryModel>>> getEntries(String assetId);
}
