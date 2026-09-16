import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'driver_live_next_pickup_screen_95.dart';

class DriverOnTripSeatsScreen extends StatelessWidget {
  final String origin;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final String duration;

  const DriverOnTripSeatsScreen({
    super.key,
    this.origin = '-',
    this.destination = '-',
    this.departureTime = '-',
    this.arrivalTime = '-',
    this.duration = '-',
  });

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
              // Main Live Route Card matching 91.png
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(origin, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text(duration, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text(destination, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(departureTime, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        const Text('• • • • • • •', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        Text(arrivalTime, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Map Container inside Card matching 91.png
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8DEF8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary, size: 24),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // EAT & Distance Left Row matching 91.png
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('EAT  02h 45 Mins', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text('Distance Left  210 Km', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Seats Available Section matching 91.png
              const Text(
                'Seats Available',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5FE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSeatBox('S-1 Booked', isBooked: true),
                    _buildSeatBox('S-2 Booked', isBooked: true),
                    _buildSeatBox('S-3 Booked', isBooked: true),
                    _buildSeatBox('Available', isBooked: false),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Share Trip Card CTA Button matching 91.png
              CustomButton(
                text: 'Share Trip Card',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverLiveNextPickupScreen()),
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

  Widget _buildSeatBox(String label, {required bool isBooked}) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isBooked ? const Color(0xFFE8DEF8) : const Color(0xFFC4D5C5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              isBooked ? Icons.person_rounded : Icons.check_box_outline_blank_rounded,
              color: isBooked ? AppColors.primary : Colors.transparent,
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
