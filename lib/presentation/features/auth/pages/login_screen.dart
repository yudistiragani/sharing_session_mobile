import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../common_widgets/primary_button.dart';
import '../../../routes/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _u = TextEditingController();
  final _p = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _u.dispose();
    _p.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthLoginRequested(_u.text.trim(), _p.text));
    }
  }

  void navigateAfterLogin(BuildContext context, String role) {
  switch (role) {
    case 'admin':
      Navigator.pushReplacementNamed(context, AppRouter.adminHome);
      break;
    case 'user':
      Navigator.pushReplacementNamed(context, AppRouter.userHome);
      break;
    default:
      Navigator.pushReplacementNamed(context, AppRouter.userHome);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error ?? 'Login failed')),
              );
            } else if (state.status == AuthStatus.success && state.user != null) {
              final role = state.user!.role;
              // if (role == 'admin') {
              //   Navigator.pushReplacementNamed(context, AppRouter.adminHome);
              // } else {
              //   Navigator.pushReplacementNamed(context, AppRouter.userHome);
              // }
              navigateAfterLogin(context, role);
            }
          },
          child: LayoutBuilder(
            builder: (_, c) {
              final maxW = c.maxWidth;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW > 480 ? 420 : maxW * .92),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('assets/logo.png', height: 30),
                            const SizedBox(height: 12),
                            const Text(
                              'Enter your username and password correctly',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Username', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _u,
                                decoration: InputDecoration(
                                  hintText: 'Enter username',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (v) => Validators.required(v, field: 'Username'),
                              ),
                              const SizedBox(height: 16),
                              const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _p,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  hintText: 'Enter password',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                  ),
                                ),
                                validator: (v) => Validators.required(v, field: 'Password'),
                              ),
                              const SizedBox(height: 24),
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return PrimaryButton(
                                    text: 'Sign In',
                                    loading: state.status == AuthStatus.loading,
                                    onPressed: _onSubmit,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
