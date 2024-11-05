import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class HideItemsInOldCartUseCase
    extends UseCase<bool, HideItemsInOldCartParams> {
  final HomeRepository repository;

  HideItemsInOldCartUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(HideItemsInOldCartParams params) {
    return repository.hideItemsInOldCart(params.map);
  }
}

class HideItemsInOldCartParams {
  int? oLdCartId;
  bool hideAll;

  HideItemsInOldCartParams({this.oLdCartId, this.hideAll = false});
  Map<String, dynamic> get map => {
        "id": hideAll ? null : "${oLdCartId}",
      }..removeWhere((key, value) => value == null);
}
