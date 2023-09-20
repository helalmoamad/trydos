
import 'package:injectable/injectable.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/features/authentication/data/models/store_fcm_token_response_model.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_response_model.dart';
import '../../../../common/constant/configuration/chat_url_routes.dart';
import '../../../../common/constant/configuration/stories_url_routes.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/methods/get.dart';
import '../../../../core/api/methods/post.dart';
import '../models/create_user_response_model.dart';
import '../models/login_user_response_model.dart';
import '../models/send_otp_response_model.dart';
import '../models/verify_guest_phone_response_model.dart';
import '../models/verify_otp_sign_up_and_in_response_model.dart';

@injectable
class AuthRemoteDatasource {

  Future<LoginUserResponseModel> loginUser(Map<String,dynamic> params){
    PostClient<LoginUserResponseModel> loginUser= PostClient<LoginUserResponseModel>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<LoginUserResponseModel>(
        endpoint: ChatEndPoints.loginEP,
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
      serverName: ServerName.chat,
      requestPrams: RequestConfig<bool>(
        endpoint: ChatEndPoints.deleteFcmEP(params['id']),
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
      serverName: ServerName.chat,
      requestPrams: RequestConfig<StoreFcmTokenResponseModel>(
        endpoint: ChatEndPoints.storeFcmEP,
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
      serverName: ServerName.chat,
      requestPrams: RequestConfig<CreateUserResponseModel>(
        endpoint: ChatEndPoints.createUserEP,
        data: params,
        response: ResponseValue<CreateUserResponseModel>(
            fromJson: (response) => CreateUserResponseModel.fromJson(response)
        ),
      ),
    );
    return createUser();
  }
  Future<SendOtpResponseModel> sendOtp(Map<String,dynamic> params){
    GetClient<SendOtpResponseModel> sendOtp= GetClient<SendOtpResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<SendOtpResponseModel>(
        endpoint: MarketEndPoints.sendOtpEP,
        queryParameters: params,
        response: ResponseValue<SendOtpResponseModel>(
            fromJson: (response) => SendOtpResponseModel.fromJson(response)
        ),
      ),
    );
    return sendOtp();
  }

  Future<VerifyOtpSignUpAndInResponseModel> verifyOtpSignUp(Map<String,dynamic> params){
    GetClient<VerifyOtpSignUpAndInResponseModel> verifyOtpSignUp= GetClient<VerifyOtpSignUpAndInResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
        endpoint: MarketEndPoints.verifyOtpSignUpEP,
        queryParameters: params,
        response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
            fromJson: (response) => VerifyOtpSignUpAndInResponseModel.fromJson(response)
        ),
      ),
    );
    return verifyOtpSignUp();
  }
  Future<VerifyOtpSignUpAndInResponseModel> verifyOtpSignIn(Map<String,dynamic> params){
    GetClient<VerifyOtpSignUpAndInResponseModel> verifyOtpSignIn= GetClient<VerifyOtpSignUpAndInResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
        endpoint: MarketEndPoints.verifyOtpSignInEP,
        queryParameters: params,
        response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
            fromJson: (response) => VerifyOtpSignUpAndInResponseModel.fromJson(response)
        ),
      ),
    );
    return verifyOtpSignIn();
  }
  Future<VerifyGuestPhoneResponseModel> verifyGuestPhone(Map<String,dynamic> params){
    PostClient<VerifyGuestPhoneResponseModel> verifyGuestPhone= PostClient<VerifyGuestPhoneResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<VerifyGuestPhoneResponseModel>(
        endpoint: MarketEndPoints.verifyGuestPhoneEP,
        data: params,
        response: ResponseValue<VerifyGuestPhoneResponseModel>(
            fromJson: (response) => VerifyGuestPhoneResponseModel.fromJson(response)
        ),
      ),
    );
    return verifyGuestPhone();
  }
  Future<LoginUserResponseModel> loginToStore(Map<String,dynamic> params){
    PostClient<LoginUserResponseModel> loginToStore= PostClient<LoginUserResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<LoginUserResponseModel>(
        endpoint: MarketEndPoints.loginEP,
        data: params,
        response: ResponseValue<LoginUserResponseModel>(
            fromJson: (response) => LoginUserResponseModel.fromJson(response)
        ),
      ),
    );
    return loginToStore();
  }
  Future<LoginUserResponseModel> loginToStories(Map<String,dynamic> params){
    PostClient<LoginUserResponseModel> loginToStories= PostClient<LoginUserResponseModel>(
      serverName: ServerName.stories,
      requestPrams: RequestConfig<LoginUserResponseModel>(
        endpoint: StoriesEndPoints.loginEP,
        data: params,
        response: ResponseValue<LoginUserResponseModel>(
            fromJson: (response) => LoginUserResponseModel.fromJson(response)
        ),
      ),
    );
    return loginToStories();
  }
}
