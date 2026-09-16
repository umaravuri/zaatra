import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'driver_on_trip_progress_screen_108.dart';

class DriverRideStartBoardingScreen extends StatelessWidget {
  const DriverRideStartBoardingScreen({Key? key}) : super(key: key);

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
          'Ride start',
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
            Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Box matching 103.png
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text('Madhapur', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              SizedBox(width: 12),
                              Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 18),
                              SizedBox(width: 12),
                              Text('Secundrabad', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text('20 May 2024 - 09 : 00 AM', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pickup Pin Row matching 103.png
                    Row(
                      children: [
                        const Icon(Icons.circle, color: Color(0xFF4CAF50), size: 16),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Pickup location', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            SizedBox(height: 2),
                            Text('Madhapur , Hyderabad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Destination Pin Row matching 103.png
                    Row(
                      children: [
                        const Icon(Icons.circle, color: Color(0xFFE53935), size: 16),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Destination', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            SizedBox(height: 2),
                            Text('Secundrabad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Passengers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text('3/3 Boarded', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Interactive Route Map Container matching 103.png
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8DEF8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.navigation_rounded, color: AppColors.primary, size: 36),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Start Navigations CTA matching 103.png
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomButton(
                text: 'Start Navigations',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverOnTripProgressScreen()),
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
}
