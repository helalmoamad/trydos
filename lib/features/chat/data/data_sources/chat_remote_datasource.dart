
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/authentication/data/models/login_user_response_model.dart';
import 'package:trydos/features/chat/data/models/change_chat_property_model.dart';
import 'package:trydos/features/chat/data/models/my_contacts_response_model.dart';
import 'package:trydos/features/chat/data/models/upload_file_response_model.dart';

import '../../../../common/constant/configuration/url_routes.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/methods/get.dart';
import '../../../../core/api/methods/post.dart';
import '../models/my_chats_response_model.dart';


@injectable
class ChatRemoteDataSource{

  Future<MyContactsResponseModel> getContacts(){
    GetClient<MyContactsResponseModel> getContacts= GetClient<MyContactsResponseModel>(
      requestPrams: RequestConfig<MyContactsResponseModel>(
        endpoint: EndPoints.getMyContactsEP,
        response: ResponseValue<MyContactsResponseModel>(
          fromJson: (response)=> MyContactsResponseModel.fromJson(response)
        ),
      ),
    );
    return getContacts();
  }
  Future<bool> readAllMessages(Map<String,dynamic> params){
    GetClient<bool> readAllMessages= GetClient<bool>(
      requestPrams: RequestConfig<bool>(
        endpoint: EndPoints.readAllMessagesEP(params['id'].toString()),
        response: ResponseValue<bool>(
          returnValueOnSuccess: true
        ),
      ),
    );
    return readAllMessages();
  }
  Future<bool> receiveMessage(Map<String,dynamic> params){
    GetClient<bool> receiveMessage= GetClient<bool>(
      requestPrams: RequestConfig<bool>(
        endpoint: EndPoints.receiveMessageEP(params['id'].toString()),
        response: ResponseValue<bool>(
          returnValueOnSuccess: true
        ),
      ),
    );
    return receiveMessage();
  }

  Future<MyChatsResponseModel> getChats(){
    PostClient<MyChatsResponseModel> getChats= PostClient<MyChatsResponseModel>(
      requestPrams: RequestConfig<MyChatsResponseModel>(
        endpoint: EndPoints.getMyChatsEP,
        response: ResponseValue<MyChatsResponseModel>(
            fromJson: (response)=> MyChatsResponseModel.fromJson(response)
        ),
      ),
    );
    return getChats();
  }

  Future<ChangeChatPropertyModel> changeChatProperty(Map<String,dynamic> params){
    PostClient<ChangeChatPropertyModel> changeChatProperty= PostClient<ChangeChatPropertyModel>(
      requestPrams: RequestConfig<ChangeChatPropertyModel>(
        endpoint: EndPoints.setChatPropertyEP,
        data: params,
        response: ResponseValue<ChangeChatPropertyModel>(
            fromJson: (response)=> ChangeChatPropertyModel.fromJson(response)
        ),
      ),
    );
    return changeChatProperty();
  }
  Future<List<Message>> getMessagesForChat(Map<String,dynamic> params){
    PostClient<List<Message>> getMessagesForChat= PostClient<List<Message>>(
      requestPrams: RequestConfig<List<Message>>(
        endpoint: EndPoints.getMessagesForChatEP(params['params']),
        data: params['data'],
        response: ResponseValue<List<Message>>(
            fromJson: (response)=> List<Message>.from(
                response["data"]!.map((x) => Message.fromJson(x)))
        ),
      ),
    );
    return getMessagesForChat();
  }

  Future<List<Message>> getMessagesBetween(Map<String,dynamic> params){
    PostClient<List<Message>> getMessagesBetween= PostClient<List<Message>>(
      requestPrams: RequestConfig<List<Message>>(
        endpoint: EndPoints.getMessagesBetweenEP,
        data: params,
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
        response: ResponseValue<List<Message>>(
            fromJson: (response)=> List<Message>.from(
                response["data"]!.map((x) => Message.fromJson(x)))
        ),
      ),
    );
    return getMessagesBetween();
  }

  Future<UploadFileResponseModel> uploadFile(Map<String,dynamic> params){
    PostClient<UploadFileResponseModel> uploadFile= PostClient<UploadFileResponseModel>(
      requestPrams: RequestConfig<UploadFileResponseModel>(
        endpoint: EndPoints.uploadFileEP,
        data: params['data'],
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 5),
        response: ResponseValue<UploadFileResponseModel>(
            fromJson: (response)=> UploadFileResponseModel.fromJson(response)
        ),
      ),
    );
    return uploadFile();
  }

  Future<bool> saveContacts(Map<String,dynamic> params){
    PostClient<bool> saveContacts= PostClient<bool>(
      requestPrams: RequestConfig<bool>(
        endpoint: EndPoints.saveContactsEP,
        data: params,
        response: ResponseValue<bool>(
          returnValueOnSuccess: true
        ),
      ),
    );
    return saveContacts();
  }
  Future<bool> deleteChat(Map<String,dynamic> params){
    PostClient<bool> deleteChat= PostClient<bool>(
      requestPrams: RequestConfig<bool>(
        endpoint: EndPoints.deleteChatEP,
        data: params,
        response: ResponseValue<bool>(
          returnValueOnSuccess: true
        ),
      ),
    );
    return deleteChat();
  }
  Future<Message> sendMessage(Map<String,dynamic> params){
    PostClient<Message> sendMessage= PostClient<Message>(
      requestPrams: RequestConfig<Message>(
        endpoint: EndPoints.sendMessageEP,
        data: params,
        response: ResponseValue<Message>(
         fromJson: (response) => Message.fromJson(response['data'])
        ),
      ),
    );
    return sendMessage();
  }

  Future<LoginUserResponseModel> loginUser(Map<String,dynamic> params){
    PostClient<LoginUserResponseModel> loginUser= PostClient<LoginUserResponseModel>(
      requestPrams: RequestConfig<LoginUserResponseModel>(
        endpoint: EndPoints.loginEP,
        data: params,
        response: ResponseValue<LoginUserResponseModel>(
          fromJson: (response) => LoginUserResponseModel.fromJson(response)
        ),
      ),
    );
    return loginUser();
  }

  Future<CreateUserResponseModel> createUser(Map<String,dynamic> params){
    PostClient<CreateUserResponseModel> createUser= PostClient<CreateUserResponseModel>(
      requestPrams: RequestConfig<CreateUserResponseModel>(
        endpoint: EndPoints.createUserEP,
        data: params,
        response: ResponseValue<CreateUserResponseModel>(
          fromJson: (response) => CreateUserResponseModel.fromJson(response)
        ),
      ),
    );
    return createUser();
  }

}