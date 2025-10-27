import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../data/models/product_model.dart';
import '../../../../../data/models/category_option_model.dart';
import '../../../../../domain/usecases/product_usecases.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProductsUC;
  final GetCategories getCategoriesUC;
  final UpdateProductStatus updateStatusUC;
  final DeleteProduct deleteProductUC;

  ProductBloc({
    required this.getProductsUC,
    required this.getCategoriesUC,
    required this.updateStatusUC,
    required this.deleteProductUC,
  }) : super(const ProductState()) {
    on<ProductStarted>(_onStarted);
    on<ProductFetchMore>(_onFetchMore);
    on<ProductSearchChanged>(_onSearch);
    on<ProductFilterChanged>(_onFilter);
    on<ProductSortChanged>(_onSort);
    on<ProductOrderChanged>(_onOrder);
    on<ProductRefresh>(_onRefresh);
    on<ProductStatusUpdateRequested>(_onUpdateStatus);
    on<ProductDeleteRequested>(_onDelete);
  }

  Future<void> _load(Emitter<ProductState> emit, {bool append = false}) async {
    emit(state.copyWith(loading: !append, loadingMore: append, error: null));
    try {
      final res = await getProductsUC(
        page: state.page,
        pageSize: state.pageSize,
        search: state.search,
        categoryId: state.categoryId,
        status: state.status,
        sortBy: state.sortBy,
        order: state.order,
      );
      final items = append ? [...state.items, ...res.items] : res.items;
      final hasMore = items.length < res.total;
      emit(state.copyWith(
        items: items,
        hasMore: hasMore,
        loading: false,
        loadingMore: false,
        total: res.total,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, loadingMore: false, error: f.message));
    } catch (e) {
      emit(state.copyWith(loading: false, loadingMore: false, error: e.toString()));
    }
  }

  Future<void> _onStarted(ProductStarted e, Emitter<ProductState> emit) async {
    try {
      final cats = await getCategoriesUC();
      emit(state.copyWith(categories: cats));
    } catch (_) {}
    await _load(emit);
  }

  Future<void> _onFetchMore(ProductFetchMore e, Emitter<ProductState> emit) async {
    if (state.loadingMore || !state.hasMore) return;
    emit(state.copyWith(page: state.page + 1));
    await _load(emit, append: true);
  }

  Future<void> _onSearch(ProductSearchChanged e, Emitter<ProductState> emit) async {
    emit(state.copyWith(search: e.search, page: 1));
    await _load(emit);
  }

  Future<void> _onFilter(ProductFilterChanged e, Emitter<ProductState> emit) async {
    emit(state.copyWith(categoryId: e.categoryId, status: e.status, page: 1));
    await _load(emit);
  }

  Future<void> _onSort(ProductSortChanged e, Emitter<ProductState> emit) async {
    emit(state.copyWith(sortBy: e.sortBy, page: 1));
    await _load(emit);
  }

  Future<void> _onOrder(ProductOrderChanged e, Emitter<ProductState> emit) async {
    emit(state.copyWith(order: e.order, page: 1));
    await _load(emit);
  }

  Future<void> _onRefresh(ProductRefresh e, Emitter<ProductState> emit) async {
    emit(state.copyWith(page: 1));
    await _load(emit);
  }

  Future<void> _onUpdateStatus(ProductStatusUpdateRequested e, Emitter<ProductState> emit) async {
    try {
      await updateStatusUC(e.id, e.status);
      add(ProductRefresh());
    } on Failure catch (f) {
      emit(state.copyWith(error: f.message));
    }
  }

  Future<void> _onDelete(ProductDeleteRequested e, Emitter<ProductState> emit) async {
    try {
      await deleteProductUC(e.id);
      add(ProductRefresh());
    } on Failure catch (f) {
      emit(state.copyWith(error: f.message));
    }
  }
}
