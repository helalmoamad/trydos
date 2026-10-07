import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/boutique_edit_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// `GET /shop/boutiques/lookups` — countries and availabilities for the
/// New Boutique page. Needs `CREATE_BUTIKS`, so it runs only when that page
/// opens. An existing boutique gets its lookups from `/edit` instead.
@injectable
class GetBoutiqueLookupsUseCase
    extends UseCase<BoutiqueLookupsResponseModel, NoParams> {
  final DashBoardRepository repository;

  GetBoutiqueLookupsUseCase(this.repository);

  @override
  Future<Either<Failure, BoutiqueLookupsResponseModel>> call(NoParams params) {
    return repository.getBoutiqueLookups();
  }
}
