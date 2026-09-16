import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'driver_ratings_reviews_screen_113.dart';

class DriverTripCompletionSuccessScreen extends StatelessWidget {
  const DriverTripCompletionSuccessScreen({Key? key}) : super(key: key);

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
            Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Green Checkmark Confetti Circle matching 109.png
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 90),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Route Box matching 109.png
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Madhapur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 18),
                          SizedBox(width: 12),
                          Text('Secundrabad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('20 May 2024 - 08 : 00 AM', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),

                      const SizedBox(height: 28),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 16),

                      // Metrics Summary List matching 109.png
                      _buildMetricRow('Total Fuel Saved', '₹ 1,650'),
                      const SizedBox(height: 16),
                      _buildMetricRow('Paid By', 'Online'),
                      const SizedBox(height: 16),
                      _buildMetricRow('Co-travelers', '3'),

                      const SizedBox(height: 24),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 20),

                      // Congratulations Text matching 109.png
                      const Text(
                        'Congratulations!',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'your trip has been completed successfully',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons matching 109.png
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    CustomButton(
                      text: 'View share trip card',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DriverRatingsReviewsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
