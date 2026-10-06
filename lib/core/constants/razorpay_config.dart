import '../config/app_env.dart';

class RazorpayConfig {
  /// Live/Test Razorpay Key ID from AppEnv (.env or fallback)
  static String get keyId => AppEnv.razorpayKeyId;

  /// Business Name shown on the Razorpay checkout header
  static const String businessName = 'Zaatra';

  /// Default currency code
  static const String currency = 'INR';

  /// Default theme color hex for checkout header
  static const String themeColor = '#5D3891';
}
