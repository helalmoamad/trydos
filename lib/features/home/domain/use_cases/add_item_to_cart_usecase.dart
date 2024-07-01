import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class AddItemToCartUseCase extends UseCase<bool, AddITemToCartParams> {
  final HomeRepository repository;

  AddItemToCartUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(AddITemToCartParams params) {
    return repository.addItemToCart(params.map);
  }
}

class AddITemToCartParams {
  String? id;
  int? quantity;
  String? choice_1;
  String? color;
  AddITemToCartParams({this.choice_1, this.color, this.id, this.quantity});
  Map<String, dynamic> get map => {
        "id": id,
        "quantity": quantity,
        "choice_1": choice_1,
        "color": color,
      }..removeWhere((key, value) => value == null || value == "");
}
