import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import 'package:trydos/features/home/data/models/add_item_to_cart_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/get_comment_for_product_model.dart';

@injectable
class AddCommentUseCase
    extends UseCase<Comment, AddCommentParams> {
  final HomeRepository repository;

  AddCommentUseCase(this.repository);

  @override
  Future<Either<Failure, Comment>> call(AddCommentParams params) {
    return repository.addComment(params.map);
  }
}

class AddCommentParams {
  final String productId;
  final String comment;
  AddCommentParams(
      {required this.productId, required this.comment});
  Map<String, dynamic> get map => {
    "product_id": productId,
    "comment": comment,
    "customer_id" : GetIt.I<PrefsRepository>().myMarketId
  };
}
