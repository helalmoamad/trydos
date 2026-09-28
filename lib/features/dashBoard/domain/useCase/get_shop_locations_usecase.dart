import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_shop_locations_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// `GET /shop/locations`.
///
/// [status] is `1` active, `0` inactive, `null` for all. It is tested for
/// "not set", never for falsy — `status = 0` is a real filter value, and a
/// falsy test would drop the "inactive" choice with no error.
///
/// This screen does not send it today: AC-7 narrows the locations already
/// loaded, on the device, without asking the backend again. The parameter
/// exists because the endpoint takes it and the paging follow-up will need it.
class GetShopLocationsParams {
  final int? status;

  const GetShopLocationsParams({this.status});
}

@injectable
class GetShopLocationsUseCase
    extends UseCase<GetShopLocationsModel, GetShopLocationsParams> {
  final DashBoardRepository repository;

  GetShopLocationsUseCase(this.repository);

  @override
  Future<Either<Failure, GetShopLocationsModel>> call(
    GetShopLocationsParams params,
  ) {
    return repository.getShopLocations(status: params.status);
  }
}
