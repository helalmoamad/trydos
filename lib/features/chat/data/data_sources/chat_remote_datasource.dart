import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/chat/data/models/change_chat_property_model.dart';
import 'package:trydos/features/chat/data/models/my_contacts_response_model.dart';
import 'package:trydos/features/chat/data/models/shared_product_count_model.dart';
import 'package:trydos/features/chat/data/models/upload_file_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';

import '../../../../common/constant/configuration/chat_url_routes.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/methods/get.dart';
import '../../../../core/api/methods/post.dart';
import '../models/ImageDetail.dart';
import '../models/media_count.dart';
import '../models/my_chats_response_model.dart';

@injectable
class ChatRemoteDataSource {
  Future<MyContactsResponseModel> getContacts() {
    GetClient<MyContactsResponseModel> getContacts =
        GetClient<MyContactsResponseModel>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<MyContactsResponseModel>(
        endpoint: ChatEndPoints.getMyContactsEP,
        response: ResponseValue<MyContactsResponseModel>(
            fromJson: (response) => MyContactsResponseModel.fromJson(response)),
      ),
    );
    return getContacts();
  }

  Future<bool> readAllMessages(Map<String, dynamic> params) {
    GetClient<bool> readAllMessages = GetClient<bool>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<bool>(
        endpoint: ChatEndPoints.readAllMessagesEP(params['id'].toString()),
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return readAllMessages();
  }

  Future<bool> receiveMessage(Map<String, dynamic> params) {
    GetClient<bool> receiveMessage = GetClient<bool>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<bool>(
        endpoint: ChatEndPoints.receiveMessageEP(params['id'].toString()),
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return receiveMessage();
  }

  Future<String> getDateTime() {
    GetClient<String> getDateTime = GetClient<String>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<String>(
        endpoint: ChatEndPoints.getDateTime,
        response:
            ResponseValue<String>(fromJson: (response) => response["data"]),
      ),
    );
    return getDateTime();
  }

  Future<MyChatsResponseModel> getChats(Map<String, dynamic> params) {
    PostClient<MyChatsResponseModel> getChats =
        PostClient<MyChatsResponseModel>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<MyChatsResponseModel>(
        endpoint: ChatEndPoints.getMyChatsEP,
        queryParameters: params,
        response: ResponseValue<MyChatsResponseModel>(fromJson: (response) {
          return MyChatsResponseModel.fromJson(response);
//return MyChatsResponseModel();
        }),
      ),
    );
    return getChats();
  }

  Future<ChangeChatPropertyModel> changeChatProperty(
      Map<String, dynamic> params) {
    PostClient<ChangeChatPropertyModel> changeChatProperty =
        PostClient<ChangeChatPropertyModel>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<ChangeChatPropertyModel>(
        endpoint: ChatEndPoints.setChatPropertyEP,
        data: params,
        response: ResponseValue<ChangeChatPropertyModel>(
            fromJson: (response) => ChangeChatPropertyModel.fromJson(response)),
      ),
    );
    return changeChatProperty();
  }

  Future<List<Message>> getMessagesForChat(Map<String, dynamic> params) {
    PostClient<List<Message>> getMessagesForChat = PostClient<List<Message>>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<List<Message>>(
        endpoint: ChatEndPoints.getMessagesForChatEP(params['params']),
        data: params['data'],
        response: ResponseValue<List<Message>>(
            fromJson: (response) => List<Message>.from(
                response["data"]!.map((x) => Message.fromJson(x)))),
      ),
    );
    return getMessagesForChat();
  }

  Future<List<Message>> getMessagesBetween(Map<String, dynamic> params) {
    PostClient<List<Message>> getMessagesBetween = PostClient<List<Message>>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<List<Message>>(
        endpoint: ChatEndPoints.getMessagesBetweenEP,
        data: params,
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
        response: ResponseValue<List<Message>>(
            fromJson: (response) => List<Message>.from(
                response["data"]!.map((x) => Message.fromJson(x)))),
      ),
    );
    return getMessagesBetween();
  }

  Future<UploadFileResponseModel> uploadFile(Map<String, dynamic> params) {
    PostClient<UploadFileResponseModel> uploadFile =
        PostClient<UploadFileResponseModel>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<UploadFileResponseModel>(
        endpoint: ChatEndPoints.uploadFileEP,
        data: params['data'],
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 5),
        response: ResponseValue<UploadFileResponseModel>(
            fromJson: (response) => UploadFileResponseModel.fromJson(response)),
      ),
    );
    return uploadFile();
  }

  Future<bool> saveContacts(Map<String, dynamic> params) {
    PostClient<bool> saveContacts = PostClient<bool>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<bool>(
        endpoint: ChatEndPoints.saveContactsEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return saveContacts();
  }

  Future<bool> deleteChat(Map<String, dynamic> params) {
    PostClient<bool> deleteChat = PostClient<bool>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<bool>(
        endpoint: ChatEndPoints.deleteChatEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return deleteChat();
  }

  Future<Message> sendMessage(Map<String, dynamic> params) {
    PostClient<Message> sendMessage = PostClient<Message>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<Message>(
        receiveTimeout: const Duration(minutes: 1),
        sendTimeout: const Duration(minutes: 1),
        endpoint: ChatEndPoints.sendMessageEP,
        data: params,
        response: ResponseValue<Message>(
            fromJson: (response) => Message.fromJson(response['data'])),
      ),
    );
    return sendMessage();
  }

  Future<Message> shareProductWithContactsOrChannels(
      Map<String, dynamic> params) {
    PostClient<Message> shareProductWithContactsOrChannels =
        PostClient<Message>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<Message>(
        receiveTimeout: const Duration(minutes: 1),
        sendTimeout: const Duration(minutes: 1),
        endpoint: ChatEndPoints.shareProductWithChannelsOrContacts,
        data: params,
        response: ResponseValue<Message>(
            fromJson: (response) => Message.fromJson(response['data'])),
      ),
    );
    return shareProductWithContactsOrChannels();
  }

  Future<CreateUserResponseModel> createUser(Map<String, dynamic> params) {
    PostClient<CreateUserResponseModel> createUser =
        PostClient<CreateUserResponseModel>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<CreateUserResponseModel>(
        endpoint: ChatEndPoints.createUserEP,
        data: params,
        response: ResponseValue<CreateUserResponseModel>(
            fromJson: (response) => CreateUserResponseModel.fromJson(response)),
      ),
    );
    return createUser();
  }

  Future<bool> shareProductOnApps(Map<String, dynamic> params) {
    PostClient<bool> shareProductOnApps = PostClient<bool>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<bool>(
        endpoint: ChatEndPoints.shareProductOnAppsEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return shareProductOnApps();
  }

  Future<ChatImageDetail> loadWidthAndHeightForImage(
      {required File ImageFile, Function? onError}) async {
    Completer<ChatImageDetail> completer = Completer<ChatImageDetail>();

    completer = Completer<ChatImageDetail>();
    Image image;
    image = Image.file(ImageFile);
    try {
      image.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener(
            (
              ImageInfo imageInfo,
              bool _,
            ) {
              final dimensions = ChatImageDetail(
                width: imageInfo.image.width,
                height: imageInfo.image.height,
              );
              if (completer.isCompleted == false) {
                completer.complete(dimensions);
              }
            },
            onError: (exception, stackTrace) {
              if (onError != null) onError();
            },
          ));
    } catch (e, s) {
      // GetIt.I<StoryBloc>().add(LoadFailureEvent());
    }
    return completer.future;
  }

  Future<MediaCount> getMediaCount(Map<String, dynamic> params) {
    GetClient<MediaCount> receiveMessage = GetClient<MediaCount>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<MediaCount>(
        endpoint: ChatEndPoints.getMediaCount(params["id"]),
        response: ResponseValue<MediaCount>(
            fromJson: (response) => MediaCount.fromJson(response)),
      ),
    );
    return receiveMessage();
  }

  Future<GetSharedProductCountModel> getSharedProductCount(
      Map<String, dynamic> params) {
    print("/////////////////////////////////////////////////${params["id"]}");
    GetClient<GetSharedProductCountModel> getSharedProductCount =
        GetClient<GetSharedProductCountModel>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<GetSharedProductCountModel>(
        endpoint: ChatEndPoints.getSharedProductCount(params["id"]),
        response: ResponseValue<GetSharedProductCountModel>(
            fromJson: (response) =>
                GetSharedProductCountModel.fromJson(response)),
      ),
    );
    return getSharedProductCount();
  }

  Future<bool> sendErrorChatToServer(Map<String, dynamic> params) {
    PostClient<bool> sendErrorChatToServer = PostClient<bool>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<bool>(
          endpoint: ChatEndPoints.sendErrorChatToServer,
          data: params,
          response: ResponseValue<bool>(returnValueOnSuccess: true)),
    );
    return sendErrorChatToServer();
  }
}
