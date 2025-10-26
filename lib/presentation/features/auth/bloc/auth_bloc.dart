import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../domain/usecases/login_user.dart';
import '../../../../domain/usecases/logout_user.dart';
import '../../../../core/errors/failures.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final LogoutUser logoutUser;

  AuthBloc(this.loginUser, this.logoutUser) : super(const AuthState()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      try {
        final result = await loginUser(event.username, event.password);
        emit(state.copyWith(status: AuthStatus.success, user: result));
      } on Failure catch (f) {
        emit(state.copyWith(status: AuthStatus.failure, error: f.message));
      } catch (e) {
        emit(state.copyWith(status: AuthStatus.failure, error: e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {     // ⬅️ add
      emit(state.copyWith(status: AuthStatus.loggingOut));
      try {
        await logoutUser();
        emit(const AuthState(status: AuthStatus.loggedOut)); // reset user+error
      } on Failure catch (f) {
        emit(state.copyWith(status: AuthStatus.failure, error: f.message));
      } catch (e) {
        emit(state.copyWith(status: AuthStatus.failure, error: e.toString()));
      }
    });
  }
}

