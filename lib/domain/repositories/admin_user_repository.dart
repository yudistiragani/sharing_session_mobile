import 'dart:io';

abstract class AdminUserRepository {
  /// Adds user and returns API response as Map
  Future<Map<String, dynamic>> addUser({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
    required String status,
    File? profileImage,
  });
}
