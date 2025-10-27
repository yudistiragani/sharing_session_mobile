import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final http.Client _http;
  ApiClient(this._http);

  // ================== PUBLIC ==================

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
    bool includeAuth = true,
  }) async {
    final uri = _buildUri(path, query: query);
    final reqHeaders = await _mergedHeaders(headers, includeAuth: includeAuth);
    _debugPrint('GET', uri, null, reqHeaders);

    final resp = await _http.get(uri, headers: reqHeaders);
    return _toJsonOrThrow(resp);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool includeAuth = true,
  }) async {
    final uri = _buildUri(path);
    final reqHeaders = await _mergedHeaders(headers,
        includeAuth: includeAuth, json: true);
    final payload = jsonEncode(body);
    _debugPrint('POST', uri, payload, reqHeaders);

    final resp = await _http.post(uri, headers: reqHeaders, body: payload);
    return _toJsonOrThrow(resp);
  }

  /// Kirim form (x-www-form-urlencoded) — dipakai untuk LOGIN
  Future<Map<String, dynamic>> postForm(
    String path,
    Map<String, String> form, {
    Map<String, String>? headers,
    bool includeAuth = false, // ⬅️ login TIDAK pakai token
  }) async {
    final uri = _buildUri(path);
    final reqHeaders = await _mergedHeaders(headers,
        includeAuth: includeAuth, form: true);
    _debugPrint('POST', uri, form, reqHeaders);

    final resp = await _http.post(uri, headers: reqHeaders, body: form);
    return _toJsonOrThrow(resp);
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool includeAuth = true,
  }) async {
    final uri = _buildUri(path);
    final reqHeaders = await _mergedHeaders(headers,
        includeAuth: includeAuth, json: true);
    final payload = jsonEncode(body);
    _debugPrint('PUT', uri, payload, reqHeaders);

    final resp = await _http.put(uri, headers: reqHeaders, body: payload);
    return _toJsonOrThrow(resp);
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Map<String, dynamic>? body, // opsional: ada API yang minta body saat delete
    Map<String, String>? headers,
    bool includeAuth = true,
  }) async {
    final uri = _buildUri(path);
    final reqHeaders = await _mergedHeaders(headers,
        includeAuth: includeAuth, json: body != null);
    final payload = body == null ? null : jsonEncode(body);
    _debugPrint('DELETE', uri, payload, reqHeaders);

    final resp = await _http.send(http.Request('DELETE', uri)
      ..headers.addAll(reqHeaders)
      ..bodyBytes = payload == null ? <int>[] : utf8.encode(payload));
    final raw = await http.Response.fromStream(resp);
    return _toJsonOrThrow(raw);
  }

  // ================== HELPERS ==================

  Uri _buildUri(String path, {Map<String, String>? query}) {
    // Kalau path sudah absolute URL, langsung pakai & merge query
    if (path.startsWith('http://') || path.startsWith('https://')) {
      final u = Uri.parse(path);
      return u.replace(queryParameters: {
        ...?u.queryParameters,
        ...?query,
      });
    }

    // Normalisasi base & path agar tidak double slash
    final base = AppConstants.baseUrl; // pastikan TANPA slash di ujung (lebih aman)
    final baseUri = Uri.parse(base);

    // gabungkan baseUri.path (bisa kosong atau '/something') dengan path relatif
    String _normalizePath(String a, String b) {
      var aa = a; var bb = b;
      if (aa.endsWith('/')) aa = aa.substring(0, aa.length - 1);
      if (bb.startsWith('/')) bb = bb.substring(1);
      if (aa.isEmpty) return '/$bb';
      if (bb.isEmpty) return aa; // tidak menambah slash ekstra
      return '$aa/$bb';
    }

    final combinedPath = _normalizePath(baseUri.path, path);

    return baseUri.replace(
      path: combinedPath,
      queryParameters: query,
    );
  }

  Future<Map<String, String>> _mergedHeaders(
    Map<String, String>? extra, {
    required bool includeAuth,
    bool json = false,
    bool form = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (json) headers['Content-Type'] = 'application/json';
    if (form) headers['Content-Type'] = 'application/x-www-form-urlencoded';

    if (includeAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.kTokenKey);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    if (extra != null && extra.isNotEmpty) headers.addAll(extra);
    return headers;
  }

  Map<String, dynamic> _toJsonOrThrow(http.Response resp) {
    final status = resp.statusCode;
    final body = resp.body.trim();

    if (status >= 200 && status < 300) {
      if (body.isEmpty) return <String, dynamic>{};
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is List) return {'data': decoded};
        return {'data': decoded};
      } on FormatException {
        return {'data': body};
      }
    }

    // Error path
    String msg = 'Request failed ($status)';
    if (body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) {
          msg = (decoded['detail'] ??
                 decoded['message'] ??
                 decoded['error'] ??
                 decoded['errors'] ??
                 decoded.toString()).toString();
        } else {
          msg = decoded.toString();
        }
      } catch (_) {
        msg = body;
      }
    }
    throw ServerException(msg, statusCode: status);
  }

  void _debugPrint(String method, Uri uri, Object? body, Map<String, String> headers) {
    // print log sederhana; kalau mau, ganti ke logger package
    // ignore: avoid_print
    print('➡️ $method $uri');
    if (headers['Authorization'] != null) {
      // ignore: avoid_print
      print('   headers: {Authorization: Bearer ***}');
    }
    if (body != null) {
      // ignore: avoid_print
      print('   payload: $body');
    }
  }
}
