import '../repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_option_model.dart';

class GetProducts {
  final ProductRepository repo;
  GetProducts(this.repo);
  Future<ProductListResponse> call({
    required int page, required int pageSize,
    String? search, String? categoryId, String? status,
    String? sortBy, String? order,
  }) => repo.getProducts(
        page: page, pageSize: pageSize, search: search,
        categoryId: categoryId, status: status, sortBy: sortBy, order: order);
}

class GetCategories {
  final ProductRepository repo;
  GetCategories(this.repo);
  Future<List<CategoryOptionModel>> call() => repo.getCategories();
}

class UpdateProductStatus {
  final ProductRepository repo;
  UpdateProductStatus(this.repo);
  Future<void> call(String id, String status) => repo.updateStatus(id: id, status: status);
}

class DeleteProduct {
  final ProductRepository repo;
  DeleteProduct(this.repo);
  Future<void> call(String id) => repo.deleteProduct(id: id);
}
