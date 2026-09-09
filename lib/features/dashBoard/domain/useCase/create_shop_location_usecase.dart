import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/dashBoard/data/models/get_shop_locations_model.dart';
import 'package:trydos/features/dashBoard/domain/repositories/dashBoard_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

/// The body of a create or an update — the contract gives the two the same
/// shape and the same rules.
///
/// `address`, `latitude` and `longitude` are sent only when the member filled
/// them. Coordinates go out as **numbers**, whatever the record carried as a
/// string, and a location can be saved without them (AC-34).
///
/// [sellerId] is the shop the action was started for. It travels on the request
/// as a header, never in the body: the backend takes the owner from
/// `X-Seller-ID` and ignores any owner field here.
class SaveShopLocationParams {
  final String name;
  final int countryId;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? sellerId;

  const SaveShopLocationParams({
    required this.name,
    required this.countryId,
    this.address,
    this.latitude,
    this.longitude,
    required this.sellerId,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> body = <String, dynamic>{
      'name': name,
      'country_id': countryId,
    };
    final String? trimmedAddress = address?.trim();
    if (trimmedAddress != null && trimmedAddress.isNotEmpty) {
      body['address'] = trimmedAddress;
    }
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    return body;
  }
}

/// `POST /shop/locations`.
///
/// A new location always starts active — `status` cannot be set here. The name
/// is unique per shop, per country; a duplicate comes back as a 422 whose
/// `detailed_error[].code` is `name`, and that refusal is the backend's to
/// report because this screen never holds the shop's locations in other
/// countries.
@injectable
class CreateShopLocationUseCase
    extends UseCase<ShopLocationWriteResponseModel, SaveShopLocationParams> {
  final DashBoardRepository repository;

  CreateShopLocationUseCase(this.repository);

  @override
  Future<Either<Failure, ShopLocationWriteResponseModel>> call(
    SaveShopLocationParams params,
  ) {
    return repository.createShopLocation(params.toMap(), params.sellerId);
  }
}
