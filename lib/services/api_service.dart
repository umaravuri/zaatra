import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String localUrl = 'http://localhost:5000/api';
  static const String tunnelUrl = 'https://qvxd0wjl-5000.inc1.devtunnels.ms/api';

  // Base URL pointing to public VS Code devtunnel for mobile testing
  static String get baseUrl {
    if (kIsWeb) {
      return localUrl;
    }
    return tunnelUrl;
  }

  static Future<Map<String, String>> _getHeaders({String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Bypass-Tunnel-Reminder': 'true',
    };

    String activeToken = token ?? '';
    if (activeToken.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        activeToken = prefs.getString('authToken') ?? '';
      } catch (_) {}
    }

    if (activeToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $activeToken';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body, {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {'message': response.body};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': data,
          if (data is Map<String, dynamic>) ...data,
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': (data is Map ? data['message'] : null) ?? 'Request failed with status ${response.statusCode}',
          'data': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: Could not reach backend server at $baseUrl. Please ensure "npm start" is running in Zaatra_Backend-main.',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url, headers: headers);

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {'message': response.body};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': data,
          if (data is Map<String, dynamic>) ...data,
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': (data is Map ? data['message'] : null) ?? 'Request failed with status ${response.statusCode}',
          'data': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: Could not reach backend server at $baseUrl.',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body, {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {'message': response.body};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': data,
          if (data is Map<String, dynamic>) ...data,
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': (data is Map ? data['message'] : null) ?? 'Request failed with status ${response.statusCode}',
          'data': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: Could not reach backend server at $baseUrl.',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> body, {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {'message': response.body};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': data,
          if (data is Map<String, dynamic>) ...data,
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': (data is Map ? data['message'] : null) ?? 'Request failed with status ${response.statusCode}',
          'data': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: Could not reach backend server at $baseUrl.',
        'error': e.toString(),
      };
    }
  }
}
