import 'dart:io';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';

abstract class AdminUserRemoteDataSource {
  /// Add user via multipart/form-data (admin)
  Future<Map<String, dynamic>> addUserAdmin({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
    required String status,
    File? profileImage,
  });
}

class AdminUserRemoteDataSourceImpl implements AdminUserRemoteDataSource {
  final ApiClient client;
  AdminUserRemoteDataSourceImpl(this.client);

  @override
  Future<Map<String, dynamic>> addUserAdmin({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
    required String status,
    File? profileImage,
  }) async {
    final fields = <String, String>{
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role,
      'status': status,
    };

    final files = <String, File>{};
    if (profileImage != null) {
      files['profile_image'] = profileImage;
    }

    final resp = await client.postMultipart(
      AppConstants.usersPath,
      fields: fields,
      files: files,
      includeAuth: true,
    );

    return resp;
  }
}
