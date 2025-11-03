import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../datasources/user_remote_data_source.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;
  UserRepositoryImpl(this.remote);

  @override
  Future<UserListResponse> getUsers({
    required int page,
    required int pageSize,
    String? search,
    String? status,
    String? sortBy,
    String? order,
  }) async {
    try {
      return await remote.getUsers(
        page: page,
        pageSize: pageSize,
        search: search,
        status: status,
        sortBy: sortBy,
        order: order,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
