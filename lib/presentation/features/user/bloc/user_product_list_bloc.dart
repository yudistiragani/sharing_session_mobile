import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/category_option_model.dart';
import '../../../../domain/usecases/product_usecases.dart';

part 'user_product_list_event.dart';
part 'user_product_list_state.dart';

class UserProductListBloc extends Bloc<UserProductListEvent, UserProductListState> {
  final GetProducts getProducts;
  final GetCategories getCategories;

  UserProductListBloc({
    required this.getProducts,
    required this.getCategories,
  }) : super(const UserProductListState()) {
    on<UserProductsStarted>(_onStarted);
    on<UserProductsSearchChanged>(_onSearchChanged);
    on<UserProductsSortChanged>(_onSortChanged);
    on<UserProductsOrderChanged>(_onOrderChanged);
    on<UserProductsFilterApplied>(_onFilterApplied);
    on<UserProductsRefresh>(_onRefresh);
    on<UserProductsFetchMore>(_onFetchMore);
  }

  Future<void> _onStarted(UserProductsStarted e, Emitter<UserProductListState> emit) async {
    // Load categories (once)
    try {
      emit(state.copyWith(loading: true, error: null));
      final cats = await getCategories();
      emit(state.copyWith(categories: cats));
    } catch (_) {}
    await _fetch(page: 1, emit: emit, reset: true);
  }

  Future<void> _onSearchChanged(UserProductsSearchChanged e, Emitter<UserProductListState> emit) async {
    emit(state.copyWith(search: e.search));
    await _fetch(page: 1, emit: emit, reset: true);
  }

  Future<void> _onSortChanged(UserProductsSortChanged e, Emitter<UserProductListState> emit) async {
    emit(state.copyWith(sortBy: e.sortBy));
    await _fetch(page: 1, emit: emit, reset: true);
  }

  Future<void> _onOrderChanged(UserProductsOrderChanged e, Emitter<UserProductListState> emit) async {
    emit(state.copyWith(order: e.order));
    await _fetch(page: 1, emit: emit, reset: true);
  }

  Future<void> _onFilterApplied(UserProductsFilterApplied e, Emitter<UserProductListState> emit) async {
    emit(state.copyWith(categoryId: e.categoryId, status: e.status));
    await _fetch(page: 1, emit: emit, reset: true);
  }

  Future<void> _onRefresh(UserProductsRefresh e, Emitter<UserProductListState> emit) async {
    await _fetch(page: 1, emit: emit, reset: true);
  }

  Future<void> _onFetchMore(UserProductsFetchMore e, Emitter<UserProductListState> emit) async {
    if (!state.hasMore || state.loadingMore || state.loading) return;
    final next = state.page + 1;
    await _fetch(page: next, emit: emit, reset: false);
  }

  Future<void> _fetch({
      required int page,
      required Emitter<UserProductListState> emit,
      required bool reset,
    }) async {
      try {
        if (reset) {
          emit(state.copyWith(loading: true, error: null, page: 1, hasMore: true));
        } else {
          emit(state.copyWith(loadingMore: true, error: null));
        }

        // +++ SANITASI HANYA DI SINI (USER LAYER)
        final search = (state.search?.trim().isNotEmpty ?? false) ? state.search!.trim() : null;
        final cat    = (state.categoryId?.trim().isNotEmpty ?? false) ? state.categoryId!.trim() : null;
        final st     = (state.status?.trim().isNotEmpty ?? false) ? state.status!.trim().toLowerCase() : null;
        final sort   = (state.sortBy.trim().isNotEmpty) ? state.sortBy.trim() : 'name';
        final ord    = (state.order.trim().isNotEmpty)  ? state.order.trim()  : 'asc';

        final resp = await getProducts(
          page: page,
          pageSize: state.pageSize,
          search: search,
          categoryId: cat,  // null = tidak dikirim
          status: st,       // null = tidak dikirim
          sortBy: sort,     // 'name' | 'price'
          order: ord,       // 'asc' | 'desc'
        );

        final newItems = reset ? resp.items : [...state.items, ...resp.items];
        final hasMore = newItems.length < resp.total;

        emit(state.copyWith(
          loading: false,
          loadingMore: false,
          items: newItems,
          page: page,
          total: resp.total,
          hasMore: hasMore,
        ));
      } catch (err) {
        emit(state.copyWith(
          loading: false,
          loadingMore: false,
          error: err.toString(),
        ));
      }
    }
}
