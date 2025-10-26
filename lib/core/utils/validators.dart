class Validators {
  static String? required(String? v, {String field = 'Field'}) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }
}
