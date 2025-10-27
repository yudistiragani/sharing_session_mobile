part of 'product_bloc.dart';

class ProductState {
  final List<ProductModel> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final int page;
  final int pageSize;
  final int total;

  final String? search;
  final String? categoryId;
  final String? status;      // "active" | "inactive"
  final String? sortBy;      // name | price | stock
  final String? order;       // asc | desc
  final List<CategoryOptionModel> categories;
  final String? error;

  const ProductState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.hasMore = false,
    this.page = 1,
    this.pageSize = 10,
    this.total = 0,
    this.search,
    this.categoryId,
    this.status,
    this.sortBy = 'name',
    this.order = 'asc',
    this.categories = const [],
    this.error,
  });

  int get activeFilterCount =>
      (categoryId?.isNotEmpty == true ? 1 : 0) + (status?.isNotEmpty == true ? 1 : 0);

  ProductState copyWith({
    List<ProductModel>? items,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    int? page,
    int? pageSize,
    int? total,
    String? search,
    String? categoryId,
    String? status,
    String? sortBy,
    String? order,
    List<CategoryOptionModel>? categories,
    String? error,
  }) {
    return ProductState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      search: search ?? this.search,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      sortBy: sortBy ?? this.sortBy,
      order: order ?? this.order,
      categories: categories ?? this.categories,
      error: error,
    );
  }
}
