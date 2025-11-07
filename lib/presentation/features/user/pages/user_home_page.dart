import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_home_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHomePage extends StatefulWidget {
  final String displayName; // kirim dari auth jika ada
  final String? avatarUrl;

  const UserHomePage({
    super.key,
    this.displayName = 'Sam',
    this.avatarUrl,
  });

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  String? _profileName;
  String? _profileAvatar;
  final _search = TextEditingController();
  final _bannerCtrl = PageController(viewportFraction: 0.94);
  int _bannerIndex = 0;
  Timer? _autoTimer;

  Future<void> _loadProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final name   = prefs.getString(AppConstants.kDisplayName);
    final avatar = prefs.getString(AppConstants.kAvatarUrl);

    // // Jika avatar di prefs masih path relatif, jadikan absolut:
    // final resolvedAvatar = (av != null && av.isNotEmpty)
    //     ? UrlUtils.join(AppConstants.baseUrl, av)
    //     : '';

    if (!mounted) return;
    setState(() {
      _profileName   = name;
      _profileAvatar = avatar;
    });
  }

  // ---- Banner dari assets ----
  final _banners = const [
    _BannerData(
      image: 'assets/banner/banner1.jpg',
      title: 'Cari Furnitur Impian',
      subtitle: 'Cari furnitur mulai dari meja, lemari, hingga rak disini',
    ),
    _BannerData(
      image: 'assets/banner/banner2.jpg',
      title: 'Promo Minggu Ini',
      subtitle: 'Dapatkan harga spesial untuk produk pilihan',
    ),
    _BannerData(
      image: 'assets/banner/banner3.jpg',
      title: 'Produk Terbaru',
      subtitle: 'Temukan koleksi terbaru musim ini',
    ),
  ];

  // ---- Mock data rekomendasi (ganti ke data API nanti) ----
  final _reco = <_ProductCardData>[
    _ProductCardData(
      title: 'Kursi Santai Rotan - Deluxe',
      image:
          'https://images.unsplash.com/photo-1484101403633-562f891dc89a?q=80&w=1200&auto=format&fit=crop',
      price: 1200000,
      discountPct: 10,
      rating: 4.9,
      sold: 121,
    ),
    _ProductCardData(
      title: 'Rak Dinding Modern - 5 Susun',
      image:
          'https://images.unsplash.com/photo-1582582494700-33c0bb09b9f1?q=80&w=1200&auto=format&fit=crop',
      price: 3400000,
      discountPct: 12,
      rating: 4.8,
      sold: 87,
    ),
    _ProductCardData(
      title: 'Meja Makan Kayu Jati - Ukuran Besar',
      image:
          'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?q=80&w=1200&auto=format&fit=crop',
      price: 3400000,
      discountPct: 12,
      rating: 4.9,
      sold: 121,
    ),
    _ProductCardData(
      title: 'Sofa Minimalis - 3 Dudukan',
      image:
          'https://images.unsplash.com/photo-1540573133985-87b6da6d54a9?q=80&w=1200&auto=format&fit=crop',
      price: 5000000,
      discountPct: 5,
      rating: 4.7,
      sold: 59,
    ),
    _ProductCardData(
      title: 'Rak Buku Kayu Solid',
      image:
          'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?q=80&w=1200&auto=format&fit=crop',
      price: 950000,
      discountPct: 0,
      rating: 4.6,
      sold: 78,
    ),
    _ProductCardData(
      title: 'Kursi Santai Anyam',
      image:
          'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?q=80&w=1200&auto=format&fit=crop',
      price: 1250000,
      discountPct: 10,
      rating: 4.7,
      sold: 53,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto slide tiap 4 detik
    _loadProfileFromPrefs();

    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _banners.isEmpty) return;
      final next = (_bannerIndex + 1) % _banners.length;
      _bannerCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
      setState(() => _bannerIndex = next);
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _search.dispose();
    _bannerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF7A00);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _Greeting(
                        name: _profileName ?? widget.displayName,
                        subtitle: 'Selamat datang kembali',
                      ),
                    ),
                    const SizedBox(width: 12),
                    // _AvatarCircle(url: _profileAvatar ?? widget.avatarUrl, name: _profileName ?? widget.displayName),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'logout') {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          if (!context.mounted) return;
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRouter.login,
                            (route) => false,
                          );
                        } else if (value == 'profile') {
                          // route ke page profil kalau kamu punya
                          // Navigator.of(context).pushNamed(AppRouter.profile);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'profile',
                          child: Text('Profil Saya'),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Logout', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: _AvatarCircle(
                        url: _profileAvatar ?? widget.avatarUrl,
                        name: _profileName ?? widget.displayName,
                      ),
                    )

                  ],
                ),
              ),
            ),

            // Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SearchField(
                  controller: _search,
                  hint: 'Cari produk',
                  onSubmitted: (q) {
                    FocusScope.of(context).unfocus();
                    context.read<UserHomeBloc>().add(UserHomeSearchChanged(q));
                    // TODO: navigate ke halaman hasil
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Banner slider (assets)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: _bannerCtrl,
                  onPageChanged: (i) => setState(() => _bannerIndex = i),
                  itemCount: _banners.length,
                  itemBuilder: (_, i) => _BannerCard(data: _banners[i]),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _DotsIndicator(
                count: _banners.length,
                index: _bannerIndex,
                activeColor: Colors.orange.shade700,
            ),
            ),

            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Rekomendasi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('Produk - produk pilihan terbaik dari kami',
                        style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ),

            // Grid rekomendasi (maks 6)
            // SliverPadding(
            //   padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            //   sliver: SliverGrid(
            //     delegate: SliverChildBuilderDelegate(
            //       (context, i) => _ProductCard(
            //         data: _reco[i],
            //         onTap: () {
            //           // TODO: detail
            //         },
            //       ),
            //       childCount: min(_reco.length, 6),
            //     ),
            //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //       crossAxisCount: 2,
            //       mainAxisExtent: 260,
            //       mainAxisSpacing: 12,
            //       crossAxisSpacing: 12,
            //     ),
            //   ),
            // ),
            // === Rekomendasi (maks 6) pakai BLoC ===
            SliverToBoxAdapter(
              child: BlocBuilder<UserHomeBloc, UserHomeState>(
                builder: (context, state) {
                  if (state.loading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state.error != null) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                    );
                  }
                  if (state.items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Belum ada produk.'),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.items.length, // sudah 6 dari BLoC
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 270,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemBuilder: (context, i) {
                        final p = state.items[i];
                        // mapping ringan ke card data lama kamu
                        final data = _ProductCardData(
                          title: p.name,
                          image: (p.images.isNotEmpty && (p.images.first).trim().isNotEmpty)
                                  ? UrlUtils.join(AppConstants.baseUrl, p.images.first)
                                  : 'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png',
                          price: p.price,
                          discountPct: null, // sesuaikan kalau API menyediakan diskon
                          rating: null,
                          sold: null,
                        );
                        return _ProductCard(
                          data: data,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRouter.userProductDetail,
                              arguments: p.id, // pastikan id produk di model: p.id atau p.productId
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),


            // Tombol Lihat Semua Produk
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // TODO: navigate ke halaman semua produk
                      // Navigator.of(context).pushNamed('/products');
                      Navigator.of(context).pushNamed(AppRouter.userProducts);
                    },
                    child: const Text(
                      'Lihat Semua Produk',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: orange,
      //   onPressed: () {
      //     // TODO: action user
      //   },
      //   child: const Icon(Icons.shopping_cart, color: Colors.white),
      // ),
    );
  }
}

/// ============== Small widgets ==============

class _Greeting extends StatelessWidget {
  final String name;
  final String subtitle;
  const _Greeting({required this.name, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Halo $name',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String? url;
  final String name;
  const _AvatarCircle({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
      return CircleAvatar(radius: 20, child: Text(initial));
    }
    return CircleAvatar(radius: 20, backgroundImage: NetworkImage(url!));
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  const _SearchField({
    required this.controller,
    required this.hint,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        filled: true,
        fillColor: const Color(0xFFF5F6F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _BannerData {
  final String image;   // asset path
  final String title;
  final String subtitle;
  const _BannerData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(data.image, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 24,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(data.subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int index;
  final Color activeColor;
  const _DotsIndicator({
    required this.count,
    required this.index,
    this.activeColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final active = i == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
            height: 6,
            width: active ? 18 : 6,
            decoration: BoxDecoration(
              color: active ? activeColor : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ),
    );
  }
}

class _ProductCardData {
  final String? title;
  final String? image;
  final int? price;        // IDR
  final int? discountPct;  // 0..100
  final double? rating;
  final int? sold;
  const _ProductCardData({
    this.title,
    this.image,
    this.price,
    this.discountPct,
    this.rating,
    this.sold,
  });
}

class _ProductCard extends StatelessWidget {
  final _ProductCardData data;
  final VoidCallback? onTap;
  const _ProductCard({required this.data, this.onTap});

  String _formatRupiah(int? n) {
    if (n == null) return 'Rp -';
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write('.');
    }
    return 'Rp ${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final hasDisc = (data.discountPct ?? 0) > 0;
    final price = data.price ?? 0;
    final discPrice = hasDisc ? (price - (price * (data.discountPct ?? 0) ~/ 100)) : price;
    final image = data.image;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE9EBEE)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              child: AspectRatio(
                aspectRatio: 1.6,
                child: (image == null || image.isEmpty)
                    ? Container(color: const Color(0xFFF0F1F3))
                    : Image.network(image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),

            // title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                (data.title?.isNotEmpty == true) ? data.title! : 'Tanpa Judul',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 6),

            // price + discount
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    _formatRupiah(discPrice),
                    style: const TextStyle(
                      color: Color(0xFFFF7A00),
                      fontWeight: FontWeight.w700,
                    ),
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
                        '-${data.discountPct}%',
                        style: const TextStyle(
                          color: Color(0xFFFF7A00),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // rating + sold
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Color(0xFFFFB300)),
                  const SizedBox(width: 4),
                  Text(
                    (data.rating ?? 0).toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  const Text('•', style: TextStyle(color: Colors.black38)),
                  const SizedBox(width: 8),
                  Text(
                    '${data.sold ?? 0} Terjual',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const Spacer(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
