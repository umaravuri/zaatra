import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'driver_my_ride_screen_30.dart';
import 'driver_ride_start_screen_38.dart';

class DriverTripPreparationScreen extends StatelessWidget {
  const DriverTripPreparationScreen({Key? key}) : super(key: key);

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
            SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route & Date Header Card matching Image 3
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withAlpha(25)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text('Madhapur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textMuted),
                        SizedBox(width: 10),
                        Text('Secundrabad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('20 May 2024 - 09 : 00 AM', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Checklist Bullet Points matching Image 3
              const Text('• Verify your govt ID', style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              const Text('• Add your profile photo to recognize you at the meeting point', style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),

              const SizedBox(height: 24),

              // Vertical Waypoints Timeline matching Image 3
              _buildWaypointItem('9 : 00', 'Madhapur', isStart: true),
              _buildTimelineLine(),
              _buildWaypointItem('10 : 00', 'Ameerpet'),
              _buildTimelineLine(),
              _buildWaypointItem('12 : 00', 'Begumpet'),
              _buildTimelineLine(),
              _buildWaypointItem('01 : 00', 'Secundrabad'),

              const SizedBox(height: 24),

              // Passengers Section Title matching Image 3
              const Text(
                'Passengers (3)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),

              const SizedBox(height: 12),

              // Passengers List Box matching Image 3
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withAlpha(25)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    _buildPassengerRow(context, 'Ramesh Verma', '₹ 380 Madhapur'),
                    const Divider(height: 24, color: AppColors.border),
                    _buildPassengerRow(context, 'Suresh', '₹ 250 Hitech city'),
                    const Divider(height: 24, color: AppColors.border),
                    _buildPassengerRow(context, 'Ramesh Verma', '₹ 180 Ameerpet'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Pickup Point info matching Image 3
              const Text('Pickup Point', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('pink square mall,Madhapur', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  Text('07 : 45 AM', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ],
              ),

              const SizedBox(height: 28),

              // Edit Ride Button matching Image 3
              CustomButton(
                text: 'Edit Ride',
                isOutlined: true,
                backgroundColor: const Color(0xFFF3EDF7),
                textColor: AppColors.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverMyRideScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Start Ride CTA Button matching Image 3
              CustomButton(
                text: 'Start Ride',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverRideStartScreen()),
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

  Widget _buildWaypointItem(String time, String station, {bool isStart = false}) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ),
        const SizedBox(width: 10),
        isStart
            ? const Icon(Icons.directions_car_rounded, color: Colors.redAccent, size: 20)
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

  Widget _buildPassengerRow(BuildContext context, String name, String detail) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primaryBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(detail, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Calling $name...')),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF3EDF7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_rounded, size: 18, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
