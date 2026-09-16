import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'confirmed_booking_management_screen_67.dart';

class StayBookingSuccessScreen extends StatelessWidget {
  const StayBookingSuccessScreen({Key? key}) : super(key: key);

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
            Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Confetti Celebration Checkmark Graphic matching 110.png
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

              const SizedBox(height: 36),

              // Title Header matching 110.png
              const Text(
                'Booking Conformed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Your Stay has\nbeen booked successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Booking ID',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              const Text(
                'STAY123456789',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),

              const Spacer(),

              // Primary CTA: View Booking matching 110.png
              CustomButton(
                text: 'View Booking',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ConfirmedBookingManagementScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Secondary CTA: Go To Home matching 110.png
              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text(
                  'Go To Home',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }
}
