import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class RemoveItemToCartUseCase extends UseCase<bool, RemoveITemToCartParams> {
  final HomeRepository repository;

  RemoveItemToCartUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(RemoveITemToCartParams params) {
    return repository.removeItemToCart(params.map);
  }
}

class RemoveITemToCartParams {
  String? id;

  RemoveITemToCartParams({this.id});
  Map<String, dynamic> get map => {
        "key": id,
      };
}
