import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../models/product_model.dart';
import '../models/category_option_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductListResponse> getProducts({
    required int page,
    required int pageSize,
    String? search,
    String? categoryId,
    String? status,
    String? sortBy,
    String? order,
  });

  Future<List<CategoryOptionModel>> getCategories();

  Future<void> updateStatus({required String id, required String status});
  Future<void> deleteProduct({required String id});
  Future<ProductModel> getProductById(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient client;
  ProductRemoteDataSourceImpl(this.client);

  @override
  Future<ProductListResponse> getProducts({
    required int page,
    required int pageSize,
    String? search,
    String? categoryId,
    String? status,
    String? sortBy,
    String? order,
  }) async {
    final qp = <String, String>{ 'page': '$page', 'page_size': '$pageSize' };
    if (search?.isNotEmpty == true) qp['search'] = search!;
    if (categoryId?.isNotEmpty == true) qp['category_id'] = categoryId!;
    if (status?.isNotEmpty == true) qp['status'] = status!;
    if (sortBy?.isNotEmpty == true) qp['sort_by'] = sortBy!;
    if (order?.isNotEmpty == true) qp['order'] = order!;

    final map = await client.getJson(AppConstants.productsPath, query: qp); // ⬅️ token otomatis
    return ProductListResponse.fromJson(map);
  }

  @override
  Future<List<CategoryOptionModel>> getCategories() async {
    final obj = await client.getJson(AppConstants.categoriesPath); // ⬅️ token otomatis
    final raw = ((obj['items'] ?? obj['data'] ?? obj['results'] ?? obj['categories'])) as List<dynamic>? ?? const <dynamic>[];
    return raw
        .map((e) => CategoryOptionModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  @override
  Future<void> updateStatus({required String id, required String status}) async {
    await client.putJson('${AppConstants.productsPath}/$id/status', {'status': status}); // ⬅️ token otomatis
  }

  @override
  Future<void> deleteProduct({required String id}) async {
    await client.deleteJson('${AppConstants.productsPath}/$id'); // ⬅️ token otomatis
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final map = await client.getJson('/api/v1/products/$id');
    return ProductModel.fromJson(map);
  }
}
