import 'dart:convert';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Token App Check cuando está activo (no-web) — el API lo verifica si
/// `APP_CHECK_ENFORCE=1` en el B2B; hoy es soft-check.
Future<String?> _appCheckToken() async {
  if (kIsWeb || !AppConfig.useFirebase) return null;
  try {
    return await FirebaseAppCheck.instance.getToken();
  } catch (_) {
    return null;
  }
}

/// Cliente HTTP hacia el backend Nuxt (B2B) con el ID token de Firebase.
/// Usa package:http — dart:io HttpClient no existe en web.
class ApiClient {
  ApiClient._();

  static Future<Map<String, String>> _headers() async {
    final headers = {'Content-Type': 'application/json'};
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final appCheck = await _appCheckToken();
    if (appCheck != null) headers['X-Firebase-AppCheck'] = appCheck;
    return headers;
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) return const {};
    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : const {};
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) return const {};
    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : const {};
  }

  static Future<Map<String, dynamic>> del(String path) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final response = await http.delete(uri, headers: await _headers());
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) return const {};
    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : const {};
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  /// `statusMessage` del backend si el body es JSON de error de Nuxt.
  String? get serverMessage {
    try {
      final decoded = jsonDecode(body);
      final msg = decoded is Map ? decoded['statusMessage'] : null;
      return msg is String && msg.isNotEmpty ? msg : null;
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $body';
}
