class AppConstants {
  static const String baseUrl = 'http://192.168.1.6:8001/'; // ganti sesuai API

  // Auth
  static const String loginPath = '/api/v1/auth/login';
  static const String logoutPath = '/api/v1/auth/logout';

  // Products
  static const String productsPath   = '/api/v1/products';
  static const String categoriesPath = '/api/v1/categories/categories/select';

  static const String kTokenKey = 'auth_token';
  static const String kRoleKey  = 'user_role'; // 'admin' | 'user'
}
