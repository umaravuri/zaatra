import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized Environment Configuration
/// Reads environment variables loaded from `.env` with safe fallbacks.
class AppEnv {
  AppEnv._();

  /// Initialize and load the `.env` file at app launch
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppEnv: Notice - .env file not loaded ($e). Utilizing fallback defaults.');
      }
    }
  }

  /// Backend API Base URL
  /// Automatically uses `WEB_BASE_URL` (or localhost) when running on Chrome/Web (`kIsWeb`),
  /// or loads `BASE_URL` from `.env` for mobile APK / devices.
  static String get baseUrl {
    String rawUrl;
    if (kIsWeb) {
      final webUrl = dotenv.env['WEB_BASE_URL']?.trim();
      rawUrl = (webUrl != null && webUrl.isNotEmpty) ? webUrl : 'http://localhost:5000/api';
    } else {
      final envUrl = dotenv.env['BASE_URL']?.trim();
      rawUrl = (envUrl != null && envUrl.isNotEmpty)
          ? envUrl
          : 'https://8tbz4t2r-5000.inc1.devtunnels.ms/api';
    }
    return _normalizeBaseUrl(rawUrl);
  }

  static String _normalizeBaseUrl(String url) {
    var trimmed = url.trim();
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (!trimmed.endsWith('/api')) {
      trimmed = '$trimmed/api';
    }
    return trimmed;
  }

  /// Server root URL without '/api' suffix (e.g. 'https://8tbz4t2r-5000.inc1.devtunnels.ms')
  static String get serverBaseUrl {
    var base = baseUrl;
    if (base.endsWith('/api')) {
      base = base.substring(0, base.length - 4);
    }
    return base;
  }

  /// Google Maps Places & Directions API Key
  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY']?.trim() ?? 'AIzaSyBeecni1nLIOjHAWCb3Jof73kI1IeIyz2o';

  /// Razorpay Payment Gateway Key ID
  static String get razorpayKeyId =>
      dotenv.env['RAZORPAY_KEY_ID']?.trim() ?? 'rzp_test_SruZTYXpRSuPCc';

  /// Default Driver Password for automated registration fallback
  static String get defaultDriverPassword =>
      dotenv.env['DEFAULT_DRIVER_PASSWORD']?.trim() ?? 'DriverSecretPassword123';
}
