import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'driver_in_trip_navigation_screen_33.dart';

class IncomingRideRequestDialog extends StatelessWidget {
  const IncomingRideRequestDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row matching Screen 31
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'NEW RIDE REQUEST ⚡',
                    style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                const Text(
                  '15s',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Passenger Info matching Screen 31
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryBackground,
                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sarah Ahmed',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                        SizedBox(width: 4),
                        Text('4.9 (42 rides)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '\$24.50',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),

            const Divider(height: 24, color: AppColors.border),

            // Pickup & Dropoff Addresses matching Screen 31
            Row(
              children: const [
                Icon(Icons.my_location_rounded, color: AppColors.primary, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Gulshan 2, Avenue 4 (1.2 km away)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.location_on_rounded, color: AppColors.accent, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Banani Model Town, Block D (8.5 km trip)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Decline & Accept Action Buttons matching Screen 31
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Decline',
                    isOutlined: true,
                    backgroundColor: AppColors.error,
                    textColor: AppColors.error,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Accept Ride',
                    backgroundColor: AppColors.success,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DriverInTripNavigationScreen()),
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
