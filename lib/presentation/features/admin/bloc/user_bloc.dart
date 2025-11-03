import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../data/models/user_model.dart';
import '../../../../domain/usecases/user_usecases.dart';

/// ================= EVENTS =================
abstract class UserEvent {}

class UserStarted extends UserEvent {}
class UserFetchMore extends UserEvent {}
class UserRefresh extends UserEvent {}

class UserSearchChanged extends UserEvent {
  final String? search;
  UserSearchChanged(this.search);
}

class UserStatusChanged extends UserEvent {
  final String? status; // null | active | inactive
  UserStatusChanged(this.status);
}

class UserSortChanged extends UserEvent {
  final String sortBy;
  UserSortChanged(this.sortBy);
}

class UserOrderChanged extends UserEvent {
  final String order; // asc / desc
  UserOrderChanged(this.order);
}

/// ================= STATE =================
class UserState {
  final List<UserModel> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final int page;
  final int pageSize;
  final int total;

  final String? search;
  final String? status;
  final String sortBy;
  final String order;
  final String? error;

  const UserState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.hasMore = false,
    this.page = 1,
    this.pageSize = 10,
    this.total = 0,
    this.search,
    this.status,
    this.sortBy = 'created_at',
    this.order = 'desc',
    this.error,
  });

  static const _unset = Object();

  UserState copyWith({
    List<UserModel>? items,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    int? page,
    int? pageSize,
    int? total,
    Object? search = _unset,
    Object? status = _unset,
    String? sortBy,
    String? order,
    Object? error = _unset,
  }) {
    return UserState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      search: identical(search, _unset) ? this.search : search as String?,
      status: identical(status, _unset) ? this.status : status as String?,
      sortBy: sortBy ?? this.sortBy,
      order: order ?? this.order,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

/// ================= BLOC =================
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUsers getUsers;

  UserBloc({required this.getUsers}) : super(const UserState()) {
    on<UserStarted>(_onStarted);
    on<UserFetchMore>(_onFetchMore);
    on<UserRefresh>(_onRefresh);
    on<UserSearchChanged>(_onSearch);
    on<UserStatusChanged>(_onStatus);
    on<UserSortChanged>(_onSort);
    on<UserOrderChanged>(_onOrder);
  }

  Future<void> _load(Emitter<UserState> emit,{bool append = false}) async {
    emit(state.copyWith(loading: !append, loadingMore: append, error: null));

    try {
      final r = await getUsers(
        page: state.page,
        pageSize: state.pageSize,
        search: state.search,
        status: state.status,
        sortBy: state.sortBy,
        order: state.order,
      );

      final newList = append
          ? <UserModel>[...state.items, ...r.items]
          : <UserModel>[...r.items];

      emit(
        state.copyWith(
          items: newList,
          total: r.total,
          hasMore: newList.length < r.total,
          loading: false,
          loadingMore: false,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, loadingMore: false, error: f.message));
    } catch (e) {
      emit(state.copyWith(loading: false, loadingMore: false, error: e.toString()));
    }
  }

  Future<void> _onStarted(UserStarted e,Emitter<UserState> emit) async {
    await _load(emit);
  }

  Future<void> _onFetchMore(UserFetchMore e,Emitter<UserState> emit) async {
    if (!state.hasMore || state.loadingMore) return;
    emit(state.copyWith(page: state.page + 1));
    await _load(emit, append: true);
  }

  Future<void> _onRefresh(UserRefresh e,Emitter<UserState> emit) async {
    emit(state.copyWith(page: 1, items: <UserModel>[]));
    await _load(emit);
  }

  Future<void> _onSearch(UserSearchChanged e,Emitter<UserState> emit) async {
    emit(state.copyWith(search: e.search, page: 1, items: <UserModel>[]));
    await _load(emit);
  }

  Future<void> _onStatus(UserStatusChanged e, Emitter<UserState> emit) async {
    final newStatus = (e.status == null || e.status!.isEmpty) ? null : e.status;

    emit(state.copyWith(
      status: newStatus,
      page: 1,
      items: <UserModel>[], // force reload
    ));

    await _load(emit);
  }


  Future<void> _onSort(UserSortChanged e,Emitter<UserState> emit) async {
    emit(state.copyWith(sortBy: e.sortBy, page: 1, items: <UserModel>[]));
    await _load(emit);
  }

  Future<void> _onOrder(UserOrderChanged e,Emitter<UserState> emit) async {
    emit(state.copyWith(order: e.order, page: 1, items: <UserModel>[]));
    await _load(emit);
  }
}
