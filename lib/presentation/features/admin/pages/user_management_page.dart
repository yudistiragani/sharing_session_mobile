import 'package:flutter/material.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen User')),
      body: const Center(
        child: Text('Daftar user & aksi CRUD akan tampil di sini.'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: navigate to add user form
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Tambah User'),
      ),
    );
  }
}
