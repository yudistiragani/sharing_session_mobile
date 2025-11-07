import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/network/api_client.dart';
import 'core/constants/app_constants.dart';

// ===== AUTH LAYERS =====
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/login_user.dart';
import 'domain/usecases/logout_user.dart';
import 'presentation/features/auth/bloc/auth_bloc.dart';

// ===== PRODUCT LAYERS =====
import 'data/datasources/product_remote_data_source.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/product_repository.dart';

// ===== USER LAYERS =====
import 'data/datasources/user_remote_data_source.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/usecases/user_usecases.dart';

// Router
import 'presentation/routes/app_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // HTTP & API client (dipakai semua stack)
  final httpClient = http.Client();
  final apiClient = ApiClient(http.Client(), onUnauthorized: () {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRouter.login,
      (route) => false,
    );
  });

  // ========== AUTH ==========
  final authDS   = AuthRemoteDataSourceImpl(apiClient);
  final authRepo = AuthRepositoryImpl(authDS, apiClient);
  final loginUC  = LoginUser(authRepo);
  final logoutUC = LogoutUser(authRepo);

  // ========== PRODUCT ==========
  final productDS   = ProductRemoteDataSourceImpl(apiClient);
  final ProductRepository productRepo = ProductRepositoryImpl(productDS);

  // ========== USER ==========
  final userDS   = UserRemoteDataSourceImpl(apiClient);
  final userRepo = UserRepositoryImpl(userDS);
  final getUsers = GetUsers(userRepo);

  // Tentukan halaman awal dari token & role
  final initialRoute = await _resolveInitialRoute();

  runApp(MyApp(
    loginUser: loginUC,
    logoutUser: logoutUC,
    productRepo: productRepo,
    getUsers: getUsers,
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
  final GetUsers getUsers;
  final String initialRoute;

  const MyApp({
    super.key,
    required this.loginUser,
    required this.logoutUser,
    required this.productRepo,
    required this.getUsers,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    // Router butuh productRepo & getUsers
    final router = AppRouter(
      productRepo: productRepo,
      getUsers: getUsers,
    );

    return MultiBlocProvider(
      providers: [
        // AuthBloc dipasang global (biar login/logout bisa dipanggil dari mana saja)
        BlocProvider(
          create: (_) => AuthBloc(loginUser, logoutUser),
        ),
        // NOTE:
        // ProductBloc & UserBloc disediakan per-route di AppRouter,
        // jadi tidak perlu dipasang global di sini.
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
