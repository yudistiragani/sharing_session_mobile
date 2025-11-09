import 'dart:io';
import '../../domain/repositories/admin_product_repository.dart';
import '../datasources/admin_product_remote_data_source.dart';

class AdminProductRepositoryImpl implements AdminProductRepository {
  final AdminProductRemoteDataSource remote;
  AdminProductRepositoryImpl({required this.remote});

  @override
  Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required int price,
    required String categoryId,
    required int stock,
    required int lowStockThreshold,
    required String status,
  }) {
    return remote.addProduct(
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      stock: stock,
      lowStockThreshold: lowStockThreshold,
      status: status,
    );
  }

  @override
  Future<Map<String, dynamic>> uploadProductImages({
    required String productId,
    required List<File> images,
    bool replace = false,
  }) {
    return remote.uploadProductImages(productId: productId, images: images, replace: replace);
  }
}
