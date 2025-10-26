import 'package:flutter/material.dart';

class ProductManagementPage extends StatelessWidget {
  const ProductManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
      ),
      body: const Center(
        child: Text('Daftar produk & aksi CRUD akan tampil di sini.'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: navigate to add product form
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}
