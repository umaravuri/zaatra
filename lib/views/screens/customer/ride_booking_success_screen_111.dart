import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/ride_booking_model.dart';
import '../../widgets/custom_button.dart';
import 'customer_home_screen_38.dart';
import 'live_ride_tracking_screen_106.dart';

class RideBookingSuccessScreen extends StatelessWidget {
  final RideBookingSession? session;

  const RideBookingSuccessScreen({
    super.key,
    this.session,
  });

  RideBookingSession get _activeSession =>
      session ??
      RideBookingSession(
        driver: mockRideDrivers[0],
      );

  @override
  Widget build(BuildContext context) {
    final active = _activeSession;

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
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            const SizedBox(height: 16),

                            // Celebration Checkmark Circle matching 111.png
                            Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 80),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Title Header matching 111.png
                            const Text(
                              'Booking Confirmed!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Your ride with ${active.driver.name} has\nbeen booked successfully',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Security Boarding PIN & Booking Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F4FB),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Flexible(
                                        child: Text(
                                          'Boarding 4-Digit PIN:',
                                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          active.boardingPin,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(color: AppColors.border),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Flexible(
                                        child: Text(
                                          'Car & Plate:',
                                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          active.driver.vehicleNumber,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Flexible(
                                        child: Text(
                                          'Amount Paid:',
                                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '₹${active.totalAmount.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),
                            const SizedBox(height: 16),

                            // Primary CTA: View Tracking matching 111.png
                            CustomButton(
                              text: 'View Live Tracking',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LiveRideTrackingScreen()),
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Secondary CTA: Go To Home (Screen 38)
                            TextButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                'Go To Dashboard',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
