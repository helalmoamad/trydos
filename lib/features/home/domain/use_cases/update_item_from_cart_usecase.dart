import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/data/models/update_item_in_cart_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class UpdateItemInCartUseCase
    extends UseCase<UpdateItemInCartModel, UpdateITemInCartParams> {
  final HomeRepository repository;

  UpdateItemInCartUseCase(this.repository);

  @override
  Future<Either<Failure, UpdateItemInCartModel>> call(
      UpdateITemInCartParams params) {
    return repository.UpdateItemToCart(params.map);
  }
}

class UpdateITemInCartParams {
  String? id;
  int? quantity;
  UpdateITemInCartParams({this.id, this.quantity});
  Map<String, dynamic> get map => {"key": id, "quantity": quantity};
}
