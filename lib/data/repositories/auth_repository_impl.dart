import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<UserEntity> login({required String username, required String password}) async {
    try {
      final resp = await remote.login(username: username, password: password);
      final user = UserEntity(token: resp.token, role: resp.role);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.kTokenKey, user.token);
      await prefs.setString(AppConstants.kRoleKey, user.role);
      return user;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on SocketException {
      throw NetworkFailure('No internet connection');
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }
}
