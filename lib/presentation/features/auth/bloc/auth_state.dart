import 'package:equatable/equatable.dart';
import '../../../../domain/entities/user_entity.dart';

enum AuthStatus { initial, loading, success, failure, loggingOut, loggedOut }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({AuthStatus? status, UserEntity? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, user, error];
}
