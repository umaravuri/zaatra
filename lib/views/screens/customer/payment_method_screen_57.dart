import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/ride_booking_model.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_button.dart';
import 'stay_booking_success_screen_110.dart';
import 'ride_booking_success_screen_111.dart';

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

  double get _amount => widget.totalAmount ?? widget.rideSession?.totalAmount ?? 16750.0;

  final List<Map<String, dynamic>> _methods = [
    {'title': 'UPI', 'icon': Icons.account_balance_wallet_rounded},
    {'title': 'Credit/debit card', 'icon': Icons.credit_card_rounded},
    {'title': 'Net Banking', 'icon': Icons.account_balance_rounded},
    {'title': 'Wallet', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Pay later', 'icon': Icons.access_time_rounded},
  ];

  void _handlePayment() async {
    if (_isProcessing) return;

    if (widget.rideSession != null) {
      setState(() => _isProcessing = true);

      final selectedTitle = _methods[_selectedMethodIndex]['title'] as String;
      final finalSession = widget.rideSession!.copyWith(
        paymentMethod: selectedTitle,
        totalAmount: _amount,
      );

      // 🚀 Trigger Live Backend API: POST /api/rides/book
      final response = await RideService.bookRide(finalSession);

      if (!mounted) return;
      setState(() => _isProcessing = false);

      // Extract dynamic PIN from backend if returned or keep confirmed session
      final pin = response['boardingPin']?.toString() ??
          (response['data'] is Map ? response['data']['boardingPin']?.toString() : null) ??
          finalSession.boardingPin;

      final confirmedSession = finalSession.copyWith(boardingPin: pin);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride Booked Successfully!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RideBookingSuccessScreen(session: confirmedSession),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StayBookingSuccessScreen()),
      );
    }
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
