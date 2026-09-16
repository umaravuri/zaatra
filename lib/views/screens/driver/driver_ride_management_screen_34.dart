import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/driver_service.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_button.dart';
import 'driver_in_trip_navigation_screen_33.dart';
import 'driver_my_ride_screen_30.dart';
import 'driver_ride_start_details_screen_88.dart';
import 'driver_trip_shared_screen_94.dart';

class DriverRideManagementScreen extends StatefulWidget {
  final int initialTabIndex;

  const DriverRideManagementScreen({super.key, this.initialTabIndex = 0});

  @override
  State<DriverRideManagementScreen> createState() => _DriverRideManagementScreenState();
}

class _DriverRideManagementScreenState extends State<DriverRideManagementScreen> {
  late int _selectedTab;

  final List<String> _tabs = ['Active', 'Upcoming', 'Completed', 'Cancelled'];

  List<Map<String, dynamic>> _activeRides = [];
  List<Map<String, dynamic>> _upcomingRides = [];
  List<Map<String, dynamic>> _completedRides = [];
  List<Map<String, dynamic>> _cancelledRides = [];
  String _registeredVehicle = '';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPhone = prefs.getString('currentPhone') ?? '';
      final cleanDigits = currentPhone.replaceAll(RegExp(r'[^0-9]'), '');
      _registeredVehicle = prefs.getString('driver_vehicle_$cleanDigits') ?? 
                           prefs.getString('driver_vehicle_name_$cleanDigits') ?? '';

      if (_registeredVehicle.isEmpty && currentPhone.isNotEmpty) {
        try {
          final vehRes = await DriverService.getVehicleInfo(phone: currentPhone);
          if (vehRes['success'] == true) {
            final v = vehRes['vehicleInformation'] ?? vehRes['data'] ?? vehRes;
            if (v is Map && v['vehicleName'] != null) {
              _registeredVehicle = v['vehicleName'].toString();
            }
          }
        } catch (_) {}
      }

      final List<Map<String, dynamic>> allFetchedRides = [];

      // 1. Fetch from Unified Rides API (GET /api/rides)
      try {
        final ridesRes = await RideService.getRides();
        if (ridesRes['success'] == true && ridesRes['rides'] is List) {
          allFetchedRides.addAll(List<Map<String, dynamic>>.from(ridesRes['rides']));
        }
      } catch (_) {}

      // 2. Fallback check for driver upcoming rides
      if (allFetchedRides.isEmpty) {
        try {
          final upcomingRes = await DriverService.getUpcomingRides();
          if (upcomingRes['success'] == true && upcomingRes['upcomingRides'] is List) {
            allFetchedRides.addAll(List<Map<String, dynamic>>.from(upcomingRes['upcomingRides']));
          }
        } catch (_) {}
      }

      final active = <Map<String, dynamic>>[];
      final upcoming = <Map<String, dynamic>>[];
      final completed = <Map<String, dynamic>>[];
      final cancelled = <Map<String, dynamic>>[];

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      for (final ride in allFetchedRides) {
        final status = (ride['status']?.toString().toLowerCase()) ?? 'scheduled';
        final rideDateTime = _parseRideDateTime(ride);

        if (status == 'cancelled' || status == 'rejected') {
          cancelled.add(ride);
        } else if (status == 'completed' || status == 'finished') {
          completed.add(ride);
        } else if (status == 'active' || status == 'in-progress' || status == 'in_progress' || status == 'ongoing' || status == 'boarding') {
          if (rideDateTime != null && rideDateTime.isBefore(todayStart)) {
            completed.add(ride);
          } else {
            active.add(ride);
          }
        } else {
          // Scheduled / Pending
          if (rideDateTime != null && rideDateTime.isBefore(todayStart)) {
            // 🚫 Backdated ride! Date has passed -> Completed
            completed.add(ride);
          } else if (rideDateTime != null && !rideDateTime.isAfter(todayEnd)) {
            // Today -> Active
            active.add(ride);
          } else {
            // Future -> Upcoming
            upcoming.add(ride);
          }
        }
      }

      if (mounted) {
        setState(() {
          _activeRides = active;
          _upcomingRides = upcoming;
          _completedRides = completed;
          _cancelledRides = cancelled;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getCurrentTabRides() {
    switch (_selectedTab) {
      case 0:
        return _activeRides;
      case 1:
        return _upcomingRides;
      case 2:
        return _completedRides;
      case 3:
        return _cancelledRides;
      default:
        return _activeRides;
    }
  }

  DateTime? _parseRideDateTime(Map<String, dynamic> ride) {
    final val = ride['departs'] ?? ride['departureDate'] ?? ride['date'] ?? ride['scheduledDate'] ?? ride['createdAt'];
    if (val == null) return null;
    if (val is DateTime) return val.toLocal();

    final str = val.toString().trim();
    if (str.isEmpty) return null;

    final isoParsed = DateTime.tryParse(str);
    if (isoParsed != null) return isoParsed.toLocal();

    final numbers = RegExp(r'(\d+)').allMatches(str).map((m) => int.tryParse(m.group(0)!)).whereType<int>().toList();
    if (numbers.length >= 3) {
      if (numbers[0] > 1000) {
        return DateTime(numbers[0], numbers[1], numbers[2]);
      }
      if (numbers[2] > 1000) {
        return DateTime(numbers[2], numbers[1], numbers[0]);
      }
    }
    return null;
  }

  String _formatRideDate(Map<String, dynamic> ride) {
    final dt = _parseRideDateTime(ride);
    if (dt != null) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final dayName = days[dt.weekday - 1];
      final monthName = months[dt.month - 1];
      return '${dt.day.toString().padLeft(2, '0')} $monthName, ${dt.year} ( $dayName )';
    }

    final raw = ride['departureDate'] ?? ride['date'] ?? ride['departs'];
    if (raw != null && raw.toString().isNotEmpty) {
      return raw.toString();
    }

    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]}, ${now.year} ( ${days[now.weekday - 1]} )';
  }

  String get _appBarTitle {
    switch (_selectedTab) {
      case 1:
        return 'Upcoming';
      case 2:
        return 'Completed';
      case 3:
        return 'Cancelled';
      case 0:
      default:
        return 'My Rides';
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28),
            tooltip: 'Post Ride',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DriverMyRideScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        tooltip: 'Post Ride',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DriverMyRideScreen()),
          );
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
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

                // Horizontal Tab Selector Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: List.generate(_tabs.length, (index) {
                      final isSelected = _selectedTab == index;
                      final count = index == 0
                          ? _activeRides.length
                          : index == 1
                              ? _upcomingRides.length
                              : index == 2
                                  ? _completedRides.length
                                  : _cancelledRides.length;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : const Color(0xFFF3EDF7),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _tabs[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                if (count > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white.withAlpha(50) : AppColors.primary.withAlpha(30),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 16),

                // Main Content Area based on Selected Tab (Renders Dynamic Cards)
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : Builder(
                          builder: (context) {
                            final currentRides = _getCurrentTabRides();
                            return RefreshIndicator(
                              color: AppColors.primary,
                              onRefresh: _fetchRides,
                              child: currentRides.isEmpty
                                  ? _buildEmptyState()
                                  : ListView.separated(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      itemCount: currentRides.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                                      itemBuilder: (context, index) {
                                        return _buildDynamicRideCard(currentRides[index]);
                                      },
                                    ),
                            );
                          },
                        ),
                ),

                // Bottom CTA Button "Next"
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    text: 'Next',
                    onPressed: () {
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

  Widget _buildDynamicRideCard(Map<String, dynamic> ride) {
    final from = ride['from'] ?? ride['pickupLocation'] ?? 'Mangalagiri Road, Vijayawada';
    final to = ride['to'] ?? ride['destinationLocation'] ?? 'Tirupati';
    final departureTime = ride['departureTime'] ?? '06:00 AM';
    final arrivalTime = ride['arrivalTime'] ?? '10:30 AM';
    final dateStr = _formatRideDate(ride);
    final bookedSeats = ride['booked'] ?? ride['seatsBooked'] ?? 0;
    final totalSeats = ride['seats'] ?? ride['totalSeats'] ?? 4;
    final price = ride['price'] ?? ride['pricePerSeat'] ?? 850;
    final vehicle = (ride['vehicle'] ?? '${ride['vehicleMake'] ?? ''} ${ride['vehicleModel'] ?? ''}').toString().trim();
    final effectiveVehicle = vehicle.isNotEmpty 
        ? vehicle 
        : (_registeredVehicle.isNotEmpty ? _registeredVehicle : '-');

    Color statusBgColor = const Color(0xFFE8F5E9);
    Color statusTextColor = const Color(0xFF4CAF50);
    String statusLabel = 'Active';

    if (_selectedTab == 1) {
      statusBgColor = const Color(0xFFEDE7F6);
      statusTextColor = AppColors.primary;
      statusLabel = 'Scheduled';
    } else if (_selectedTab == 2) {
      statusBgColor = const Color(0xFFF5F5F5);
      statusTextColor = Colors.grey.shade700;
      statusLabel = 'Completed';
    } else if (_selectedTab == 3) {
      statusBgColor = const Color(0xFFFFEBEE);
      statusTextColor = Colors.red;
      statusLabel = 'Cancelled';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F8FD),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dateStr,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusTextColor),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            from.split(',').first,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(departureTime, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Text(
                            ride['duration']?.toString().split(' ').take(2).join(' ') ?? '4h 30m',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          const SizedBox(height: 2),
                          const Text('• • • • • •', style: TextStyle(color: AppColors.border, letterSpacing: 2)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            to.split(',').first,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(arrivalTime, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Vehicle, Seat Count & Price Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F5FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_car_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(effectiveVehicle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.event_seat_rounded, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('$bookedSeats / $totalSeats Seats', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      Text('₹$price/seat', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DriverTripSharedScreen()),
                          );
                        },
                        child: const Text(
                          'View & Share trip card',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DriverRideStartDetailsScreen()),
                          );
                        },
                        child: const Text(
                          'View & Start Ride',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Bottom "+ Publish new ride" Bar inside card
          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DriverMyRideScreen()),
              );
              _fetchRides();
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

  Widget _buildEmptyState() {
    final tabName = _tabs[_selectedTab];
    String title = 'No $tabName Rides';
    String message = 'You do not have any $tabName rides at the moment.';

    if (_selectedTab == 0) {
      title = 'No Active Rides';
      message = 'You do not have any active rides in progress.';
    } else if (_selectedTab == 1) {
      title = 'No Upcoming Rides';
      message = 'You have no scheduled upcoming rides at the moment.';
    } else if (_selectedTab == 2) {
      title = 'No completed rides yet';
      message = 'You have not completed any rides yet.';
    } else if (_selectedTab == 3) {
      title = 'No Cancelled Rides';
      message = 'You do not have any cancelled rides.';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primaryBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_car_outlined, size: 54, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DriverMyRideScreen()),
                );
                _fetchRides();
              },
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Publish New Ride', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
