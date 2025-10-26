class LoginResponseModel {
  final String token;      // kita tetap simpan sebagai 'token'
  final String role;       // 'admin' | 'user'
  final String tokenType;  // mis. 'bearer'
  final int exp;           // epoch seconds
  final String jti;

  LoginResponseModel({
    required this.token,
    required this.role,
    required this.tokenType,
    required this.exp,
    required this.jti,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['access_token'] as String,            // ⬅️ ambil dari access_token
      role: (json['role'] as String).toLowerCase(),
      tokenType: (json['token_type'] as String?) ?? 'bearer',
      exp: (json['exp'] as num?)?.toInt() ?? 0,
      jti: (json['jti'] as String?) ?? '',
    );
  }
}
