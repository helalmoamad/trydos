import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/boutique_edit_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

import 'create_boutique_usecase.dart' show missingBoutiqueShopFailure;

/// [status] is the value being asked for — `0` inactive, `1` active. The new
/// value shown is the one the **response** carries, never this one.
class ChangeBoutiqueStatusParams {
  final int boutiqueId;
  final int status;
  final String? sellerId;

  const ChangeBoutiqueStatusParams({
    required this.boutiqueId,
    required this.status,
    required this.sellerId,
  });
}

/// `POST /shop/boutiques/{id}/change-status`. Runs only after a successful
/// update, and only when the status moved. Activation can be refused with a
/// `422` (not approved, missing translations, no active products); the edits
/// stay saved in that case (AC-35).
@injectable
class ChangeBoutiqueStatusUseCase
    extends UseCase<BoutiqueStatusResponseModel, ChangeBoutiqueStatusParams> {
  final DashBoardRepository repository;

  ChangeBoutiqueStatusUseCase(this.repository);

  @override
  Future<Either<Failure, BoutiqueStatusResponseModel>> call(
    ChangeBoutiqueStatusParams params,
  ) async {
    final String? sellerId = params.sellerId;
    if (sellerId == null || sellerId.isEmpty) {
      return const Left(missingBoutiqueShopFailure);
    }
    return repository.changeBoutiqueStatus(
      params.boutiqueId,
      params.status,
      sellerId,
    );
  }
}
