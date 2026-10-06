import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/driver_service.dart';
import '../../widgets/custom_button.dart';
import 'driver_booking_requests_screen_99.dart';
import 'driver_edit_ride_screen_84.dart';
import 'driver_home_dashboard_screen_83.dart';
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
  late int _selectedTabIndex; // 0: Active, 1: Upcoming, 2: Completed, 3: Cancelled

  String _driverId = '';
  String _registeredVehicle = '';
  bool _isLoading = true;

  final List<String> _tabs = ['Active', 'Upcoming', 'Completed', 'Cancelled'];
  final Map<String, int> _tabCounts = {
    'active': 0,
    'upcoming': 0,
    'completed': 0,
    'cancelled': 0,
  };
  final Map<String, List<Map<String, dynamic>>> _cachedTabRides = {
    'active': [],
    'upcoming': [],
    'completed': [],
    'cancelled': [],
  };

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
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

      // Try fetching vehicle info directly from Driver Vehicle API
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

      // 1. Resolve Driver ID
      _driverId = await DriverService.resolveCurrentDriverId();

      // 2. Fetch Driver Scoped Rides API (GET /api/drivers/:driverId/rides?tab=...)
      final currentTabKey = _tabs[_selectedTabIndex].toLowerCase();
      final res = await DriverService.getDriverRides(driverId: _driverId, tab: currentTabKey);

      if (res['success'] == true) {
        // Parse tab counts from backend
        if (res['tabs'] is List) {
          for (final t in res['tabs'] as List) {
            final id = (t['id']?.toString().toLowerCase()) ?? '';
            final count = int.tryParse(t['count']?.toString() ?? '0') ?? 0;
            if (id.isNotEmpty) {
              _tabCounts[id] = count;
            }
          }
        }

        // Parse all tabs data cache if provided
        if (res['allTabsData'] is Map) {
          final all = res['allTabsData'] as Map;
          for (final entry in all.entries) {
            if (entry.value is List) {
              final list = List<Map<String, dynamic>>.from(entry.value);
              final key = entry.key.toString().toLowerCase();
              _cachedTabRides[key] = list;
              _tabCounts[key] = list.length;
            }
          }
        }

        // Set current tab rides
        if (res['rides'] is List) {
          final list = List<Map<String, dynamic>>.from(res['rides']);
          _cachedTabRides[currentTabKey] = list;
          _tabCounts[currentTabKey] = list.length;
        }
      } else {
        // Fallback to empty list for newly registered drivers or errors
        _cachedTabRides[currentTabKey] = [];
        _tabCounts[currentTabKey] = 0;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onTabSelected(int index) {
    if (_selectedTabIndex == index) return;
    setState(() {
      _selectedTabIndex = index;
    });
    _fetchRides();
  }

  List<Map<String, dynamic>> _getCurrentTabRides() {
    final currentTabKey = _tabs[_selectedTabIndex].toLowerCase();
    return _cachedTabRides[currentTabKey] ?? [];
  }

  /// Robust date parser extracting date from departs, departureDate, date, scheduledDate, or createdAt
  DateTime? _parseRideDateTime(Map<String, dynamic> ride) {
    final val = ride['departs'] ?? ride['departureDate'] ?? ride['date'] ?? ride['scheduledDate'] ?? ride['createdAt'];
    if (val == null) return null;
    if (val is DateTime) return val.toLocal();

    final str = val.toString().trim();
    if (str.isEmpty) return null;

    // 1. Try ISO8601 string parser
    final isoParsed = DateTime.tryParse(str);
    if (isoParsed != null) return isoParsed.toLocal();

    // 2. Try regex extraction for DD-MM-YYYY or YYYY-MM-DD
    final numbers = RegExp(r'(\d+)').allMatches(str).map((m) => int.tryParse(m.group(0)!)).whereType<int>().toList();
    if (numbers.length >= 3) {
      if (numbers[0] > 1000) {
        // YYYY-MM-DD
        return DateTime(numbers[0], numbers[1], numbers[2]);
      }
      if (numbers[2] > 1000) {
        // DD-MM-YYYY
        return DateTime(numbers[2], numbers[1], numbers[0]);
      }
    }
    return null;
  }

  String _formatRideDate(Map<String, dynamic> ride) {
    final dt = _parseRideDateTime(ride);
    if (dt != null) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]}, ${now.year} ( ${days[now.weekday - 1]} )';
  }

  void _confirmDeleteRide(Map<String, dynamic> ride) {
    final from = (ride['from'] ?? ride['pickupLocation'] ?? 'Pickup').toString().split(',').first;
    final to = (ride['to'] ?? ride['destinationLocation'] ?? 'Destination').toString().split(',').first;
    final dateStr = _formatRideDate(ride);
    final rideId = (ride['_id'] ?? ride['rideId'] ?? ride['id'])?.toString() ?? '';

    showDialog(
      context: context,
      builder: (ctx) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Delete Ride',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to delete this upcoming ride from $from to $to on $dateStr?',
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'This action cannot be undone and will cancel this ride from your schedule.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(ctx);
                          final res = await DriverService.deleteRide(rideId);
                          nav.pop();
                          if (!mounted) return;

                          if (res['success'] == true) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Upcoming ride deleted successfully.'),
                                backgroundColor: Color(0xFF2E7D32),
                              ),
                            );
                            _fetchRides();
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(res['message']?.toString() ?? 'Failed to delete ride.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DriverHomeDashboardScreen83()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRides = _getCurrentTabRides();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: _handleBack,
          ),
          title: const Text(
            'My Rides',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 26),
              tooltip: 'Publish New Ride',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DriverMyRideScreen()),
                );
                _fetchRides();
              },
            ),
            const SizedBox(width: 8),
          ],
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
                  // Segmented Tabs Header matching backend tabs metadata
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: List.generate(_tabs.length, (index) {
                        final tabKey = _tabs[index].toLowerCase();
                        final count = _tabCounts[tabKey] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _buildTabButton(_tabs[index], index, count),
                        );
                      }),
                    ),
                  ),

                  // Main Ride List View
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: _fetchRides,
                            child: currentRides.isEmpty
                                ? _buildEmptyState()
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                    itemCount: currentRides.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      return _buildDynamicRideCard(currentRides[index]);
                                    },
                                  ),
                          ),
                  ),

                  // Bottom Next CTA matching 98.png
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CustomButton(
                      text: 'Next',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DriverBookingRequestsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index, int count) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF3EDF7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
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
    );
  }

  Widget _buildDynamicRideCard(Map<String, dynamic> ride) {
    final rideId = (ride['rideId'] ?? ride['id'] ?? ride['_id'] ?? '').toString();
    final from = (ride['from'] ?? ride['pickupLocation'] ?? 'Origin').toString();
    final to = (ride['to'] ?? ride['destinationLocation'] ?? 'Destination').toString();
    final departureTime = (ride['departureTime'] ?? '06:00 AM').toString();
    final arrivalTime = (ride['arrivalTime'] ?? '10:30 AM').toString();
    final dateStr = (ride['dateDisplay'] ?? ride['date'] ?? _formatRideDate(ride)).toString();
    final bookedSeats = ride['booked'] ?? ride['seatsBooked'] ?? 0;
    final totalSeats = ride['seats'] ?? ride['totalSeats'] ?? 4;
    final priceFormatted = ride['priceFormatted']?.toString() ?? '₹${ride['price'] ?? 850}/seat';
    final seatsDisplay = ride['seatsDisplay']?.toString() ?? '$bookedSeats / $totalSeats Seats';
    final durationStr = (ride['duration'] ?? '4h 30m').toString();
    final distanceStr = (ride['distance'] ?? '275 KM').toString();
    
    final vehicle = (ride['vehicle'] ?? '${ride['vehicleMake'] ?? ''} ${ride['vehicleModel'] ?? ''}').toString().trim();
    final effectiveVehicle = vehicle.isNotEmpty 
        ? vehicle 
        : (_registeredVehicle.isNotEmpty ? _registeredVehicle : '-');

    final actions = ride['actions'] is Map ? (ride['actions'] as Map) : null;
    final canViewTripCard = actions?['canViewTripCard'] ?? true;
    final startRideButtonText = actions?['startRideButtonText']?.toString() ?? 'View & Start Ride';

    Color statusBgColor = const Color(0xFFE8F5E9);
    Color statusTextColor = const Color(0xFF4CAF50);
    String statusLabel = ride['statusBadge']?.toString() ?? 'Active';

    if (_selectedTabIndex == 1) {
      statusBgColor = const Color(0xFFEDE7F6);
      statusTextColor = AppColors.primary;
      statusLabel = ride['statusBadge']?.toString() ?? 'Upcoming';
    } else if (_selectedTabIndex == 2) {
      statusBgColor = const Color(0xFFF5F5F5);
      statusTextColor = Colors.grey.shade700;
      statusLabel = ride['statusBadge']?.toString() ?? 'Completed';
    } else if (_selectedTabIndex == 3) {
      statusBgColor = const Color(0xFFFFEBEE);
      statusTextColor = Colors.red;
      statusLabel = ride['statusBadge']?.toString() ?? 'Cancelled';
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
          // Header Date & Status Pill
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
                // Departure & Arrival Route Timings
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
                            durationStr.split(' ').take(2).join(' '),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F5FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Vehicle Info
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_car_rounded, size: 15, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                effectiveVehicle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Seats Info
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.event_seat_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            seatsDisplay,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Price Info
                      Text(
                        priceFormatted,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons Row
                Row(
                  children: [
                    if (canViewTripCard) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriverTripSharedScreen(
                                  rideId: rideId,
                                  tripData: ride,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'View & Share trip card',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverRideStartDetailsScreen(
                                rideData: ride,
                                rideId: rideId,
                                origin: from,
                                destination: to,
                                departureTime: departureTime,
                                totalDistance: distanceStr,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          startRideButtonText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_selectedTabIndex == 1) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriverEditRideScreen(
                                  rideData: ride,
                                  rideId: rideId,
                                ),
                              ),
                            );
                            if (res != null) {
                              _fetchRides();
                            }
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                          label: const Text(
                            'Edit Ride',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: AppColors.primary),
                            backgroundColor: const Color(0xFFF7F5FE),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmDeleteRide(ride),
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                          label: const Text(
                            'Delete Ride',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: Color(0xFFFFCDD2)),
                            backgroundColor: const Color(0xFFFFFBFA),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final tabName = _tabs[_selectedTabIndex];
    String title = 'No $tabName Rides';
    String message = 'You do not have any $tabName rides at the moment.';

    if (_selectedTabIndex == 0) {
      title = 'No Active Rides';
      message = 'You do not have any active rides in progress.';
    } else if (_selectedTabIndex == 1) {
      title = 'No Upcoming Rides';
      message = 'You have no scheduled upcoming rides at the moment.';
    } else if (_selectedTabIndex == 2) {
      title = 'No completed rides yet';
      message = 'You have not completed any rides yet.';
    } else if (_selectedTabIndex == 3) {
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

