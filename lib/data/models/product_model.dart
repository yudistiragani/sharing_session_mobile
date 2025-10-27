class ProductModel {
  final String id;
  final String name;
  final String? description;
  final int price;                 // rupiah
  final String? categoryId;
  final List<String> images;       // ex: ["/uploads/products/file.jpg"]
  final int stock;
  final int lowStockThreshold;
  final String status;             // "active" | "inactive"
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.categoryId,
    required this.images,
    required this.stock,
    required this.lowStockThreshold,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// status UI yang diinginkan desain:
  /// - Jika status != active → "Nonaktif"
  /// - Jika active & stock <= lowStockThreshold → "Menipis"
  /// - Selain itu → "Aktif"
  String get uiStatus {
    if (status != 'active') return 'inactive';
    if (stock <= lowStockThreshold) return 'low';
    return 'available';
  }

  factory ProductModel.fromJson(Map<String, dynamic> j) => ProductModel(
        id: (j['_id'] ?? j['id']).toString(),
        name: (j['name'] ?? '').toString(),
        description: j['description']?.toString(),
        price: (j['price'] as num?)?.toInt() ?? 0,
        categoryId: j['category_id']?.toString(),
        images: ((j['images'] ?? const <dynamic>[]) as List)
            .map((e) => e.toString())
            .toList(),
        stock: (j['stock'] as num?)?.toInt() ?? 0,
        lowStockThreshold: (j['low_stock_threshold'] as num?)?.toInt() ?? 0,
        status: (j['status'] ?? '').toString(),
        createdAt: j['created_at'] != null ? DateTime.tryParse(j['created_at'].toString()) : null,
        updatedAt: j['updated_at'] != null ? DateTime.tryParse(j['updated_at'].toString()) : null,
      );
}

class ProductListResponse {
  final List<ProductModel> items;
  final int page;
  final int pageSize;
  final int total;

  ProductListResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> j) {
    final listRaw = (j['items'] ??
        j['data'] ??
        j['products'] ??
        j['results'] ??
        j['rows'] ??
        []) as List;

    final items = listRaw
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProductListResponse(
      items: items,
      page: (j['page'] as num?)?.toInt() ?? 1,
      pageSize: (j['page_size'] as num?)?.toInt() ??
          (j['limit'] as num?)?.toInt() ??
          items.length,
      total: (j['total'] as num?)?.toInt() ??
          (j['count'] as num?)?.toInt() ??
          items.length,
    );
  }
}
