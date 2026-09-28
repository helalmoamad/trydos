import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/auth_repository.dart';

@injectable
class CreateWalletUseCase implements UseCase<bool, NoParams> {
  CreateWalletUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    // إنشاء محفظة على سيرفر RDB معطّل، ودالة الـ repository معلّقة معه.
    throw UnimplementedError('wallet requests are disabled');
    // return repository.createWallet();
  }
}
