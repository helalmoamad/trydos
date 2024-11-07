import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/data/models/convert_item_from_oldCart_to_cart_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class ConvertItemFromOldcartToCartUsecase extends UseCase<
    ConvertItemFromOldCartToCartModel, ConvertItemFromOldcartToCartParams> {
  final HomeRepository repository;

  ConvertItemFromOldcartToCartUsecase(this.repository);

  @override
  Future<Either<Failure, ConvertItemFromOldCartToCartModel>> call(
      ConvertItemFromOldcartToCartParams params) {
    return repository.convertItemInOldCartToCart(params.map);
  }
}

class ConvertItemFromOldcartToCartParams {
  int? oLdCartId;

  ConvertItemFromOldcartToCartParams({this.oLdCartId});
  Map<String, dynamic> get map => {
        "id": "${oLdCartId}",
      }..removeWhere((key, value) => value == null);
}
