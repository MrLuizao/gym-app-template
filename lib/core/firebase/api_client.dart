import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Cliente HTTP hacia el backend Nuxt (B2B) con el ID token de Firebase.
/// Usa package:http — dart:io HttpClient no existe en web.
class ApiClient {
  ApiClient._();

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) return const {};
    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : const {};
  }

  static Future<Map<String, dynamic>> del(String path) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final response = await http.delete(
      uri,
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
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
