import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/product_model.dart';
import '../../../../domain/usecases/product_usecases.dart';

part 'user_home_event.dart';
part 'user_home_state.dart';

class UserHomeBloc extends Bloc<UserHomeEvent, UserHomeState> {
  final GetProducts getProducts;

  UserHomeBloc({required this.getProducts}) : super(const UserHomeState()) {
    on<UserHomeStarted>(_onStarted);
    on<UserHomeSearchChanged>(_onSearchChanged);
    on<UserHomeRefreshed>(_onRefreshed);
  }

  Future<void> _onStarted(
    UserHomeStarted e,
    Emitter<UserHomeState> emit,
  ) async {
    await _fetch(emit, search: state.search);
  }

  Future<void> _onSearchChanged(
    UserHomeSearchChanged e,
    Emitter<UserHomeState> emit,
  ) async {
    emit(state.copyWith(search: e.search));
    await _fetch(emit, search: e.search);
  }

  Future<void> _onRefreshed(
    UserHomeRefreshed e,
    Emitter<UserHomeState> emit,
  ) async {
    await _fetch(emit, search: state.search);
  }

  Future<void> _fetch(
    Emitter<UserHomeState> emit, {
    String? search,
  }) async {
    try {
      emit(state.copyWith(loading: true, error: null));
      final resp = await getProducts(
        page: 1,
        pageSize: 6,              // rekomendasi maks 6 item
        search: (search?.isNotEmpty ?? false) ? search : null,
        status: 'active',
        sortBy: 'created_at',
        order: 'desc',
      );
      emit(state.copyWith(loading: false, items: resp.items, total: resp.total));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }
}
