import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/boutique_edit_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// `GET /shop/boutiques/{id}/edit` — the record and its lookups.
///
/// Needs `UPDATE_BUTIKS`. A boutique of another shop answers `404`, not
/// `403`, so nobody learns that the id exists elsewhere (AC-4).
@injectable
class GetBoutiqueForEditUseCase
    extends UseCase<BoutiqueEditResponseModel, int> {
  final DashBoardRepository repository;

  GetBoutiqueForEditUseCase(this.repository);

  @override
  Future<Either<Failure, BoutiqueEditResponseModel>> call(int boutiqueId) {
    return repository.getBoutiqueForEdit(boutiqueId);
  }
}
