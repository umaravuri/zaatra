import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'stay_search_results_screen_45.dart';
import 'ride_search_screen_42.dart';

class StayRideSearchScreen extends StatefulWidget {
  const StayRideSearchScreen({Key? key}) : super(key: key);

  @override
  State<StayRideSearchScreen> createState() => _StayRideSearchScreenState();
}

class _StayRideSearchScreenState extends State<StayRideSearchScreen> {
  bool _isStaySelected = true;
  final _destinationController = TextEditingController(text: 'Goa, India');
  String _checkInDate = '12 May, Monday';
  String _checkOutDate = '15 May, Thursday';
  String _guests = '2 Adult, 1 Child';
  String _rooms = '1 Room';
  String _pets = 'No Peats';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isStaySelected = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isStaySelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Stay',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _isStaySelected ? AppColors.primary : Colors.white,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isStaySelected = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: !_isStaySelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Ride',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: !_isStaySelected ? AppColors.primary : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
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
                child: _isStaySelected ? _buildStaySearchBody() : _buildRideSearchBody(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomButton(
                text: _isStaySelected ? 'Search Stays' : 'Search Rides',
                icon: _isStaySelected ? Icons.search_rounded : Icons.directions_car_rounded,
                onPressed: () {
                  if (_isStaySelected) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StaySearchResultsScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RideSearchScreen()),
                    );
                  }
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

  Widget _buildStaySearchBody() {
    return Column(
      children: [
        // Destination Input Card matching 41.png
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Destination', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              TextField(
                controller: _destinationController,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Check In / Check Out Row matching 41.png
        Row(
          children: [
            Expanded(
              child: _buildInfoCard('Check In', _checkInDate, Icons.calendar_today_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard('Check Out', _checkOutDate, Icons.calendar_today_rounded),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Guests & Rooms Row matching 41.png
        Row(
          children: [
            Expanded(
              child: _buildInfoCard('Guests', _guests, Icons.person_outline_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard('Rooms', _rooms, Icons.king_bed_outlined),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Pets Card matching 41.png
        _buildInfoCard('Pets', _pets, Icons.pets_rounded),
      ],
    );
  }

  Widget _buildRideSearchBody() {
    return Column(
      children: [
        // Pickup Location Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pickup Location', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.my_location_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text('Current Location (Airport / Station)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Destination Location Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Drop Destination', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on_rounded, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Calangute Beach, Goa', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Date & Passengers Row
        Row(
          children: [
            Expanded(
              child: _buildInfoCard('Travel Date', 'Today, 2:30 PM', Icons.access_time_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard('Passengers', '2 Seats Needed', Icons.airline_seat_recline_normal_rounded),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Vehicle Class Selection Card
        _buildInfoCard('Ride Type', 'AC Sedan / SUV Pool', Icons.directions_car_rounded),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
