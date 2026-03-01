import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class WalletCheckoutUseCase extends UseCase<bool, WalletCheckoutParams> {
  final HomeRepository repository;

  WalletCheckoutUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(WalletCheckoutParams params) {
    return repository.walletCheckout(
      params.payloadMap,
      params.signature,
      params.timestamp,
      params.idempotencyKey,
    );
  }
}

class WalletCheckoutParams {
  final double amount;
  final String currencyId;
  final List<String> cartGroupIds;
  final String idempotencyKey;
  final String timestamp;
  final String signature;
  final String myMarketId;

  WalletCheckoutParams({
    required this.amount,
    required this.currencyId,
    required this.cartGroupIds,
    required this.idempotencyKey,
    required this.myMarketId,
    required this.timestamp,
    required this.signature,
  });

  Map<String, dynamic> get payloadMap => {
    // ensure the same key order that we sign in the frontend
    "currencyId": currencyId,
    // backend requires numeric store_user_id; convert if possible
    // the prefs repository stores it as String, so try parsing to int
    "store_user_id": int.tryParse(myMarketId) ?? myMarketId,
    "amount": amount,
    "cart_group_ids": cartGroupIds,
    "idempotencyKey": idempotencyKey,
  };
}
