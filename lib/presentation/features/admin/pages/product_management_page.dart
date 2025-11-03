import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/utils/url_utils.dart';
import '../bloc/product_bloc.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});
  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final _search = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // kalau AppRouter sudah memanggil ProductStarted(), baris ini bisa dihapus.
    // context.read<ProductBloc>().add(ProductStarted());
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 220) {
        context.read<ProductBloc>().add(ProductFetchMore());
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF7A00);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        titleSpacing: 0,
        title: _SearchInAppBar(
          controller: _search,
          onSubmit: (v) =>
              context.read<ProductBloc>().add(ProductSearchChanged(v.trim())),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        surfaceTintColor: Colors.white,
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state.error != null && state.error!.isNotEmpty) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Filter & sort (horizontal scroll supaya aman di layar kecil)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _DropdownPill<String>(
                        label: 'Nama Produk',
                        value: state.sortBy ?? 'name',
                        items: const [
                          DropdownMenuItem(
                              value: 'name', child: Text('Nama Produk')),
                          DropdownMenuItem(value: 'price', child: Text('Harga')),
                          DropdownMenuItem(value: 'stock', child: Text('Stok')),
                          DropdownMenuItem(
                              value: 'created_at', child: Text('Tanggal Buat')),
                        ],
                        onChanged: (v) => context
                            .read<ProductBloc>()
                            .add(ProductSortChanged(v)),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        count: state.activeFilterCount,
                        onTap: () => _openFilterSheet(context, state),
                      ),
                      const SizedBox(width: 8),
                      _OrderPill(
                        asc: (state.order ?? 'asc') == 'asc',
                        onChanged: (asc) => context
                            .read<ProductBloc>()
                            .add(ProductOrderChanged(asc ? 'asc' : 'desc')),
                      ),
                    ],
                  ),
                ),
              ),

              // Daftar produk
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async =>
                      context.read<ProductBloc>().add(ProductRefresh()),
                  child: ListView.separated(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: state.items.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      if (i >= state.items.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final p = state.items[i];

                      // URL gambar aman dari double slash
                      final firstImagePath =
                          p.images.isNotEmpty ? p.images.first : null;
                      final imageUrl = firstImagePath == null
                          ? null
                          : UrlUtils.join(AppConstants.baseUrl, firstImagePath);

                      // status UI (available | low | inactive) → label & warna
                      final uiStatus = p.uiStatus; // asumsi ada getter di model
                      final statusClr = _statusColorFromUi(uiStatus);
                      final statusLabel = _statusLabelFromUi(uiStatus);

                      return _ProductCard(
                        name: p.name,
                        price: formatRupiah(p.price),
                        category: null, // isi jika kamu punya nama kategori
                        stock: p.stock,
                        statusLabel: statusLabel,
                        statusColor: statusClr,
                        imageUrl: imageUrl,
                        onEdit: () {
                          // TODO: navigate ke edit produk
                        },
                        onChangeStatus: () =>
                            _openStatusSheet(context, p.id, p.status),
                        onDelete: () => _confirmDelete(context, p.id),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: orange,
        onPressed: () {
          // TODO: navigate ke tambah produk
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _openFilterSheet(
      BuildContext context, ProductState state) async {
    final bloc = context.read<ProductBloc>();
    String? selectedCat = state.categoryId;
    String? selectedStatus = state.status;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(builder: (context, set) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),

              // Kategori
              const Text('Kategori',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: (selectedCat == null || selectedCat!.isEmpty),
                    onSelected: (_) => set(() => selectedCat = null),
                  ),
                  for (final c in state.categories)
                    ChoiceChip(
                      label: Text(c.name),
                      selected: selectedCat == c.id,
                      onSelected: (_) => set(() => selectedCat = c.id),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Status (active/inactive sesuai API-mu)
              const Text('Status',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected:
                        (selectedStatus == null || selectedStatus!.isEmpty),
                    onSelected: (_) => set(() => selectedStatus = null),
                  ),
                  ChoiceChip(
                    label: const Text('Aktif'),
                    selected: selectedStatus == 'active',
                    onSelected: (_) => set(() => selectedStatus = 'active'),
                  ),
                  ChoiceChip(
                    label: const Text('Nonaktif'),
                    selected: selectedStatus == 'inactive',
                    onSelected: (_) => set(() => selectedStatus = 'inactive'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        selectedCat = null;
                        selectedStatus = null;
                        bloc.add(ProductFilterChanged(
                            categoryId: null, status: null));
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        bloc.add(ProductFilterChanged(
                            categoryId: selectedCat, status: selectedStatus));
                        Navigator.pop(context);
                      },
                      child: const Text('Terapkan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _openStatusSheet(
      BuildContext context, String id, String currentApiStatus) async {
    final bloc = context.read<ProductBloc>();
    String selected = currentApiStatus; // "active" | "inactive"
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(builder: (context, set) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ubah Status',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              for (final s in ['active', 'inactive'])
                RadioListTile<String>(
                  value: s,
                  groupValue: selected,
                  onChanged: (v) => set(() => selected = v!),
                  title: Text(s == 'active' ? 'Aktif' : 'Nonaktif'),
                ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () {
                  bloc.add(ProductStatusUpdateRequested(id, selected));
                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text(
            'Yakin ingin menghapus produk ini? Tindakan tidak dapat dibatalkan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<ProductBloc>().add(ProductDeleteRequested(id));
    }
  }
}

/// ===================
/// WIDGETS & HELPERS
/// ===================

class _SearchInAppBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  const _SearchInAppBar({
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: controller,
          onSubmitted: onSubmit,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Cari produk',
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: Color(0xFFE6E7EA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: Color(0xFFE6E7EA)),
            ),
          ),
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E7EA)),
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

class _FilterPill extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _FilterPill({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE6E7EA)),
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
        ),
        child: Row(children: [
          const Icon(Icons.filter_list, size: 18),
          const SizedBox(width: 6),
          const Text('Filter', style: TextStyle(fontSize: 13)),
          if (count > 0) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text('$count',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ]
        ]),
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
          border: Border.all(color: const Color(0xFFE6E7EA)),
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

class _ProductCard extends StatelessWidget {
  final String name, price, statusLabel;
  final int stock;
  final Color statusColor;
  final String? category, imageUrl;
  final VoidCallback onEdit, onChangeStatus, onDelete;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.statusLabel,
    required this.statusColor,
    required this.stock,
    required this.onEdit,
    required this.onChangeStatus,
    required this.onDelete,
    this.category,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EBF0)),
        color: Colors.white,
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ROW: Gambar + Detail
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl == null
                    ? Container(
                        width: 72, height: 72, color: const Color(0xFFF2F3F5))
                    : Image.network(imageUrl!,
                        width: 72, height: 72, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // judul
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    // harga
                    Text(
                      price,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    // kategori (opsional)
                    if (category != null && category!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3F5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          category!,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black87),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    // stok + status
                    Row(
                      children: [
                        Text('Stok: $stock',
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 12)),
                        const SizedBox(width: 8),
                        Icon(Icons.circle, size: 9, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ROW: 3 tombol kecil di bawah (selalu muat 1 baris)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SmallButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: onEdit,
              ),
              _SmallButton(
                icon: Icons.change_circle_outlined,
                label: 'Ubah Status',
                onTap: onChangeStatus,
              ),
              _SmallButton(
                icon: Icons.delete_outline,
                label: 'Hapus',
                onTap: onDelete,
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _SmallButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDestructive ? const Color(0xFFFFCDD2) : const Color(0xFFE0E0E0);
    final bgColor =
        isDestructive ? const Color(0xFFFFEBEE) : Colors.white;
    final textColor =
        isDestructive ? const Color(0xFFD32F2F) : Colors.black87;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===== Helper status UI lokal (kalau kamu belum punya di utils) =====

Color _statusColorFromUi(String uiStatus) {
  switch (uiStatus) {
    case 'available':
      return const Color(0xFF2E7D32); // hijau
    case 'low':
      return const Color(0xFFF9A825); // kuning
    default:
      return const Color(0xFFD32F2F); // merah / inactive
  }
}

String _statusLabelFromUi(String uiStatus) {
  switch (uiStatus) {
    case 'available':
      return 'Tersedia';
    case 'low':
      return 'Stok Menipis';
    default:
      return 'Nonaktif';
  }
}
