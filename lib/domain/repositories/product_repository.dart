import '../../data/models/product_model.dart';
import '../../data/models/category_option_model.dart';

abstract class ProductRepository {
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
}
