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
  final String? categoryId; // nullable
  final String? status;     // nullable
  final String? sortBy;
  final String? order;
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
      (categoryId?.isNotEmpty == true ? 1 : 0) +
      (status?.isNotEmpty == true ? 1 : 0);

  // ---- SENTINEL TRICK ----
  static const _unset = Object();

  ProductState copyWith({
    List<ProductModel>? items,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    int? page,
    int? pageSize,
    int? total,
    Object? search = _unset,     // <-- pakai Object? + sentinel
    Object? categoryId = _unset, // <-- bisa set null
    Object? status = _unset,     // <-- bisa set null
    String? sortBy,
    String? order,
    List<CategoryOptionModel>? categories,
    Object? error = _unset,
  }) {
    return ProductState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,

      // jika argumen tidak diisi → pertahankan nilai lama,
      // jika diisi null → betul-betul menjadi null
      search: identical(search, _unset) ? this.search : search as String?,
      categoryId: identical(categoryId, _unset) ? this.categoryId : categoryId as String?,
      status: identical(status, _unset) ? this.status : status as String?,

      sortBy: sortBy ?? this.sortBy,
      order: order ?? this.order,
      categories: categories ?? this.categories,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}
