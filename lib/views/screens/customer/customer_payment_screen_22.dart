import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/booking_model.dart';
import '../../../models/ride_option_model.dart';
import '../../widgets/custom_button.dart';
import 'customer_ride_tracking_screen_23.dart';

class CustomerPaymentScreen extends StatefulWidget {
  final String pickupAddress;
  final String dropoffAddress;
  final RideOptionModel? selectedRide;

  const CustomerPaymentScreen({
    Key? key,
    this.pickupAddress = 'Madhapur, Hitech City',
    this.dropoffAddress = 'Gachibowli, Hyderabad',
    this.selectedRide,
  }) : super(key: key);

  @override
  State<CustomerPaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends State<CustomerPaymentScreen> {
  RideOptionModel get _ride => widget.selectedRide ?? RideOptionModel.sampleOptions.first;
  String _selectedPaymentMethod = 'Credit Card';
  final _promoController = TextEditingController();
  double _discount = 0.0;
  bool _isLoading = false;

  void _applyPromoCode() {
    if (_promoController.text.trim().toUpperCase() == 'ZAATRA50') {
      setState(() {
        _discount = _ride.estimatedFare * 0.5;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('50% Promo Discount Applied! 🎉')),
      );
    } else if (_promoController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Promo Code. Try "ZAATRA50".')),
      );
    }
  }

  void _confirmBooking() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      final booking = BookingModel.createSample(
        pickup: widget.pickupAddress,
        dropoff: widget.dropoffAddress,
        ride: _ride,
        payment: _selectedPaymentMethod,
        discount: _discount,
        promo: _promoController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerRideTrackingScreen(booking: booking),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final finalFare = (_ride.estimatedFare - _discount).clamp(0.0, 999.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Payment & Booking')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Summary Card matching Screen 22
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
                          decoration: BoxDecoration(
                            color: AppColors.primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_ride.icon, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_ride.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('${_ride.capacity} Seats • ${_ride.etaMinutes} min away', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.border),
                    _buildAddressRow(Icons.my_location_rounded, 'Pickup', widget.pickupAddress),
                    const SizedBox(height: 10),
                    _buildAddressRow(Icons.location_on_rounded, 'Dropoff', widget.dropoffAddress),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildPaymentTile('Credit Card', Icons.credit_card_rounded, '•••• 4242'),
              _buildPaymentTile('Zaatra Wallet', Icons.account_balance_wallet_rounded, 'Balance: \$85.00'),
              _buildPaymentTile('Google / Apple Pay', Icons.payment_rounded, 'Instant Pay'),
              _buildPaymentTile('Cash', Icons.payments_rounded, 'Pay Driver Directly'),

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
                    onPressed: _applyPromoCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBackground,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      minimumSize: const Size(100, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Price Breakdown matching Screen 22
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildFareRow('Ride Fare', '\$${_ride.estimatedFare.toStringAsFixed(2)}'),
                    if (_discount > 0) ...[
                      const SizedBox(height: 8),
                      _buildFareRow('Promo Discount (50%)', '-\$${_discount.toStringAsFixed(2)}', isDiscount: true),
                    ],
                    const SizedBox(height: 8),
                    _buildFareRow('Taxes & Fee', '\$1.50'),
                    const Divider(height: 24, color: AppColors.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Fare', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Text(
                          '\$${(finalFare + 1.50).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              CustomButton(
                text: 'Confirm & Pay \$${(finalFare + 1.50).toStringAsFixed(2)}',
                isLoading: _isLoading,
                onPressed: _confirmBooking,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildPaymentTile(String title, IconData icon, String subtitle) {
    final isSelected = _selectedPaymentMethod == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBackground : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.8 : 1,
          ),
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
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareRow(String title, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDiscount ? AppColors.success : AppColors.textPrimary)),
      ],
    );
  }
}
