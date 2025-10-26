import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repo;
  LoginUser(this.repo);

  Future<UserEntity> call(String username, String password) {
    return repo.login(username: username, password: password);
  }
}
