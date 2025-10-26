import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String token;
  final String role; // 'admin' | 'user'
  const UserEntity({required this.token, required this.role});

  @override
  List<Object?> get props => [token, role];
}
