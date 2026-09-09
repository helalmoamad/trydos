import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_shop_locations_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// `GET /shop/locations/lookups` — the add form's country list.
///
/// Create-gated, so it runs only when the add form opens, never while the list
/// is being shown. A member who may read locations but not create one still
/// sees the list, and a failure of this call is confined to the form (AC-33).
///
/// The list's own country values never come from here: each location carries
/// its own country object, so a row reads the name off the record it already
/// holds.
@injectable
class GetLocationFormCountriesUseCase
    extends UseCase<LocationFormLookupsModel, NoParams> {
  final DashBoardRepository repository;

  GetLocationFormCountriesUseCase(this.repository);

  @override
  Future<Either<Failure, LocationFormLookupsModel>> call(NoParams params) {
    return repository.getLocationFormCountries();
  }
}
