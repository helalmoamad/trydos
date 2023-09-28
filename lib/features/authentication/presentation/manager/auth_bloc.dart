import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:trydos/features/authentication/domain/use_cases/register_guest_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/send_otp_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/store_fcm_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_guest_phone_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_otp_signin_usecase.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../service/notification_service/notification_service/handle_notification/notification_process.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../../domain/use_cases/create_user_usecase.dart';
import '../../domain/use_cases/login_to_chat_usecase.dart';
import '../../domain/use_cases/login_to_market_usecase.dart';
import '../../domain/use_cases/login_to_stories_usecase.dart';
import '../../domain/use_cases/verify_otp_signup_usecase.dart';

part 'auth_event.dart';

part 'auth_state.dart';

const throttleDuration = Duration(milliseconds: 1000);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.createUserUseCase,
      this.loginToChatUseCase,
      this.loginToMarketUseCase,
      this.loginToStoriesUseCase,
      this.storeFcmUseCase,
      this.registerGuestUseCase,
      this.sendOtpUseCase,
      this.verifyGuestPhoneUseCase,
      this.verifyOtpSignInUseCase,
      this.verifyOtpSignUpUseCase)
      : super(const AuthState()) {
    on<AuthEvent>((event, emit) {});
    on<CreateUserEvent>(_onCreateUserEvent,
        transformer: throttleDroppable(throttleDuration));
    on<LoginToChatEvent>(_onLoginToChatEvent,
        transformer: throttleDroppable(throttleDuration));
    on<LoginToMarketEvent>(_onLoginToMarketEvent,
        transformer: throttleDroppable(throttleDuration));
    on<LoginToStoriesEvent>(_onLoginToStoriesEvent,
        transformer: throttleDroppable(throttleDuration));
    on<StoreFcmTokenEvent>(_onStoreFcmTokenEvent,
        transformer: throttleDroppable(throttleDuration));
    on<SendOtpEvent>(_onSendOtpEvent,
        transformer: throttleDroppable(throttleDuration));
    on<VerifyOtpSignInEvent>(_onVerifyOtpSignInEvent,
        transformer: throttleDroppable(throttleDuration));
    on<VerifyOtpSignUpEvent>(_onVerifyOtpSignUpEvent,
        transformer: throttleDroppable(throttleDuration));
    on<VerifyGuestPhoneEvent>(_onVerifyGuestPhoneEvent, transformer: throttleDroppable(throttleDuration));
    on<RegisterGuestEvent>(_onRegisterGuestEvent,
        transformer: throttleDroppable(throttleDuration));
  }

  final LoginToChatUseCase loginToChatUseCase;
  final LoginToMarketUseCase loginToMarketUseCase;
  final LoginToStoriesUseCase loginToStoriesUseCase;
  final CreateUserUseCase createUserUseCase;
  final StoreFcmUseCase storeFcmUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpSignInUseCase verifyOtpSignInUseCase;
  final VerifyOtpSignUpUseCase verifyOtpSignUpUseCase;
  final VerifyGuestPhoneUseCase verifyGuestPhoneUseCase;
  final RegisterGuestUseCase registerGuestUseCase;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  FutureOr<void> _onCreateUserEvent(CreateUserEvent event,
      Emitter<AuthState> emit) async {
    emit(state.copyWith(createUserStatus: CreateUserStatus.loading));

    final response = await createUserUseCase(
      CreateUserParams(
          mobilePhone: event.mobilePhone,
          password: event.password,
          name: event.name),
    );
    response.fold(
          (l) =>
          emit(state.copyWith(createUserStatus: CreateUserStatus.failure)),
          (r) {
        emit(
          state.copyWith(createUserStatus: CreateUserStatus.success),
        );
      },
    );
  }

  FutureOr<void> _onLoginToChatEvent(LoginToChatEvent event,
      Emitter<AuthState> emit) async {
    emit(state.copyWith(loginToChatStatus: LoginToChatStatus.loading));

    final response = await loginToChatUseCase(
      LoginToChatParams(
          mobilePhone: event.mobilePhone,
          otpIdToken: event.otpIdToken,
          name: event.name,
          originalUserId: event.originalUserId),
    );
    response.fold(
          (l) =>
          emit(state.copyWith(loginToChatStatus: LoginToChatStatus.failure)),
          (r) {
        final id = r.data!.id;
        final token = r.data!.accessToken;
        final name = r.data!.name;
        final checkToken = token?.isNotEmpty ?? false;

        if (checkToken) {
          _prefsRepository.setChatToken(token!);
          _prefsRepository.setMyChatId(id!);
          _prefsRepository.setMyChatName(name!);
        }
        add(StoreFcmTokenEvent(userId: id!, fcmToken: event.fcmToken));
      },
    );
  }

  FutureOr<void> _onStoreFcmTokenEvent(StoreFcmTokenEvent event,
      Emitter<AuthState> emit) async {
    final response = await storeFcmUseCase(
      StoreFcmParams(userId: event.userId, fcmToken: event.fcmToken),
    );
    response.fold(
            (l) =>
            emit(state.copyWith(loginToChatStatus: LoginToChatStatus.failure)),
            (r) {
          final id = r.data!.id;
          _prefsRepository.setFcmTokenId(id!);
          emit(state.copyWith(loginToChatStatus: LoginToChatStatus.success));
        });
  }

  FutureOr<void> _onSendOtpEvent(SendOtpEvent event,
      Emitter<AuthState> emit) async {
    emit(state.copyWith(sendOtpStatus: SendOtpStatus.loading));
    final response = await sendOtpUseCase(
      SendOtpParams(isViaWhatsApp: event.isViaWhatsApp, phone: event.phone),
    );
    response.fold(
            (l) => emit(state.copyWith(sendOtpStatus: SendOtpStatus.failure)), (
        r) {
      _prefsRepository.setVerificationId(r.data!.verificationId!);
      emit(state.copyWith(sendOtpStatus: SendOtpStatus.success));
    });
  }

  FutureOr<void> _onVerifyGuestPhoneEvent(VerifyGuestPhoneEvent event,
      Emitter<AuthState> emit) async {
    emit(
        state.copyWith(verifyGuestPhoneStatus: VerifyGuestPhoneStatus.loading));
    final response = await verifyGuestPhoneUseCase(
      VerifyGuestPhoneParams(idToken: event.idToken),
    );
    response.fold(
            (l) =>
            emit(state.copyWith(
                verifyGuestPhoneStatus: VerifyGuestPhoneStatus.failure)), (r) {
      emit(state.copyWith(
          verifyGuestPhoneStatus: VerifyGuestPhoneStatus.success));
    });
  }

  FutureOr<void> _onLoginToMarketEvent(event, Emitter<AuthState> emit) async {}

  FutureOr<void> _onLoginToStoriesEvent(LoginToStoriesEvent event,
      Emitter<AuthState> emit) async {
    emit(state.copyWith(loginToStoriesStatus: LoginToStoriesStatus.loading));

    final response = await loginToStoriesUseCase(
      LoginToStoriesParams(
          phone: event.phone,
          otpIdToken: event.otpIdToken,
          originalUserId: event.originalUserId),
    );
    response.fold(
          (l) =>
          emit(
              state.copyWith(
                  loginToStoriesStatus: LoginToStoriesStatus.failure)),
          (r) {
        final id = r.data!.id;
        final token = r.data!.accessToken;
        final checkToken = token?.isNotEmpty ?? false;

        if (checkToken) {
          _prefsRepository.setStoriesToken(token!);
          _prefsRepository.setMyStoriesId(id!);
        }
      },
    );
  }

  FutureOr<void> _onVerifyOtpSignInEvent(VerifyOtpSignInEvent event,
      Emitter<AuthState> emit) async {
    emit(state.copyWith(verifyOtpSignInStatus: VerifyOtpSignInStatus.loading));
    final response = await verifyOtpSignInUseCase(
      VerifyOtpSignInParams(
          verificationId: event.verificationId, otp: event.otp),
    );
    response.fold(
            (l) {
              _prefsRepository.setOtpCode(event.otp);
          emit(state.copyWith(
              verifyOtpSignInStatus: VerifyOtpSignInStatus.failure,
              signInErrorMessage: l.message));
        }, (r) {
      _prefsRepository.setMarketToken(r.data!.token!);
      //_prefsRepository.setOtpIdToken(r.data!.idToken!);
      add(LoginToChatEvent(
          fcmToken: NotificationProcess.myFcmToken!,
          mobilePhone: event.phone,
          name: r.data?.user?.name,
          originalUserId: r.data!.user!.id!.toString(),
          otpIdToken: r.data!.idToken!));
      add(LoginToStoriesEvent(
          phone: event.phone,
          originalUserId: r.data!.user!.id!.toString(),
          otpIdToken: r.data!.idToken!));
      emit(state.copyWith(
          verifyOtpSignInStatus: VerifyOtpSignInStatus.success,
          marketUser: r.data!.user));
    });
  }

  FutureOr<void> _onVerifyOtpSignUpEvent(VerifyOtpSignUpEvent event,
      Emitter<AuthState> emit) async {
    emit(state.copyWith(verifyOtpSignUpStatus: VerifyOtpSignUpStatus.loading));
    final response = await verifyOtpSignUpUseCase(
      VerifyOtpSignUpParams(
          verificationId: event.verificationId,
          otp: event.otp,
          name: event.name),
    );
    response.fold(
            (l) =>
            emit(state.copyWith(
                verifyOtpSignUpStatus: VerifyOtpSignUpStatus.failure,
                signUpErrorMessage: l.message)), (r) {
      _prefsRepository.setMarketToken(r.data!.token!);
      add(LoginToChatEvent(
          fcmToken: NotificationProcess.myFcmToken!,
          mobilePhone: r.data!.user!.phone,
          originalUserId: r.data!.user!.id!.toString(),
          otpIdToken: r.data!.idToken!));
      add(LoginToStoriesEvent(
          phone: r.data!.user!.phone,
          originalUserId: r.data!.user!.id!.toString(),
          otpIdToken: r.data!.idToken!));
      emit(state.copyWith(
          verifyOtpSignUpStatus: VerifyOtpSignUpStatus.success,
          marketUser: r.data!.user));
    });
  }

  FutureOr<void> _onRegisterGuestEvent(RegisterGuestEvent event, Emitter<AuthState> emit) async {

    emit(state.copyWith(registerGuestStatus: RegisterGuestStatus.loading));
    final response = await registerGuestUseCase(
      RegisterGuestParams(deviceId: event.deviceId),
    );
    response.fold((l) => emit(state.copyWith(registerGuestStatus: RegisterGuestStatus.failure)),
    (r) {
      _prefsRepository.setMarketToken(r.data!.token!);
      emit(state.copyWith(
          registerGuestStatus: RegisterGuestStatus.success,
          marketUser: r.data!.user));
    }
    );
  }
}
