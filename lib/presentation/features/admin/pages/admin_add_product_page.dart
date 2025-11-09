// lib/presentation/features/admin/pages/admin_add_product_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../data/datasources/admin_product_remote_data_source.dart';
import '../../../../data/repositories/admin_product_repository_impl.dart';

class AdminAddProductPage extends StatefulWidget {
  const AdminAddProductPage({Key? key}) : super(key: key);

  @override
  State<AdminAddProductPage> createState() => _AdminAddProductPageState();
}

class _AdminAddProductPageState extends State<AdminAddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0');
  String? _selectedCategoryId;
  final _stockCtrl = TextEditingController(text: '0');
  final _lowStockCtrl = TextEditingController(text: '0'); // produk menipis
  bool _isActive = false;

  List<XFile> _pickedFiles = [];
  bool _isLoading = false;

  late final ApiClient _apiClient;
  late final AdminProductRemoteDataSourceImpl _remote;
  late final AdminProductRepositoryImpl _repo;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, String>> _categories = [];

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(http.Client());
    _remote = AdminProductRemoteDataSourceImpl(_apiClient);
    _repo = AdminProductRepositoryImpl(remote: _remote);
    _loadCategories();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _lowStockCtrl.dispose();
    super.dispose();
  }

  // --------------------------
  // Load categories (robust)
  // --------------------------
  Future<void> _loadCategories() async {
    setState(() {
      _categories = [];
      _selectedCategoryId = null;
    });

    debugPrint('AppConstants.categoriesPath = ${AppConstants.categoriesPath}');

    final suffixes = [
      'categories/select', // matches cURL: /api/v1/categories/categories/select
      'select',            // /api/v1/categories/select
      '',                  // try raw AppConstants value
    ];

    Map<String, dynamic>? map;
    bool success = false;

    for (final s in suffixes) {
      String path = AppConstants.categoriesPath;
      if (path.endsWith('/')) path = path.substring(0, path.length - 1);
      if (s.isNotEmpty && !path.endsWith(s)) {
        path = '$path/$s';
      }

      try {
        debugPrint('Trying categories path: $path');
        map = await _apiClient.getJson(path, query: {'status': 'active'});
        debugPrint('Categories response for $path: $map');
        if (map != null) {
          success = true;
          break;
        }
      } catch (e) {
        debugPrint('Categories load failed for $path: $e');
      }
    }

    if (!success || map == null) {
      debugPrint('All category endpoints failed.');
      if (mounted) setState(() {
        _categories = [];
        _selectedCategoryId = null;
      });
      return;
    }

    final dynamic rawList = map['data'] ?? map['items'] ?? map['categories'] ?? (map is List ? map : null);
    if (rawList == null) {
      debugPrint('Category response has unexpected shape: $map');
      if (mounted) setState(() { _categories = []; _selectedCategoryId = null; });
      return;
    }

    final parsed = <Map<String, String>>[];
    for (final e in (rawList as List)) {
      if (e is Map) {
        final id = (e['_id'] ?? e['id'] ?? e['value'] ?? '').toString();
        final name = (e['name'] ?? e['label'] ?? e['text'] ?? '').toString();
        if (id.isNotEmpty) parsed.add({'id': id, 'name': name});
      } else if (e is String) {
        parsed.add({'id': e, 'name': e});
      }
    }

    if (mounted) {
      setState(() {
        _categories = parsed;
        if (_categories.isNotEmpty) _selectedCategoryId ??= _categories.first['id'];
      });
    }
  }

  // --------------------------
  // Image picking
  // --------------------------
  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked != null && picked.isNotEmpty) {
        setState(() => _pickedFiles = picked);
      }
    } catch (e) {
      debugPrint('pick images error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memilih gambar')));
    }
  }

  // --------------------------
  // Upload helper (calls repo)
  // --------------------------
  Future<Map<String, dynamic>> _uploadProductImages(String productId, List<XFile> xfiles) async {
    if (xfiles.isEmpty) return <String, dynamic>{};
    final files = xfiles.map((x) => File(x.path)).toList();

    try {
      debugPrint('Start uploading ${files.length} file(s) to product $productId');
      final resp = await _repo.uploadProductImages(productId: productId, images: files, replace: false);
      debugPrint('Upload images response: $resp');
      return resp;
    } catch (e, st) {
      debugPrint('Upload images failed: $e\n$st');
      rethrow;
    }
  }

  // --------------------------
  // Validate form + extra checks
  // --------------------------
  bool _validateAll() {
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kategori produk')));
      return false;
    }

    if (_pickedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap unggah minimal 1 gambar produk')));
      return false;
    }

    if (_isActive) {
      final low = int.tryParse(_lowStockCtrl.text.trim()) ?? -1;
      if (low < 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi Produk Menipis dengan angka yang valid')));
        return false;
      }
    }

    return true;
  }

  // --------------------------
  // Submit flow: create product -> upload images
  // --------------------------
  Future<void> _submit() async {
    if (!_validateAll()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1) create product
      final addResp = await _repo.addProduct(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: int.tryParse(_priceCtrl.text.trim()) ?? 0,
        categoryId: _selectedCategoryId!,
        stock: int.tryParse(_stockCtrl.text.trim()) ?? 0,
        lowStockThreshold: int.tryParse(_lowStockCtrl.text.trim()) ?? 0,
        status: _isActive ? 'active' : 'inactive',
      );

      debugPrint('Create product response: $addResp');

      // Robust parsing product id
      String? productId;
      if (addResp.containsKey('data')) {
        final d = addResp['data'];
        if (d is Map) productId = (d['_id'] ?? d['id'])?.toString();
      }
      productId ??= addResp['_id']?.toString() ?? addResp['id']?.toString();
      if (productId == null && addResp.containsKey('product')) {
        final p = addResp['product'];
        if (p is Map) productId = (p['_id'] ?? p['id'])?.toString();
      }
      if (productId == null) {
        for (final v in addResp.values) {
          if (v is Map && (v['_id'] != null || v['id'] != null)) {
            productId = (v['_id'] ?? v['id'])?.toString();
            break;
          }
        }
      }

      if (productId == null || productId.isEmpty) {
        throw Exception('Tidak dapat menemukan product id dari response: $addResp');
      }

      // 2) upload images
      try {
        final uploadResp = await _uploadProductImages(productId, _pickedFiles);
        debugPrint('Upload completed: $uploadResp');
      } catch (e) {
        // jika upload gagal, beri tahu user tapi produk sudah dibuat
        debugPrint('Upload images error: $e');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Produk dibuat, tapi upload gambar gagal: $e')));
        // keputusan: tetap lanjut (produk sudah tersimpan)
        if (mounted) Navigator.of(context).pop(true);
        return;
      }

      // success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil ditambahkan')));
        Navigator.of(context).pop(true);
      }
    } catch (e, st) {
      debugPrint('add product error: $e\n$st');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambah produk: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --------------------------
  // UI
  // --------------------------
  Widget _labelled(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: const Center(child: Icon(Icons.image_outlined, size: 36, color: Colors.black26)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Tambah Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Masukkan detail produk untuk menambahkannya ke inventaris.', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),

              _labelled('Gambar Produk'),
              GestureDetector(
                onTap: _pickImages,
                child: _pickedFiles.isEmpty
                    ? placeholder
                    : SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _pickedFiles.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (ctx, i) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(_pickedFiles[i].path), width: 120, height: 120, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _pickedFiles.removeAt(i));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
              ),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.upload_outlined),
                  label: const Text('Unggah Gambar'),
                ),
              ),

              const SizedBox(height: 16),
              _labelled('Nama Produk*'),
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Masukan nama produk', border: OutlineInputBorder(), isDense: true), validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null),
              const SizedBox(height: 12),

              _labelled('Kategori Produk*'),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                items: _categories.map((c) => DropdownMenuItem(value: c['id'], child: Text(c['name'] ?? ''))).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                validator: (v) => v == null || v.isEmpty ? 'Kategori wajib dipilih' : null,
              ),
              const SizedBox(height: 12),

              _labelled('Deskripsi Produk*'),
              TextFormField(controller: _descCtrl, decoration: const InputDecoration(hintText: 'Masukan deskripsi produk', border: OutlineInputBorder(), isDense: true), maxLines: 4, validator: (v) => v == null || v.trim().isEmpty ? 'Deskripsi wajib diisi' : null),
              const SizedBox(height: 12),

              _labelled('Harga Satuan*'),
              TextFormField(controller: _priceCtrl, decoration: const InputDecoration(prefixText: 'Rp ', hintText: '0', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, validator: (v) => v == null || v.trim().isEmpty ? 'Harga wajib diisi' : null),
              const SizedBox(height: 12),

              _labelled('Stok Awal*'),
              Row(children: [
                Expanded(child: TextFormField(controller: _stockCtrl, decoration: const InputDecoration(hintText: '0', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, validator: (v) => v == null || v.trim().isEmpty ? 'Stok wajib diisi' : null)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFEDEDED)), borderRadius: BorderRadius.circular(8)),
                  child: DropdownButton<String>(
                    value: 'Unit',
                    items: const [DropdownMenuItem(value: 'Unit', child: Text('Unit'))],
                    onChanged: (_) {},
                    underline: const SizedBox(),
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              _labelled('Status Produk'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFEDEDED)), color: const Color(0xFFF9F9FB)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Status Produk', style: TextStyle(fontWeight: FontWeight.w600)), SizedBox(height: 4), Text('Sistem akan menandai produk sebagai "Menipis" secara otomatis jika stoknya mendekati habis', style: TextStyle(color: Colors.black54))])),
                  Column(children: [Switch(value: _isActive, onChanged: (v) => setState(() => _isActive = v)), Text(_isActive ? 'Aktif' : 'Nonaktif', style: const TextStyle(color: Colors.black54))])
                ]),
              ),

              const SizedBox(height: 12),

              if (_isActive) ...[
                _labelled('Produk Menipis*'),
                TextFormField(
                  controller: _lowStockCtrl,
                  decoration: const InputDecoration(hintText: 'Masukkan jumlah untuk menandai menipis', border: OutlineInputBorder(), isDense: true),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (!_isActive) return null;
                    if (v == null || v.trim().isEmpty) return 'Produk Menipis wajib diisi';
                    if (int.tryParse(v.trim()) == null) return 'Masukkan angka yang valid';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 20),

              Row(children: [
                Expanded(child: OutlinedButton(onPressed: _isLoading ? null : () => Navigator.of(context).pop(), child: const Text('Batal'))),
                const SizedBox(width: 12),
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submit,
                        icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check),
                        label: Text(_isLoading ? 'Menyimpan...' : 'Tambah'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
