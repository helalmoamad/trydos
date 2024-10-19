import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/features/chat/data/data_sources/chat_remote_datasource.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/chat/data/models/change_chat_property_model.dart';
import 'package:trydos/features/chat/data/models/my_contacts_response_model.dart';
import 'package:trydos/features/chat/data/models/shared_product_count_model.dart';
import 'package:trydos/features/chat/data/models/upload_file_response_model.dart';

import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';
import '../../../../core/api/handling_exception.dart';
import '../models/ImageDetail.dart';
import '../models/media_count.dart';
import '../models/my_chats_response_model.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl extends ChatRepository with HandlingExceptionRequest {
  final ChatRemoteDataSource dataSource;

  ChatRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, ChatImageDetail>> loadWidthAndHeight(
      {required File file}) async {
    ChatImageDetail result = await dataSource.loadWidthAndHeightForImage(
        onError: () {
          // GetIt.I<StoryBloc>().add(LoadFailureEvent());
        },
        ImageFile: file);
    return Right(result);
  }

  @override
  Future<Either<Failure, String>> getDateTime() async {
    String result = await dataSource.getDateTime();
    return Right(result);
  }

  @override
  Future<Either<Failure, MyContactsResponseModel>> getContacts() {
    return handlingExceptionRequest(tryCall: dataSource.getContacts);
  }

  @override
  Future<Either<Failure, CreateUserResponseModel>> createUser(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.createUser(params));
  }

  @override
  Future<Either<Failure, GetSharedProductCountModel>> getSharedProductCount(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getSharedProductCount(params));
  }

  @override
  Future<Either<Failure, bool>> shareProductOnApps(Map<String, dynamic> params) {
    ///todo debug12
//    Fluttertoast.showToast(msg: dataSource.saveContacts(params).toString());
    return handlingExceptionRequest(
        tryCall: () => dataSource.shareProductOnApps(params));
  }
@override
  Future<Either<Failure, bool>> saveContacts(Map<String, dynamic> params) {
    ///todo debug12
//    Fluttertoast.showToast(msg: dataSource.saveContacts(params).toString());
    return handlingExceptionRequest(
        tryCall: () => dataSource.saveContacts(params));
  }

  @override
  Future<Either<Failure, MyChatsResponseModel>> getChats(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(tryCall: () => dataSource.getChats(params));
  }

  @override
  Future<Either<Failure, Message>> sendMessage(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.sendMessage(params));
  }

  @override
  Future<Either<Failure, UploadFileResponseModel>> uploadFile(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.uploadFile(params));
  }

  @override
  Future<Either<Failure, bool>> readAllMessages(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.readAllMessages(params));
  }

  @override
  Future<Either<Failure, bool>> receiveMessage(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.receiveMessage(params));
  }

  @override
  Future<Either<Failure, ChangeChatPropertyModel>> changeChatProperty(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.changeChatProperty(params));
  }

  @override
  Future<Either<Failure, bool>> deleteChat(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.deleteChat(params));
  }

  @override
  Future<Either<Failure, List<Message>>> getMessagesForChat(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getMessagesForChat(params));
  }

  @override
  Future<Either<Failure, List<Message>>> getMessagesBetween(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getMessagesBetween(params));
  }

  @override
  Future<Either<Failure, MediaCount>> getMediaCount(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.getMediaCount(params));
  }

  @override
  Future<Either<Failure, bool>> SendErrorChatToServer(
      Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.sendErrorChatToServer(params));
  }

  @override
  Future<Either<Failure, Message>> shareProductWithContactsOrChannels(Map<String, dynamic> params) {
    return handlingExceptionRequest(
        tryCall: () => dataSource.shareProductWithContactsOrChannels(params));
  }
}
