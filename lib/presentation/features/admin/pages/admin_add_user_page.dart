import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../data/datasources/admin_user_remote_data_source.dart';
import '../../../../data/repositories/admin_user_repository_impl.dart';

class AdminAddUserPage extends StatefulWidget {
  const AdminAddUserPage({Key? key}) : super(key: key);

  @override
  State<AdminAddUserPage> createState() => _AdminAddUserPageState();
}

class _AdminAddUserPageState extends State<AdminAddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isActive = true;
  File? _pickedImage;
  bool _isLoading = false;

  late final ApiClient _apiClient;
  late final AdminUserRemoteDataSourceImpl _remote;
  late final AdminUserRepositoryImpl _repo;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(http.Client());
    _remote = AdminUserRemoteDataSourceImpl(_apiClient);
    _repo = AdminUserRepositoryImpl(remote: _remote);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x != null) setState(() => _pickedImage = File(x.path));
  }

  bool get _canSubmit {
    return !_isLoading &&
        _pickedImage != null &&
        _nameCtrl.text.trim().isNotEmpty &&
        _phoneCtrl.text.trim().isNotEmpty &&
        _emailCtrl.text.trim().isNotEmpty &&
        _passwordCtrl.text.trim().isNotEmpty &&
        (_formKey.currentState?.validate() ?? false);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unggah gambar terlebih dahulu')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final resp = await _repo.addUser(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        fullName: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        role: 'user',
        status: _isActive ? 'active' : 'inactive',
        profileImage: _pickedImage,
      );

      // sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User berhasil ditambahkan')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambah user: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
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
      appBar: AppBar(title: const Text('Tambah User')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Tambah User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Masukkan detail user untuk menambahkannya ke management user', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: _pickImage,
                child: _pickedImage == null
                    ? placeholder
                    : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_pickedImage!, height: 120, width: double.infinity, fit: BoxFit.cover)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(icon: const Icon(Icons.upload_outlined), label: const Text('Unggah Gambar'), onPressed: _pickImage),
              ),
              const SizedBox(height: 16),

              _label('Nama User*'),
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Masukan nama user', border: OutlineInputBorder(), isDense: true), validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null),
              const SizedBox(height: 12),

              _label('No Telephone*'),
              TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Masukan nomor telepon', border: OutlineInputBorder(), isDense: true), validator: (v) => v == null || v.trim().isEmpty ? 'No telephone wajib diisi' : null),
              const SizedBox(height: 12),

              _label('Email*'),
              TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Masukan email', border: OutlineInputBorder(), isDense: true), validator: (v) { if (v == null || v.trim().isEmpty) return 'Email wajib diisi'; if (!v.contains('@')) return 'Email tidak valid'; return null; }),
              const SizedBox(height: 12),

              _label('Password*'),
              TextFormField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Masukan password', border: OutlineInputBorder(), isDense: true), validator: (v) => v == null || v.trim().isEmpty ? 'Password wajib diisi' : null),
              const SizedBox(height: 12),

              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFEDEDED)), color: const Color(0xFFF9F9FB)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Status User', style: TextStyle(fontWeight: FontWeight.w600)), SizedBox(height: 4), Text('Jika user telah lama tidak aktif anda bisa menonaktifkan status user secara manual', style: TextStyle(color: Colors.black54)),])), Column(children: [Switch(value: _isActive, onChanged: (v) => setState(() => _isActive = v)), Text(_isActive ? 'Aktif' : 'Nonaktif', style: const TextStyle(color: Colors.black54))])])), const SizedBox(height: 20),

              Row(children: [
                Expanded(child: OutlinedButton(onPressed: _isLoading ? null : () => Navigator.of(context).pop(), child: const Text('Batal'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(onPressed: _canSubmit ? _submit : null, icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check), label: Text(_isLoading ? 'Menyimpan...' : 'Tambah'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
