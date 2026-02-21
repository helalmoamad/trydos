import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';

@injectable
class ShareProductOnAppsUseCase
    extends UseCase<bool, ShareProductOnAppsParams> {
  final ChatRepository repository;

  ShareProductOnAppsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ShareProductOnAppsParams params) {
    return repository.shareProductOnApps(params.map);
  }
}

class ShareProductOnAppsParams {
  String appName;
  String productId;
  int sharedCount;

  ShareProductOnAppsParams({
    required this.appName,
    required this.productId,
    required this.sharedCount,
  });
  Map<String, dynamic> get map => {
        "app_name": "${appName}",
        "product_id": "${productId}",
        "shared_count": sharedCount,
      };
}
