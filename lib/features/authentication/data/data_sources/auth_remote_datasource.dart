
import 'package:injectable/injectable.dart';
import '../../../../common/constant/configuration/url_routes.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/methods/post.dart';
import '../../../chat/data/models/create_user_response_model.dart';
import '../../../chat/data/models/login_user_response_model.dart';

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
