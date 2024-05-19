import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:mockito/annotations.dart';
import 'package:trydos/core/data/repository/prefs_repository_impl.dart';
import 'package:trydos/core/di/di_container.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/authentication/data/data_sources/auth_remote_datasource.dart';
import 'package:trydos/features/authentication/domain/repositories/auth_repository.dart';
import 'package:trydos/features/authentication/domain/use_cases/create_user_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/get_customer_info_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/get_user_country_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/login_to_chat_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/login_to_market_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/login_to_stories_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/register_guest_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/send_otp_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/store_fcm_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/update_chat_user_name_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/update_name_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/update_stories_user_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_guest_phone_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_otp_signin_usecase.dart';
import 'package:trydos/features/authentication/domain/use_cases/verify_otp_signup_usecase.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:trydos/features/chat/domain/repositories/chat_repository.dart';

@GenerateMocks(
  [
    AuthRepository,
    AuthRemoteDatasource,
    CreateUserUseCase,
    ChatRepository,
    UpdateStoriesUserUseCase,
    UpdateChatUserNameUseCase,
    LoginToMarketUseCase,
    LoginToChatUseCase,
    LoginToStoriesUseCase,
    StoreFcmUseCase,
    UpdateNameUseCase,
    RegisterGuestUseCase,
    SendOtpUseCase,
    GetCustomerInfoUseCase,
    VerifyGuestPhoneUseCase,
    VerifyOtpSignInUseCase,
    VerifyOtpSignUpUseCase,
    GetUserCountryUseCase,
    PrefsRepository,
    AppModule,
    AuthBloc
  ],
  customMocks: [],
)
void main() async {}
