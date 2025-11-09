class AppConstants {
  static const String baseUrl = 'http://192.168.1.12:8001/'; // ganti sesuai API

  // Auth
  static const String loginPath = '/api/v1/auth/login';
  static const String logoutPath = '/api/v1/auth/logout';
  static const String kTokenKey = 'auth_token';
  static const String kRoleKey  = 'user_role'; // 'admin' | 'user'
  static const String kDisplayName = 'display_name';
  static const String kAvatarUrl   = 'avatar_url';

  // Products
  static const String productsPath   = '/api/v1/products';
  static const String categoriesPath = '/api/v1/categories/categories/select';

  // Users
  static const String usersPath = '/api/v1/users';
  static const String mePath = '/api/v1/users/me';
}
