import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/home/data/models/convert_item_from_cart_to_oldCart_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class ConvertItemFromcartToOldCartUsecase extends UseCase<
    ConvertItemFromCartToOldCartModel, ConvertItemFromcartToOldCartParams> {
  final HomeRepository repository;

  ConvertItemFromcartToOldCartUsecase(this.repository);

  @override
  Future<Either<Failure, ConvertItemFromCartToOldCartModel>> call(
      ConvertItemFromcartToOldCartParams params) {
    return repository.convertItemInCartToOldCart(params.map);
  }
}

class ConvertItemFromcartToOldCartParams {
  String? CartId;

  ConvertItemFromcartToOldCartParams({this.CartId});
  Map<String, dynamic> get map => {
        "key": "${CartId}",
      }..removeWhere((key, value) => value == null);
}
