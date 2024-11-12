import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';
import 'package:trydos/features/home/domain/use_cases/get_allowed_country_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/get_user_country_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/register_guest_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/send_otp_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/store_fcm_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/update_chat_user_name_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/update_name_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/update_stories_user_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_guest_phone_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_otp_signin_usecase.dart';
import 'package:trydos/features/calls/data/models/agora_token_remote_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import '../../../../common/constant/countries.dart';
import '../../../../common/helper/show_message.dart';
import '../../../../core/api/methods/detect_server.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../main.dart';
import '../../../../service/notification_service/notification_service/handle_notification/notification_process.dart';
import '../../../chat/presentation/manager/chat_event.dart';
import '../../../home/presentation/manager/home_event.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../../domain/use_cases/create_user_usecase.dart';
import '../../domain/use_cases/get_customer_info_usecase.dart';
import '../../domain/use_cases/login_to_chat_usecase.dart';
import '../../domain/use_cases/login_to_market_usecase.dart';
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
    this.updateNameUseCase,
    this.registerGuestUseCase,
    this.sendOtpUseCase,
    this.getCustomerInfoUseCase,
    this.verifyGuestPhoneUseCase,
    this.verifyOtpSignInUseCase,
    this.getUserCountryUseCase,
    this.verifyOtpSignUpUseCase,
  ) : super(const AuthState()) {
    on<AuthEvent>((event, emit) {});
    on<CreateUserEvent>(_onCreateUserEvent,
        transformer: throttleDroppable(throttleDuration));
    on<UpdateStoriesUserEvent>(_onUpdateStoriesUserEvent,
        transformer: throttleDroppable(throttleDuration));
    on<UpdateChatUserNameEvent>(_onUpdateChatUserNameEvent,
        transformer: throttleDroppable(throttleDuration));
    on<LoginToChatEvent>(_onLoginToChatEvent,
        transformer: throttleDroppable(throttleDuration));
    on<LoginToStoriesEvent>(_onLoginToStoriesEvent,
        transformer: throttleDroppable(throttleDuration));
    on<StoreFcmTokenEvent>(_onStoreFcmTokenEvent,
        transformer: throttleDroppable(throttleDuration));
    on<SendOtpEvent>(_onSendOtpEvent);
    on<VerifyOtpSignInEvent>(_onVerifyOtpSignInEvent);
    on<VerifyOtpSignUpEvent>(_onVerifyOtpSignUpEvent);
    on<VerifyGuestPhoneEvent>(
      _onVerifyGuestPhoneEvent,
    );
    on<RegisterGuestEvent>(_onRegisterGuestEvent,
        transformer: throttleDroppable(throttleDuration));
    on<UpdateNameEvent>(_onUpdateNameEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetCustomerInfoEvent>(_onGetCustomerInfoEvent,
        transformer: throttleDroppable(throttleDuration));
    on<GetUserCountryEvent>(
      _onGetUserCountryEvent,
      //transformer: throttleDroppable(throttleDuration)
    );
  }

  final LoginToChatUseCase loginToChatUseCase;
  final LoginToStoriesUseCase loginToStoriesUseCase;
  final CreateUserUseCase createUserUseCase;
  final StoreFcmUseCase storeFcmUseCase;
  final SendOtpUseCase sendOtpUseCase;

  final VerifyOtpSignInUseCase verifyOtpSignInUseCase;
  final VerifyOtpSignUpUseCase verifyOtpSignUpUseCase;
  final VerifyGuestPhoneUseCase verifyGuestPhoneUseCase;
  final RegisterGuestUseCase registerGuestUseCase;
  final UpdateNameUseCase updateNameUseCase;
  final GetCustomerInfoUseCase getCustomerInfoUseCase;
  final GetUserCountryUseCase getUserCountryUseCase;
  final UpdateStoriesUserUseCase updateStoriesUserUseCase;
  final UpdateChatUserNameUseCase updateChatUserNameUseCase;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  FutureOr<void> _onCreateUserEvent(
      CreateUserEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(createUserStatus: CreateUserStatus.loading));

    final response = await createUserUseCase(
      CreateUserParams(
          mobilePhone: event.mobilePhone,
          password: event.password,
          name: event.name),
    );
    response.fold(
      (l) => emit(state.copyWith(createUserStatus: CreateUserStatus.failure)),
      (r) {
        emit(
          state.copyWith(createUserStatus: CreateUserStatus.success),
        );
      },
    );
  }

  FutureOr<void> _onLoginToChatEvent(
      LoginToChatEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loginToChatStatus: LoginToChatStatus.loading));

    final response = await loginToChatUseCase(
      LoginToChatParams(
          mobilePhone: event.mobilePhone,
          otpIdToken: event.otpIdToken,
          name: event.name,
          originalUserId: event.originalUserId),
    );
    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('LoginToChatEvent')) {
          add(LoginToChatEvent(
              mobilePhone: event.mobilePhone,
              otpIdToken: event.otpIdToken,
              name: event.name,
              fcmToken: event.fcmToken,
              originalUserId: event.originalUserId));
          isFailedTheFirstTime.add('LoginToChatEvent');
        }
        emit(state.copyWith(loginToChatStatus: LoginToChatStatus.failure));
      },
      (r) {
        isFailedTheFirstTime.remove('LoginToChatEvent');
        final id = r.data!.id;
        final token = r.data!.accessToken;
        final name = r.data!.name;
        final photo = r.data!.photoPath;
        final checkToken = token?.isNotEmpty ?? false;

        if (checkToken) {
          _prefsRepository.setChatToken(token!);
          _prefsRepository.setMyChatId(id!);
          _prefsRepository.setMyChatName(name ?? 'No Name');
          _prefsRepository.setMyChatPhoto(photo);
        }
        add(StoreFcmTokenEvent(
            userId: id!,
            fcmToken: event.fcmToken,
            serverName: ServerName.chat));
        apisMustNotToRequest.remove('GetChatsEvent');
        GetIt.I<ChatBloc>().add(GetChatsEvent(limit: 10));
      },
    );
  }

  FutureOr<void> _onStoreFcmTokenEvent(
      StoreFcmTokenEvent event, Emitter<AuthState> emit) async {
    final response = await storeFcmUseCase(
      StoreFcmParams(
          userId: event.userId,
          fcmToken: event.fcmToken,
          serverName: event.serverName),
    );
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('StoreFcmTokenEvent')) {
        add(StoreFcmTokenEvent(
            userId: event.userId,
            fcmToken: event.fcmToken,
            serverName: event.serverName));
        isFailedTheFirstTime.add('StoreFcmTokenEvent');
      }
      emit(state.copyWith(loginToChatStatus: LoginToChatStatus.failure));
    }, (r) {
      isFailedTheFirstTime.remove('StoreFcmTokenEvent');
      final id = r.data!.id;
      _prefsRepository.setFcmTokenId(id!);
      emit(state.copyWith(loginToChatStatus: LoginToChatStatus.success));
    });
  }

  FutureOr<void> _onSendOtpEvent(
      SendOtpEvent event, Emitter<AuthState> emit) async {
    _prefsRepository.clearVerificationId();
    emit(state.copyWith(sendOtpStatus: SendOtpStatus.loading));
    final response = await sendOtpUseCase(
      SendOtpParams(isViaWhatsApp: event.isViaWhatsApp, phone: event.phone),
    );
    response.fold(
        (l) => emit(state.copyWith(
            sendOtpStatus: SendOtpStatus.failure,
            sendOtpError: 'please wait some seconds and try again')), (r) {
      _prefsRepository.setVerificationId(r.data!.verificationId!);
      emit(state.copyWith(sendOtpStatus: SendOtpStatus.success));
    });
  }

  FutureOr<void> _onVerifyGuestPhoneEvent(
      VerifyGuestPhoneEvent event, Emitter<AuthState> emit) async {
    emit(
        state.copyWith(verifyGuestPhoneStatus: VerifyGuestPhoneStatus.loading));
    final response = await verifyGuestPhoneUseCase(
      VerifyGuestPhoneParams(idToken: event.idToken),
    );
    response.fold(
        (l) => emit(state.copyWith(
            verifyGuestPhoneStatus: VerifyGuestPhoneStatus.failure)), (r) {
      emit(state.copyWith(
          verifyGuestPhoneStatus: VerifyGuestPhoneStatus.success));
    });
  }

//todo _onLoginToStoriesEvent
  FutureOr<void> _onLoginToStoriesEvent(
      LoginToStoriesEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loginToStoriesStatus: LoginToStoriesStatus.loading));

    final response = await loginToStoriesUseCase(
      LoginToStoriesParams(
          phone: event.phone,
          name: event.name,
          otpIdToken: event.otpIdToken,
          originalUserId: event.originalUserId),
    );
    response.fold(
      (l) {
        if (!isFailedTheFirstTime.contains('LoginToStoriesEvent')) {
          add(LoginToStoriesEvent(
              phone: event.phone,
              name: event.name,
              otpIdToken: event.otpIdToken,
              originalUserId: event.originalUserId));
          isFailedTheFirstTime.add('LoginToStoriesEvent');
        }
        emit(
            state.copyWith(loginToStoriesStatus: LoginToStoriesStatus.failure));
      },
      (r) {
        isFailedTheFirstTime.remove('LoginToStoriesEvent');

        final id = r.data!.id;
        final token = r.data!.accessToken;
        final checkToken = token?.isNotEmpty ?? false;
        final name = r.data!.name;
        if (checkToken) {
          _prefsRepository.setStoriesToken(token!);
          _prefsRepository.setMyStoriesId(id!);
          _prefsRepository.setMyStoriesName(name ?? 'No Name');
        }
        apisMustNotToRequest.remove('GetStoryEvent');
        GetIt.I<StoryBloc>().add(GetStoryEvent());
      },
    );
  }

  FutureOr<void> _onVerifyOtpSignInEvent(
      VerifyOtpSignInEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(verifyOtpSignInStatus: VerifyOtpSignInStatus.loading));
    final response = await verifyOtpSignInUseCase(
      VerifyOtpSignInParams(
          verificationId: event.verificationId, otp: event.otp),
    );
    response.fold((l) {
      emit(state.copyWith(
          verifyOtpSignInStatus: VerifyOtpSignInStatus.failure,
          signInErrorMessage: l.message));
    }, (r) {
      try {
        _prefsRepository.setMyMarketId(r.data!.user!.id.toString());
        if ((r.data!.user!.name?.replaceAll(' ', '') ?? '') != '') {
          _prefsRepository.setMyMarketName(r.data!.user!.name!);
        }
        _prefsRepository.setMarketToken(r.data!.token!);
        _prefsRepository.setMyMarketId(r.data!.user!.id.toString());
        print(
            "*****************************-----------------------------${r.data!.token!}");
        _prefsRepository.setVerifiedPhone(r.data!.user?.isPhoneVerified == 1);
        _prefsRepository.setPhoneNumber((r.data!.user?.phone).toString());
        add(StoreFcmTokenEvent(
            userId: r.data!.user!.id!,
            fcmToken: NotificationProcess.myFcmToken!,
            serverName: ServerName.market));
        add(LoginToChatEvent(
            fcmToken: NotificationProcess.myFcmToken!,
            mobilePhone: r.data!.user!.phone,
            name: r.data!.user!.name,
            originalUserId: r.data!.user!.id!.toString(),
            otpIdToken: r.data!.idToken!));
        add(LoginToStoriesEvent(
          originalUserId: r.data!.user!.id!.toString(),
          otpIdToken: r.data!.idToken!,
          name: r.data!.user!.name,
          phone: r.data!.user!.phone,
        ));
      } catch (error) {
        showMessage(error.toString());
      }
      debugPrint(
          'login _prefsRepository.chatToken${_prefsRepository.chatToken}');
      debugPrint(
          'login _prefsRepository.marketToken${_prefsRepository.marketToken}');
      debugPrint(
          'login _prefsRepository.storiesToken${_prefsRepository.storiesToken}');
      if (!r.data!.alreadyExist!) {
        emit(state.copyWith(
            verifyOtpSignInStatus: VerifyOtpSignInStatus.failure,
            marketUser: r.data!.user,
            signInErrorMessage: 'auth-001'));

        return;
      }
      emit(state.copyWith(
          verifyOtpSignInStatus: VerifyOtpSignInStatus.success,
          marketUser: r.data!.user));
    });
  }

  FutureOr<void> _onVerifyOtpSignUpEvent(
      VerifyOtpSignUpEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(verifyOtpSignUpStatus: VerifyOtpSignUpStatus.loading));
    final response = await verifyOtpSignUpUseCase(
      VerifyOtpSignUpParams(
          verificationId: event.verificationId,
          otp: event.otp,
          name: event.name),
    );
    response.fold((l) {
      emit(state.copyWith(
        verifyOtpSignUpStatus: VerifyOtpSignUpStatus.failure,
      ));
    }, (r) {
      print(
          "87777777777777777777777777777777777777777777777777777777${r.data!.user!.name}77777777777777777777777${r.data!.user!.id!}");

      if ((r.data!.user!.name?.replaceAll(' ', '') ?? '') != '') {
        _prefsRepository.setMyMarketName(r.data!.user!.name!);
      }
      _prefsRepository.setMarketToken(r.data!.token!);
      _prefsRepository.setMyMarketId(r.data!.user!.id.toString());
      print(
          ".................................*****************************-----------------------------${r.data!.token!}");

      _prefsRepository.setVerifiedPhone(r.data!.user?.isPhoneVerified == 1);
      _prefsRepository.setPhoneNumber((r.data!.user?.phone).toString());
      add(StoreFcmTokenEvent(
          userId: r.data!.user!.id!,
          fcmToken: NotificationProcess.myFcmToken!,
          serverName: ServerName.market));
      add(LoginToChatEvent(
          fcmToken: NotificationProcess.myFcmToken!,
          mobilePhone: r.data!.user!.phone,
          originalUserId: r.data!.user!.id!.toString(),
          name: r.data!.user!.name,
          otpIdToken: r.data!.idToken!));
      add(LoginToStoriesEvent(
        originalUserId: r.data!.user!.id!.toString(),
        otpIdToken: r.data!.idToken!,
        name: r.data!.user!.name,
        phone: r.data!.user!.phone,
      ));
      if (r.data!.alreadyExist!) {
        emit(state.copyWith(
            verifyOtpSignUpStatus: VerifyOtpSignUpStatus.failure,
            marketUser: r.data!.user,
            signUpErrorMessage: 'auth-001'));

        return;
      }
      emit(state.copyWith(
          verifyOtpSignUpStatus: VerifyOtpSignUpStatus.success,
          marketUser: r.data!.user));
    });
  }

  FutureOr<void> _onRegisterGuestEvent(
      RegisterGuestEvent event, Emitter<AuthState> emit) async {
    _prefsRepository.clearTokenForMarket();
    _prefsRepository.clearTokensForChatAndStory();
    _prefsRepository.setVerifiedPhone(false);
    emit(state.copyWith(registerGuestStatus: RegisterGuestStatus.loading));
    final response = await registerGuestUseCase(
      RegisterGuestParams(deviceId: event.deviceId),
    );
    bool? previousStatusOfIsVerifiedPhone =
        _prefsRepository.isVerifiedPhone ?? false;
    _prefsRepository.setVerifiedPhone(false);

    response.fold((l) {
      _prefsRepository.setVerifiedPhone(previousStatusOfIsVerifiedPhone);
      if (!isFailedTheFirstTime.contains('RegisterGuestEvent')) {
        add(RegisterGuestEvent(deviceId: event.deviceId));
        isFailedTheFirstTime.add('RegisterGuestEvent');
      }
      emit(state.copyWith(registerGuestStatus: RegisterGuestStatus.failure));
    }, (r) {
      isFailedTheFirstTime.remove('RegisterGuestEvent');
      _prefsRepository.setMarketToken(r.data!.token!);
      _prefsRepository.setMyMarketId(r.data!.user!.id.toString());
      add(StoreFcmTokenEvent(
          userId: r.data!.user!.id!,
          fcmToken: NotificationProcess.myFcmToken!,
          serverName: ServerName.market));
      emit(state.copyWith(
          registerGuestStatus: RegisterGuestStatus.success,
          marketUser: r.data!.user));
    });
  }

  FutureOr<void> _onUpdateNameEvent(
      UpdateNameEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(updateNameStatus: UpdateNameStatus.loading));
    final response = await updateNameUseCase(
      UpdateNameParams(name: event.name),
    );
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('UpdateNameEvent')) {
        add(UpdateNameEvent(name: event.name));
        isFailedTheFirstTime.add('UpdateNameEvent');
      }
      emit(state.copyWith(updateNameStatus: UpdateNameStatus.failure));
    }, (r) {
      add(UpdateChatUserNameEvent(name: event.name));
      add(UpdateStoriesUserEvent(name: event.name));
      isFailedTheFirstTime.remove('UpdateNameEvent');
      emit(state.copyWith(
        updateNameStatus: UpdateNameStatus.success,
      ));
    });
  }

  FutureOr<void> _onGetCustomerInfoEvent(
      GetCustomerInfoEvent event, Emitter<AuthState> emit) async {
    if (state.marketUser != null ||
        state.getCustomerInfoStatus == GetCustomerInfoStatus.loading) return;
    emit(state.copyWith(getCustomerInfoStatus: GetCustomerInfoStatus.loading));
    final response = await getCustomerInfoUseCase(NoParams());
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('GetCustomerInfoEvent')) {
        add(GetCustomerInfoEvent());
        isFailedTheFirstTime.add('GetCustomerInfoEvent');
      }
      emit(
          state.copyWith(getCustomerInfoStatus: GetCustomerInfoStatus.failure));
    }, (userInfo) {
      isFailedTheFirstTime.remove('GetCustomerInfoEvent');
      _prefsRepository.setVerifiedPhone(userInfo.isPhoneVerified == 1);
      if ((userInfo.name?.replaceAll(' ', '') ?? '') != '') {
        _prefsRepository.setMyMarketName(userInfo.name!);
        _prefsRepository.setMyChatName(userInfo.name!);
        _prefsRepository.setMyStoriesName(userInfo.name!);
      }
      emit(state.copyWith(
          getCustomerInfoStatus: GetCustomerInfoStatus.success,
          marketUser: userInfo));
    });
  }

  FutureOr<void> _onGetUserCountryEvent(
      GetUserCountryEvent event, Emitter<AuthState> emit) async {
    final response = await getUserCountryUseCase(NoParams());
    response.fold((l) {
      emit(state.copyWith(
          getCustomerCountryStatus: GetCustomerCountryStatus.failure));
      if (!isFailedTheFirstTime.contains('GetUserCountryEvent')) {
        add(GetUserCountryEvent());
        isFailedTheFirstTime.add('GetUserCountryEvent');
      }
    }, (r) {
      isFailedTheFirstTime.remove('GetUserCountryEvent');
      _prefsRepository.setCountryIso(r.countryCode);

      emit(state.copyWith(
          countryName: r.country,
          getCustomerCountryStatus: GetCustomerCountryStatus.success));
    });
  }

  FutureOr<void> _onUpdateStoriesUserEvent(
      UpdateStoriesUserEvent event, Emitter<AuthState> emit) async {
    bool requestForMarketName = false;
    emit(state.copyWith(
        updateStoriesUserStatus: UpdateStoriesUserStatus.loading));
    final response = await updateStoriesUserUseCase(
      UpdateStoriesUserParams(name: event.name),
    );
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('UpdateStoriesUserEvent')) {
        add(UpdateStoriesUserEvent(name: event.name));
        isFailedTheFirstTime.add('UpdateStoriesUserEvent');
      }
      emit(state.copyWith(
          updateStoriesUserStatus: UpdateStoriesUserStatus.failure));
    }, (r) {
      requestForMarketName = true;
    });
    if (!requestForMarketName) return;
    final marketResponse = await updateNameUseCase(
      UpdateNameParams(name: event.name),
    );
    marketResponse.fold((l) {
      if (!isFailedTheFirstTime.contains('UpdateStoriesUserEvent')) {
        add(UpdateStoriesUserEvent(name: event.name));
        isFailedTheFirstTime.add('UpdateStoriesUserEvent');
      }
      emit(state.copyWith(
        updateStoriesUserStatus: UpdateStoriesUserStatus.failure,
      ));
    }, (r) {
      requestForMarketName = true;
    });
    if (!requestForMarketName) return;
    final chatResponse = await updateChatUserNameUseCase(
      UpdateChatUserNameParams(name: event.name),
    );
    chatResponse.fold((l) {
      if (!isFailedTheFirstTime.contains('UpdateStoriesUserEvent')) {
        add(UpdateStoriesUserEvent(name: event.name));
        isFailedTheFirstTime.add('UpdateStoriesUserEvent');
      }
      emit(state.copyWith(
        updateStoriesUserStatus: UpdateStoriesUserStatus.failure,
      ));
    }, (r) {
      isFailedTheFirstTime.remove('UpdateStoriesUserEvent');
      _prefsRepository.setMyStoriesName(event.name);
      _prefsRepository.setMyMarketName(event.name);

      GetIt.I<StoryBloc>()
          .add(UpdateNameForUserInCollectionIfExistEvent(name: event.name));

      emit(state.copyWith(
        updateStoriesUserStatus: UpdateStoriesUserStatus.success,
      ));
    });
  }

  FutureOr<void> _onUpdateChatUserNameEvent(
      UpdateChatUserNameEvent event, Emitter<AuthState> emit) async {
    bool requestForMarketName = false;
    emit(state.copyWith(
        updateChatUserNameStatus: UpdateChatUserNameStatus.loading));
    final response = await updateChatUserNameUseCase(
      UpdateChatUserNameParams(name: event.name),
    );
    response.fold((l) {
      if (!isFailedTheFirstTime.contains('UpdateChatUserNameEvent')) {
        add(UpdateStoriesUserEvent(name: event.name));
        isFailedTheFirstTime.add('UpdateChatUserNameEvent');
      }
      emit(state.copyWith(
          updateChatUserNameStatus: UpdateChatUserNameStatus.failure));
    }, (r) {
      requestForMarketName = true;
    });
    if (!requestForMarketName) return;
    final marketResponse = await updateNameUseCase(
      UpdateNameParams(name: event.name),
    );
    marketResponse.fold((l) {
      if (!isFailedTheFirstTime.contains('UpdateChatUserNameEvent')) {
        add(UpdateStoriesUserEvent(name: event.name));
        isFailedTheFirstTime.add('UpdateChatUserNameEvent');
      }
      emit(state.copyWith(
          updateChatUserNameStatus: UpdateChatUserNameStatus.failure));
    }, (r) {
      requestForMarketName = true;
    });
    if (!requestForMarketName) return;
    final storiesResponse = await updateStoriesUserUseCase(
      UpdateStoriesUserParams(name: event.name),
    );
    storiesResponse.fold((l) {
      if (!isFailedTheFirstTime.contains('UpdateChatUserNameEvent')) {
        add(UpdateStoriesUserEvent(name: event.name));
        isFailedTheFirstTime.add('UpdateChatUserNameEvent');
      }
      emit(state.copyWith(
          updateChatUserNameStatus: UpdateChatUserNameStatus.failure));
    }, (r) {
      isFailedTheFirstTime.remove('UpdateChatUserNameEvent');
      _prefsRepository.setMyChatName(event.name);
      _prefsRepository.setMyMarketName(event.name);
      emit(state.copyWith(
        updateChatUserNameStatus: UpdateChatUserNameStatus.success,
      ));
    });
  }
}
