part of 'user_home_bloc.dart';

class UserHomeState {
  final List<ProductModel> items;
  final bool loading;
  final String? error;
  final String? search;
  final int total;

  const UserHomeState({
    this.items = const <ProductModel>[],
    this.loading = false,
    this.error,
    this.search,
    this.total = 0,
  });

  UserHomeState copyWith({
    List<ProductModel>? items,
    bool? loading,
    String? error,   // kirim null untuk clear
    String? search,  // kirim null untuk clear
    int? total,
  }) {
    return UserHomeState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: error,
      search: search,
      total: total ?? this.total,
    );
  }
}
