import '../../data/repositories/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';

class LogoutUser {
  final AuthRepository repo;
  LogoutUser(this.repo);

  Future<void> call() => repo.logout();
}
