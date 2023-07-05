import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../domain/use_cases/create_user_usecase.dart';
import '../../domain/use_cases/login_usecase.dart';

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
  AuthBloc(this.createUserUseCase,this.loginUseCase) : super(const AuthState()) {
    on<AuthEvent>((event, emit) {});
    on<CreateUserEvent>(_onCreateUserEvent,transformer: throttleDroppable(throttleDuration));
    on<LoginEvent>(_onLoginEvent,transformer: throttleDroppable(throttleDuration));
  }

  final LoginUseCase loginUseCase;
  final CreateUserUseCase createUserUseCase;

  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  FutureOr<void> _onCreateUserEvent(CreateUserEvent event, Emitter<AuthState> emit) async{
  }

  FutureOr<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async{
    emit(state.copyWith(loginUserStatus: LoginUserStatus.loading));

    final response = await loginUseCase(

      LoginParams(mobilePhone: event.mobilePhone , password: event.password),
    );
    response.fold(
          (l) => emit(state.copyWith(loginUserStatus: LoginUserStatus.failure)),
          (r) {
        final token = r.data!.accessToken;
        final id = r.data!.id;
        final checkToken = token?.isNotEmpty ?? false;

        if (checkToken) {
          _prefsRepository.setToken(token!);
          _prefsRepository.setUserId(id!);
        }
        emit(
          state.copyWith(
            loginUserStatus: LoginUserStatus.success
          ),
        );
      },
    );
  }
}
