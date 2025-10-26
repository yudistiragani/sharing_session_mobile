import 'dart:convert';
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger({
    this.enabledInRelease = false,
    this.maxBodyLength = 10_000,
  });

  bool enabledInRelease;
  int maxBodyLength;

  void configure({bool? enabledInRelease, int? maxBodyLength}) {
    if (enabledInRelease != null) this.enabledInRelease = enabledInRelease;
    if (maxBodyLength != null) this.maxBodyLength = maxBodyLength;
  }

  void logWithTime(String message, {String level = 'INFO'}) {
    if (!kDebugMode && !enabledInRelease) return;
    final ts = DateTime.now().toIso8601String();
    debugPrint('[$ts][$level] $message');
  }

  void logRequest({
    required String method,
    required Uri uri,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    logWithTime('🟩 [$method] $uri', level: 'HTTP');
    if (headers != null && headers.isNotEmpty) {
      logWithTime('🧾 Headers: ${jsonEncode(headers)}', level: 'HTTP');
    }
    if (body != null) {
      final json = jsonEncode(body);
      logWithTime('📦 Body: ${_truncate(json)}', level: 'HTTP');
    }
  }

  void logResponse({
    required Uri uri,
    required int statusCode,
    required String body,
  }) {
    logWithTime('⬅️ Status: $statusCode (${uri.path})', level: 'HTTP');
    logWithTime('📨 Response: ${_truncate(body)}', level: 'HTTP');
  }

  void logSocketError(Uri uri) {
    logWithTime('⚠️ SocketException: cannot reach $uri (check internet or baseUrl)', level: 'HTTP');
  }

  void logUnexpected(Uri uri, Object e) {
    logWithTime('❌ Unexpected error on $uri → $e', level: 'HTTP');
  }

  String _truncate(String s) {
    if (s.length <= maxBodyLength) return s;
    return '${s.substring(0, maxBodyLength)}... [truncated ${s.length - maxBodyLength} chars]';
  }
}

final appLogger = AppLogger(); // default
