import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'host_add_property_step1_71.dart';
import 'host_home_dashboard_screen_37.dart';

class BecomeHostScreen extends StatelessWidget {
  const BecomeHostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Bottom Background Graphic (image 31.png)
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
                // Top Header with Back Arrow
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 12.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // House Vector Graphic Banner matching 28.png
                        const CustomImagePlaceholder(
                          height: 200,
                          width: double.infinity,
                          icon: Icons.villa_rounded,
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),

                        const SizedBox(height: 28),

                        // Title Header matching 28.png
                        const Text(
                          'Become a Host',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'List your Property and start\nearning with us.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                        ),

                        const SizedBox(height: 36),

                        // Feature Row 1: Easy Property Listing
                        _buildFeatureRow(Icons.home_outlined, 'Easy property listing'),
                        const SizedBox(height: 20),

                        // Feature Row 2: Secure Payment
                        _buildFeatureRow(Icons.shield_outlined, 'Secure payment'),
                        const SizedBox(height: 20),

                        // Feature Row 3: Grow Your Earning
                        _buildFeatureRow(Icons.trending_up_rounded, 'Grow Your earning'),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Bottom Get Started CTA matching 28.png -> Goes to Screen 71
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: CustomButton(
                    text: 'Get Started',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HostAddPropertyStep1Screen()),
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
