import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../core/utils/url_utils.dart';      // sudah ada di projectmu
import '../../core/network/api_client.dart';  // kita manfaatkan langsung

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final ApiClient apiClient;

  AuthRepositoryImpl(this.remote, this.apiClient);

  @override
  Future<UserEntity> login({required String username, required String password}) async {
    try {
      final resp = await remote.login(username: username, password: password);
      final user = UserEntity(token: resp.token, role: resp.role);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.kTokenKey, user.token);
      await prefs.setString(AppConstants.kRoleKey, user.role);

      // +++ ADD (ambil profil setelah login)
      try {
        final map = await apiClient.getJson(AppConstants.mePath);
        final u = map['user'] as Map? ?? {};
        final fullName = (u['full_name'] ?? '').toString();
        final profile = (u['profile_image'] ?? '').toString();

        final avatar = profile.isNotEmpty
            ? UrlUtils.join(AppConstants.baseUrl, profile)
            : '';

        await prefs.setString(AppConstants.kDisplayName, fullName);
        await prefs.setString(AppConstants.kAvatarUrl,   avatar);
      } catch (_) {
        // ignored supaya login tetap lanjut walaupun GET me gagal
      }

      return user;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on SocketException {
      throw NetworkFailure('No internet connection');
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.kTokenKey);
      if (token == null || token.isEmpty) {
        // tetap bersihkan lokal kalau tidak ada token
        await prefs.remove(AppConstants.kTokenKey);
        await prefs.remove(AppConstants.kRoleKey);
        return;
      }

      await remote.logout(token: token);             // hit API
      await prefs.remove(AppConstants.kTokenKey);    // bersihkan lokal
      await prefs.remove(AppConstants.kRoleKey);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on SocketException {
      throw NetworkFailure('No internet connection');
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }
}
