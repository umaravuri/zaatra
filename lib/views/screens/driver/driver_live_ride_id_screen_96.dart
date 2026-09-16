import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DriverLiveRideIdScreen extends StatelessWidget {
  final String? rideId;
  final String? statusBadge;
  final List<Map<String, dynamic>>? routeTimeline;
  final List<Map<String, dynamic>>? seatsAvailable;
  final String? coTravelers;
  final String? rating;
  final String? fuelSaved;
  final Map<String, dynamic>? tripData;

  const DriverLiveRideIdScreen({
    super.key,
    this.rideId,
    this.statusBadge,
    this.routeTimeline,
    this.seatsAvailable,
    this.coTravelers,
    this.rating,
    this.fuelSaved,
    this.tripData,
  });

  @override
  Widget build(BuildContext context) {
    final data = tripData ?? {};
    final String badge = statusBadge ?? data['statusBadge'] ?? 'Seats Open';
    final String travelers = coTravelers ?? data['coTravelers'] ?? '-';
    final String rate = rating ?? data['rating'] ?? '-';
    final String fuel = fuelSaved ?? data['fuelSaved'] ?? '-';
    final String displayRideId = rideId ?? data['rideId'] ?? '-';

    // Dynamic timeline
    final List<Map<String, dynamic>> timeline = routeTimeline ??
        (data['routeTimeline'] is List
            ? List<Map<String, dynamic>>.from(data['routeTimeline'])
            : [
                {'time': '9 : 00', 'location': 'Madhapur', 'isStart': true},
                {'time': '10 : 00', 'location': 'Ameerpet', 'isStart': false},
                {'time': '12 : 00', 'location': 'Begumpet', 'isStart': false},
                {'time': '01 : 00', 'location': 'Secundrabad', 'isStart': false},
              ]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Live',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.textPrimary, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing Ride ID $displayRideId details...'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
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
                  // Header Pill "Seats Open" matching 96.png
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        badge,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Dynamic Waypoint Timeline matching 96.png
                  ...List.generate(timeline.length, (i) {
                    final item = timeline[i];
                    final isStart = item['isStart'] == true || item['type'] == 'start' || i == 0;
                    final isLast = i == timeline.length - 1;
                    final time = item['time'] ?? '09:00';
                    final station = item['location'] ?? item['station'] ?? '';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWaypointItem(time, station, isStart: isStart),
                        if (!isLast) _buildTimelineLine(),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  // Seats Available Section matching 96.png
                  const Text(
                    'Seats Available',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  _buildStatusPill(
                    icon: Icons.account_circle,
                    iconColor: const Color(0xFF4CAF50),
                    label: 'Co-travelers',
                    value: travelers,
                  ),
                  const SizedBox(height: 10),
                  _buildStatusPill(
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFFFB300),
                    label: '',
                    value: rate,
                  ),
                  const SizedBox(height: 10),
                  _buildStatusPill(
                    icon: Icons.local_gas_station_outlined,
                    iconColor: AppColors.primary,
                    label: 'Fuel saved',
                    value: fuel,
                  ),

                  const SizedBox(height: 60),

                  // Gold Ride ID Banner matching 96.png
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFE0B2)),
                    ),
                    child: Center(
                      child: Text(
                        'Ride ID - ${displayRideId.replaceAll('RD-', '')}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                      ),
                    ),
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
        Expanded(
          child: Text(
            station,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
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

  Widget _buildStatusPill({required IconData icon, required Color iconColor, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              if (label.isNotEmpty) const SizedBox(width: 12),
              if (label.isNotEmpty)
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
