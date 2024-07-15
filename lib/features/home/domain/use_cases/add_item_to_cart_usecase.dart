import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/data/models/add_item_to_cart_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class AddItemToCartUseCase
    extends UseCase<AddItemToCartModel, AddITemToCartParams> {
  final HomeRepository repository;

  AddItemToCartUseCase(this.repository);

  @override
  Future<Either<Failure, AddItemToCartModel>> call(AddITemToCartParams params) {
    return repository.addItemToCart(params.map);
  }
}

class AddITemToCartParams {
  String? id;
  int? quantity;
  String? choice_1;
  String? color;
  String? image;
  AddITemToCartParams(
      {this.choice_1, this.color, this.id, this.quantity, this.image});
  Map<String, dynamic> get map => {
        "id": id,
        "quantity": quantity,
        "choice_1": choice_1,
        "color": color,
        "image": image
      }..removeWhere((key, value) => value == null || value == "");
}
