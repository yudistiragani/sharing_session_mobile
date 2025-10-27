import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/constants/app_constants.dart';

// Auth layers
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/login_user.dart';
import 'domain/usecases/logout_user.dart';
import 'presentation/features/auth/bloc/auth_bloc.dart';

// Product layers
import 'data/datasources/product_remote_data_source.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/product_repository.dart';

// Router
import 'presentation/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Wiring dependencies
  final httpClient = http.Client();
  final apiClient = ApiClient(httpClient);

  // Auth
  final authDS   = AuthRemoteDataSourceImpl(apiClient);
  final authRepo = AuthRepositoryImpl(authDS);
  final loginUC  = LoginUser(authRepo);
  final logoutUC = LogoutUser(authRepo);

  // Product
  final productDS   = ProductRemoteDataSourceImpl(apiClient);
  final ProductRepository productRepo = ProductRepositoryImpl(productDS);

  // Tentukan initial route dari token/role
  final initialRoute = await _resolveInitialRoute();

  runApp(MyApp(
    loginUser: loginUC,
    logoutUser: logoutUC,
    productRepo: productRepo,
    initialRoute: initialRoute,
  ));
}

/// Cek token & role untuk menentukan halaman awal
Future<String> _resolveInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(AppConstants.kTokenKey);
  final role  = prefs.getString(AppConstants.kRoleKey);
  if (token != null && token.isNotEmpty && role != null && role.isNotEmpty) {
    if (role == 'admin') return AppRouter.adminHome;
    return AppRouter.userHome;
  }
  return AppRouter.login;
}

class MyApp extends StatelessWidget {
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final ProductRepository productRepo;
  final String initialRoute;

  const MyApp({
    super.key,
    required this.loginUser,
    required this.logoutUser,
    required this.productRepo,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(productRepo: productRepo);

    return MultiBlocProvider(
      providers: [
        // AuthBloc di level app (untuk login/logout dari mana saja)
        BlocProvider(
          create: (_) => AuthBloc(loginUser, logoutUser),
        ),
        // NOTE: ProductBloc diprovider di AppRouter pada route /admin/products,
        // jadi tidak perlu dipasang global di sini.
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Admin Panel',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFFF7A00),
          scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        ),
        initialRoute: initialRoute,
        onGenerateRoute: router.onGenerate,
      ),
    );
  }
}
