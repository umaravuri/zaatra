import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'customer_bookings_history_screen_43.dart';

class StayCheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> hotel;

  const StayCheckoutScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  State<StayCheckoutScreen> createState() => _StayCheckoutScreenState();
}

class _StayCheckoutScreenState extends State<StayCheckoutScreen> {
  String _selectedPayment = 'Credit Card';
  final _promoController = TextEditingController();
  double _discount = 0.0;
  bool _isLoading = false;

  void _applyPromo() {
    final basePrice = (widget.hotel['price'] as double) * 3;
    if (_promoController.text.trim().toUpperCase() == 'ZAATRA50') {
      setState(() {
        _discount = basePrice * 0.5;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('50% Stay Promo Applied! 🎉')),
      );
    }
  }

  void _confirmReservation() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CustomerBookingsHistoryScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final basePrice = (widget.hotel['price'] as double) * 3;
    final total = (basePrice - _discount + 35.0).clamp(0.0, 9999.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirm & Pay Reservation'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reservation Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(widget.hotel['imageIcon'] as IconData, color: AppColors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.hotel['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(widget.hotel['location'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Check-in / Check-out', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text('25 Aug - 28 Aug (3 Nights)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Guests', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text('2 Adults • Deluxe King Room', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildPaymentOption('Credit Card', Icons.credit_card_rounded, '•••• 4242'),
              _buildPaymentOption('Zaatra Wallet', Icons.account_balance_wallet_rounded, 'Balance: \$250.00'),
              _buildPaymentOption('Google / Apple Pay', Icons.payment_rounded, 'Instant Pay'),

              const SizedBox(height: 24),

              const Text('Promo Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Enter code (e.g. ZAATRA50)',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _applyPromo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBackground,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(90, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Price Breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildRow('Room Rate (3 Nights x \$${(widget.hotel['price'] as double).toStringAsFixed(0)})', '\$${basePrice.toStringAsFixed(2)}'),
                    if (_discount > 0) ...[
                      const SizedBox(height: 8),
                      _buildRow('Promo Discount (50%)', '-\$${_discount.toStringAsFixed(2)}', isDiscount: true),
                    ],
                    const SizedBox(height: 8),
                    _buildRow('Service Fee & Taxes', '\$35.00'),
                    const Divider(height: 24, color: AppColors.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              CustomButton(
                text: 'Confirm & Pay \$${total.toStringAsFixed(2)}',
                isLoading: _isLoading,
                onPressed: _confirmReservation,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, String subtitle) {
    final isSelected = _selectedPayment == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayment = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBackground : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 1.8 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, color: isSelected ? AppColors.primary : AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDiscount ? AppColors.success : AppColors.textPrimary)),
      ],
    );
  }
}
