import '../../data/models/user_model.dart';
import '../repositories/user_repository.dart';

class GetUsers {
  final UserRepository repo;
  GetUsers(this.repo);

  Future<UserListResponse> call({
    required int page,
    required int pageSize,
    String? search,
    String? status,
    String? sortBy,
    String? order,
  }) {
    return repo.getUsers(
      page: page,
      pageSize: pageSize,
      search: search,
      status: status,
      sortBy: sortBy,
      order: order,
    );
  }
}
