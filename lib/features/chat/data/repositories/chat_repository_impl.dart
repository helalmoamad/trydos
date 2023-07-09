
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/chat/data/data_sources/chat_remote_datasource.dart';
import 'package:trydos/features/chat/data/models/create_user_response_model.dart';
import 'package:trydos/features/chat/data/models/login_user_response_model.dart';
import 'package:trydos/features/chat/data/models/my_contacts_response_model.dart';
import 'package:trydos/features/chat/data/models/upload_file_response_model.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import '../../../../core/api/handling_exception.dart';
import '../models/my_chats_response_model.dart';
@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl extends ChatRepository with HandlingExceptionRequest {

  final ChatRemoteDataSource dataSource;
  ChatRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, MyContactsResponseModel>> getContacts() {
    return handlingExceptionRequest(tryCall:dataSource.getContacts );
  }

  @override
  Future<Either<Failure, CreateUserResponseModel>> createUser(Map<String, dynamic> params) {
    return handlingExceptionRequest(tryCall:()=> dataSource.createUser(params) );

  }

  @override
  Future<Either<Failure, LoginUserResponseModel>> loginUser(Map<String, dynamic> params) {
    return handlingExceptionRequest(tryCall:()=> dataSource.loginUser(params) );

  }

  @override
  Future<Either<Failure, bool>> saveContacts(Map<String, dynamic> params) {
    return handlingExceptionRequest(tryCall:()=> dataSource.saveContacts(params) );

  }

  @override
  Future<Either<Failure, MyChatsResponseModel>> getChats() {
    return handlingExceptionRequest(tryCall:dataSource.getChats);

  }

  @override
  Future<Either<Failure, bool>> sendMessage(Map<String, dynamic> params) {
    return handlingExceptionRequest(tryCall:()=> dataSource.sendMessage(params) );

  }

  @override
  Future<Either<Failure, UploadFileResponseModel>> uploadFile(Map<String, dynamic> params) {
    return handlingExceptionRequest(tryCall:()=> dataSource.uploadFile(params) );
  }

}