import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/auth_controller.dart';

typedef TokenProvider = Future<String?> Function();
typedef RefreshTokenProvider = Future<String?> Function();

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late String baseUrl;
  TokenProvider? tokenProvider;
  RefreshTokenProvider? refreshTokenProvider;

  void init({
    required String baseUrl,
    TokenProvider? tokenProvider,
    RefreshTokenProvider? refreshToken,
  }) {
    this.baseUrl = baseUrl;
    this.tokenProvider = tokenProvider;
    this.refreshTokenProvider = refreshToken;
  }

  Uri _uri(String path) =>
      Uri.parse(path.startsWith('http') ? path : '$baseUrl$path');

  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    return _send('GET', path, null, headers);
  }

  Future<http.Response> post(
    String path,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    return _send('POST', path, body, headers);
  }

  Future<http.Response> patch(
    String path,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    return _send('PATCH', path, body, headers);
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    return _send('DELETE', path, null, headers);
  }

  Future<http.Response> _send(
    String method,
    String path,
    dynamic body,
    Map<String, String>? headers,
  ) async {
    final uri = _uri(path);
    final token = tokenProvider == null ? null : await tokenProvider!();
    final allHeaders = <String, String>{'Content-Type': 'application/json'};
    if (headers != null) allHeaders.addAll(headers);
    if (token != null && token.isNotEmpty) {
      allHeaders['Authorization'] = 'Bearer $token';
    }

    http.Response res;
    try {
      if (method == 'GET') {
        res = await http.get(uri, headers: allHeaders);
      } else if (method == 'POST') {
        final cleaned = _cleanBody(body);
        res = await http.post(
          uri,
          headers: allHeaders,
          body: jsonEncode(cleaned),
        );
      } else if (method == 'PATCH') {
        final cleaned = _cleanBody(body);
        res = await http.patch(
          uri,
          headers: allHeaders,
          body: jsonEncode(cleaned),
        );
      } else if (method == 'DELETE') {
        res = await http.delete(uri, headers: allHeaders);
      } else {
        throw UnsupportedError('Method not supported');
      }
    } catch (e) {
      rethrow;
    }

    if (res.statusCode == 401 && refreshTokenProvider != null) {
      // try refresh
      final newToken = await refreshTokenProvider!();
      if (newToken != null && newToken.isNotEmpty) {
        allHeaders['Authorization'] = 'Bearer $newToken';
        if (method == 'GET') {
          res = await http.get(uri, headers: allHeaders);
        } else if (method == 'POST') {
          final cleaned = _cleanBody(body);
          res = await http.post(
            uri,
            headers: allHeaders,
            body: jsonEncode(cleaned),
          );
        } else if (method == 'PATCH') {
          final cleaned = _cleanBody(body);
          res = await http.patch(
            uri,
            headers: allHeaders,
            body: jsonEncode(cleaned),
          );
        } else if (method == 'DELETE') {
          res = await http.delete(uri, headers: allHeaders);
        }
      }
    }

    // If response indicates lack of authorization (401 or 403) attempt to clear tokens
    // and navigate to login so the app enforces sign-in.
    if (res.statusCode == 401 || res.statusCode == 403) {
      try {
        if (GetIt.I.isRegistered<AuthController>()) {
          final auth = GetIt.I.get<AuthController>();
          // Ask AuthController to validate session (may attempt refresh).
          final valid = await auth.ensureSessionValid();
          if (!valid) {
            await auth.clearTokens();
            if (GetIt.I.isRegistered<GlobalKey<NavigatorState>>()) {
              final key = GetIt.I.get<GlobalKey<NavigatorState>>();
              key.currentState?.pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          }
        } else {
          // No AuthController available — perform redirect as fallback
          if (GetIt.I.isRegistered<GlobalKey<NavigatorState>>()) {
            final key = GetIt.I.get<GlobalKey<NavigatorState>>();
            key.currentState?.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        }
      } catch (_) {}
    }

    return res;
  }

  dynamic _cleanBody(dynamic input) {
    if (input == null) return null;
    if (input is String) {
      final s = input.trim();
      return s.isEmpty ? null : s;
    }
    if (input is num || input is bool) return input;
    if (input is List) {
      final out = input.map(_cleanBody).where((e) => e != null).toList();
      return out.isEmpty ? null : out;
    }
    if (input is Map) {
      final Map<String, dynamic> out = {};
      input.forEach((k, v) {
        final cleaned = _cleanBody(v);
        if (cleaned != null) out[k] = cleaned;
      });
      return out.isEmpty ? null : out;
    }
    // fallback: attempt to json encode; if empty string, return null
    return input;
  }
}
