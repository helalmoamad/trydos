import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/story/data/models/image_detail.dart';

import '../../../../core/use_case/use_case.dart';
import '../../data/models/ImageDetail.dart';
import '../repositories/chat_repository.dart';

@injectable
class GetDateTimeUseCase extends UseCase<String, NoParams> {
  final ChatRepository repository;

  GetDateTimeUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return repository.getDateTime();
  }
}
