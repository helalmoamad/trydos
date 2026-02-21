import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/home/data/models/translate_comment_model.dart';
import 'package:trydos/features/home/domain/repositories/home_repository.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class TranslateCommentUsecase
    extends UseCase<TranslateCommentModel, TranslateCommentParam> {
  final HomeRepository repository;

  TranslateCommentUsecase(this.repository);

  @override
  Future<Either<Failure, TranslateCommentModel>> call(
    TranslateCommentParam params,
  ) {
    return repository.translateCommentsToAppLan(params.map);
  }
}

class TranslateCommentParam {
  final String? commentId;
  final bool isSeller;

  TranslateCommentParam({this.commentId, this.isSeller = false});
  Map<String, dynamic> get map => {
    "target_language": LanguageService.isKurdish
        ? "ku"
        : LanguageService.languageCode,
    "comment_id": commentId,
    "translate_type": isSeller ? "seller_reply" : "comment",
  };
}
