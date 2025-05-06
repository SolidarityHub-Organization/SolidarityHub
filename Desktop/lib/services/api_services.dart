import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';

extension StatusCodeExtension on int {
  bool get ok => this >= 200 && this < 300;
}

class ApiServices {
  static final AppConfig _config = AppConfig();
  static String get baseUrl => _config.apiBaseUrl;
  static Map<String, String> get headers => {'Content-Type': 'application/json', 'Accept': 'application/json'};

  static Future<http.Response> get(String endpoint, {Map<String, String>? queryParams}) async {
    final Uri uri = _buildUri(endpoint, queryParams);

    if (kDebugMode) {
      print('🌐 GET Request: $uri');
    }

    try {
      final response = await http.get(uri, headers: headers);

      if (kDebugMode) {
        print('📥 Response [${response.statusCode}]: ${response.statusCode.ok ? "" : response.body}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en GET $endpoint: $e');
      }
      rethrow;
    }
  }

  static Future<http.Response> post(String endpoint, {Map<String, String>? queryParams, dynamic body}) async {
    final Uri uri = _buildUri(endpoint, queryParams);
    final String jsonBody = json.encode(body);

    if (kDebugMode) {
      print('🌐 POST Request: $uri');
      print('📤 Body: $jsonBody');
    }

    try {
      final response = await http.post(uri, headers: headers, body: jsonBody);

      if (kDebugMode) {
        print('📥 Response [${response.statusCode}]: ${response.statusCode.ok ? "" : response.body}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en POST $endpoint: $e');
      }
      rethrow;
    }
  }

  static Future<http.Response> put(String endpoint, {Map<String, String>? queryParams, dynamic body}) async {
    final Uri uri = _buildUri(endpoint, queryParams);
    final String jsonBody = json.encode(body);

    if (kDebugMode) {
      print('🌐 PUT Request: $uri');
      print('📤 Body: $jsonBody');
    }

    try {
      final response = await http.put(uri, headers: headers, body: jsonBody);

      if (kDebugMode) {
        print('📥 Response [${response.statusCode}]: ${response.statusCode.ok ? "" : response.body}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en PUT $endpoint: $e');
      }
      rethrow;
    }
  }

  static Future<http.Response> delete(String endpoint, {Map<String, String>? queryParams}) async {
    final Uri uri = _buildUri(endpoint, queryParams);

    if (kDebugMode) {
      print('🌐 DELETE Request: $uri');
    }

    try {
      final response = await http.delete(uri, headers: headers);

      if (kDebugMode) {
        print('📥 Response [${response.statusCode}]: ${response.statusCode.ok ? "" : response.body}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en DELETE $endpoint: $e');
      }
      rethrow;
    }
  }

  static Uri _buildUri(String endpoint, Map<String, String>? queryParams) {
    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }

    final String url = '$baseUrl/$endpoint';
    return Uri.parse(url).replace(queryParameters: queryParams);
  }
}
