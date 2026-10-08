import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/boutique_edit_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// `GET /languages` — the boutique editor's language tabs.
///
/// An empty or unreadable answer comes back as an empty list. The editor turns
/// that, and any failure, into the built-in four-language fallback (AC-12).
@injectable
class GetLanguagesUseCase
    extends UseCase<BoutiqueLanguagesResponseModel, NoParams> {
  final DashBoardRepository repository;

  GetLanguagesUseCase(this.repository);

  @override
  Future<Either<Failure, BoutiqueLanguagesResponseModel>> call(
    NoParams params,
  ) {
    return repository.getBoutiqueLanguages();
  }
}
