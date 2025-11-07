import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/url_utils.dart';
import '../bloc/user_product_list_bloc.dart';
import '../../../common_widgets/pills.dart';
import '../../../routes/app_router.dart';


// Reuse card visuals dari user_home_page (atau minimal versi ringkas di sini)
class UserProductListPage extends StatefulWidget {
  const UserProductListPage({super.key});

  @override
  State<UserProductListPage> createState() => _UserProductListPageState();
}

class _UserProductListPageState extends State<UserProductListPage> {
  final _scroll = ScrollController();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    if (position.pixels >= position.maxScrollExtent - 480) {
      context.read<UserProductListBloc>().add(UserProductsFetchMore());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _openSortSheet(BuildContext context) {
    // CAPTURE SEKALI dari context halaman (bukan dari sheet)
    final bloc = context.read<UserProductListBloc>();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) { // <-- pakai sheetCtx
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text('Urutkan berdasarkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Nama Produk'),
                onTap: () {
                  Navigator.of(sheetCtx).pop();         // <-- FIX: pakai sheetCtx
                  bloc.add(UserProductsSortChanged('name'));
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Harga'),
                onTap: () {
                  Navigator.of(sheetCtx).pop();         // <-- FIX: pakai sheetCtx
                  bloc.add(UserProductsSortChanged('price'));
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF7A00);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _SearchField(
          controller: _search,
          hint: 'Cari produk',
          onSubmitted: (q) {
            context.read<UserProductListBloc>().add(UserProductsSearchChanged(q));
          },
        ),
      ),
      body: BlocBuilder<UserProductListBloc, UserProductListState>(
        builder: (context, state) {
          return CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // ===== Nama Produk (Sort) =====
                      PillButton(
                        onTap: () => _openSortSheet(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.sortBy == 'price' ? 'Harga' : 'Nama Produk',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF6B7280)),
                          ],
                        ),
                      ),

                      // ===== Filter (+ badge) =====
                      PillButton(
                        onTap: () => _openFilterSheet(context, state),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.activeFilterCount > 0) ...[
                              SmallBadge('${state.activeFilterCount}'),
                              const SizedBox(width: 8),
                            ],
                            const Text('Filter', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),

                      // ===== Order (Asc/Desc) =====
                      PillButton(
                        selected: true, // tampil selalu aktif
                        onTap: () {
                          final isAsc = state.order == 'asc';
                          context.read<UserProductListBloc>()
                              .add(UserProductsOrderChanged(isAsc ? 'desc' : 'asc'));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.swap_vert, size: 16, color: Color(0xFF6B7280)),
                            const SizedBox(width: 6),
                            Text(
                              state.order == 'asc' ? 'Asc' : 'Desc',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Loading/Error/Empty
              if (state.loading && state.items.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (state.error != null && state.items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                  ),
                )
              else if (state.items.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Data kosong'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 260,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: state.items.length + (state.loadingMore ? 2 : 0),
                    itemBuilder: (context, i) {
                      if (i >= state.items.length) {
                        return const _LoadingCard();
                      }
                      final p = state.items[i];
                      final img = (p.images.isNotEmpty && p.images.first.trim().isNotEmpty)
                          ? UrlUtils.join(AppConstants.baseUrl, p.images.first)
                          : 'https://via.placeholder.com/600x400?text=No+Image';

                      return _ProductTile(
                        title: p.name,
                        price: p.price,
                        discountPct: null, // sesuaikan jika API punya diskon
                        rating: null,
                        sold: null,
                        imageUrl: img,
                        onTap: () {
                          // TODO: ke detail product kalau sudah ada
                          Navigator.of(context).pushNamed(
                            AppRouter.userProductDetail,
                            arguments: p.id, // id dari ProductModel
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openFilterSheet(BuildContext context, UserProductListState state) {
    final bloc = context.read<UserProductListBloc>(); // <-- CAPTURE SEKALI

    String? selCategory = state.categoryId;
    String? selStatus = state.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) { // <-- pakai sheetCtx
        return StatefulBuilder(
          builder: (sheetCtx, setModal) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),

                    // --- KATEGORI ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Kategori', style: TextStyle(color: Colors.grey.shade700)),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: (selCategory ?? ''),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('Semua')),
                        ...state.categories.map((c) => DropdownMenuItem(
                          // UBAH: pastikan String
                          value: c.id.toString(),
                          child: Text(c.name),
                        )),
                      ],
                      onChanged: (v) => setModal(() {
                        // '' -> null, lain -> String
                        selCategory = (v == null || v.isEmpty) ? null : v;
                      }),
                    ),
                    const SizedBox(height: 12),

                    // --- STATUS ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Status', style: TextStyle(color: Colors.grey.shade700)),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: (selStatus ?? ''), // SELALU cocok dengan item ''
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('Semua')),
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                      ],
                      onChanged: (v) => setModal(() {
                        selStatus = (v == null || v.isEmpty) ? null : v; // '' -> null
                      }),
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(sheetCtx).pop();
                          bloc.add(UserProductsFilterApplied(
                            categoryId: selCategory,          // null = Semua
                            status: selStatus?.toLowerCase(), // normalisasi
                          ));
                        },
                        child: const Text('Terapkan'),
                      ),

                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

}

// ====== WIDGETS RINGKAS ======

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  const _SearchField({required this.controller, required this.hint, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, size: 20, color: Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 2),
              ),
            ),
          ),
          // kebab icon di AppBar kanan sudah ada—kalau mau taruh di sini, uncomment:
          // IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}



class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SortChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}

class _FilterChipWithBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _FilterChipWithBadge({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      icon: const Icon(Icons.filter_list),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Filter'),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderChip extends StatelessWidget {
  final bool ascSelected;
  final VoidCallback onTapAsc;
  final VoidCallback onTapDesc;
  const _OrderChip({
    required this.ascSelected,
    required this.onTapAsc,
    required this.onTapDesc,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'asc', label: Text('Asc'), icon: Icon(Icons.north_east)),
        ButtonSegment(value: 'desc', label: Text('Desc'), icon: Icon(Icons.south_east)),
      ],
      selected: {ascSelected ? 'asc' : 'desc'},
      onSelectionChanged: (s) {
        final v = s.first;
        if (v == 'asc') onTapAsc(); else onTapDesc();
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  final String title;
  final int price;
  final int? discountPct;
  final double? rating;
  final int? sold;
  final String imageUrl;
  final VoidCallback? onTap;
  const _ProductTile({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.discountPct,
    this.rating,
    this.sold,
    this.onTap,
  });

  String _formatRp(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      b.write(s[i]);
      if (idx > 1 && idx % 3 == 1) b.write('.');
    }
    return 'Rp $b';
  }

  @override
  Widget build(BuildContext context) {
    final hasDisc = (discountPct ?? 0) > 0;
    final discPrice = hasDisc ? (price - (price * (discountPct ?? 0) ~/ 100)) : price;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    _formatRp(discPrice),
                    style: const TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 6),
                  if (hasDisc)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEADF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${discountPct}%',
                        style: const TextStyle(color: Color(0xFFFF7A00), fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFFFB300)),
                  const SizedBox(width: 4),
                  Text((rating ?? 4.9).toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 10),
                  Text('${sold ?? 121} Terjual', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
