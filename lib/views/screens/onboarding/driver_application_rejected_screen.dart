import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../driver/become_driver_screen_29.dart';
import '../auth/login_screen_115.dart';

class DriverApplicationRejectedScreen extends StatelessWidget {
  final String? rejectionReason;
  final String? driverPhone;

  const DriverApplicationRejectedScreen({
    super.key,
    this.rejectionReason,
    this.driverPhone,
  });

  @override
  Widget build(BuildContext context) {
    final reason = (rejectionReason != null && rejectionReason!.isNotEmpty)
        ? rejectionReason!
        : "Your submitted documents (Driving License, Vehicle RC, or Pollution Certificate) could not be verified by the admin team.";

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const Spacer(),

                  // Red Cross Rejection Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFEF5350), width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.close_rounded,
                        color: Color(0xFFD32F2F),
                        size: 56,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Title
                  const Text(
                    "Application Rejected",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle Notice
                  const Text(
                    "Your driver application has been reviewed and rejected by the admin team.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reason Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Color(0xFFD32F2F), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Reason for Rejection',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reason,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Primary Button: Re-apply / Upload Documents Again
                  CustomButton(
                    text: 'Re-apply / Update Documents',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BecomeDriverScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Secondary Button: Back to Login
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Back To Login',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
