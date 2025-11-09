import 'dart:io';
import '../../domain/repositories/admin_user_repository.dart';
import '../datasources/admin_user_remote_data_source.dart';

class AdminUserRepositoryImpl implements AdminUserRepository {
  final AdminUserRemoteDataSource remote;

  AdminUserRepositoryImpl({required this.remote});

  @override
  Future<Map<String, dynamic>> addUser({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
    required String status,
    File? profileImage,
  }) {
    return remote.addUserAdmin(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: role,
      status: status,
      profileImage: profileImage,
    );
  }
}
