import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'trip_completed_summary_screen_35.dart';

class DriverOnTripScreen extends StatelessWidget {
  const DriverOnTripScreen({Key? key}) : super(key: key);

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
            SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Route Card matching Image 5
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withAlpha(25)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
                ),
                child: Row(
                  children: const [
                    Text('Madhapur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textMuted),
                    SizedBox(width: 12),
                    Text('Secundrabad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text('Mapping details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),

              // Mapping Details Map Box matching Image 5
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8DEF8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: const Text('EAT 02h 45 Mins', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: const Text('Distance Left 210 Km', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                        ),
                        child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary, size: 24),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Passengers Row Title & Count Badge matching Image 5
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Passengers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3EDF7),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 3 Passenger Circular Avatars matching Image 5
              Row(
                children: [
                  _buildPassengerAvatar(),
                  const SizedBox(width: 8),
                  _buildPassengerAvatar(),
                  const SizedBox(width: 8),
                  _buildPassengerAvatar(),
                ],
              ),

              const SizedBox(height: 24),

              // Vertical Timeline Waypoints matching Image 5
              _buildWaypointItem('9 : 00', 'Madhapur', isStart: true),
              _buildTimelineLine(),
              _buildWaypointItem('10 : 00', 'Ameerpet'),
              _buildTimelineLine(),
              _buildWaypointItem('12 : 00', 'Begumpet'),
              _buildTimelineLine(),
              _buildWaypointItem('01 : 00', 'Secundrabad'),

              const SizedBox(height: 32),

              // Trip Details CTA Button matching Image 5
              CustomButton(
                text: 'trip Details',
                isOutlined: true,
                backgroundColor: const Color(0xFFF3EDF7),
                textColor: AppColors.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TripCompletedSummaryScreen()),
                  );
                },
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
    );
  }

  Widget _buildWaypointItem(String time, String station, {bool isStart = false}) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ),
        const SizedBox(width: 10),
        isStart
            ? const Icon(Icons.directions_car_rounded, color: Colors.redAccent, size: 18)
            : Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.border,
                  shape: BoxShape.circle,
                ),
              ),
        const SizedBox(width: 16),
        Text(station, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildTimelineLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 74),
      child: Container(
        height: 16,
        width: 2,
        color: AppColors.border,
      ),
    );
  }
}
