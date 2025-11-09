import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/utils/url_utils.dart';
import 'admin_add_user_page.dart';
import '../bloc/user_bloc.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();

    /// WAJIB, initial load
    context.read<UserBloc>().add(UserStarted());

    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 220) {
        context.read<UserBloc>().add(UserFetchMore());
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF7A00);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Management User',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final q = await showSearch<String?>(
                context: context,
                delegate: _UserSearchDelegate(),
              );
              if (q != null) {
                context.read<UserBloc>().add(
                    UserSearchChanged(q.trim().isEmpty ? null : q.trim())
                );
              }
            },
          ),
        ],
        surfaceTintColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: orange,
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AdminAddUserPage()),
          );

          if (result == true) {
            // halaman Add User mengembalikan true saat sukses.
            // Trigger reload list user: karena user_management_page.dart dibungkus UserBloc
            // kita dispatch event reload (sesuaikan nama event/Bloc-mu).
            context.read<UserBloc>().add(UserStarted()); // atau event reload yang kamu punya
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state.error != null && state.error!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Controls row
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StatusPill(
                        value: state.status,
                        onChanged: (v) => context.read<UserBloc>().add(UserStatusChanged(v)),
                      ),
                      const SizedBox(width: 8),
                      _DropdownPill<String>(
                        label: 'Sort',
                        value: state.sortBy,
                        items: const [
                          DropdownMenuItem(value: 'created_at', child: Text('Tanggal Buat')),
                          DropdownMenuItem(value: 'name', child: Text('Nama')),
                          DropdownMenuItem(value: 'email', child: Text('Email')),
                        ],
                        onChanged: (v) => context.read<UserBloc>().add(UserSortChanged(v!)),
                      ),
                      const SizedBox(width: 8),
                      _OrderPill(
                        asc: state.order == 'asc',
                        onChanged: (asc) =>
                            context.read<UserBloc>().add(UserOrderChanged(asc ? 'asc' : 'desc')),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => context.read<UserBloc>().add(UserRefresh()),
                  child: ListView.separated(
                    controller: _scroll,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: state.items.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      if (i >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final u = state.items[i];
                      final avatarUrl = (u.avatar == null || u.avatar!.isEmpty)
                          ? null
                          : UrlUtils.join(AppConstants.baseUrl, u.avatar!);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: _Avatar(url: avatarUrl, name: u.displayName),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                u.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            _StatusIcon(status: u.status),
                          ],
                        ),
                        subtitle: Text(
                          '${u.phone ?? '-'}  •  ${u.email}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


/// ============ Search ================
class _UserSearchDelegate extends SearchDelegate<String?> {
  @override
  String get searchFieldLabel => 'Cari user';

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            onPressed: () => query = '',
            icon: const Icon(Icons.clear),
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox.shrink();
}


/// ============ Pills / small widgets ================
class _DropdownPill<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _DropdownPill({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE6E7EA)),
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }
}

class _OrderPill extends StatelessWidget {
  final bool asc;
  final ValueChanged<bool> onChanged;
  const _OrderPill({required this.asc, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!asc),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFE6E7EA)),
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
        ),
        child: Row(children: [
          const Icon(Icons.sort, size: 18),
          const SizedBox(width: 6),
          Text(asc ? 'Asc' : 'Desc', style: const TextStyle(fontSize: 13)),
        ]),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _StatusPill({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final label = switch (value) {
      'active' => 'Active',
      'inactive' => 'Inactive',
      _ => 'Status',
    };

    return PopupMenuButton<String?>(
      onSelected: onChanged,
      itemBuilder: (context) => const <PopupMenuEntry<String?>>[
        PopupMenuItem<String?>(value: '', child: Text('Semua')),
        PopupMenuItem<String?>(value: 'active', child: Text('Active')),
        PopupMenuItem<String?>(value: 'inactive', child: Text('Inactive')),
      ],
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFE6E7EA)),
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  const _Avatar({required this.url,required this.name});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
      return CircleAvatar(radius: 22, child: Text(initial));
    }
    return CircleAvatar(
      radius: 22,
      backgroundImage: NetworkImage(url!),
      backgroundColor: Colors.transparent,
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final String status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == 'active') {
      return const Icon(Icons.verified, color: Colors.green, size: 16);
    } else {
      return const Icon(Icons.cancel, color: Colors.black87, size: 16);
    }
  }
}
