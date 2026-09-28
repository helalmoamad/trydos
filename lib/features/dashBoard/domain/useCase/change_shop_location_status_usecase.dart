import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_shop_locations_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// [status] is the value being asked for — `0` inactive, `1` active. The row's
/// new marker is the value the **response** carries, never this one (AC-30).
class ChangeShopLocationStatusParams {
  final int id;
  final int status;
  final String? sellerId;

  const ChangeShopLocationStatusParams({
    required this.id,
    required this.status,
    required this.sellerId,
  });
}

/// `POST /shop/locations/{id}/change-status`.
///
/// The record is kept — nothing is removed, because the backend has no delete
/// call at all. Taking a location out of service does **not** detach it from
/// products that already point at it, and the screen must not suggest it does
/// (AC-32).
///
/// There is no reload after a toggle: the contract says the new value comes
/// from the response, so the bloc writes that one row in place.
@injectable
class ChangeShopLocationStatusUseCase
    extends
        UseCase<
          ChangeLocationStatusResponseModel,
          ChangeShopLocationStatusParams
        > {
  final DashBoardRepository repository;

  ChangeShopLocationStatusUseCase(this.repository);

  @override
  Future<Either<Failure, ChangeLocationStatusResponseModel>> call(
    ChangeShopLocationStatusParams params,
  ) {
    return repository.changeShopLocationStatus(
      params.id,
      params.status,
      params.sellerId,
    );
  }
}
