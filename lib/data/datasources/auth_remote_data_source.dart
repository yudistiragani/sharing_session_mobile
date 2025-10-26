import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({required String username, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;
  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<LoginResponseModel> login({required String username, required String password}) async {
    final map = await client.postForm(
      AppConstants.loginPath,
      {'username': username, 'password': password},
    );
    return LoginResponseModel.fromJson(map);
  }
}
