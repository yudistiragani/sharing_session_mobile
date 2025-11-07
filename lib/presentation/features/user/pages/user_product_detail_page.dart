import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../data/models/product_model.dart';
import '../../../../domain/repositories/product_repository.dart';

class UserProductDetailPage extends StatefulWidget {
  final String productId;
  final ProductRepository productRepo;

  const UserProductDetailPage({
    super.key,
    required this.productId,
    required this.productRepo,
  });

  @override
  State<UserProductDetailPage> createState() => _UserProductDetailPageState();
}

class _UserProductDetailPageState extends State<UserProductDetailPage> {
  late Future<ProductModel> _future;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _future = widget.productRepo.getProductById(widget.productId);
  }

  String _formatRp(num n) {
    final s = n.toInt().toString();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<ProductModel>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Gagal memuat: ${snap.error}'));
          }
          final p = snap.data!;
          final images = (p.images.isNotEmpty ? p.images : <String>[''])
              .map((e) => (e.isNotEmpty) ? UrlUtils.join(AppConstants.baseUrl, e) : e)
              .toList();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // === Carousel sederhana ===
                    SizedBox(
                      height: 240,
                      child: PageView.builder(
                        itemCount: images.length,
                        itemBuilder: (ctx, i) {
                          final url = images[i];
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: (url.isNotEmpty)
                                    ? Image.network(url, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.broken_image_outlined),
                                        ))
                                    : Container(color: Colors.grey.shade200),
                              ),
                              Positioned(
                                right: 12, bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54, borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('${i + 1}/${images.length}',
                                      style: const TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // === Judul + rating dummy & terjual ===
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: Text(
                        p.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Row(
                        children: const [
                          Icon(Icons.star, size: 16, color: Color(0xFFFFB300)),
                          SizedBox(width: 4),
                          Text('4.9'),
                          SizedBox(width: 10),
                          Text('121 Terjual', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),

                    // === Pengiriman (placeholder UI) ===
                    const SizedBox(height: 12),
                    Container(
                      color: const Color(0xFFF7F7F8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.local_shipping_outlined),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Pengiriman  •  Garansi Tiba : 4 - 6 September',
                                    style: TextStyle(fontWeight: FontWeight.w600)),
                                SizedBox(height: 2),
                                Text('Dapatkan Voucher s/d Rp10.000 jika pesanan terlambat.',
                                    style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // === Deskripsi ===
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Deskripsi Produk',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        (p.description?.isNotEmpty ?? false)
                            ? p.description!
                            : 'Tidak ada deskripsi.',
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 100), // space for bottom bar
                  ],
                ),
              ),

              // === Bottom Bar (harga + qty + aksi) ===
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(
                    color: Colors.black12.withOpacity(0.06),
                    blurRadius: 12, offset: const Offset(0, -2),
                  )],
                ),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Harga + diskon dummy
                    Row(
                      children: [
                        Text(
                          _formatRp(p.price),
                          style: const TextStyle(
                            color: Color(0xFFFF7A00),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEADF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('-12%',
                              style: TextStyle(color: Color(0xFFFF7A00), fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        const Spacer(),
                        // Qty
                        _QtyControl(
                          qty: _qty,
                          onMinus: () => setState(() { if (_qty > 1) _qty--; }),
                          onPlus:  () => setState(() { _qty++; }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              // TODO: aksi tambah ke keranjang
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ditambahkan ke keranjang')),
                              );
                            },
                            child: const Text('Tambah'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _QtyControl({required this.qty, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconBtn(icon: Icons.remove, onTap: onMinus),
          SizedBox(
            width: 36,
            child: Center(child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.w700))),
          ),
          _IconBtn(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 36, height: 36,
        child: Icon(icon, size: 18),
      ),
    );
  }
}
