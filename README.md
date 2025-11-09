# 🛍️ Flutter Admin Panel - Add User & Product

Project ini merupakan bagian dari sistem admin panel berbasis **Flutter + REST API**, dengan fitur utama:
- Menambah User (dengan upload foto profil)
- Menambah Produk (dengan upload multiple images ke endpoint terpisah)
- Integrasi API backend (FastAPI + MongoDB)

---

## 📁 Struktur Folder Utama

lib/
├── core/
│ ├── constants/
│ ├── network/
│ └── utils/
├── data/
│ ├── datasources/
│ ├── models/
│ └── repositories/
├── domain/
│ ├── entities/
│ ├── repositories/
│ └── usecases/
├── presentation/
│ ├── features/
│ │ ├── admin/
│ │ │ ├── pages/
│ │ │ │ ├── admin_add_user_page.dart
│ │ │ │ ├── admin_add_product_page.dart
│ │ │ │ └── user_management_page.dart
│ ├── widgets/
│ └── app.dart
└── main.dart

## 🔑 Catatan Penting

- Semua field produk **required**, termasuk foto.
- Field `low_stock_threshold` wajib diisi (stok menipis).
- Endpoint `categories/select` harus aktif dan mengembalikan data kategori aktif.
- Token `Bearer` harus disertakan pada semua request yang membutuhkan autentikasi.

## 🧩 Dependencies yang digunakan

- `flutter_bloc`
- `dio`
- `image_picker`
- `fluttertoast`
- `cached_network_image`

## 🚀 Jalankan Project

```bash
flutter pub get
flutter run