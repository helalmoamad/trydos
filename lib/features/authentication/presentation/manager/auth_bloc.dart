import 'package:flutter/foundation.dart' hide Category;
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/error/error_manager.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/authentication/data/models/get_user_country_response_model.dart';
import 'package:trydos/features/authentication/domain/use_cases/create_wallet_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/delete_fcm_from_chat_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/generating_token_for_comment.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_otp_in_profile_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/get_user_country_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/register_guest_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/send_otp_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/store_fcm_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/update_chat_user_name_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/update_name_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/update_stories_user_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_guest_phone_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_otp_signin_usecase.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/dashBoard/presentation/bloc/dashBoard_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import '../../../../common/helper/show_message.dart';
import '../../../../core/api/methods/detect_server.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../main.dart';
import '../../domain/use_cases/login_to_wallet_usecase.dart';
import '../../../../service/notification_service/notification_service/handle_notification/notification_process.dart';
import '../../../chat/presentation/manager/chat_event.dart';
import '../../../home/presentation/manager/homeBloc/home_event.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../../domain/use_cases/create_user_usecase.dart';
import '../../domain/use_cases/get_customer_info_usecase.dart';
import '../../domain/use_cases/login_to_chat_usecase.dart';
import '../../domain/use_cases/login_to_stories_usecase.dart';
import '../../domain/use_cases/verify_otp_signup_usecase.dart';
part 'auth_event.dart';

part 'auth_state.dart';

const throttleDuration = Duration(minutes: 2);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@LazySingleton()
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this.updateStoriesUserUseCase,
    this.updateChatUserNameUseCase,
    this.createUserUseCase,
    this.loginToChatUseCase,
    this.loginToStoriesUseCase,
    this.storeFcmUseCase,
    this.verifyOtpInProfileUseCase,
    this.updateNameUseCase,
    this.registerGuestUseCase,
    this.createWalletUseCase,

    this.loginToWalletUseCase,
    this.generateTokenForCommentUseCase,
    this.sendOtpUseCase,
    this.getCustomerInfoUseCase,
    this.verifyOtpFromGuestUseCase,
    this.verifyOtpSignInUseCase,
    this.getUserCountryUseCase,
    this.deleteFcmFromChatUseCase,
    this.verifyOtpSignUpUseCase,
  ) : super(const AuthState()) {
    on<AuthEvent>((event, emit) {});
    on<CreateUserEvent>(
      _onCreateUserEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UpdateStoriesUserEvent>(
      _onUpdateStoriesUserEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UpdateChatUserNameEvent>(
      _onUpdateChatUserNameEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<LoginToChatEvent>(
      _onLoginToChatEvent,
      transformer: throttleDroppable(const Duration(seconds: 10)),
    );
    on<LoginToStoriesEvent>(
      _onLoginToStoriesEvent,
      transformer: throttleDroppable(const Duration(seconds: 10)),
    );
    on<LoginToWalletEvent>(
      _onLoginToWalletEvent,
      transformer: throttleDroppable(const Duration(seconds: 10)),
    );
    on<StoreFcmTokenEvent>(_onStoreFcmTokenEvent);
    on<SendOtpEvent>(
      _onSendOtpEvent,
      transformer: throttleDroppable(const Duration(seconds: 10)),
    );
    on<VerifyOtpSignInEvent>(_onVerifyOtpSignInEvent);
    on<VerifyOtpInProfileEvent>(_onVerifyOtpInProfileEvent);
    on<DeleteFcmTokenFromChatEvent>(_onDeleteFcmTokenFromChatEvent);
    on<VerifyOtpSignUpEvent>(_onVerifyOtpSignUpEvent);
    on<VerifyOtpFromGuestEvent>(_onVerifyGuestPhoneEvent);
    on<RegisterGuestEvent>(
      _onRegisterGuestEvent,
      transformer: throttleDroppable(const Duration(seconds: 5)),
    );
    on<UpdateNameEvent>(
      _onUpdateNameEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<GetCustomerInfoEvent>(
      _onGetCustomerInfoEvent,
      transformer: restartable(),
    );
    on<GetUserCountryEvent>(
      _onGetUserCountryEvent,
      //transformer: throttleDroppable(throttleDuration)
    );
    on<CreateWalletEvent>(_onCreateWalletEvent);

    on<GenerateTokenForCommentEvent>(_onGenerateTokenForCommentEvent);
  }

  final LoginToChatUseCase loginToChatUseCase;
  final LoginToStoriesUseCase loginToStoriesUseCase;
  final CreateUserUseCase createUserUseCase;
  final StoreFcmUseCase storeFcmUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final GeneratingTokenForCommentUseCase generateTokenForCommentUseCase;
  final VerifyOtpSignInUseCase verifyOtpSignInUseCase;
  final VerifyOtpSignUpUseCase verifyOtpSignUpUseCase;
  final CreateWalletUseCase createWalletUseCase;

  final VerifyOtpFromGuestUseCase verifyOtpFromGuestUseCase;
  final RegisterGuestUseCase registerGuestUseCase;
  final UpdateNameUseCase updateNameUseCase;
  final LoginToWalletUseCase loginToWalletUseCase;
  final DeleteFcmFromChatUseCase deleteFcmFromChatUseCase;
  final GetCustomerInfoUseCase getCustomerInfoUseCase;
  final GetUserCountryUseCase getUserCountryUseCase;
  final VerifyOtpInProfileUseCase verifyOtpInProfileUseCase;
  final UpdateStoriesUserUseCase updateStoriesUserUseCase;
  final UpdateChatUserNameUseCase updateChatUserNameUseCase;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  FutureOr<void> _onCreateUserEvent(
    CreateUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(createUserStatus: CreateUserStatus.loading));

    final response = await createUserUseCase(
      CreateUserParams(
        mobilePhone: event.mobilePhone,
        password: event.password,
        name: event.name,
      ),
    );
    response.fold(
      (l) => emit(state.copyWith(createUserStatus: CreateUserStatus.failure)),
      (r) {
        emit(state.copyWith(createUserStatus: CreateUserStatus.success));
      },
    );
  }

  FutureOr<void> _onLoginToChatEvent(
    LoginToChatEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(loginToChatStatus: LoginToChatStatus.loading));

    final response = await loginToChatUseCase(
      LoginToChatParams(
        mobilePhone: event.mobilePhone,
        otpIdToken: event.otpIdToken,
        name: event.name,
        originalUserId: event.originalUserId,
      ),
    );
    await response.fold(
      (l) {
        if (ErrorManager.shouldRetry('LoginToChatEvent', l.statusCode)) {
          add(
            LoginToChatEvent(
              mobilePhone: event.mobilePhone,
              otpIdToken: event.otpIdToken,
              name: event.name,
              fcmToken: event.fcmToken,
              originalUserId: event.originalUserId,
            ),
          );
          ErrorManager.incrementRetry('LoginToChatEvent');
        }
        emit(state.copyWith(loginToChatStatus: LoginToChatStatus.failure));
        showMessage(
          "fail to log in to chat",
          foreGroundColor: Colors.white,
          hasError: true,
          backGroundColor: Colors.black,
          showInRelease: true,
        );
        _prefsRepository.setLogInToChat(false);
      },
      (r) async {
        _prefsRepository.setLogInToChat(true);
        ErrorManager.resetRetry('LoginToChatEvent');
        final id = r.data!.id;
        final token = r.data!.accessToken;
        final name = r.data!.name;
        final photo = r.data!.photoPath;
        final checkToken = token?.isNotEmpty ?? false;
        GetIt.I<ChatBloc>().add(
          UpdateProfileInChatEvent(
            userId: _prefsRepository.myMarketId.toString(),
            name: _prefsRepository.myMarketName ?? "",
            photo: _prefsRepository.myProfilePhoto ?? "",
            phone: r.data?.mobilePhone ?? "",
          ),
        );
        if (checkToken) {
          await _prefsRepository.setChatToken(token!);
          await _prefsRepository.setMyChatId(id!);
          await _prefsRepository.setMyChatName(name ?? 'No Name');
          await _prefsRepository.setMyChatPhoto(photo);
        }
        emit(state.copyWith(loginToChatStatus: LoginToChatStatus.success));
        NotificationProcess().fcmToken(null, null, null, null);

        apisMustNotToRequest.remove('GetChatsEvent');
        GetIt.I<ChatBloc>().add(const GetChatsEvent(limit: 10));
      },
    );
  }

  FutureOr<void> _onDeleteFcmTokenFromChatEvent(
    DeleteFcmTokenFromChatEvent event,
    Emitter<AuthState> emit,
  ) async {
    await deleteFcmFromChatUseCase(DeleteFcmParams(fcmToken: event.fcmToken));
  }

  FutureOr<void> _onStoreFcmTokenEvent(
    StoreFcmTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (event.serverName == ServerName.chat &&
        (_prefsRepository.chatToken?.length ?? 0) < 7) {
      return;
    }
    if (event.serverName == ServerName.stories &&
        (_prefsRepository.storiesToken?.length ?? 0) < 7) {
      return;
    }
    final response = await storeFcmUseCase(
      StoreFcmParams(
        userId: event.userId,
        fcmToken: event.fcmToken,
        serverName: event.serverName,
      ),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('StoreFcmTokenEvent', l.statusCode)) {
          add(
            StoreFcmTokenEvent(
              userId: event.userId,
              fcmToken: event.fcmToken,
              serverName: event.serverName,
            ),
          );
          ErrorManager.incrementRetry('StoreFcmTokenEvent');
        }
        if (event.serverName == ServerName.chat) {
          emit(state.copyWith(loginToChatStatus: LoginToChatStatus.failure));
        }
      },
      (r) {
        ErrorManager.resetRetry('StoreFcmTokenEvent');
        final id = r.data!.id;
        _prefsRepository.setFcmTokenId(id!);
        if (event.serverName == ServerName.chat) {
          emit(state.copyWith(loginToChatStatus: LoginToChatStatus.success));
        }
      },
    );
  }

  FutureOr<void> _onSendOtpEvent(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    _prefsRepository.clearVerificationId();
    emit(state.copyWith(sendOtpStatus: SendOtpStatus.loading));
    final response = await sendOtpUseCase(
      SendOtpParams(isViaWhatsApp: event.isViaWhatsApp, phone: event.phone),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('SendOtpEvent', l.statusCode)) {
          add(
            SendOtpEvent(
              isViaWhatsApp: event.isViaWhatsApp,
              phone: event.phone,
            ),
          );
          ErrorManager.incrementRetry('SendOtpEvent');
        }
        emit(
          state.copyWith(
            sendOtpStatus: SendOtpStatus.failure,
            sendOtpError: 'please wait some seconds and try again',
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('SendOtpEvent');
        _prefsRepository.setVerificationId(r.data!.verificationId!);
        emit(state.copyWith(sendOtpStatus: SendOtpStatus.success));
      },
    );
  }

  FutureOr<void> _onVerifyGuestPhoneEvent(
    VerifyOtpFromGuestEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        verifyOtpFromGuestStatus: VerifyOtpFromGuestStatus.loading,
      ),
    );
    final response = await verifyOtpFromGuestUseCase(
      VerifyOtpFromGuestParams(
        otp: event.otp,
        verificationId: event.verificationId,
      ),
    );
    await response.fold(
      (l) {
        if (ErrorManager.shouldRetry('VerifyOtpFromGuestEvent', l.statusCode)) {
          add(
            VerifyOtpFromGuestEvent(
              otp: event.otp,
              verificationId: event.verificationId,
            ),
          );
          ErrorManager.incrementRetry('VerifyOtpFromGuestEvent');
        }
        emit(
          state.copyWith(
            verifyOtpFromGuestStatus: VerifyOtpFromGuestStatus.failure,
          ),
        );
      },
      (r) async {
        ErrorManager.resetRetry('VerifyOtpFromGuestEvent');
        try {
          if ((r.data!.user?.name?.replaceAll(' ', '') ?? '') != '') {
            await _prefsRepository.setMyMarketName(r.data!.user!.name!);
          }

          await _prefsRepository.setMyMarketId(r.data!.user!.id.toString());
          await _prefsRepository.setMarketToken(r.data?.token.toString());

          Future.delayed(const Duration(seconds: 30), () {
            if (kDebugMode) print("#########33333333332");
            _prefsRepository.setTokenExpired(false);
          });
          GetIt.I<HomeBloc>().add(
            SaveUserInfoFromAuthEvent(userInfo: r.data!.user!),
          );
          _prefsRepository.setVerifiedPhone(r.data?.user?.isPhoneVerified == 1);
          _prefsRepository.setPhoneNumber((r.data?.user?.phone).toString());
          _prefsRepository.setMyProfilePhoto(
            (r.data?.user?.image ?? "").toString(),
          );
          GetIt.I<HomeBloc>().add(GetCurrencyForCountryEvent());
          GetIt.I<HomeBloc>().add(const GetCartItemEvent());
          GetIt.I<HomeBloc>().add(const GetOldCartItemEvent());
          //GetIt.I<HomeBloc>().add(GetProductsListInCartEvent());

          add(
            LoginToStoriesEvent(
              name: r.data!.user?.name,
              originalUserId: r.data!.user?.id.toString(),
              otpIdToken: r.data?.idToken,
              phone: r.data?.user?.phone,
            ),
          );
          /* add(
            LoginToWalletEvent(
              otpIdToken: r.data?.idToken,
              name: r.data?.user?.name,
              phone: r.data?.user?.phone,
            ),
          );*/
          add(
            GenerateTokenForCommentEvent(
              mobilePhone: r.data?.user?.phone,
              otpIdToken: r.data?.idToken,
              userId: r.data!.user?.id.toString(),
            ),
          );
        } catch (error) {
          showMessage(error.toString(), hasError: true);
        }
        debugPrint(
          'login _prefsRepository.chatToken${_prefsRepository.chatToken}',
        );
        debugPrint(
          'login _prefsRepository.marketToken${_prefsRepository.marketToken}',
        );
        debugPrint(
          'login _prefsRepository.storiesToken${_prefsRepository.storiesToken}',
        );

        emit(
          state.copyWith(
            verifyOtpFromGuestStatus: VerifyOtpFromGuestStatus.success,
          ),
        );
        await NotificationProcess().fcmToken(
          r.data?.user?.phone,
          r.data!.user?.name,
          r.data!.user?.id.toString(),
          r.data!.user?.lastOtpIdToken,
        );
      },
    );
  }

  //todo _onLoginToStoriesEvent
  FutureOr<void> _onLoginToStoriesEvent(
    LoginToStoriesEvent event,
    Emitter<AuthState> emit,
  ) async {
    GetIt.I<DashboardBloc>().add(GetUserPermissionEvent());
    emit(state.copyWith(loginToStoriesStatus: LoginToStoriesStatus.loading));

    final response = await loginToStoriesUseCase(
      LoginToStoriesParams(
        phone: event.phone,
        name: event.name,
        otpIdToken: event.otpIdToken,
        originalUserId: event.originalUserId,
      ),
    );
    await response.fold(
      (l) {
        if (ErrorManager.shouldRetry('LoginToStoriesEvent', l.statusCode)) {
          add(
            LoginToStoriesEvent(
              phone: event.phone,
              name: event.name,
              otpIdToken: event.otpIdToken,
              originalUserId: event.originalUserId,
            ),
          );
          ErrorManager.incrementRetry('LoginToStoriesEvent');
        }
        emit(
          state.copyWith(loginToStoriesStatus: LoginToStoriesStatus.failure),
        );
      },
      (r) async {
        emit(
          state.copyWith(loginToStoriesStatus: LoginToStoriesStatus.success),
        );
        ErrorManager.resetRetry('LoginToStoriesEvent');

        final id = r.data!.id;
        final token = r.data!.accessToken;
        final checkToken = token?.isNotEmpty ?? false;
        final name = r.data!.name;
        if (checkToken) {
          await _prefsRepository.setStoriesToken(token!);
          await _prefsRepository.setMyStoriesId(id!);
          await _prefsRepository.setMyStoriesName(name ?? 'No Name');
        }
        NotificationProcess().fcmToken(null, null, null, null);
        apisMustNotToRequest.remove('GetStoryEvent');
        GetIt.I<StoryBloc>().add(const GetStoryEvent(withPaginition: false));
      },
    );
  }

  FutureOr<void> _onLoginToWalletEvent(
    LoginToWalletEvent event,
    Emitter<AuthState> emit,
  ) async {
    final response = await loginToWalletUseCase(
      LoginToWalletParams(
        otpIdToken: event.otpIdToken,
        phone: event.phone,
        name: event.name,
      ),
    );
    await response.fold(
      (l) {
        if (ErrorManager.shouldRetry('LoginToWalletEvent', l.statusCode)) {
          add(
            LoginToWalletEvent(
              otpIdToken: event.otpIdToken,
              phone: event.phone,
              name: event.name,
            ),
          );
          ErrorManager.incrementRetry('LoginToWalletEvent');
        }
      },
      (r) async {
        await _prefsRepository.setWalletToken(r.accessToken?.token ?? "");
        add(CreateWalletEvent());

        ErrorManager.resetRetry('LoginToWalletEvent');
      },
    );
  }

  FutureOr<void> _onCreateWalletEvent(
    CreateWalletEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (_prefsRepository.isCreateWallet ?? false) {
      GetIt.I<HomeBloc>().add(GetCurrenciesForWalletEvent());
      return;
    }
    final response = await createWalletUseCase(NoParams());
    await response.fold(
      (l) {
        if (l.statusCode == 409) {
          _prefsRepository.setIsCearteWallet(true);
          GetIt.I<HomeBloc>().add(GetCurrenciesForWalletEvent());
          return;
        }
        if (ErrorManager.shouldRetry('CreateWalletEvent', l.statusCode)) {
          add(CreateWalletEvent());
          ErrorManager.incrementRetry('CreateWalletEvent');
          return;
        }
        GetIt.I<HomeBloc>().add(GetCurrenciesForWalletEvent());
      },
      (r) {
        _prefsRepository.setIsCearteWallet(true);
        ErrorManager.resetRetry('CreateWalletEvent');
        GetIt.I<HomeBloc>().add(GetCurrenciesForWalletEvent());
      },
    );
  }

  FutureOr<void> _onVerifyOtpInProfileEvent(
    VerifyOtpInProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        verifyOtpInProfileStatus: VerifyOtpInProfileStatus.loading,
      ),
    );

    final response = await verifyOtpInProfileUseCase(
      VerifyOtpInProfileParams(
        verificationId: event.verificationId,
        otp: event.otp,
      ),
    );
    await response.fold(
      (l) {
        if (ErrorManager.shouldRetry('VerifyOtpInProfileEvent', l.statusCode)) {
          add(
            VerifyOtpInProfileEvent(
              verificationId: event.verificationId,
              otp: event.otp,
            ),
          );
          ErrorManager.incrementRetry('VerifyOtpInProfileEvent');
        }
        emit(
          state.copyWith(
            verifyOtpInProfileStatus: VerifyOtpInProfileStatus.failure,
            signInErrorMessage: l.message,
          ),
        );
      },
      (r) async {
        ErrorManager.resetRetry('VerifyOtpInProfileEvent');
        _prefsRepository.setIdToken((r.data!.idToken).toString());
        emit(
          state.copyWith(
            verifyOtpInProfileStatus: VerifyOtpInProfileStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onVerifyOtpSignInEvent(
    VerifyOtpSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(verifyOtpSignInStatus: VerifyOtpSignInStatus.loading));

    final response = await verifyOtpSignInUseCase(
      VerifyOtpSignInParams(
        verificationId: event.verificationId,
        otp: event.otp,
      ),
    );
    await response.fold(
      (l) {
        if (ErrorManager.shouldRetry('VerifyOtpSignInEvent', l.statusCode)) {
          add(
            VerifyOtpSignInEvent(
              verificationId: event.verificationId,
              otp: event.otp,
              phone: event.phone,
            ),
          );
          ErrorManager.incrementRetry('VerifyOtpSignInEvent');
        }
        emit(
          state.copyWith(
            verifyOtpSignInStatus: VerifyOtpSignInStatus.failure,
            signInErrorMessage: l.message,
          ),
        );
      },
      (r) async {
        ErrorManager.resetRetry('VerifyOtpSignInEvent');
        try {
          await _prefsRepository.setMyMarketId(r.data!.user!.id.toString());
          if ((r.data!.user!.name?.replaceAll(' ', '') ?? '') != '') {
            await _prefsRepository.setMyMarketName(r.data!.user!.name!);
          }

          await _prefsRepository.setMarketToken(r.data!.token!);
          await _prefsRepository.setTokenExpired(false);
          await _prefsRepository.setIdToken((r.data!.idToken).toString());
          GetIt.I<HomeBloc>().add(
            SaveUserInfoFromAuthEvent(userInfo: r.data!.user!),
          );
          GetIt.I<HomeBloc>().add(GetCurrencyForCountryEvent());
          GetIt.I<HomeBloc>().add(const GetCartItemEvent());
          GetIt.I<HomeBloc>().add(const GetOldCartItemEvent());
          // GetIt.I<HomeBloc>().add(GetProductsListInCartEvent());
          _prefsRepository.setMyMarketId(r.data!.user!.id.toString());
          if (kDebugMode)
            print(
              "*****************************-----------------------------${r.data!.token!}",
            );
          await _prefsRepository.setVerifiedPhone(
            r.data!.user?.isPhoneVerified == 1,
          );
          await _prefsRepository.setPhoneNumber(
            (r.data!.user?.phone).toString(),
          );
          await _prefsRepository.setMyProfilePhoto(
            (r.data?.user?.image ?? "").toString(),
          );
          NotificationProcess().fcmToken(
            r.data!.user!.phone,
            r.data!.user!.name,
            r.data!.user!.id!.toString(),
            r.data!.idToken,
          );
          ////////////////////////
          FirebaseAnalytics.instance.setUserId(id: r.data!.user!.id.toString());

          FirebaseAnalytics.instance.setUserId(id: "12345");

          FirebaseAnalytics.instance.setUserProperty(
            name: 'gender',
            value: r.data!.user!.gender.toString(),
          );

          FirebaseAnalytics.instance.setUserProperty(
            name: 'user_type',
            value: 'registered',
          );
          ///////////////////////
          add(
            LoginToStoriesEvent(
              originalUserId: r.data!.user!.id!.toString(),
              otpIdToken: r.data!.idToken!,
              name: r.data!.user!.name,
              phone: r.data!.user!.phone,
            ),
          );
          /*add(
            LoginToWalletEvent(
              otpIdToken: r.data?.idToken,
              name: r.data?.user?.name,
              phone: r.data?.user?.phone,
            ),
          );*/
          add(
            GenerateTokenForCommentEvent(
              mobilePhone: r.data?.user?.phone,
              otpIdToken: r.data?.idToken,
              userId: r.data!.user?.id.toString(),
            ),
          );
        } catch (error) {
          showMessage(error.toString(), hasError: true);
        }
        debugPrint(
          'login _prefsRepository.chatToken${_prefsRepository.chatToken}',
        );
        debugPrint(
          'login _prefsRepository.marketToken${_prefsRepository.marketToken}',
        );
        debugPrint(
          'login _prefsRepository.storiesToken${_prefsRepository.storiesToken}',
        );
        if (!r.data!.alreadyExist!) {
          emit(
            state.copyWith(
              verifyOtpSignInStatus: VerifyOtpSignInStatus.failure,
              marketUser: r.data!.user,
              signInErrorMessage: 'auth-001',
            ),
          );

          return;
        }

        emit(
          state.copyWith(
            verifyOtpSignInStatus: VerifyOtpSignInStatus.success,
            marketUser: r.data!.user,
          ),
        );
      },
    );
  }

  FutureOr<void> _onVerifyOtpSignUpEvent(
    VerifyOtpSignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(verifyOtpSignUpStatus: VerifyOtpSignUpStatus.loading));
    final response = await verifyOtpSignUpUseCase(
      VerifyOtpSignUpParams(
        verificationId: event.verificationId,
        otp: event.otp,
        name: event.name,
      ),
    );
    await response.fold(
      (l) {
        if (ErrorManager.shouldRetry('VerifyOtpSignUpEvent', l.statusCode)) {
          add(
            VerifyOtpSignUpEvent(
              verificationId: event.verificationId,
              otp: event.otp,
              name: event.name,
            ),
          );
          ErrorManager.incrementRetry('VerifyOtpSignUpEvent');
        }
        emit(
          state.copyWith(
            signUpErrorMessage: 'faild',
            verifyOtpSignUpStatus: VerifyOtpSignUpStatus.failure,
          ),
        );
      },
      (r) async {
        ErrorManager.resetRetry('VerifyOtpSignUpEvent');
        if ((r.data!.user!.name?.replaceAll(' ', '') ?? '') != '') {
          await _prefsRepository.setMyMarketName(r.data!.user!.name!);
        }
        GetIt.I<HomeBloc>().add(
          SaveUserInfoFromAuthEvent(userInfo: r.data!.user!),
        );
        await _prefsRepository.setOtpCode(event.otp);
        await _prefsRepository.setMarketToken(r.data!.token!);
        await _prefsRepository.setTokenExpired(false);

        //////////////////////////////////////
        FirebaseAnalytics.instance.setUserId(id: r.data!.user!.id.toString());
        FirebaseAnalytics.instance.setUserId(id: "12345");

        FirebaseAnalytics.instance.setUserProperty(
          name: 'gender',
          value: r.data!.user!.gender.toString(),
        );

        FirebaseAnalytics.instance.setUserProperty(
          name: 'user_type',
          value: 'new',
        );
        /////////////////////////////////////
        GetIt.I<HomeBloc>().add(GetCurrencyForCountryEvent());
        GetIt.I<HomeBloc>().add(const GetCartItemEvent());
        GetIt.I<HomeBloc>().add(const GetOldCartItemEvent());
        //  GetIt.I<HomeBloc>().add(GetProductsListInCartEvent());
        ;
        await _prefsRepository.setIdToken((r.data!.idToken).toString());
        await _prefsRepository.setMyMarketId(r.data!.user!.id.toString());
        //    print(
        //    "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd${r.data!.user?.isPhoneVerified}");

        await _prefsRepository.setVerifiedPhone(
          r.data!.user?.isPhoneVerified == 1,
        );
        await _prefsRepository.setPhoneNumber((r.data!.user?.phone).toString());
        await _prefsRepository.setMyProfilePhoto(
          (r.data?.user?.image ?? "").toString(),
        );
        NotificationProcess().fcmToken(
          r.data!.user!.phone,
          r.data!.user!.name,
          r.data!.user!.id!.toString(),
          r.data!.idToken,
        );
        add(
          LoginToStoriesEvent(
            originalUserId: r.data!.user!.id!.toString(),
            otpIdToken: r.data!.idToken!,
            name: r.data!.user!.name,
            phone: r.data!.user!.phone,
          ),
        );
        /* add(
          LoginToWalletEvent(
            otpIdToken: r.data?.idToken,
            name: r.data?.user?.name,
            phone: r.data?.user?.phone,
          ),
        );*/
        add(
          GenerateTokenForCommentEvent(
            mobilePhone: r.data?.user?.phone,
            otpIdToken: r.data?.idToken,
            userId: r.data!.user?.id.toString(),
          ),
        );

        if (r.data!.alreadyExist!) {
          emit(
            state.copyWith(
              verifyOtpSignUpStatus: VerifyOtpSignUpStatus.failure,
              marketUser: r.data!.user,
              signUpErrorMessage: 'auth-001',
            ),
          );

          return;
        }

        emit(
          state.copyWith(
            verifyOtpSignUpStatus: VerifyOtpSignUpStatus.success,
            marketUser: r.data!.user,
          ),
        );
      },
    );
  }

  FutureOr<void> _onRegisterGuestEvent(
    RegisterGuestEvent event,
    Emitter<AuthState> emit,
  ) async {
    _prefsRepository.clearTokenForMarket();
    _prefsRepository.clearTokensForChatAndStory();

    emit(state.copyWith(registerGuestStatus: RegisterGuestStatus.loading));
    final response = await registerGuestUseCase(
      RegisterGuestParams(
        deviceId: event.deviceId,
        oldGuestUserId: event.oldGuestUserId,
      ),
    );
    bool? previousStatusOfIsVerifiedPhone =
        _prefsRepository.isVerifiedPhone ?? false;
    if ((event.oldGuestUserId?.length ?? 0) == 0) {
      _prefsRepository.setIsCearteWallet(false);
    }

    _prefsRepository.setVerifiedPhone(false);
    await response.fold(
      (l) {
        _prefsRepository.setVerifiedPhone(previousStatusOfIsVerifiedPhone);
        if (ErrorManager.shouldRetry('RegisterGuestEvent', l.statusCode)) {
          add(
            RegisterGuestEvent(
              deviceId: event.deviceId,
              oldGuestUserId: event.oldGuestUserId,
            ),
          );
          ErrorManager.incrementRetry('RegisterGuestEvent');
        }
        emit(state.copyWith(registerGuestStatus: RegisterGuestStatus.failure));
      },
      (r) async {
        emit(
          state.copyWith(
            registerGuestStatus: RegisterGuestStatus.success,
            marketUser: r.data!.user,
          ),
        );
        Future.delayed(const Duration(minutes: 2), () {
          _prefsRepository.setTokenExpired(false);
        });
        ErrorManager.resetRetry('RegisterGuestEvent');
        await _prefsRepository.setMarketToken(r.data!.token!);
        await _prefsRepository.setMyProfilePhoto(
          (r.data?.user?.image ?? "").toString(),
        );
        await _prefsRepository.setMyMarketName(r.data!.user!.name ?? "guest");

        //////////////////////////////////////
        FirebaseAnalytics.instance.setUserId(id: r.data!.user!.id.toString());

        FirebaseAnalytics.instance.setUserId(id: "12345");

        FirebaseAnalytics.instance.setUserProperty(
          name: 'gender',
          value: r.data!.user!.gender.toString(),
        );

        FirebaseAnalytics.instance.setUserProperty(
          name: 'user_type',
          value: 'guest',
        );
        /////////////////////////////////////

        GetIt.I<HomeBloc>().add(
          SaveUserInfoFromAuthEvent(userInfo: r.data!.user!),
        );
        await _prefsRepository.setMyMarketId(r.data!.user!.id.toString());
        GetIt.I<HomeBloc>().add(GetCurrencyForCountryEvent());
        GetIt.I<HomeBloc>().add(const GetCartItemEvent());

        GetIt.I<HomeBloc>().add(const GetOldCartItemEvent());
        //  GetIt.I<HomeBloc>().add(GetProductsListInCartEvent());
        NotificationProcess().fcmToken(null, null, null, null);
      },
    );
  }

  FutureOr<void> _onUpdateNameEvent(
    UpdateNameEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(updateNameStatus: UpdateNameStatus.loading));
    final response = await updateNameUseCase(
      UpdateNameParams(name: event.name),
    );
    await response.fold(
      (l) {
        if (ErrorManager.shouldRetry('UpdateNameEvent', l.statusCode)) {
          add(UpdateNameEvent(name: event.name));
          ErrorManager.incrementRetry('UpdateNameEvent');
        }
        emit(state.copyWith(updateNameStatus: UpdateNameStatus.failure));
      },
      (r) {
        //  GetIt.I<HomeBloc>().add(UpdateProfileEvent(name: event.name));
        // add(UpdateChatUserNameEvent(name: event.name ?? ""));
        //  add(UpdateStoriesUserEvent(name: event.name ?? ""));
        ErrorManager.resetRetry('UpdateNameEvent');
        emit(state.copyWith(updateNameStatus: UpdateNameStatus.success));
      },
    );
  }

  FutureOr<void> _onGetCustomerInfoEvent(
    GetCustomerInfoEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(getCustomerInfoStatus: GetCustomerInfoStatus.loading));
    GetIt.I<DashboardBloc>().add(GetUserPermissionEvent());
    final response = await getCustomerInfoUseCase(NoParams());
    await response.fold(
      (l) {
        if (ErrorManager.shouldRetry('GetCustomerInfoEvent', l.statusCode)) {
          add(GetCustomerInfoEvent());
          ErrorManager.incrementRetry('GetCustomerInfoEvent');
        }
        emit(
          state.copyWith(getCustomerInfoStatus: GetCustomerInfoStatus.failure),
        );
      },
      (userInfo) async {
        ErrorManager.resetRetry('GetCustomerInfoEvent');
        if (kDebugMode)
          print(
            "userInfo.user?.isPhoneVerified ${userInfo.toJson()}------------------",
          );

        _prefsRepository.setAllowedToUploadStories(
          userInfo.isAllowedToUploadStories ?? false,
        );
        bool x = _prefsRepository.getAllowedToUploadStories();

        if (kDebugMode) print("allowedToUploadStories $x------------------");

        await _prefsRepository.setVerifiedPhone(userInfo.isPhoneVerified == 1);
        if ((userInfo.name?.replaceAll(' ', '') ?? '') != '') {
          await _prefsRepository.setMyMarketName(userInfo.name!);
          await _prefsRepository.setMyChatName(userInfo.name!);

          await _prefsRepository.setMyStoriesName(userInfo.name!);
        }
        if (userInfo.image != null && userInfo.image != "") {
          await _prefsRepository.setMyProfilePhoto(
            userInfo.image!.contains("cloudinary") ||
                    userInfo.image!.contains("media_server")
                ? userInfo.image
                : ("${dotenv.env['Media_S3_Server']}" + userInfo.image!),
          );
          await _prefsRepository.setMyChatPhoto(
            userInfo.image!.contains("cloudinary") ||
                    userInfo.image!.contains("media_server")
                ? userInfo.image
                : ("${dotenv.env['Media_S3_Server']}" + userInfo.image!),
          );
        }

        await _prefsRepository.setMyMarketId(userInfo.id.toString());
        await _prefsRepository.setPhoneNumber((userInfo.phone).toString());
        GetIt.I<HomeBloc>().add(SaveUserInfoFromAuthEvent(userInfo: userInfo));
        emit(
          state.copyWith(
            getCustomerInfoStatus: GetCustomerInfoStatus.success,
            marketUser: userInfo,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetUserCountryEvent(
    GetUserCountryEvent event,
    Emitter<AuthState> emit,
  ) async {
    final response = await getUserCountryUseCase(NoParams());
    await response.fold(
      (l) {
        emit(
          state.copyWith(
            getCustomerCountryStatus: GetCustomerCountryStatus.failure,
          ),
        );
        if (ErrorManager.shouldRetry('GetUserCountryEvent', l.statusCode)) {
          add(GetUserCountryEvent());
          ErrorManager.incrementRetry('GetUserCountryEvent');
        }
      },
      (r) async {
        ErrorManager.resetRetry('GetUserCountryEvent');
        await _prefsRepository.setCountryIso(r.countryCode);

        emit(
          state.copyWith(
            getUserCountryResponseModel: r,
            countryName: r.country,
            getCustomerCountryStatus: GetCustomerCountryStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateStoriesUserEvent(
    UpdateStoriesUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (_prefsRepository.storiesToken == null ||
        _prefsRepository.storiesToken == "") {
      return;
    }
    bool requestForMarketName = false;
    emit(
      state.copyWith(updateStoriesUserStatus: UpdateStoriesUserStatus.loading),
    );
    final response = await updateStoriesUserUseCase(
      UpdateStoriesUserParams(
        name: event.name,
        phone: event.phone,
        photo: event.photo,
      ),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('UpdateStoriesUserEvent', l.statusCode)) {
          add(UpdateStoriesUserEvent(name: event.name));
          ErrorManager.incrementRetry('UpdateStoriesUserEvent');
        }
        emit(
          state.copyWith(
            updateStoriesUserStatus: UpdateStoriesUserStatus.failure,
          ),
        );
      },
      (r) {
        requestForMarketName = true;
      },
    );
    if (!requestForMarketName) return;
    final marketResponse = await updateNameUseCase(
      UpdateNameParams(name: event.name),
    );
    marketResponse.fold(
      (l) {
        if (ErrorManager.shouldRetry('UpdateStoriesUserEvent', l.statusCode)) {
          add(UpdateStoriesUserEvent(name: event.name));
          ErrorManager.incrementRetry('UpdateStoriesUserEvent');
        }
        emit(
          state.copyWith(
            updateStoriesUserStatus: UpdateStoriesUserStatus.failure,
          ),
        );
      },
      (r) {
        requestForMarketName = true;
      },
    );
    if (!requestForMarketName) return;
    final chatResponse = await updateChatUserNameUseCase(
      UpdateChatUserNameParams(name: event.name ?? ""),
    );
    chatResponse.fold(
      (l) {
        if (ErrorManager.shouldRetry('UpdateStoriesUserEvent', l.statusCode)) {
          add(UpdateStoriesUserEvent(name: event.name));
          ErrorManager.incrementRetry('UpdateStoriesUserEvent');
        }
        emit(
          state.copyWith(
            updateStoriesUserStatus: UpdateStoriesUserStatus.failure,
          ),
        );
      },
      (r) {
        GetIt.I<StoryBloc>().add(const GetStoryEvent(withPaginition: false));
        ErrorManager.resetRetry('UpdateStoriesUserEvent');
        _prefsRepository.setMyStoriesName(event.name ?? "");
        _prefsRepository.setMyMarketName(event.name ?? "");

        GetIt.I<StoryBloc>().add(
          UpdateNameForUserInCollectionIfExistEvent(name: event.name ?? ""),
        );

        emit(
          state.copyWith(
            updateStoriesUserStatus: UpdateStoriesUserStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateChatUserNameEvent(
    UpdateChatUserNameEvent event,
    Emitter<AuthState> emit,
  ) async {
    bool requestForMarketName = false;
    if (_prefsRepository.chatToken == null ||
        _prefsRepository.chatToken == "") {
      return;
    }
    emit(
      state.copyWith(
        updateChatUserNameStatus: UpdateChatUserNameStatus.loading,
      ),
    );
    final response = await updateChatUserNameUseCase(
      UpdateChatUserNameParams(name: event.name),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('UpdateChatUserNameEvent', l.statusCode)) {
          add(UpdateStoriesUserEvent(name: event.name));
          ErrorManager.incrementRetry('UpdateChatUserNameEvent');
        }
        emit(
          state.copyWith(
            updateChatUserNameStatus: UpdateChatUserNameStatus.failure,
          ),
        );
      },
      (r) {
        requestForMarketName = true;
      },
    );
    if (!requestForMarketName) return;
    final marketResponse = await updateNameUseCase(
      UpdateNameParams(name: event.name),
    );
    marketResponse.fold(
      (l) {
        if (ErrorManager.shouldRetry('UpdateChatUserNameEvent', l.statusCode)) {
          add(UpdateStoriesUserEvent(name: event.name));
          ErrorManager.incrementRetry('UpdateChatUserNameEvent');
        }
        emit(
          state.copyWith(
            updateChatUserNameStatus: UpdateChatUserNameStatus.failure,
          ),
        );
      },
      (r) {
        _prefsRepository.setMyChatName(event.name);
        _prefsRepository.setMyMarketName(event.name);
        requestForMarketName = true;
      },
    );
    if (!requestForMarketName) return;
    if (_prefsRepository.storiesToken == null ||
        _prefsRepository.storiesToken == "") {
      return;
    }
    final storiesResponse = await updateStoriesUserUseCase(
      UpdateStoriesUserParams(name: event.name),
    );
    storiesResponse.fold(
      (l) {
        if (ErrorManager.shouldRetry('UpdateChatUserNameEvent', l.statusCode)) {
          add(UpdateStoriesUserEvent(name: event.name));
          ErrorManager.incrementRetry('UpdateChatUserNameEvent');
        }
        emit(
          state.copyWith(
            updateChatUserNameStatus: UpdateChatUserNameStatus.failure,
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('UpdateChatUserNameEvent');
        _prefsRepository.setMyStoriesName(event.name);

        emit(
          state.copyWith(
            updateChatUserNameStatus: UpdateChatUserNameStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGenerateTokenForCommentEvent(
    GenerateTokenForCommentEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        generateTokenForCommentStatus: GenerateTokenForCommentStatus.loading,
      ),
    );
    await _prefsRepository.setTokenForComment("");
    final response = await generateTokenForCommentUseCase(
      GeneratingTokenForCommentParams(
        userId: event.userId,
        mobilePhone: event.mobilePhone,
        otpIdToken: event.otpIdToken,
      ),
    );
    await response.fold(
      (l) {
        if (ErrorManager.shouldRetry(
          'GenerateTokenForCommentEvent',
          l.statusCode,
        )) {
          add(
            GenerateTokenForCommentEvent(
              userId: event.userId,
              mobilePhone: event.mobilePhone,
              otpIdToken: event.otpIdToken,
            ),
          );
          ErrorManager.incrementRetry('GenerateTokenForCommentEvent');
          return;
        }
        emit(
          state.copyWith(
            generateTokenForCommentStatus:
                GenerateTokenForCommentStatus.failure,
          ),
        );
      },
      (r) async {
        await _prefsRepository.setTokenForComment(r);
        ErrorManager.resetRetry('GenerateTokenForCommentEvent');
        emit(
          state.copyWith(
            generateTokenForCommentStatus:
                GenerateTokenForCommentStatus.success,
          ),
        );
      },
    );
  }
}
