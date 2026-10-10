import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/boutique_edit_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// The failure every boutique write returns when it has no shop id. Nothing is
/// sent: with an empty id `_sellerHeader` adds no header, and the request
/// would fall back to whatever shop `BaseApi` reads from prefs (AC-2, review
/// finding S-3).
const Failure missingBoutiqueShopFailure = OperationFailedFailure(
  message: 'Missing shop id',
  statusCode: 0,
);

/// [body] is built by the editor's form layer, with the per-language list under
/// `boutique_custom_data`. [sellerId] is the shop captured when the page
/// opened; it travels as a header, never in the body.
class CreateBoutiqueParams {
  final Map<String, dynamic> body;
  final String? sellerId;

  const CreateBoutiqueParams({required this.body, required this.sellerId});
}

/// `POST /shop/boutiques`. A new boutique always starts inactive — the body
/// never carries `status`. The new id is read from the answer.
@injectable
class CreateBoutiqueUseCase
    extends UseCase<BoutiqueWriteResponseModel, CreateBoutiqueParams> {
  final DashBoardRepository repository;

  CreateBoutiqueUseCase(this.repository);

  @override
  Future<Either<Failure, BoutiqueWriteResponseModel>> call(
    CreateBoutiqueParams params,
  ) async {
    final String? sellerId = params.sellerId;
    if (sellerId == null || sellerId.isEmpty) {
      return const Left(missingBoutiqueShopFailure);
    }
    return repository.createBoutique(params.body, sellerId);
  }
}
