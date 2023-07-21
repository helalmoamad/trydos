
import 'package:injectable/injectable.dart';
import 'package:trydos/features/authentication/data/models/store_fcm_token_response_model.dart';
import '../../../../common/constant/configuration/url_routes.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/methods/post.dart';
import '../models/create_user_response_model.dart';
import '../models/login_user_response_model.dart';

@injectable
class AuthRemoteDatasource {

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
  Future<bool> deleteFcmToken(Map<String,dynamic> params){
    PostClient<bool> deleteFcmToken= PostClient<bool>(
      requestPrams: RequestConfig<bool>(
        endpoint: EndPoints.deleteFcmEP(params['id']),
        data: params,
        response: ResponseValue<bool>(
            returnValueOnSuccess: true
        ),
      ),
    );
    return deleteFcmToken();
  }
  Future<StoreFcmTokenResponseModel> storeFcmToken(Map<String,dynamic> params){
    PostClient<StoreFcmTokenResponseModel> storeFcmToken= PostClient<StoreFcmTokenResponseModel>(
      requestPrams: RequestConfig<StoreFcmTokenResponseModel>(
        endpoint: EndPoints.storeFcmEP,
        data: params,
        response: ResponseValue<StoreFcmTokenResponseModel>(
            fromJson: (response)=> StoreFcmTokenResponseModel.fromJson(response)
        ),
      ),
    );
    return storeFcmToken();
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
