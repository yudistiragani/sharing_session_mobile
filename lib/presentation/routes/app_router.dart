import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/product_usecases.dart';

import '../features/auth/pages/login_screen.dart';
import '../features/admin/pages/admin_home_page.dart';
import '../features/user/pages/user_home_page.dart';
import '../features/admin/pages/product_management_page.dart';
import '../features/admin/pages/user_management_page.dart';

import '../features/admin/bloc/product_bloc.dart';

class AppRouter {
  AppRouter({required this.productRepo});
  final ProductRepository productRepo;

  static const login         = '/';
  static const adminHome     = '/admin';
  static const userHome      = '/user';
  static const adminProducts = '/admin/products';
  static const adminUsers    = '/admin/users';

  Route<dynamic> onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomePage());

      case userHome:
        return MaterialPageRoute(builder: (_) => const UserHomePage());

      case adminProducts:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ProductBloc(
              getProductsUC: GetProducts(productRepo),
              getCategoriesUC: GetCategories(productRepo),
              updateStatusUC: UpdateProductStatus(productRepo),
              deleteProductUC: DeleteProduct(productRepo),
            ),
            child: const ProductManagementPage(),
          ),
        );

      case adminUsers:
        return MaterialPageRoute(builder: (_) => const UserManagementPage());

      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
