import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'driver_on_trip_screen_39.dart';

class DriverRideStartScreen extends StatelessWidget {
  const DriverRideStartScreen({super.key});

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
            SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Route & Date Header Card
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
                  children: const [
                    Row(
                      children: [
                        Text('Madhapur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textMuted),
                        SizedBox(width: 10),
                        Text('Secundrabad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text('20 May 2024 - 09 : 00 AM', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Pickup location badge
              _buildLocationBadge('Pickup location', 'Madhapur , Hyderabad', const Color(0xFF4CAF50)),

              const SizedBox(height: 12),

              // Destination badge
              _buildLocationBadge('Destination', 'Secundrabad', const Color(0xFFE53935)),

              const SizedBox(height: 20),

              // Passengers Boarded Header
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Passengers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('No passengers boarded', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ],
              ),

              const SizedBox(height: 12),

              // Live Navigation Map Box
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
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                        ),
                        child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary, size: 28),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 1. Share Trip Card Button
              CustomButton(
                text: 'Share Trip Card',
                isOutlined: true,
                backgroundColor: const Color(0xFFF3EDF7),
                textColor: AppColors.primary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trip card shared successfully!')),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 2. Start Ride Button
              CustomButton(
                text: 'Start Ride',
                backgroundColor: AppColors.primary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ride started!')),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 3. Start Navigation Button
              CustomButton(
                text: 'Start Navigation',
                backgroundColor: const Color(0xFF4CAF50),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverOnTripScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 4. Complete Ride Button
              CustomButton(
                text: 'Complete Ride',
                isOutlined: true,
                backgroundColor: Colors.white,
                textColor: AppColors.primary,
                onPressed: () {
                  Navigator.pop(context);
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

  Widget _buildLocationBadge(String label, String address, Color color) {
    return Row(
      children: [
        Icon(Icons.location_on_rounded, color: color, size: 22),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(address, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }
}
