import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_placeholder.dart';
import '../onboarding/driver_personal_info_screen_20.dart';

class BecomeDriverScreen extends StatelessWidget {
  const BecomeDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.inputBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Purple Car Vector Graphic Banner matching 29.png
                    const CustomImagePlaceholder(
                      height: 200,
                      width: double.infinity,
                      icon: Icons.directions_car_filled_rounded,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),

                    const SizedBox(height: 28),

                    // Title Header matching 29.png
                    const Text(
                      'Become a Driver',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Drive with us and earn on\nyour own schedule',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                    ),

                    const SizedBox(height: 36),

                    // Feature Row 1: Flexible Hours
                    _buildFeatureRow(Icons.access_time_rounded, 'Flexible hours'),
                    const SizedBox(height: 20),

                    // Feature Row 2: Weekly Earnings
                    _buildFeatureRow(Icons.account_balance_wallet_outlined, 'Weekly earnings'),
                    const SizedBox(height: 20),

                    // Feature Row 3: Bonuses & Rewards
                    _buildFeatureRow(Icons.emoji_events_outlined, 'Bonuses & rewards'),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom Get Started CTA matching Screen 29
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: CustomButton(
                text: 'Get Started',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverPersonalInfoScreen(role: 'Driver'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFF3EDF7),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
