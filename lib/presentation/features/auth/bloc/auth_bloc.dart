import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../domain/usecases/login_user.dart';
import '../../../../core/errors/failures.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;

  AuthBloc(this.loginUser) : super(const AuthState()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      try {
        final result = await loginUser(event.username, event.password);
        emit(state.copyWith(status: AuthStatus.success, user: result));
      } on Failure catch (f) {
        emit(state.copyWith(status: AuthStatus.failure, error: f.message));
      } catch (e) {
        final msg = (e is ServerException) ? e.message : e.toString();
        emit(state.copyWith(status: AuthStatus.failure, error: msg));
      }
    });
  }
}
