import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/razorpay_config.dart';
import '../../../models/ride_booking_model.dart';
import '../../../services/ride_service.dart';
import '../../../services/razorpay_web_service.dart';
import '../../widgets/custom_button.dart';
import 'stay_booking_success_screen_110.dart';
import 'ride_confirmed_detail_screen_112.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double? totalAmount;
  final RideBookingSession? rideSession;

  const PaymentMethodScreen({
    super.key,
    this.totalAmount,
    this.rideSession,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _selectedMethodIndex = 0;
  bool _isProcessing = false;
  late Razorpay _razorpay;

  double get _amount => widget.totalAmount ?? widget.rideSession?.totalAmount ?? 250.0;

  final List<Map<String, dynamic>> _methods = [
    {'title': 'UPI', 'icon': Icons.account_balance_wallet_rounded},
    {'title': 'Credit/debit card', 'icon': Icons.credit_card_rounded},
    {'title': 'Net Banking', 'icon': Icons.account_balance_rounded},
    {'title': 'Wallet', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Pay later', 'icon': Icons.access_time_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _initRazorpay();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final session = widget.rideSession;
    if (session == null) return;

    setState(() => _isProcessing = true);

    final selectedTitle = _methods[_selectedMethodIndex]['title'] as String;
    final bookingId = session.bookingId.isNotEmpty
        ? session.bookingId
        : 'BK-RIDE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final orderId = response.orderId ?? (session.razorpayOrderId.isNotEmpty ? session.razorpayOrderId : '');
    final paymentId = response.paymentId ?? '';
    final signature = response.signature ?? '';

    // 🚀 Send genuine Razorpay cryptographic credentials to Backend: POST /api/payments/verify
    final verifyRes = await RideService.verifyPayment(
      bookingId: bookingId,
      razorpayOrderId: orderId,
      razorpayPaymentId: paymentId,
      razorpaySignature: signature,
      method: selectedTitle,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (verifyRes['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(verifyRes['message']?.toString() ?? 'Payment verification failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pin = verifyRes['boardingPin']?.toString() ??
        (verifyRes['data'] is Map ? verifyRes['data']['boardingPin']?.toString() : null) ??
        session.boardingPin;

    final confirmedSession = session.copyWith(
      bookingId: bookingId,
      paymentMethod: selectedTitle,
      totalAmount: _amount,
      boardingPin: pin,
      razorpayOrderId: orderId,
      razorpayPaymentId: paymentId,
      razorpaySignature: signature,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Verified & Ride Booked Successfully! 🎉'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RideConfirmedDetailScreen112(session: confirmedSession),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message ?? "Transaction was cancelled"}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName ?? ""}'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _handlePayment() async {
    if (_isProcessing) return;

    if (widget.rideSession != null) {
      final session = widget.rideSession!;
      final rawAmountInPaise = (_amount * 100).toInt();

      final options = <String, dynamic>{
        'key': RazorpayConfig.keyId,
        'amount': rawAmountInPaise > 0 ? rawAmountInPaise : 25000,
        'name': RazorpayConfig.businessName,
        'description': 'Shared Ride Booking - ${session.rideId.isNotEmpty ? session.rideId : "Ride"}',
        'currency': RazorpayConfig.currency,
        'timeout': 300,
        'prefill': {
          'contact': session.passengerPhone.isNotEmpty ? session.passengerPhone : '9876543210',
          'email': session.passengerEmail.isNotEmpty ? session.passengerEmail : 'customer@zaatra.com',
        },
        'theme': {
          'color': RazorpayConfig.themeColor,
        },
      };

      if (session.razorpayOrderId.isNotEmpty && !session.razorpayOrderId.startsWith('mock_')) {
        options['order_id'] = session.razorpayOrderId;
      }

      if (kIsWeb) {
        setState(() => _isProcessing = true);
        try {
          RazorpayWebService.openCheckout(
            options: options,
            onSuccess: (paymentId, orderId, signature) {
              _handlePaymentSuccess(
                PaymentSuccessResponse(
                  paymentId,
                  orderId.isNotEmpty ? orderId : (session.razorpayOrderId.isNotEmpty ? session.razorpayOrderId : ''),
                  signature,
                  {},
                ),
              );
            },
            onError: (error) {
              _handlePaymentError(
                PaymentFailureResponse(
                  Razorpay.PAYMENT_CANCELLED,
                  error,
                  {},
                ),
              );
            },
          );
        } catch (e) {
          setState(() => _isProcessing = false);
          _showWebPaymentDialog(session);
        }
        return;
      }

      try {
        setState(() => _isProcessing = true);
        _razorpay.open(options);
      } catch (e) {
        setState(() => _isProcessing = false);
        _showWebPaymentDialog(session);
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StayBookingSuccessScreen()),
      );
    }
  }

  void _showWebPaymentDialog(RideBookingSession session) {
    final selectedTitle = _methods[_selectedMethodIndex]['title'] as String;
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EDF7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.payment_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Razorpay Checkout (Web/Test)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Method: $selectedTitle • Amount: ₹${_amount.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ride ID: ${session.rideId.isNotEmpty ? session.rideId : "RD-2002-176"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Passenger: ${session.passengerName.isNotEmpty ? session.passengerName : "Passenger"}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Order ID: ${session.razorpayOrderId.isNotEmpty ? session.razorpayOrderId : "order_EK50q1A93N3X7g"}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Simulate Successful Payment (Test Mode)',
                  onPressed: () {
                    Navigator.pop(ctx);
                    final testOrderId = session.razorpayOrderId.isNotEmpty ? session.razorpayOrderId : 'order_EK50q1A93N3X7g';
                    final testPaymentId = 'pay_${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}';
                    final testSignature = '9ef4b6163b7_${DateTime.now().millisecondsSinceEpoch}';

                    _handlePaymentSuccess(
                      PaymentSuccessResponse(
                        testPaymentId,
                        testOrderId,
                        testSignature,
                        {},
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _handlePaymentError(PaymentFailureResponse(Razorpay.PAYMENT_CANCELLED, 'Cancelled by user', {}));
                    },
                    child: const Text('Cancel Transaction', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (mounted && _isProcessing) {
        setState(() => _isProcessing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Method',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Total Bill Display
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6750A4), Color(0xFF7E67BE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Payable Amount', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              Text(
                                '₹ ${_amount.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.rideSession != null ? 'Shared Ride Booking • ${widget.rideSession!.seatsCount} Seat(s)' : 'Hotel Stay Booking • 1 Room, 3 Nights',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Select Payment Method',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),

                        const SizedBox(height: 16),

                        // Payment Methods List matching 58.png
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _methods.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final method = _methods[index];
                            final isSelected = _selectedMethodIndex == index;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMethodIndex = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFF7F4FB) : const Color(0xFFFAFAFA),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(method['icon'] as IconData, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 24),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        method['title'] as String,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Pay Button matching 58.png
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    text: _isProcessing ? 'Processing Booking...' : 'Pay ₹${_amount.toStringAsFixed(0)}',
                    isLoading: _isProcessing,
                    onPressed: _handlePayment,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
