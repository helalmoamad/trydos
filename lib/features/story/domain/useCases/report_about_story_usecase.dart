import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/story/data/models/ReportResponse.dart';

import '../repository/story_repository.dart';

@injectable
class ReportAboutStoryUseCase
    extends UseCase<ReportResponse, ReportAboutStoryParams> {
  final StoryRepository repository;

  ReportAboutStoryUseCase(this.repository);

  @override
  Future<Either<Failure, ReportResponse>> call(ReportAboutStoryParams params) {
    return repository.reportAboutStory(params.map);
  }
}

class ReportAboutStoryParams {
  const ReportAboutStoryParams({
    required this.userId,
    required this.storyId,
    required this.reasons,
    this.notes,
  });
  final String storyId;
  final String userId;
  final List<String> reasons;
  final String? notes;

  Map<String, dynamic> get map => {
        'reporter_user_id': userId,
        'story_id': storyId,
        'reasons': reasons,
        if (notes != null && notes!.trim().isNotEmpty)
          'notes': notes!.trim(),
      };
}
