part of 'user_product_list_bloc.dart';

class UserProductListState {
  final List<ProductModel> items;
  final bool loading;
  final bool loadingMore;
  final String? error;

  final int page;
  final int pageSize;
  final int total;
  final bool hasMore;

  final String? search;
  final String sortBy; // 'name' atau 'price'
  final String order;  // 'asc' | 'desc'

  final String? categoryId;
  final String? status; // 'active' | 'inactive' | null

  final List<CategoryOptionModel> categories;

  const UserProductListState({
    this.items = const <ProductModel>[],
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.hasMore = true,
    this.search,
    this.sortBy = 'name',
    this.order = 'asc',
    this.categoryId,
    this.status,
    this.categories = const <CategoryOptionModel>[],
  });

  int get activeFilterCount {
    int c = 0;
    if (categoryId != null && categoryId!.isNotEmpty) c++;
    if (status != null && status!.isNotEmpty) c++;
    return c;
  }

  // ====== SENTINEL utk field yang bisa sengaja di-null ======
  static const _unset = Object();

  UserProductListState copyWith({
    List<ProductModel>? items,
    bool? loading,
    bool? loadingMore,
    String? error,         // kirim null untuk clear error
    int? page,
    int? pageSize,
    int? total,
    bool? hasMore,
    String? search,        // kirim null untuk clear search
    String? sortBy,
    String? order,

    // Pakai sentinel: kalau parameter tidak dikirim → pertahankan nilai lama.
    Object? categoryId = _unset,
    Object? status     = _unset,

    List<CategoryOptionModel>? categories,
  }) {
    return UserProductListState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      order: order ?? this.order,
      // hanya berubah kalau parameter dikirim
      categoryId: identical(categoryId, _unset) ? this.categoryId : categoryId as String?,
      status:     identical(status, _unset)     ? this.status     : status as String?,
      categories: categories ?? this.categories,
    );
  }
}
