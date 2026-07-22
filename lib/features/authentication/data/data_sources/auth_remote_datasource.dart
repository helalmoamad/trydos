import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/common/constant/configuration/market_url_routes.dart';
import 'package:trydos/common/constant/configuration/wallet_url_routes.dart';
import 'package:trydos/common/constant/configuration/web_app_url.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/core/api/methods/detect_server.dart';
import 'package:trydos/features/authentication/data/models/login_to_stories_response_model.dart';
import 'package:trydos/features/authentication/data/models/login_to_wallet_model.dart';
import 'package:trydos/features/authentication/data/models/store_fcm_token_response_model.dart';
import 'package:trydos/features/authentication/data/models/verify_otp_response_model.dart';
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
import '../parsers/heavy_response_parsers.dart';

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
                  LoginToChatResponseModel.fromJson(response),
            ),
          ),
        );
    return loginToChat();
  }

  Future<bool> deleteFcmTokenFromChat(Map<String, dynamic> params) {
    PostClient<bool> deleteFcmTokenFromChat = PostClient<bool>(
      serverName: ServerName.chat,
      requestPrams: RequestConfig<bool>(
        endpoint: ChatEndPoints.deleteFcmEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return deleteFcmTokenFromChat();
  }

  Future<StoreFcmTokenResponseModel> storeFcmToken(
    Map<String, dynamic> params,
  ) {
    PostClient<StoreFcmTokenResponseModel> storeFcmToken =
        PostClient<StoreFcmTokenResponseModel>(
          serverName: params['server_name'],
          requestPrams: RequestConfig<StoreFcmTokenResponseModel>(
            endpoint: params['server_name'] == ServerName.chat
                ? ChatEndPoints.storeFcmEP
                : MarketEndPoints.storeFcmEP,
            data: params['data'],
            response: ResponseValue<StoreFcmTokenResponseModel>(
              fromJson: (response) =>
                  StoreFcmTokenResponseModel.fromJson(response),
            ),
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
              fromJson: (response) =>
                  CreateUserResponseModel.fromJson(response),
            ),
          ),
        );
    return createUser();
  }

  Future<SendOtpResponseModel> sendOtp(Map<String, dynamic> params) {
    PostClient<SendOtpResponseModel> sendOtp = PostClient<SendOtpResponseModel>(
      serverName: ServerName.market,
      requestPrams: RequestConfig<SendOtpResponseModel>(
        endpoint: MarketEndPoints.sendOtpEP,
        data: params,
        response: ResponseValue<SendOtpResponseModel>(
          fromJson: (response) => SendOtpResponseModel.fromJson(response),
        ),
      ),
    );
    return sendOtp();
  }

  Future<VerifyOtpSignUpAndInResponseModel> verifyOtpSignUp(
    Map<String, dynamic> params,
  ) {
    PostClient<VerifyOtpSignUpAndInResponseModel> verifyOtpSignUp =
        PostClient<VerifyOtpSignUpAndInResponseModel>(
          serverName: ServerName.market,
          requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
            endpoint: MarketEndPoints.verifyOtpSignUpEP,
            data: params,
            response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
              fromJson: (response) =>
                  VerifyOtpSignUpAndInResponseModel.fromJson(response),
            ),
          ),
        );
    return verifyOtpSignUp();
  }

  Future<VerifyOtpInProfileResponseModel> verifyOtpInProfile(
    Map<String, dynamic> params,
  ) {
    PostClient<VerifyOtpInProfileResponseModel> verifyOtpInProfile =
        PostClient<VerifyOtpInProfileResponseModel>(
          serverName: ServerName.market,
          requestPrams: RequestConfig<VerifyOtpInProfileResponseModel>(
            endpoint: MarketEndPoints.verifyOtpInProfileEP,
            data: params,
            response: ResponseValue<VerifyOtpInProfileResponseModel>(
              fromJson: (response) =>
                  VerifyOtpInProfileResponseModel.fromJson(response),
            ),
          ),
        );
    return verifyOtpInProfile();
  }

  Future<User> getCustomerInfo() async {
    // Build the model on a background isolate (see heavy_response_parsers.dart).
    GetClient<dynamic> getCustomerInfo = GetClient<dynamic>(
      serverName: ServerName.marketGO,
      requestPrams: RequestConfig<dynamic>(
        endpoint: MarketEndPoints.getCustomerInfoEP,
        response: ResponseValue<dynamic>(fromJson: (response) => response),
      ),
    );
    final raw = await getCustomerInfo();
    return parseCustomerInfoInBackground(raw);
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
            endpoint: '',
            response: ResponseValue<GetUserCountryResponseModel>(
              fromJson: (response) =>
                  GetUserCountryResponseModel.fromJson(response),
            ),
          ),
        );
    return getUserCountry();
  }

  Future<bool> updateName(Map<String, dynamic> params) {
    PostClient<bool> updateName = PostClient<bool>(
      serverName: ServerName.marketGO,
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
    Map<String, dynamic> params,
  ) {
    PostClient<VerifyOtpSignUpAndInResponseModel> verifyOtpSignIn =
        PostClient<VerifyOtpSignUpAndInResponseModel>(
          serverName: ServerName.market,
          requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
            endpoint: MarketEndPoints.verifyOtpSignInEP,
            data: params,
            response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
              fromJson: (response) =>
                  VerifyOtpSignUpAndInResponseModel.fromJson(response),
            ),
          ),
        );
    return verifyOtpSignIn();
  }

  Future<String> generateTokenForComment(Map<String, dynamic> params) {
    PostClient<String> generateTokenForComment = PostClient<String>(
      serverName: ServerName.get_comment_token,
      requestPrams: RequestConfig<String>(
        endpoint: WebAppEndPoints.generateTokenForCommentEP,
        data: params,
        response: ResponseValue<String>(
          fromJson: (response) => response['comments_token'].toString(),
        ),
      ),
    );
    return generateTokenForComment();
  }

  Future<VerifyOtpFromGuestResponseModel> verifyOtpFromGuest(
    Map<String, dynamic> params,
  ) {
    PostClient<VerifyOtpFromGuestResponseModel> verifyOtpFromGuest =
        PostClient<VerifyOtpFromGuestResponseModel>(
          serverName: ServerName.market,
          requestPrams: RequestConfig<VerifyOtpFromGuestResponseModel>(
            endpoint: MarketEndPoints.verifyOtpFromGuestEP,
            data: params,
            response: ResponseValue<VerifyOtpFromGuestResponseModel>(
              fromJson: (response) =>
                  VerifyOtpFromGuestResponseModel.fromJson(response),
            ),
          ),
        );
    return verifyOtpFromGuest();
  }

  Future<VerifyOtpSignUpAndInResponseModel> loginToMarket(
    Map<String, dynamic> params,
  ) {
    PostClient<VerifyOtpSignUpAndInResponseModel> loginToMarket =
        PostClient<VerifyOtpSignUpAndInResponseModel>(
          serverName: ServerName.market,
          requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
            endpoint: MarketEndPoints.loginEP,
            data: params,
            response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
              fromJson: (response) =>
                  VerifyOtpSignUpAndInResponseModel.fromJson(response),
            ),
          ),
        );
    return loginToMarket();
  }

  Future<VerifyOtpSignUpAndInResponseModel> registerGuest(
    Map<String, dynamic> params,
  ) {
    PostClient<VerifyOtpSignUpAndInResponseModel> registerGuest =
        PostClient<VerifyOtpSignUpAndInResponseModel>(
          serverName: ServerName.market,
          requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
            endpoint: MarketEndPoints.registerGuestEP,
            data: params,
            response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
              fromJson: (response) =>
                  VerifyOtpSignUpAndInResponseModel.fromJson(response),
            ),
          ),
        );
    return registerGuest();
  }

  Future<LoginToStoriesResponseModel> loginToStories(
    Map<String, dynamic> params,
  ) {
    PostClient<LoginToStoriesResponseModel> loginToStories =
        PostClient<LoginToStoriesResponseModel>(
          serverName: ServerName.stories,
          requestPrams: RequestConfig<LoginToStoriesResponseModel>(
            endpoint: StoriesEndPoints.loginEP,
            data: params,
            response: ResponseValue<LoginToStoriesResponseModel>(
              fromJson: (response) =>
                  LoginToStoriesResponseModel.fromJson(response),
            ),
          ),
        );
    return loginToStories();
  }

  Future<LoginToWalletModel> loginToWallet(Map<String, dynamic> params) {
    PostClient<LoginToWalletModel> loginToWallet =
        PostClient<LoginToWalletModel>(
          serverName: ServerName.wallet,
          requestPrams: RequestConfig<LoginToWalletModel>(
            endpoint: WalletEndPoints.loginWithIdTokenEP,
            data: params,
            extraHeaders: {
              'x-merchant-api-key': dotenv.env['Public_Api_Key'] ?? '',
            },
            response: ResponseValue<LoginToWalletModel>(
              fromJson: (response) => LoginToWalletModel.fromJson(response),
            ),
          ),
        );
    return loginToWallet();
  }

  Future<bool> createWallet() {
    PostClient<bool> createWallet = PostClient<bool>(
      serverName: ServerName.wallet,
      requestPrams: RequestConfig<bool>(
        endpoint: WalletEndPoints.createWalletEP,
        data: {"name": "Primary Funding Wallet"},
        queryParameters: {"subtype": "MAIN"},
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return createWallet();
  }
}
