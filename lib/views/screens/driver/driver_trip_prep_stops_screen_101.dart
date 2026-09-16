import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'driver_ride_start_boarding_screen_103.dart';

class DriverTripPrepStopsScreen extends StatelessWidget {
  const DriverTripPrepStopsScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> _stops = const [
    {'time': '9 : 00', 'location': 'Madhapur'},
    {'time': '10 : 00', 'location': 'Ameerpet'},
    {'time': '12 : 00', 'location': 'Begumpet'},
    {'time': '01 : 00', 'location': 'Secundrabad'},
  ];

  final List<Map<String, String>> _passengers = const [
    {'name': 'Ramesh Verma', 'fare': '₹ 380 Madhapur'},
    {'name': 'Suresh', 'fare': '₹ 250 Hitech city'},
    {'name': 'Ramesh Verma', 'fare': '₹ 180 Ameerpet'},
  ];

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
          'Trip Preparation',
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
                    // Route Box matching 101.png
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

                    const SizedBox(height: 16),

                    // Verification Checklist Bullets matching 101.png
                    const Text('•  Verify your govt ID', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    const Text('•  Add your profile photo to recognize you at the meeting point', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),

                    const SizedBox(height: 24),

                    // Vertical Route Stops Timeline matching 101.png
                    Column(
                      children: List.generate(_stops.length, (index) {
                        final s = _stops[index];
                        final isFirst = index == 0;

                        return Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(s['time']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ),
                            Column(
                              children: [
                                Icon(
                                  isFirst ? Icons.directions_car_filled_rounded : Icons.circle,
                                  color: isFirst ? AppColors.primary : AppColors.border,
                                  size: isFirst ? 18 : 10,
                                ),
                                if (index < _stops.length - 1)
                                  Container(width: 2, height: 28, color: AppColors.border),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Text(s['location']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Passengers (3)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),

                    const SizedBox(height: 12),

                    // Passengers Fare List Container matching 101.png
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: List.generate(_passengers.length, (index) {
                          final p = _passengers[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: index < _passengers.length - 1 ? 14 : 0),
                            child: Row(
                              children: [
                                const CustomImagePlaceholder(
                                  width: 44,
                                  height: 44,
                                  icon: Icons.person_rounded,
                                  borderRadius: BorderRadius.all(Radius.circular(22)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                      const SizedBox(height: 2),
                                      Text(p['fare']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF3EDF7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.phone_rounded, color: AppColors.primary, size: 18),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Dual CTAs matching 101.png
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CustomButton(
                    text: 'Edit Ride',
                    isOutlined: true,
                    backgroundColor: Colors.white,
                    textColor: AppColors.primary,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Start Ride',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DriverRideStartBoardingScreen()),
                      );
                    },
                  ),
                ],
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
