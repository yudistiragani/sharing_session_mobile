import 'dart:io';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';

abstract class AdminProductRemoteDataSource {
  /// POST product (form-url-encoded)
  Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required int price,
    required String categoryId,
    required int stock,
    required int lowStockThreshold,
    required String status, // active|inactive
  });

  /// Upload multiple images to product
  Future<Map<String, dynamic>> uploadProductImages({
    required String productId,
    required List<File> images,
    bool replace = false,
  });
}

class AdminProductRemoteDataSourceImpl implements AdminProductRemoteDataSource {
  final ApiClient client;
  AdminProductRemoteDataSourceImpl(this.client);

  @override
  Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required int price,
    required String categoryId,
    required int stock,
    required int lowStockThreshold,
    required String status,
  }) async {
    final body = {
      'name': name,
      'description': description,
      'price': price.toString(),
      'category_id': categoryId,
      'stock': stock.toString(),
      'low_stock_threshold': lowStockThreshold.toString(),
      'status': status,
    };

    // server expects x-www-form-urlencoded per your cURL
    final resp = await client.postForm(AppConstants.productsPath, body, includeAuth: true);
    return resp;
  }

  @override
  Future<Map<String, dynamic>> uploadProductImages({
    required String productId,
    required List<File> images,
    bool replace = false,
  }) async {
    if (images.isEmpty) return <String, dynamic>{};

    final path = '${AppConstants.productsPath}/$productId/images';
    final fields = <String, String>{
      'replace': replace ? 'true' : 'false',
    };

    final resp = await client.postMultipartFiles(
      path,
      fields: fields,
      files: images,
      fileField: 'files',
      includeAuth: true,
    );

    return resp;
  }
}
