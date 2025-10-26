import 'package:flutter/material.dart';
import '../features/auth/pages/admin_home_page.dart';
import '../features/auth/pages/user_home_page.dart';
import '../features/auth/pages/login_screen.dart';

class AppRouter {
  static const login = '/';
  static const adminHome = '/admin';
  static const userHome  = '/user';

  static Route<dynamic> onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomePage());
      case userHome:
        return MaterialPageRoute(builder: (_) => const UserHomePage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
