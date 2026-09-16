import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'driver_my_ride_screen_30.dart';
import 'driver_trip_preparation_screen_37.dart';

import '../../../services/api_service.dart';

class DriverBookingRequestsScreen extends StatefulWidget {
  final int initialFilterIndex;

  const DriverBookingRequestsScreen({super.key, this.initialFilterIndex = 0});

  @override
  State<DriverBookingRequestsScreen> createState() => _DriverBookingRequestsScreenState();
}

class _DriverBookingRequestsScreenState extends State<DriverBookingRequestsScreen> {
  late int _selectedFilterIndex;
  bool _isLoading = true;

  List<Map<String, dynamic>> _newRequests = [];
  List<Map<String, dynamic>> _conformedRides = [];
  List<Map<String, dynamic>> _allBookings = [];

  List<String> get _filters => ['New (${_newRequests.length})', 'Conformed', 'All'];

  @override
  void initState() {
    super.initState();
    _selectedFilterIndex = widget.initialFilterIndex;
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/bookings');
      final newReqs = <Map<String, dynamic>>[];
      final conformedReqs = <Map<String, dynamic>>[];
      final allReqs = <Map<String, dynamic>>[];

      if (res['success'] == true && res['bookings'] is List) {
        final bookings = List<Map<String, dynamic>>.from(res['bookings']);
        for (final b in bookings) {
          if (b['kind'] == 'stay') continue;
          allReqs.add(b);
          final status = (b['status']?.toString().toLowerCase()) ?? 'pending';
          if (status == 'pending' || status == 'requested' || status == 'new') {
            newReqs.add(b);
          } else if (status == 'confirmed' || status == 'conformed' || status == 'accepted') {
            conformedReqs.add(b);
          }
        }
      }

      if (mounted) {
        setState(() {
          _newRequests = newReqs;
          _conformedRides = conformedReqs;
          _allBookings = allReqs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _appBarTitle {
    if (_selectedFilterIndex == 1 || _selectedFilterIndex == 2) {
      return 'Conform Ride';
    }
    return 'Booking Request';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _appBarTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
            const SizedBox(height: 12),

            // Horizontal Filter Bar matching Images 1, 2
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : const Color(0xFFF3EDF7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            // Main Content Area based on Selected Filter (New, Conformed, All)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _fetchBookings,
                      child: ((_selectedFilterIndex == 0 && _newRequests.isEmpty) ||
                              (_selectedFilterIndex == 1 && _conformedRides.isEmpty) ||
                              (_selectedFilterIndex == 2 && _allBookings.isEmpty))
                          ? _buildEmptyState()
                          : ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              children: [
                                if (_selectedFilterIndex == 0) ...[
                                  ..._newRequests.map((request) => Padding(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: _buildNewRequestCard(request),
                                      )),
                                ] else if (_selectedFilterIndex == 1) ...[
                                  ..._conformedRides.map((ride) => Padding(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: _buildConformedRideCard(ride),
                                      )),
                                ] else ...[
                                  ..._conformedRides.map((ride) => Padding(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: _buildConformedRideCard(ride),
                                      )),
                                  ..._newRequests.map((request) => Padding(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: _buildNewRequestCard(request),
                                      )),
                                ],
                              ],
                            ),
                    ),
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 54, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'No Booking Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8),
            Text(
              'You do not have any booking requests at the moment.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Conformed Ride Card matching Image 1 & 2
  Widget _buildConformedRideCard(Map<String, dynamic> ride) {
    final name = ride['customerName'] ?? ride['passengerName'] ?? ride['name'] ?? 'Passenger';
    final pickup = ride['pickup'] ?? ride['from'] ?? ride['pickupLocation'] ?? '-';
    final destination = ride['destination'] ?? ride['to'] ?? ride['destinationLocation'] ?? '-';
    final depTime = ride['depTime'] ?? ride['departureTime'] ?? '-';
    final duration = ride['duration'] ?? '4h';
    final arrTime = ride['arrTime'] ?? ride['arrivalTime'] ?? '-';
    final passengerName = ride['passengerName'] ?? ride['customerName'] ?? name;
    final seatsFare = ride['seatsFare'] ?? '${ride['seats'] ?? 1} Seat · ₹ ${ride['price'] ?? ride['amount'] ?? '-'}';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(35)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + Name Row
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, color: Color(0xFFE65100), size: 32),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              pickup.toString(),
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
                            ),
                            Text(
                              destination.toString(),
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Time & Duration Row: 09 : 00 AM  4h  14 : 00 PM
                Row(
                  children: [
                    Text(depTime.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(width: 12),
                    Text(duration.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(width: 12),
                    Text(arrTime.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),

                const SizedBox(height: 12),

                // Passenger Name Pill & Call Icon Button Row matching Image 1
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EDF7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        passengerName.toString(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling passenger $passengerName...')),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3EDF7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone_rounded, size: 18, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Fare & Conformed Status Badge Row matching Image 1
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      seatsFare.toString(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Conformed',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Bottom Bar Action "View & Shar Trip card" matching Image 1 & 2
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DriverTripPreparationScreen()),
              );
            },
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFF3EDF7),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: const Text(
                'View & Shar Trip card',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // New Request Card matching Image 2
  Widget _buildNewRequestCard(Map<String, dynamic> request) {
    final name = request['customerName'] ?? request['passengerName'] ?? request['name'] ?? 'Passenger';
    final pickup = request['pickup'] ?? request['from'] ?? request['pickupLocation'] ?? '-';
    final destination = request['destination'] ?? request['to'] ?? request['destinationLocation'] ?? '-';
    final datetime = request['datetime'] ?? request['dateTime'] ?? request['date'] ?? request['createdAt'] ?? '-';
    final seatsFare = request['seatsFare'] ?? '${request['seats'] ?? 1} Seat · ₹ ${request['price'] ?? request['amount'] ?? '-'}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(35)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, color: Color(0xFFE65100), size: 32),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                pickup.toString(),
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
                              ),
                              Text(
                                destination.toString(),
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  datetime.toString(),
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 4),

                Text(
                  seatsFare.toString(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DriverTripPreparationScreen()),
                          );
                        },
                        child: const Text(
                          'View',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          final bookingId = request['bookingId'] ?? request['_id'] ?? request['id'];
                          if (bookingId != null) {
                            try {
                              await ApiService.patch('/bookings/$bookingId/status', {'status': 'cancelled'});
                            } catch (_) {}
                          }
                          setState(() {
                            _newRequests.remove(request);
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Booking Request Declined.')),
                            );
                          }
                        },
                        child: const Text(
                          'Decline',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          final bookingId = request['bookingId'] ?? request['_id'] ?? request['id'];
                          if (bookingId != null) {
                            try {
                              await ApiService.patch('/bookings/$bookingId/status', {'status': 'confirmed'});
                            } catch (_) {}
                          }
                          setState(() {
                            _newRequests.remove(request);
                            _conformedRides.add({
                              ...request,
                              'status': 'Conformed',
                            });
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Accepted booking request from $name!')),
                            );
                          }
                        },
                        child: const Text(
                          'Accept',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DriverMyRideScreen()),
              );
            },
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Publish new ride',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
