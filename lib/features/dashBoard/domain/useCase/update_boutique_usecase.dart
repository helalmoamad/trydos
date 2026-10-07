import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/boutique_edit_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

import 'create_boutique_usecase.dart' show missingBoutiqueShopFailure;

/// [body] is built by the editor's form layer, with the per-language list under
/// `custom_data`, existing translation and banner ids kept, and the full banner
/// list of every language (the backend replaces banners per language).
class UpdateBoutiqueParams {
  final int boutiqueId;
  final Map<String, dynamic> body;
  final String? sellerId;

  const UpdateBoutiqueParams({
    required this.boutiqueId,
    required this.body,
    required this.sellerId,
  });
}

/// `POST /shop/boutiques/{id}/update`. Never changes `status`,
/// `request_status` or `position` — status has its own call.
@injectable
class UpdateBoutiqueUseCase
    extends UseCase<BoutiqueWriteResponseModel, UpdateBoutiqueParams> {
  final DashBoardRepository repository;

  UpdateBoutiqueUseCase(this.repository);

  @override
  Future<Either<Failure, BoutiqueWriteResponseModel>> call(
    UpdateBoutiqueParams params,
  ) async {
    final String? sellerId = params.sellerId;
    if (sellerId == null || sellerId.isEmpty) {
      return const Left(missingBoutiqueShopFailure);
    }
    return repository.updateBoutique(params.boutiqueId, params.body, sellerId);
  }
}
