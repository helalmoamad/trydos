import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_shop_locations_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';
import 'package:trydos/features/dashBoard/domain/useCase/create_shop_location_usecase.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// The update reuses [SaveShopLocationParams] — the contract gives create and
/// update the same body and the same rules. Only the id is extra.
class UpdateShopLocationParams {
  final int id;
  final SaveShopLocationParams body;

  const UpdateShopLocationParams({required this.id, required this.body});
}

/// `POST /shop/locations/{id}/update` — note the method: **POST, not PUT**.
///
/// That single fact is why this feature touches no shared HTTP client:
/// `post.dart` already honours `extraHeaders`, so the shop id can travel on the
/// request, while `put.dart` would have needed the merge added to it — a
/// protected-path change on the funnel every API call in the app passes
/// through.
///
/// `status` cannot be changed here; that is the change-status call. The
/// unique-name check ignores this location itself.
@injectable
class UpdateShopLocationUseCase
    extends UseCase<ShopLocationWriteResponseModel, UpdateShopLocationParams> {
  final DashBoardRepository repository;

  UpdateShopLocationUseCase(this.repository);

  @override
  Future<Either<Failure, ShopLocationWriteResponseModel>> call(
    UpdateShopLocationParams params,
  ) {
    return repository.updateShopLocation(
      params.id,
      params.body.toMap(),
      params.body.sellerId,
    );
  }
}
