import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserListResponse> getUsers({
    required int page,
    required int pageSize,
    String? search,
    String? status,   // mis: active|pending|blocked
    String? sortBy,   // created_at | name | email
    String? order,    // asc | desc
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient client;
  UserRemoteDataSourceImpl(this.client);

  @override
  Future<UserListResponse> getUsers({
    required int page,
    required int pageSize,
    String? search,
    String? status,
    String? sortBy,
    String? order,
  }) async {
    final qp = <String, String>{
      'page': '$page',
      'page_size': '$pageSize',
    };

    if (search != null && search.isNotEmpty) {
      qp['search'] = search;
    }

    if (status != null && status.isNotEmpty) {
      qp['status'] = status;
    }

    if (sortBy != null && sortBy.isNotEmpty) {
      qp['sort_by'] = sortBy;
    }

    if (order != null && order.isNotEmpty) {
      qp['order'] = order;
    }
    
    final map = await client.getJson(AppConstants.usersPath, query: qp);
    return UserListResponse.fromJson(map);
  }
}
