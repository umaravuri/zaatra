import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'driver_trip_completion_success_screen_109.dart';

class DriverOnTripProgressScreen extends StatelessWidget {
  const DriverOnTripProgressScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> _stops = const [
    {'time': '9 : 00', 'location': 'Madhapur'},
    {'time': '10 : 00', 'location': 'Ameerpet'},
    {'time': '12 : 00', 'location': 'Begumpet'},
    {'time': '01 : 00', 'location': 'Secundrabad'},
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
            Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Box matching 108.png
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: const [
                          Text('Madhapur', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 18),
                          SizedBox(width: 12),
                          Text('Secundrabad', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text('Mapping details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),

                    // Interactive Map Box Container with EAT & Distance Left overlay matching 108.png
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8DEF8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 14,
                            left: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('EAT  02h 45 Mins', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ),
                          ),
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('Distance Left  210 Km', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ),
                          ),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary, size: 32),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Passengers Row matching 108.png
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Text('Passengers', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            SizedBox(width: 14),
                            CustomImagePlaceholder(width: 28, height: 28, icon: Icons.person_rounded, borderRadius: BorderRadius.all(Radius.circular(14))),
                            SizedBox(width: 6),
                            CustomImagePlaceholder(width: 28, height: 28, icon: Icons.person_rounded, borderRadius: BorderRadius.all(Radius.circular(14))),
                            SizedBox(width: 6),
                            CustomImagePlaceholder(width: 28, height: 28, icon: Icons.person_rounded, borderRadius: BorderRadius.all(Radius.circular(14))),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: const BoxDecoration(color: Color(0xFFF3EDF7), shape: BoxShape.circle),
                          child: const Text('3', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Vertical Route Stops Timeline matching 108.png
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
                  ],
                ),
              ),
            ),

            // Bottom Trip Details CTA matching 108.png
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomButton(
                text: 'trip Details',
                isOutlined: true,
                backgroundColor: Colors.white,
                textColor: AppColors.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverTripCompletionSuccessScreen()),
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
