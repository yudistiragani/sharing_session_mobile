import 'dart:io';

abstract class AdminProductRepository {
  Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required int price,
    required String categoryId,
    required int stock,
    required int lowStockThreshold,
    required String status,
  });

  Future<Map<String, dynamic>> uploadProductImages({
    required String productId,
    required List<File> images,
    bool replace,
  });
}
