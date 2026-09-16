import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'driver_earnings_history_screen_82.dart';

class TripCompletedSummaryScreen extends StatelessWidget {
  final String? rideId;
  final String? origin;
  final String? destination;
  final String? dateDisplay;
  final String? fuelSaved;
  final String? paymentMode;
  final String? coTravelers;
  final Map<String, dynamic>? summaryData;

  const TripCompletedSummaryScreen({
    super.key,
    this.rideId,
    this.origin,
    this.destination,
    this.dateDisplay,
    this.fuelSaved,
    this.paymentMode,
    this.coTravelers,
    this.summaryData,
  });

  @override
  Widget build(BuildContext context) {
    final data = summaryData ?? {};
    final fromLoc = origin ?? data['origin'] ?? 'Madhapur';
    final toLoc = destination ?? data['destination'] ?? 'Secundrabad';
    final date = dateDisplay ?? data['dateDisplay'] ?? '20 May 2024 - 08 : 00 AM';
    final fuel = fuelSaved ?? data['formattedFuelShare'] ?? data['fuelSaved'] ?? '₹ 1,650';
    final mode = paymentMode ?? data['paymentMode'] ?? 'Online';
    final travelers = coTravelers ?? (data['totalPassengersBoarded'] != null ? '${data['totalPassengersBoarded']}' : '3');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'On Trip',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Bottom Background Graphic
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/images/image 31.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Confetti & Green Check Circle Hero graphic matching Image 1
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF4CAF50).withAlpha(50), blurRadius: 30, spreadRadius: 10),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, color: Color(0xFF2E7D32), size: 70),
                ),
              ),

              const SizedBox(height: 36),

              // Route & Date Header matching Image 1
              Row(
                children: [
                  Text(fromLoc, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 12),
                  Text(toLoc, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(date, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ),

              const SizedBox(height: 24),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 16),

              // Financial Breakdown Table matching Image 1
              _buildSummaryRow('Total Fuel Saved', fuel, isBold: true),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 16),
              _buildSummaryRow('Paid By', mode),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 16),
              _buildSummaryRow('Co-travelers', travelers),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.border),

              const SizedBox(height: 32),

              // Congratulations Banner matching Image 1
              const Text(
                'Congratulations!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              const Text(
                'your trip has been completed successfully',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // View Share Trip Card / Earnings Button
              CustomButton(
                text: 'View share trip card',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverEarningsHistoryScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Go Home Text Button matching Image 1
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  'Go Home',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
