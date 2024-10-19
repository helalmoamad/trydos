import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/chat/data/models/my_contacts_response_model.dart';
import 'package:trydos/features/chat/data/models/shared_product_count_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/ImageDetail.dart';
import '../../data/models/change_chat_property_model.dart';
import '../../data/models/media_count.dart';
import '../../data/models/my_chats_response_model.dart';
import '../../data/models/upload_file_response_model.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChangeChatPropertyModel>> changeChatProperty(
      Map<String, dynamic> params);
  Future<Either<Failure, CreateUserResponseModel>> createUser(
      Map<String, dynamic> params);
  Future<Either<Failure, UploadFileResponseModel>> uploadFile(
      Map<String, dynamic> params);
  Future<Either<Failure, GetSharedProductCountModel>> getSharedProductCount(
      Map<String, dynamic> params);

  Future<Either<Failure, bool>> saveContacts(Map<String, dynamic> params);

  Future<Either<Failure, bool>> shareProductOnApps(Map<String, dynamic> params);

  Future<Either<Failure, String>> getDateTime();

  Future<Either<Failure, Message>> shareProductWithContactsOrChannels(
      Map<String, dynamic> params);
  Future<Either<Failure, Message>> sendMessage(Map<String, dynamic> params);
  Future<Either<Failure, bool>> readAllMessages(Map<String, dynamic> params);
  Future<Either<Failure, bool>> receiveMessage(Map<String, dynamic> params);
  Future<Either<Failure, bool>> deleteChat(Map<String, dynamic> params);
  Future<Either<Failure, MyContactsResponseModel>> getContacts();
  Future<Either<Failure, MyChatsResponseModel>> getChats(
      Map<String, dynamic> params);
  Future<Either<Failure, List<Message>>> getMessagesForChat(
      Map<String, dynamic> params);
  Future<Either<Failure, List<Message>>> getMessagesBetween(
      Map<String, dynamic> params);
  Future<Either<Failure, ChatImageDetail>> loadWidthAndHeight(
      {required File file});
  Future<Either<Failure, MediaCount>> getMediaCount(
      Map<String, dynamic> params);
  Future<Either<Failure, bool>> SendErrorChatToServer(
      Map<String, dynamic> params);
}
