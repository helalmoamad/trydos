import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_shop_locations_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// `GET /shop/locations/{id}/edit` — the record **and** its country list in one
/// call, so a member who may only update never has to call the create-gated
/// lookups endpoint.
///
/// A `404` means deleted *or* another shop's, and the contract makes the two
/// look the same on purpose so no other shop's data leaks. This client cannot
/// act on the distinction anyway: every failure arrives flattened to a 400, so
/// the form closes and the list reloads on **any** failure, not on a `404`.
class GetShopLocationForEditParams {
  final int id;

  const GetShopLocationForEditParams({required this.id});
}

@injectable
class GetShopLocationForEditUseCase
    extends UseCase<ShopLocationEditModel, GetShopLocationForEditParams> {
  final DashBoardRepository repository;

  GetShopLocationForEditUseCase(this.repository);

  @override
  Future<Either<Failure, ShopLocationEditModel>> call(
    GetShopLocationForEditParams params,
  ) {
    return repository.getShopLocationForEdit(params.id);
  }
}
