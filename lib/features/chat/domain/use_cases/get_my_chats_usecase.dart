

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/create_user_response_model.dart';
import 'package:trydos/features/chat/data/models/login_user_response_model.dart';
import 'package:trydos/features/chat/data/models/my_contacts_response_model.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';



import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/my_chats_response_model.dart';
@injectable
class GetMyChatsUseCase extends UseCase<MyChatsResponseModel , NoParams>{
  final ChatRepository repository;

  GetMyChatsUseCase(this.repository);

  @override
  Future<Either<Failure, MyChatsResponseModel>> call(NoParams params) {
    return repository.getChats();
  }

}

