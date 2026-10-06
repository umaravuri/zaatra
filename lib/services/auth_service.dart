import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // 1. User Registration API
  // Endpoint: POST /auth/register
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String city,
    required String state,
    required String country,
    required String role,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'city': city,
      'state': state,
      'country': country,
      'role': role.toLowerCase(),
    };

    final result = await ApiService.post('/auth/register', body);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
      await prefs.setString('user_name_$cleanPhone', name);
      await prefs.setString('currentUserName', name);
      await prefs.setString('user_email_$cleanPhone', email);
    } catch (_) {}
    return result;
  }

  // 2. Mobile Login Step 1: Initialize Login & Receive OTP
  // Endpoint: POST /auth/mobile/login-init
  static Future<Map<String, dynamic>> loginInitMobile({
    required String phone,
    required String password,
  }) async {
    // Generate candidate phone formats to handle any whitespace or formatting differences
    final rawDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final tenDigits = rawDigits.length >= 10 ? rawDigits.substring(rawDigits.length - 10) : rawDigits;

    final candidates = <String>{
      phone.trim(),
      '+91 $tenDigits',
      '+91$tenDigits',
      tenDigits,
      if (tenDigits.length == 10) '+91 ${tenDigits.substring(0, 5)} ${tenDigits.substring(5)}',
    };

    Map<String, dynamic> lastResult = {};

    for (final candidatePhone in candidates) {
      final body = {
        'phone': candidatePhone,
        'password': password,
      };

      final result = await ApiService.post('/auth/mobile/login-init', body);
      lastResult = result;

      if (result['success'] == true) {
        // Tag matched phone so subsequent role selection or session uses exact registered string
        result['matchedPhone'] = candidatePhone;
        return result;
      }

      // If backend explicitly failed with wrong password, don't keep trying candidate formats
      final msg = (result['message'] ?? '').toString().toLowerCase();
      if (msg.contains('password') || msg.contains('incorrect') || msg.contains('invalid password')) {
        return result;
      }
    }

    return lastResult;
  }

  // 3. Mobile Login Step 2: Verify 6-Digit OTP
  // Endpoint: POST /auth/mobile/verify-otp
  static Future<Map<String, dynamic>> verifyOtpMobile({
    required String phone,
    required String otp,
  }) async {
    final body = {
      'phone': phone,
      'otp': otp,
    };

    return await ApiService.post('/auth/mobile/verify-otp', body);
  }

  // 4. Mobile Login Step 3: Choose Role & Complete Login (Receive JWT Token)
  // Endpoint: POST /auth/mobile/select-role
  static Future<Map<String, dynamic>> selectRoleMobile({
    required String phone,
    required String role,
  }) async {
    final body = {
      'phone': phone,
      'role': role.toLowerCase(),
    };

    final result = await ApiService.post('/auth/mobile/select-role', body);

    if (result['success'] == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = result['token'] ?? (result['data'] is Map ? result['data']['token'] : null);
        final user = result['user'] ?? (result['data'] is Map ? result['data']['user'] : null);
        final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

        if (token != null) {
          await prefs.setString('authToken', token.toString());
        }
        if (user != null) {
          await prefs.setString('userProfile', jsonEncode(user));
          if (user is Map) {
            if (user['name'] != null && user['name'].toString().isNotEmpty) {
              await prefs.setString('currentUserName', user['name'].toString());
              await prefs.setString('user_name_$cleanPhone', user['name'].toString());
            }
            if (user['email'] != null && user['email'].toString().isNotEmpty) {
              await prefs.setString('currentUserEmail', user['email'].toString());
              await prefs.setString('user_email_$cleanPhone', user['email'].toString());
            }
            if (user['city'] != null && user['city'].toString().isNotEmpty) {
              await prefs.setString('currentUserCity', user['city'].toString());
              await prefs.setString('user_city_$cleanPhone', user['city'].toString());
            }
            if (user['location'] != null && user['location'].toString().isNotEmpty) {
              await prefs.setString('currentUserLocation', user['location'].toString());
              await prefs.setString('user_location_$cleanPhone', user['location'].toString());
            }
          }
        }
        await prefs.setString('currentPhone', phone);
        await prefs.setString('selectedRole', role.toLowerCase());
        await prefs.setString('currentUserRole', role.toLowerCase());
        await prefs.setString('user_role_$cleanPhone', role.toLowerCase());
      } catch (_) {}
    }

    return result;
  }

  // Session Helpers
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('authToken');
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('userProfile');
      if (userStr != null && userStr.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(userStr);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
          if (decoded is Map) {
            return Map<String, dynamic>.from(decoded);
          }
        } catch (_) {
          // If stringified Dart map format, extract key-values via regex
          final parsed = <String, dynamic>{};
          final nameMatch = RegExp(r'name:\s*([^,}]+)').firstMatch(userStr);
          final emailMatch = RegExp(r'email:\s*([^,}]+)').firstMatch(userStr);
          final phoneMatch = RegExp(r'phone:\s*([^,}]+)').firstMatch(userStr);
          final cityMatch = RegExp(r'city:\s*([^,}]+)').firstMatch(userStr);
          final locMatch = RegExp(r'location:\s*([^,}]+)').firstMatch(userStr);
          if (nameMatch != null) parsed['name'] = nameMatch.group(1)?.trim();
          if (emailMatch != null) parsed['email'] = emailMatch.group(1)?.trim();
          if (phoneMatch != null) parsed['phone'] = phoneMatch.group(1)?.trim();
          if (cityMatch != null) parsed['city'] = cityMatch.group(1)?.trim();
          if (locMatch != null) parsed['location'] = locMatch.group(1)?.trim();
          if (parsed.isNotEmpty) return parsed;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<String> getUserName({String? phone, String defaultFallback = 'User'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (phone != null && phone.isNotEmpty) {
        final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
        final nameByPhone = prefs.getString('user_name_$cleanPhone');
        if (nameByPhone != null && nameByPhone.trim().isNotEmpty) {
          return nameByPhone.trim();
        }
      }
      final current = prefs.getString('currentUserName');
      if (current != null && current.trim().isNotEmpty) {
        return current.trim();
      }
      final user = await getCurrentUser();
      if (user != null && user['name'] != null && user['name'].toString().trim().isNotEmpty) {
        return user['name'].toString().trim();
      }
    } catch (_) {}
    return defaultFallback;
  }

  static Future<void> saveUserName(String name, {String? phone}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserName', name);
      if (phone != null && phone.isNotEmpty) {
        final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
        await prefs.setString('user_name_$cleanPhone', name);
      }
    } catch (_) {}
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
      await prefs.remove('userProfile');
      await prefs.remove('selectedRole');
      await prefs.remove('currentUserName');
      await prefs.remove('currentUserRole');
      await prefs.remove('last_registered_role');
      // Also remove any active session identifiers
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('user_role_') || key.startsWith('driver_onboarded_')) {
          await prefs.remove(key);
        }
      }
    } catch (_) {}
  }
}
