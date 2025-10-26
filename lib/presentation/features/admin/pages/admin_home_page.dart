import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../routes/app_router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  static const _orange = Color(0xFFFF7A00);

  // 🔸 Konfirmasi sebelum logout
  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun admin ini?',
          style: TextStyle(height: 1.4),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(AuthLogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = <_AdminCard>[
      _AdminCard(
        title: 'Manajemen Produk',
        subtitle: 'Kelola katalog, harga, dan stok',
        icon: Icons.inventory_2_outlined,
        onTap: () => Navigator.pushNamed(context, AppRouter.adminProducts),
      ),
      _AdminCard(
        title: 'Manajemen User',
        subtitle: 'Kelola akun dan peran pengguna',
        icon: Icons.group_outlined,
        onTap: () => Navigator.pushNamed(context, AppRouter.adminUsers),
      ),
    ];

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.loggedOut) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRouter.login, (_) => false);
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error ?? 'Logout gagal')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0.5,
          actions: [
            Builder(builder: (context) {
              final isLoggingOut = context.select<AuthBloc, bool>(
                  (bloc) => bloc.state.status == AuthStatus.loggingOut);

              return IconButton(
                tooltip: 'Logout',
                onPressed:
                    isLoggingOut ? null : () => _confirmLogout(context),
                icon: isLoggingOut
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.logout_rounded, color: Colors.black87),
              );
            }),
            const SizedBox(width: 8),
          ],
        ),
        drawer: _AdminDrawer(onLogout: () => _confirmLogout(context)),
        body: LayoutBuilder(
          builder: (_, c) {
            final isWide = c.maxWidth >= 720;
            final cross = isWide ? 2 : 1;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: GridView.builder(
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: isWide ? 2 : 2.8,
                ),
                itemBuilder: (context, i) => _DashboardCard(data: cards[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final _AdminCard data;
  const _DashboardCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EBF0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: const Color(0xFFFF7A00)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(data.subtitle,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 18, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  _AdminCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class _AdminDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  const _AdminDrawer({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const ListTile(
              leading: Icon(Icons.dashboard_outlined),
              title: Text('Dashboard'),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Manajemen Produk'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.adminProducts);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: const Text('Manajemen User'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.adminUsers);
              },
            ),
            const Spacer(),
            ListTile(
              leading:
                  const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
