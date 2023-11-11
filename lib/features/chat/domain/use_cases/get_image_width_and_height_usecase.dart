import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/story/data/models/image_detail.dart';

import '../../../../core/use_case/use_case.dart';
import '../../data/models/ImageDetail.dart';
import '../repositories/chat_repository.dart';


@injectable
class GetWidthAndHeightUseCase
    extends UseCase<ChatImageDetail, widthAndHeightParams> {
  final ChatRepository repository;

  GetWidthAndHeightUseCase(this.repository);

  @override
  Future<Either<Failure, ChatImageDetail>> call(widthAndHeightParams params) {
    return repository.loadWidthAndHeight(file: params.getUrl);
  }
}

class widthAndHeightParams {
  File file;

  widthAndHeightParams({required this.file});

  File get getUrl => file;
}
