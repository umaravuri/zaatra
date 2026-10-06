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
  /// Automatically uses `http://localhost:5000/api` when running on Chrome/Web (`kIsWeb`),
  /// or loads `BASE_URL` / `WEB_BASE_URL` from `.env`.
  static String get baseUrl {
    if (kIsWeb) {
      final webUrl = dotenv.env['WEB_BASE_URL']?.trim();
      if (webUrl != null && webUrl.isNotEmpty) {
        return webUrl;
      }
      return 'http://localhost:5000/api';
    }

    final envUrl = dotenv.env['BASE_URL']?.trim();
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    return 'http://localhost:5000/api';
  }

  /// Server root URL without '/api' suffix (e.g. 'http://localhost:5000')
  static String get serverBaseUrl => baseUrl.replaceAll('/api', '');

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
