import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/api_service.dart';
import 'driver_my_ride_screen_30.dart';
import 'driver_trip_prep_notes_screen_100.dart';

class DriverBookingRequestsScreen extends StatefulWidget {
  const DriverBookingRequestsScreen({super.key});

  @override
  State<DriverBookingRequestsScreen> createState() => _DriverBookingRequestsScreenState();
}

class _DriverBookingRequestsScreenState extends State<DriverBookingRequestsScreen> {
  int _selectedTabIndex = 0; // 0: New, 1: Conformed, 2: All
  bool _isLoading = true;

  List<Map<String, dynamic>> _newRequests = [];
  List<Map<String, dynamic>> _conformedRequests = [];
  List<Map<String, dynamic>> _allRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchBookingRequests();
  }

  Future<void> _fetchBookingRequests() async {
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
          _conformedRequests = conformedReqs;
          _allRequests = allReqs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _acceptBooking(Map<String, dynamic> req) async {
    final bookingId = req['bookingId'] ?? req['_id'] ?? req['id'];
    if (bookingId == null) return;

    try {
      await ApiService.patch('/bookings/$bookingId/status', {'status': 'confirmed'});
    } catch (_) {
      try {
        await ApiService.put('/bookings/$bookingId', {'status': 'confirmed'});
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking request accepted successfully!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      _fetchBookingRequests();
    }
  }

  Future<void> _declineBooking(Map<String, dynamic> req) async {
    final bookingId = req['bookingId'] ?? req['_id'] ?? req['id'];
    if (bookingId == null) return;

    try {
      await ApiService.patch('/bookings/$bookingId/status', {'status': 'cancelled'});
    } catch (_) {
      try {
        await ApiService.put('/bookings/$bookingId', {'status': 'cancelled'});
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking request declined.'),
          backgroundColor: Colors.grey,
        ),
      );
      _fetchBookingRequests();
    }
  }

  List<Map<String, dynamic>> _getCurrentRequests() {
    if (_selectedTabIndex == 0) return _newRequests;
    if (_selectedTabIndex == 1) return _conformedRequests;
    return _allRequests;
  }

  @override
  Widget build(BuildContext context) {
    final currentRequests = _getCurrentRequests();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking Request',
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
                // Segmented Tabs Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(child: _buildTabButton('New (${_newRequests.length})', 0)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTabButton('Conformed', 1)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTabButton('All', 2)),
                    ],
                  ),
                ),

                // Main Booking Requests List or Empty State
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _fetchBookingRequests,
                          child: currentRequests.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                                  itemCount: currentRequests.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    return _buildBookingCard(currentRequests[index]);
                                  },
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
    String tabLabel = _selectedTabIndex == 0 ? 'new' : _selectedTabIndex == 1 ? 'conformed' : '';
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF3EDF7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_rounded, size: 54, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Booking Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              tabLabel.isNotEmpty
                  ? 'You do not have any $tabLabel booking requests at the moment.'
                  : 'You do not have any booking requests at the moment.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> req) {
    final name = req['customerName'] ?? req['passengerName'] ?? req['name'] ?? req['userId'] ?? 'Passenger';
    final from = req['from'] ?? req['pickup'] ?? req['pickupLocation'] ?? req['origin'] ?? '-';
    final to = req['to'] ?? req['destination'] ?? req['destinationLocation'] ?? '-';
    final dateTime = req['dateTime'] ?? req['date'] ?? req['departs'] ?? req['createdAt'] ?? '-';
    final seats = req['seats'] ?? req['seatsBooked'] ?? req['seatsCount'] ?? 1;
    final price = req['price'] ?? req['amount'] ?? req['totalAmount'] ?? req['fare'] ?? '-';
    final status = (req['status']?.toString().toLowerCase()) ?? 'pending';
    final isNew = status == 'pending' || status == 'requested' || status == 'new';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3EDF7),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.toString(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  from.toString(),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 14),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  to.toString(),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text(
                  dateTime.toString(),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  '$seats Seat · ₹ $price',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),

                const SizedBox(height: 16),

                // Action Buttons (View, Decline, Accept)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DriverTripPrepNotesScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('View', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                      ),
                    ),
                    if (isNew) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _declineBooking(req),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Decline', style: TextStyle(fontSize: 12, color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _acceptBooking(req),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Accept', style: TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                      ),
                    ],
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
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text('Publish new ride', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF3EDF7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
