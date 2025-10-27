part of 'product_bloc.dart';

abstract class ProductEvent {}

class ProductStarted extends ProductEvent {}
class ProductFetchMore extends ProductEvent {}
class ProductRefresh extends ProductEvent {}

class ProductSearchChanged extends ProductEvent {
  final String? search;
  ProductSearchChanged(this.search);
}

class ProductFilterChanged extends ProductEvent {
  final String? categoryId;
  final String? status; // "active" | "inactive"
  ProductFilterChanged({this.categoryId, this.status});
}

class ProductSortChanged extends ProductEvent {
  final String? sortBy; // name | price | stock
  ProductSortChanged(this.sortBy);
}

class ProductOrderChanged extends ProductEvent {
  final String? order; // asc | desc
  ProductOrderChanged(this.order);
}

class ProductStatusUpdateRequested extends ProductEvent {
  final String id;
  /// kirim "active" | "inactive"
  final String status;
  ProductStatusUpdateRequested(this.id, this.status);
}

class ProductDeleteRequested extends ProductEvent {
  final String id;
  ProductDeleteRequested(this.id);
}
