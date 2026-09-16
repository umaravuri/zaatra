import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'trip_completed_summary_screen_35.dart';

class DriverInTripNavigationScreen extends StatefulWidget {
  const DriverInTripNavigationScreen({Key? key}) : super(key: key);

  @override
  State<DriverInTripNavigationScreen> createState() => _DriverInTripNavigationScreenState();
}

class _DriverInTripNavigationScreenState extends State<DriverInTripNavigationScreen> {
  int _tripStage = 0; // 0 = Navigating to Pickup, 1 = Arrived / In Trip, 2 = Complete

  final List<String> _stageLabels = [
    'Arrived at Pickup',
    'Start Trip to Destination',
    'Complete Trip',
  ];

  void _advanceTripStage() {
    if (_tripStage < 2) {
      setState(() {
        _tripStage++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TripCompletedSummaryScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Navigation'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Map GPS Navigation View matching Screen 33
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE8E5F4),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.navigation_rounded, size: 40, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _tripStage == 0 ? 'Navigating to Passenger Pickup' : 'Driving to Destination (Banani D)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tripStage == 0 ? '1.2 km away • 4 mins ETA' : '7.3 km remaining • 15 mins ETA',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Passenger Card & Action Controls matching Screen 33
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                        children: const [
                          Text('Sarah Ahmed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 2),
                          Text('Pickup: Gulshan 2, Avenue 4', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.phone_rounded, color: AppColors.primary),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  CustomButton(
                    text: _stageLabels[_tripStage],
                    backgroundColor: _tripStage == 2 ? AppColors.success : AppColors.primary,
                    onPressed: _advanceTripStage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
