class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String status; // ACTIVE | INACTIVE only
  final String? phone;
  final String? avatar;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    this.phone,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) {
    final fullName = (j['full_name'] ?? '').toString().trim();
    final email = (j['email'] ?? '').toString().trim();
    final phone = j['phone_number']?.toString().trim();

    String resolved = fullName;
    if (resolved.isEmpty) {
      if (email.contains('@')) {
        resolved = email.split('@').first;
      } else if (phone != null && phone.isNotEmpty) {
        resolved = phone;
      } else {
        resolved = '-';
      }
    }

    final rawStatus = (j['status'] ?? '').toString().trim().toLowerCase();
    final normalized = rawStatus == 'active' ? 'active' : 'inactive';

    return UserModel(
      id: (j['_id'] ?? j['id']).toString(),
      email: email,
      name: resolved,
      role: (j['role'] ?? 'user').toString(),
      status: normalized,
      phone: phone,
      avatar: j['profile_image']?.toString(),
    );
  }

  String get displayName => name.isNotEmpty ? name : email;
}

class UserListResponse {
  final List<UserModel> items;
  final int page;
  final int pageSize;
  final int total;

  UserListResponse(this.items, this.page, this.pageSize, this.total);

  factory UserListResponse.fromJson(Map<String, dynamic> j) {
    final meta = j['meta'] as Map? ?? {};
    final raw = (j['items'] as List?) ?? const <dynamic>[];

    return UserListResponse(
      raw.map((e) => UserModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      (meta['page'] ?? 1),
      (meta['page_size'] ?? raw.length),
      (meta['total'] ?? raw.length),
    );
  }
}
