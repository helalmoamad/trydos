
import 'package:injectable/injectable.dart';
import 'package:trydos/features/chat/data/models/create_user_response_model.dart';
import 'package:trydos/features/chat/data/models/login_user_response_model.dart';
import 'package:trydos/features/chat/data/models/my_contacts_response_model.dart';

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

  Future<MyChatsResponseModel> getChats(){
    GetClient<MyChatsResponseModel> getChats= GetClient<MyChatsResponseModel>(
      requestPrams: RequestConfig<MyChatsResponseModel>(
        endpoint: EndPoints.getMyChatsEP,
        response: ResponseValue<MyChatsResponseModel>(
            fromJson: (response)=> MyChatsResponseModel.fromJson(response)
        ),
      ),
    );
    return getChats();
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
  Future<bool> sendMessage(Map<String,dynamic> params){
    PostClient<bool> sendMessage= PostClient<bool>(
      requestPrams: RequestConfig<bool>(
        endpoint: EndPoints.sendMessageEP,
        data: params,
        response: ResponseValue<bool>(
          returnValueOnSuccess: true
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