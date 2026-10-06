import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/app_env.dart';

class ApiService {
  /// Base API URL dynamically fetched from AppEnv (.env or fallback)
  static String get baseUrl => AppEnv.baseUrl;

  /// Server root URL (without '/api' suffix), used for relative media/uploads URLs
  static String get serverBaseUrl => baseUrl.replaceAll('/api', '');

  /// Backwards-compatibility alias for server root URL
  static String get tunnelUrl => serverBaseUrl;

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

  static Future<Map<String, dynamic>> delete(String endpoint, {Map<String, dynamic>? body, String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
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
