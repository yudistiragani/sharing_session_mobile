import '../../data/models/user_model.dart';

abstract class UserRepository {
  Future<UserListResponse> getUsers({
    required int page,
    required int pageSize,
    String? search,
    String? status,
    String? sortBy,
    String? order,
  });
}
