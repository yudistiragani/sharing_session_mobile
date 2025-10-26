import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'core/network/api_client.dart';
import 'core/utils/logger.dart';

import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/login_user.dart';
import 'presentation/features/auth/bloc/auth_bloc.dart';
import 'presentation/routes/app_router.dart';

void main() {
  final apiClient = ApiClient(http.Client());
  final ds = AuthRemoteDataSourceImpl(apiClient);
  final repo = AuthRepositoryImpl(ds);
  final loginUC = LoginUser(repo);
  appLogger.configure(
    enabledInRelease: false,
    maxBodyLength: 5000,
  );

  runApp(MyApp(loginUC));
}

class MyApp extends StatelessWidget {
  final LoginUser loginUser;
  const MyApp(this.loginUser, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(loginUser),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Auth Demo',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFFF7A00),
          scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        ),
        onGenerateRoute: AppRouter.onGenerate,
        initialRoute: AppRouter.login,
      ),
    );
  }
}
