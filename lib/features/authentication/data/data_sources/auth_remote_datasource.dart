import 'package:injectable/injectable.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/features/authentication/data/models/login_to_stories_response_model.dart';
import 'package:trydos/features/authentication/data/models/store_fcm_token_response_model.dart';
import '../../../../common/constant/configuration/chat_url_routes.dart';
import '../../../../common/constant/configuration/stories_url_routes.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/methods/get.dart';
import '../../../../core/api/methods/post.dart';
import '../models/create_user_response_model.dart';
import '../models/get_user_country_response_model.dart';
import '../models/login_to_chat_response_model.dart';
import '../models/send_otp_response_model.dart';
import '../models/verify_guest_phone_response_model.dart';
import '../models/verify_otp_sign_up_and_in_response_model.dart';

@injectable
class AuthRemoteDatasource {
  Future<LoginToChatResponseModel> loginToChat(Map<String, dynamic> params) {
    PostClient<LoginToChatResponseModel> loginToChat =
        PostClient<LoginToChatResponseModel>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<LoginToChatResponseModel>(
        endpoint: ChatEndPoints.loginEP,
        data: params,
        response: ResponseValue<LoginToChatResponseModel>(
            fromJson: (response) =>
                LoginToChatResponseModel.fromJson(response)),
      ),
    );
    return loginToChat();
  }

  Future<bool> deleteFcmToken(Map<String, dynamic> params) {
    PostClient<bool> deleteFcmToken = PostClient<bool>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<bool>(
        endpoint: ChatEndPoints.deleteFcmEP(params['id']),
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return deleteFcmToken();
  }

  Future<StoreFcmTokenResponseModel> storeFcmToken(
      Map<String, dynamic> params) {
    PostClient<StoreFcmTokenResponseModel> storeFcmToken =
        PostClient<StoreFcmTokenResponseModel>(
      serverName: params['server_name'],
      requestPrams: RequestConfig<StoreFcmTokenResponseModel>(
        endpoint: params['server_name'] == ServerName.chat ? ChatEndPoints.storeFcmEP : MarketEndPoints.storeFcmEP,
        data: params['data'],
        response: ResponseValue<StoreFcmTokenResponseModel>(
            fromJson: (response) =>
                StoreFcmTokenResponseModel.fromJson(response)),
      ),
    );
    return storeFcmToken();
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

  Future<SendOtpResponseModel> sendOtp(Map<String, dynamic> params) {
    GetClient<SendOtpResponseModel> sendOtp = GetClient<SendOtpResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<SendOtpResponseModel>(
        endpoint: MarketEndPoints.sendOtpEP,
        queryParameters: params,
        response: ResponseValue<SendOtpResponseModel>(
            fromJson: (response) => SendOtpResponseModel.fromJson(response)),
      ),
    );
    return sendOtp();
  }

  Future<VerifyOtpSignUpAndInResponseModel> verifyOtpSignUp(
      Map<String, dynamic> params) {
    GetClient<VerifyOtpSignUpAndInResponseModel> verifyOtpSignUp =
        GetClient<VerifyOtpSignUpAndInResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
        endpoint: MarketEndPoints.verifyOtpSignUpEP,
        queryParameters: params,
        response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
            fromJson: (response) =>
                VerifyOtpSignUpAndInResponseModel.fromJson(response)),
      ),
    );
    return verifyOtpSignUp();
  }

  Future<User> getCustomerInfo() {
    GetClient<User> getCustomerInfo = GetClient<User>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<User>(
        endpoint: MarketEndPoints.getCustomerInfoEP,
        response: ResponseValue<User>(
            fromJson: (response) =>
                User.fromJson(response['data']['customer_info'])),
      ),
    );
    return getCustomerInfo();
  }

  Future<GetUserCountryResponseModel> getUserCountry() {
    ///// for test /////
    TestVariables.getUserCountryFlag = true;
    TestVariables.getUserCountryRequestCountFlag++;
    ////////////////////
    GetClient<GetUserCountryResponseModel> getUserCountry =
        GetClient<GetUserCountryResponseModel>(
      serverName: ServerName.location,
      requestPrams: RequestConfig<GetUserCountryResponseModel>(
        endpoint: '/json',
        response: ResponseValue<GetUserCountryResponseModel>(
            fromJson: (response) =>
                GetUserCountryResponseModel.fromJson(response)),
      ),
    );
    return getUserCountry();
  }

  Future<bool> updateName(Map<String, dynamic> params) {
    PostClient<bool> updateName = PostClient<bool>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<bool>(
        endpoint: MarketEndPoints.updateNameEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return updateName();
  }

  Future<bool> updateStoriesUser(Map<String, dynamic> params) {
    PostClient<bool> updateStoriesUser = PostClient<bool>(
      serverName: ServerName.stories,
      requestPrams: RequestConfig<bool>(
        endpoint: StoriesEndPoints.updateUserEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return updateStoriesUser();
  }

  Future<bool> updateChatUserName(Map<String, dynamic> params) {
    PostClient<bool> updateChatUserName = PostClient<bool>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<bool>(
        endpoint: ChatEndPoints.updateUserNameEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return updateChatUserName();
  }

  Future<VerifyOtpSignUpAndInResponseModel> verifyOtpSignIn(
      Map<String, dynamic> params) {
    GetClient<VerifyOtpSignUpAndInResponseModel> verifyOtpSignIn =
        GetClient<VerifyOtpSignUpAndInResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
        endpoint: MarketEndPoints.verifyOtpSignInEP,
        queryParameters: params,
        response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
            fromJson: (response) =>
                VerifyOtpSignUpAndInResponseModel.fromJson(response)),
      ),
    );
    return verifyOtpSignIn();
  }

  Future<VerifyGuestPhoneResponseModel> verifyGuestPhone(
      Map<String, dynamic> params) {
    PostClient<VerifyGuestPhoneResponseModel> verifyGuestPhone =
        PostClient<VerifyGuestPhoneResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<VerifyGuestPhoneResponseModel>(
        endpoint: MarketEndPoints.verifyGuestPhoneEP,
        data: params,
        response: ResponseValue<VerifyGuestPhoneResponseModel>(
            fromJson: (response) =>
                VerifyGuestPhoneResponseModel.fromJson(response)),
      ),
    );
    return verifyGuestPhone();
  }

  Future<VerifyOtpSignUpAndInResponseModel> loginToMarket(
      Map<String, dynamic> params) {
    PostClient<VerifyOtpSignUpAndInResponseModel> loginToMarket =
        PostClient<VerifyOtpSignUpAndInResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
        endpoint: MarketEndPoints.loginEP,
        data: params,
        response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
            fromJson: (response) =>
                VerifyOtpSignUpAndInResponseModel.fromJson(response)),
      ),
    );
    return loginToMarket();
  }

  Future<VerifyOtpSignUpAndInResponseModel> registerGuest(
      Map<String, dynamic> params) {
    PostClient<VerifyOtpSignUpAndInResponseModel> registerGuest =
        PostClient<VerifyOtpSignUpAndInResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
        endpoint: MarketEndPoints.registerGuestEP,
        data: params,
        response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
            fromJson: (response) =>
                VerifyOtpSignUpAndInResponseModel.fromJson(response)),
      ),
    );
    return registerGuest();
  }

  Future<LoginToStoriesResponseModel> loginToStories(
      Map<String, dynamic> params) {
    PostClient<LoginToStoriesResponseModel> loginToStories =
        PostClient<LoginToStoriesResponseModel>(
      serverName: ServerName.stories,
      requestPrams: RequestConfig<LoginToStoriesResponseModel>(
        endpoint: StoriesEndPoints.loginEP,
        data: params,
        response: ResponseValue<LoginToStoriesResponseModel>(
            fromJson: (response) =>
                LoginToStoriesResponseModel.fromJson(response)),
      ),
    );
    return loginToStories();
  }
}
