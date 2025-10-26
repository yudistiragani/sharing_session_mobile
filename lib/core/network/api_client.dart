import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart'; // ⬅️ import logger


class ApiClient {
  final http.Client _client;
  ApiClient(this._client);

  Map<String, String> get _jsonHeaders => {'Content-Type': 'application/json'};
  Map<String, String> get _formHeaders => {'Content-Type': 'application/x-www-form-urlencoded'};

  // =====================================================
  // 🧱 PRIVATE URI BUILDER (hapus / dobel)
  // =====================================================

  Uri _buildUri(String path) {
    var base = AppConstants.baseUrl;
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    if (!path.startsWith('/')) path = '/$path';
    return Uri.parse('$base$path');
  }

  // =====================================================
  // 🔹 POST FORM (application/x-www-form-urlencoded)
  // =====================================================

  Future<Map<String, dynamic>> postForm(
      String path, Map<String, String> data) async {
    final uri = _buildUri(path);
    appLogger.logRequest(method: 'POST (form)', uri: uri, body: data, headers: _formHeaders);
    try {
      final resp = await _client.post(uri, headers: _formHeaders, body: data);
      appLogger.logResponse(uri: uri, statusCode: resp.statusCode, body: resp.body);
      return _toJsonOrThrow(resp);
    } on SocketException {
      appLogger.logSocketError(uri);
      throw const SocketException('No Internet connection');
    } catch (e) {
      appLogger.logUnexpected(uri, e);
      rethrow;
    }
  }

  // =====================================================
  // 🔹 POST JSON
  // =====================================================

  Future<Map<String, dynamic>> postJson(
      String path, Map<String, dynamic> body) async {
    final uri = _buildUri(path);
    appLogger.logRequest(method: 'POST', uri: uri, body: body, headers: _jsonHeaders);
    try {
      final resp = await _client.post(uri, headers: _jsonHeaders, body: jsonEncode(body));
      appLogger.logResponse(uri: uri, statusCode: resp.statusCode, body: resp.body);
      return _toJsonOrThrow(resp);
    } on SocketException {
      appLogger.logSocketError(uri);
      throw const SocketException('No Internet connection');
    } catch (e) {
      appLogger.logUnexpected(uri, e);
      rethrow;
    }
  }

  // =====================================================
  // 🔹 GET JSON
  // =====================================================

  Future<Map<String, dynamic>> getJson(String path) async {
    final uri = _buildUri(path);
    appLogger.logRequest(method: 'GET', uri: uri, headers: _jsonHeaders);
    try {
      final resp = await _client.get(uri, headers: _jsonHeaders);
      appLogger.logResponse(uri: uri, statusCode: resp.statusCode, body: resp.body);
      return _toJsonOrThrow(resp);
    } on SocketException {
      appLogger.logSocketError(uri);
      throw const SocketException('No Internet connection');
    } catch (e) {
      appLogger.logUnexpected(uri, e);
      rethrow;
    }
  }

  // =====================================================
  // 🔹 PUT JSON
  // =====================================================

  Future<Map<String, dynamic>> putJson(
      String path, Map<String, dynamic> body) async {
    final uri = _buildUri(path);
    appLogger.logRequest(method: 'PUT', uri: uri, body: body, headers: _jsonHeaders);
    try {
      final resp = await _client.put(uri, headers: _jsonHeaders, body: jsonEncode(body));
      appLogger.logResponse(uri: uri, statusCode: resp.statusCode, body: resp.body);
      return _toJsonOrThrow(resp);
    } on SocketException {
      appLogger.logSocketError(uri);
      throw const SocketException('No Internet connection');
    } catch (e) {
      appLogger.logUnexpected(uri, e);
      rethrow;
    }
  }

  // =====================================================
  // 🔹 DELETE JSON
  // =====================================================

  Future<Map<String, dynamic>> deleteJson(String path,
      {Map<String, dynamic>? body}) async {
    final uri = _buildUri(path);
    appLogger.logRequest(method: 'DELETE', uri: uri, body: body, headers: _jsonHeaders);
    try {
      final resp = await _client.delete(
        uri,
        headers: _jsonHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      appLogger.logResponse(uri: uri, statusCode: resp.statusCode, body: resp.body);
      return _toJsonOrThrow(resp);
    } on SocketException {
      appLogger.logSocketError(uri);
      throw const SocketException('No Internet connection');
    } catch (e) {
      appLogger.logUnexpected(uri, e);
      rethrow;
    }
  }

  // =====================================================
  // 🧩 RESPONSE HANDLER
  // =====================================================

  Map<String, dynamic> _toJsonOrThrow(http.Response resp) {
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    }

    // try {
    //   final decoded = jsonDecode(resp.body);
    //   final msg = (decoded['detail'] ?? decoded['message'] ?? 'Request failed').toString();
    //   throw ServerException(
    //     msg, statusCode: resp.statusCode
    //   );
    // } catch (e, s) {
    //   // print('❌ Error decoding response: $e');
    //   // print('Stacktrace: $s');
    //   // print('Response body: ${resp.body}');
    //   throw ServerException(
    //     'Request failed (${resp.statusCode})',
    //     statusCode: resp.statusCode,
    //   );
    // }
    
    try {
      final decoded = jsonDecode(resp.body);
      final msg = (decoded['detail'] ?? decoded['message'] ?? 'Request failed').toString();
      throw ServerException(msg, statusCode: resp.statusCode); // <-- ini boleh
    } on FormatException {
      // hanya error decode JSON yang ditangkap
      throw ServerException('Request failed (${resp.statusCode})', statusCode: resp.statusCode);
    }
  } 
}
