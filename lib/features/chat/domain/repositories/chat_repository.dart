

import 'package:dartz/dartz.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/authentication/data/models/login_user_response_model.dart';
import 'package:trydos/features/chat/data/models/my_contacts_response_model.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/my_chats_response_model.dart';
import '../../data/models/upload_file_response_model.dart';

abstract class ChatRepository {
  Future<Either<Failure,CreateUserResponseModel>> createUser(Map<String , dynamic> params);
  Future<Either<Failure,UploadFileResponseModel>> uploadFile(Map<String , dynamic> params);
  Future<Either<Failure,LoginUserResponseModel>> loginUser(Map<String , dynamic> params);
  Future<Either<Failure,bool>> saveContacts(Map<String , dynamic> params);
  Future<Either<Failure,Message>> sendMessage(Map<String , dynamic> params);
  Future<Either<Failure,bool>> readAllMessages(Map<String , dynamic> params);
  Future<Either<Failure,bool>> receiveMessage(Map<String , dynamic> params);
  Future<Either<Failure,MyContactsResponseModel>> getContacts();
  Future<Either<Failure,MyChatsResponseModel>> getChats();
}