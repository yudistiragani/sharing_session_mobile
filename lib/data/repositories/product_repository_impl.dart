import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';
import '../models/category_option_model.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;
  ProductRepositoryImpl(this.remote);

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
    try {
      return await remote.getProducts(
        page: page,
        pageSize: pageSize,
        search: search,
        categoryId: categoryId,
        status: status,
        sortBy: sortBy,
        order: order,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<CategoryOptionModel>> getCategories() async {
    try {
      return await remote.getCategories();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> updateStatus({required String id, required String status}) async {
    try {
      await remote.updateStatus(id: id, status: status);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> deleteProduct({required String id}) async {
    try {
      await remote.deleteProduct(id: id);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
