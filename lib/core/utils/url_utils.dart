class UrlUtils {
  /// Gabungkan base + path jadi absolute URL tanpa double slash.
  /// - Jika `path` sudah absolute (http/https), dikembalikan apa adanya.
  static String join(String base, String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final p = path.startsWith('/') ? path.substring(1) : path;
    return '$b/$p';
  }
}
