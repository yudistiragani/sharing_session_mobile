import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ==== AUTH PAGES ====
import '../features/auth/pages/login_screen.dart';
import '../features/admin/pages/admin_home_page.dart';
import '../features/user/pages/user_home_page.dart';

// ==== PRODUCT ====
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/product_usecases.dart';
import '../features/admin/pages/product_management_page.dart';
import '../features/admin/bloc/product_bloc.dart';

// ==== USER ====
import '../../domain/usecases/user_usecases.dart';
import '../features/admin/pages/user_management_page.dart';
import '../features/admin/bloc/user_bloc.dart';
import '../features/user/bloc/user_home_bloc.dart';

import '../features/user/pages/user_product_list_page.dart';
import '../features/user/bloc/user_product_list_bloc.dart';
import '../../domain/usecases/product_usecases.dart';

import '../features/user/pages/user_product_detail_page.dart';


class AppRouter {
  final ProductRepository productRepo;
  final GetUsers getUsers;

  AppRouter({
    required this.productRepo,
    required this.getUsers,
  });

  static const login = '/';
  static const adminHome = '/admin';
  static const userHome  = '/user';
  static const adminProducts = '/admin/products';
  static const adminUsers    = '/admin/users';
  static const userProducts = '/user/products';
  static const userProductDetail = '/user/product/detail';

  Route<dynamic> onGenerate(RouteSettings settings) {
    switch (settings.name) {

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case userHome:
        final getProducts = GetProducts(productRepo);
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => UserHomeBloc(getProducts: getProducts)..add(UserHomeStarted()),
            child: const UserHomePage(),
          ),
        );
      case userProducts:
        final getProducts = GetProducts(productRepo);
        final getCategories = GetCategories(productRepo);
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => UserProductListBloc(
              getProducts: getProducts,
              getCategories: getCategories,
            )..add(UserProductsStarted()),
            child: const UserProductListPage(),
          ),
        );
      case userProductDetail:
        final productId = settings.arguments as String; // kirim via arguments
        return MaterialPageRoute(
          builder: (_) => UserProductDetailPage(
            productId: productId,
            productRepo: productRepo, // sudah ada di AppRouter constructor
          ),
        );
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomePage());
      case adminProducts:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ProductBloc(
              getProductsUC: GetProducts(productRepo),
              getCategoriesUC: GetCategories(productRepo),
              updateStatusUC: UpdateProductStatus(productRepo),
              deleteProductUC: DeleteProduct(productRepo),
            )..add(ProductStarted()),
            child: const ProductManagementPage(),
          ),
        );

      case adminUsers:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => UserBloc(getUsers: getUsers)..add(UserStarted()),
            child: const UserManagementPage(),
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
