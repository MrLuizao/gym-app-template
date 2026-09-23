import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import '../config/app_config.dart';

/// Cliente HTTP hacia el backend Nuxt (B2B) con el ID token de Firebase.
/// Endpoints disponibles para el socio: /api/ads/track, /api/payments/intent.
class ApiClient {
  ApiClient._();

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final request = await HttpClient().postUrl(uri);
    request.headers.contentType = ContentType.json;
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    request.write(jsonEncode(body));
    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, text);
    }
    if (text.isEmpty) return const {};
    final decoded = jsonDecode(text);
    return decoded is Map<String, dynamic> ? decoded : const {};
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}
