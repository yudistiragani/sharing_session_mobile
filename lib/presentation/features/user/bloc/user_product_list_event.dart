part of 'user_product_list_bloc.dart';

abstract class UserProductListEvent {}

class UserProductsStarted extends UserProductListEvent {}

class UserProductsSearchChanged extends UserProductListEvent {
  final String? search;
  UserProductsSearchChanged(this.search);
}

class UserProductsSortChanged extends UserProductListEvent {
  final String sortBy; // 'name' | 'price' | 'created_at'
  UserProductsSortChanged(this.sortBy);
}

class UserProductsOrderChanged extends UserProductListEvent {
  final String order; // 'asc' | 'desc'
  UserProductsOrderChanged(this.order);
}

class UserProductsFilterApplied extends UserProductListEvent {
  final String? categoryId; // nullable → "Semua"
  final String? status;     // nullable → "Semua"
  UserProductsFilterApplied({this.categoryId, this.status});
}

class UserProductsRefresh extends UserProductListEvent {}
class UserProductsFetchMore extends UserProductListEvent {}
