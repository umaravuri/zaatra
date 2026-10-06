class RazorpayWebService {
  static void openCheckout({
    required Map<String, dynamic> options,
    required Function(String paymentId, String orderId, String signature) onSuccess,
    required Function(String error) onError,
  }) {
    // No-op on native mobile platforms (handled by razorpay_flutter)
  }
}
