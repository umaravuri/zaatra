import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/route_map_webview.dart';
import 'driver_passenger_pin_verification_screen_89.dart';
import 'driver_trip_shared_screen_94.dart';
import 'trip_completed_summary_screen_35.dart';

class DriverRideStartDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? rideData;
  final String? rideId;
  final String? origin;
  final String? destination;
  final String? departureTime;
  final String? totalDistance;
  final List<Map<String, dynamic>>? initialPassengers;
  final List<Map<String, dynamic>>? initialStops;

  const DriverRideStartDetailsScreen({
    super.key,
    this.rideData,
    this.rideId,
    this.origin,
    this.destination,
    this.departureTime,
    this.totalDistance,
    this.initialPassengers,
    this.initialStops,
  });

  @override
  State<DriverRideStartDetailsScreen> createState() => _DriverRideStartDetailsScreenState();
}

class _DriverRideStartDetailsScreenState extends State<DriverRideStartDetailsScreen> {
  late String _rideId;
  late String _origin;
  late String _destination;
  late String _totalDistance;
  late List<Map<String, dynamic>> _passengers;
  late List<Map<String, dynamic>> _stops;
  final TextEditingController _broadcastMsgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final data = widget.rideData ?? {};

    _rideId = widget.rideId ?? (data['_id'] ?? data['rideId'] ?? data['id'] ?? 'RD-101').toString();
    _origin = widget.origin ?? data['from'] ?? data['pickupLocation'] ?? 'Origin';
    _destination = widget.destination ?? data['to'] ?? data['destinationLocation'] ?? 'Destination';
    _totalDistance = widget.totalDistance ?? data['distance'] ?? '';

    // Initialize stops dynamically from rideData without hardcoded fallbacks
    if (widget.initialStops != null && widget.initialStops!.isNotEmpty) {
      _stops = List<Map<String, dynamic>>.from(widget.initialStops!);
    } else if (data['routePlan'] is List && (data['routePlan'] as List).isNotEmpty) {
      _stops = (data['routePlan'] as List).map<Map<String, dynamic>>((item) {
        final loc = (item['location'] ?? item['station'] ?? '').toString();
        return {
          'time': item['time'] ?? '06:00 AM',
          'station': loc.split(',').first,
          'isStart': item['type'] == 'start' || item['isStart'] == true,
          'type': item['type'] ?? 'pickup',
          'status': item['status'] ?? 'upcoming',
        };
      }).toList();
    } else if (data['selectedCities'] is List && (data['selectedCities'] as List).isNotEmpty) {
      final list = <Map<String, dynamic>>[];
      list.add({'time': data['departureTime'] ?? '06:00 AM', 'station': _origin.split(',').first, 'isStart': true});
      for (final city in data['selectedCities']) {
        list.add({'time': '--:--', 'station': city.toString().split(',').first, 'isStart': false});
      }
      list.add({'time': data['arrivalTime'] ?? '10:30 AM', 'station': _destination.split(',').first, 'isStart': false});
      _stops = list;
    } else {
      _stops = [
        {'time': data['departureTime'] ?? '06:00 AM', 'station': _origin.split(',').first, 'isStart': true},
        {'time': data['arrivalTime'] ?? '10:30 AM', 'station': _destination.split(',').first, 'isStart': false},
      ];
    }

    // Initialize passengers purely from dynamic data
    if (widget.initialPassengers != null && widget.initialPassengers!.isNotEmpty) {
      _passengers = List<Map<String, dynamic>>.from(widget.initialPassengers!);
    } else if (data['passengers'] is List && (data['passengers'] as List).isNotEmpty) {
      _passengers = List<Map<String, dynamic>>.from(data['passengers']);
    } else {
      _passengers = [];
    }

    _loadRideData();
  }

  Future<void> _loadRideData() async {
    try {
      final List<Map<String, dynamic>> loadedPassengers = [];

      final res = await RideService.getRideStartDetails(rideId: _rideId);
      if (res['success'] == true && mounted) {
        if (res['rideId'] != null) _rideId = res['rideId'].toString();
        if (res['distance'] != null && _totalDistance.isEmpty) _totalDistance = res['distance'].toString();

        // Map API timeline if present
        if (res['timeline'] is List && (res['timeline'] as List).isNotEmpty) {
          _stops = (res['timeline'] as List).map<Map<String, dynamic>>((item) {
            return {
              'time': item['time'] ?? '09:00',
              'station': item['location'] ?? item['station'] ?? '',
              'isStart': item['isStart'] == true || item['type'] == 'start',
              'type': item['type'],
              'status': item['status'],
            };
          }).toList();
        }

        // Map API passengers if present from backend
        final passInfo = res['passengerInfo'];
        if (passInfo != null && passInfo['passengers'] is List && (passInfo['passengers'] as List).isNotEmpty) {
          for (final p in passInfo['passengers'] as List) {
            int sNum = 1;
            if (p['seatNumber'] != null) {
              final sStr = p['seatNumber'].toString().replaceAll(RegExp(r'[^0-9]'), '');
              sNum = int.tryParse(sStr) ?? 1;
            }
            loadedPassengers.add({
              'id': p['passengerId'] ?? 'p${p['passengerIndex'] ?? (loadedPassengers.length + 1)}',
              'bookingId': p['bookingId'] ?? 'BK-${loadedPassengers.length + 1}',
              'name': p['name'] ?? 'Passenger',
              'title': 'Passenger ${p['passengerIndex'] ?? (loadedPassengers.length + 1)}',
              'route': p['segment'] ?? p['route'] ?? 'Route',
              'time': p['timeWindow'] ?? '10:00 AM',
              'pickup': p['from'] ?? _origin,
              'dropoff': p['to'] ?? _destination,
              'seatNumber': sNum,
              'expectedPin': p['boardingPin'] ?? '849201',
              'isBoarded': p['isBoarded'] == true,
            });
          }
        }
      }

      // 🚀 Also query live backend bookings for this ride (GET /api/bookings)
      try {
        final bookingsRes = await ApiService.get('/bookings');
        if (bookingsRes['success'] == true && bookingsRes['bookings'] is List) {
          final allBookings = List<Map<String, dynamic>>.from(bookingsRes['bookings']);
          final matchingBookings = allBookings.where((b) {
            final bRideId = (b['rideId'] ?? b['ride']?['_id'] ?? b['ride']?['id'] ?? b['ride'] ?? '').toString();
            return bRideId.isNotEmpty && (bRideId == _rideId);
          }).toList();

          for (int i = 0; i < matchingBookings.length; i++) {
            final b = matchingBookings[i];
            final bId = (b['bookingId'] ?? b['_id'] ?? 'BK-${i + 1}').toString();
            final alreadyExists = loadedPassengers.any((p) => p['bookingId'] == bId);
            if (!alreadyExists) {
              final status = (b['status']?.toString().toLowerCase()) ?? 'confirmed';
              loadedPassengers.add({
                'id': bId,
                'bookingId': bId,
                'name': b['userName'] ?? b['passengerName'] ?? b['customerName'] ?? 'Passenger ${i + 1}',
                'title': 'Passenger ${loadedPassengers.length + 1}',
                'route': '${(b['pickupLocation'] ?? b['from'] ?? _origin).toString().split(',').first} - ${(b['destinationLocation'] ?? b['to'] ?? _destination).toString().split(',').first}',
                'time': b['departureTime'] ?? '06:00 AM',
                'pickup': b['pickupLocation'] ?? b['from'] ?? _origin,
                'dropoff': b['destinationLocation'] ?? b['to'] ?? _destination,
                'seatNumber': b['seatsBooked'] ?? b['seats'] ?? (i + 1),
                'expectedPin': b['pin'] ?? b['boardingPin'] ?? '849201',
                'isBoarded': status == 'boarded' || status == 'completed',
              });
            }
          }
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _passengers = loadedPassengers;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _broadcastMsgController.dispose();
    super.dispose();
  }

  Future<void> _verifyPassengerPin(int index) async {
    final passenger = _passengers[index];

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DriverPassengerPinVerificationScreen(
          passengerName: passenger['name'] ?? 'Passenger',
          pickupLocation: passenger['pickup'] ?? _origin,
          dropoffLocation: passenger['dropoff'] ?? _destination,
          expectedPin: passenger['expectedPin'] ?? '849201',
          boardingSeat: passenger['seatNumber'] ?? (index + 1),
          totalSeats: 4,
          bookedSeats: const [1, 2, 3],
          rideId: _rideId,
          bookingId: passenger['bookingId'],
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _passengers[index]['isBoarded'] = true;
      });
    }
  }

  Future<void> _sendBroadcastMessage() async {
    final text = _broadcastMsgController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please type a message before sending.')),
      );
      return;
    }

    _broadcastMsgController.clear();
    FocusScope.of(context).unfocus();

    final res = await RideService.sendBroadcastMessage(
      rideId: _rideId,
      message: text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Message sent to all passengers.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _startGoogleMapsNavigation() async {
    // 1. Call start-navigation API
    final apiRes = await RideService.startNavigation(
      rideId: _rideId,
      origin: _origin,
      destination: _destination,
    );

    final navData = apiRes['navigation'] ?? {};
    final navIntentUrl = navData['googleMapsNavigationUrl'] ?? 'google.navigation:q=${Uri.encodeComponent(_destination)}&mode=d';
    final webUrl = navData['googleMapsWebUrl'] ?? 'https://www.google.com/maps/dir/?api=1&origin=${Uri.encodeComponent(_origin)}&destination=${Uri.encodeComponent(_destination)}&travelmode=driving';

    // 2. Launch Google Maps navigation
    try {
      final nativeUri = Uri.parse(navIntentUrl);
      final webUri = Uri.parse(webUrl);

      bool launched = false;
      try {
        launched = await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      } catch (_) {}

      if (!launched) {
        launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }

      if (!launched) {
        await launchUrl(webUri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening Google Maps navigation to $_destination...'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  String _formatRideDateDisplay({bool includeDistance = true}) {
    final data = widget.rideData ?? {};
    DateTime? rideDate;

    if (data['departs'] != null) {
      rideDate = DateTime.tryParse(data['departs'].toString());
    }
    if (rideDate == null && data['departureDate'] != null) {
      final parts = data['departureDate'].toString().split(RegExp(r'[\s\-/]+'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (d != null && m != null && y != null) {
          rideDate = DateTime(y, m, d);
        }
      }
    }
    if (rideDate == null && data['date'] != null) {
      rideDate = DateTime.tryParse(data['date'].toString());
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = rideDate != null ? DateTime(rideDate.year, rideDate.month, rideDate.day) : today;

    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final weekdayName = weekdays[targetDate.weekday - 1];
    final monthName = months[targetDate.month - 1];
    final dayNum = targetDate.day;

    String dateLabel;
    if (targetDate.isAtSameMomentAs(today)) {
      dateLabel = '$weekdayName $dayNum $monthName (today)';
    } else if (targetDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      dateLabel = '$weekdayName $dayNum $monthName (tomorrow)';
    } else {
      dateLabel = '$weekdayName $dayNum $monthName';
    }

    if (includeDistance && _totalDistance.isNotEmpty) {
      return '$dateLabel - $_totalDistance';
    }
    return dateLabel;
  }

  Future<void> _completeRide() async {
    final res = await RideService.completeRide(rideId: _rideId);
    if (!mounted) return;

    final summary = res['summary'] ?? {};
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripCompletedSummaryScreen(
          rideId: _rideId,
          origin: _origin.split(',').first,
          destination: _destination.split(',').first,
          dateDisplay: _formatRideDateDisplay(includeDistance: false),
          fuelSaved: summary['formattedFuelShare'] ?? '₹ 1,074',
          paymentMode: 'Online',
          coTravelers: '${summary['totalPassengersBoarded'] ?? _passengers.length}',
          summaryData: summary,
        ),
      ),
    );
  }

  void _openShareTrip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverTripSharedScreen(
          rideId: _rideId,
          routeTimeline: _stops,
          seatsAvailable: const [
            {'label': 'S-1 Booked', 'isBooked': true},
            {'label': 'S-2 Booked', 'isBooked': true},
            {'label': 'S-3 Booked', 'isBooked': true},
            {'label': 'Available', 'isBooked': false},
          ],
          fuelContribution: '₹358',
          driverName: 'Rahul Siplivarma.k',
          driverCode: '#1245',
          bookingSeatZaatraId: '20124568',
          nextPickup: {
            'location': _stops.length > 1 ? _stops[1]['station'] : 'Ameerpet',
          },
        ),
      ),
    );
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
        title: const Text(
          'Ride start',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.textPrimary, size: 22),
            tooltip: 'Share Trip',
            onPressed: _openShareTrip,
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
                  // Date Header Pill matching 88.png
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDF7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        _formatRideDateDisplay(includeDistance: true),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Waypoint Timeline matching 88.png
                  ...List.generate(_stops.length, (i) {
                    final stop = _stops[i];
                    final isStart = stop['isStart'] == true || stop['type'] == 'start' || i == 0;
                    final isLast = i == _stops.length - 1;

                    return _buildWaypointTile(
                      time: stop['time'] ?? '09:00',
                      station: stop['station'] ?? stop['location'] ?? '',
                      isStart: isStart,
                      isLast: isLast,
                    );
                  }),

                  const SizedBox(height: 24),

                  // Passenger Info Section matching 88.png
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Passenger info',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        _passengers.isEmpty
                            ? '0 Boarded'
                            : '${_passengers.where((p) => p['isBoarded'] == true).length}/${_passengers.length} Boarded',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_passengers.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F5FE),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.people_outline_rounded, color: AppColors.textMuted, size: 36),
                          SizedBox(height: 8),
                          Text(
                            'No passengers yet',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Booked passenger details will appear here once passengers join your ride.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F5FE),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: List.generate(_passengers.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: index < _passengers.length - 1 ? 14.0 : 0),
                            child: _buildPassengerCard(index),
                          );
                        }),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Message Input Box matching 88.png
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FE),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _broadcastMsgController,
                          decoration: const InputDecoration(
                            hintText: 'Type here .......!',
                            hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _sendBroadcastMessage,
                            child: const Text(
                              'Send Message all',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Live Route Map Preview with Navigation overlay matching 88.png
                  RouteMapWebView(
                    pickup: _origin,
                    destination: _destination,
                    rideId: _rideId,
                    height: 220,
                    borderRadius: 18,
                    showNavigationOverlay: true,
                    onTap: _startGoogleMapsNavigation,
                  ),

                  const SizedBox(height: 20),

                  // Share Trip CTA Button
                  CustomButton(
                    text: 'Share Trip Card',
                    isOutlined: true,
                    backgroundColor: const Color(0xFFF3EDF7),
                    textColor: AppColors.primary,
                    onPressed: _openShareTrip,
                  ),

                  const SizedBox(height: 12),

                  // Start Google Maps Navigation CTA Button
                  CustomButton(
                    text: 'Start Navigation',
                    backgroundColor: AppColors.primary,
                    onPressed: _startGoogleMapsNavigation,
                  ),

                  const SizedBox(height: 12),

                  // Complete Ride Button
                  CustomButton(
                    text: 'Complete Ride',
                    isOutlined: true,
                    backgroundColor: Colors.white,
                    textColor: AppColors.primary,
                    onPressed: _completeRide,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaypointTile({
    required String time,
    required String station,
    required bool isStart,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Natural width time (works on all screen resolutions)
          Center(
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 2. Timeline marker & auto-stretching connecting line
          Column(
            children: [
              isStart
                  ? const Icon(Icons.directions_car_rounded, color: Colors.redAccent, size: 18)
                  : Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.border,
                        shape: BoxShape.circle,
                      ),
                    ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // 3. Station text claiming 100% of remaining width on any screen resolution
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
              child: Text(
                station,
                style: const TextStyle(
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

  Widget _buildPassengerCard(int index) {
    final passenger = _passengers[index];
    final isBoarded = passenger['isBoarded'] == true;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isBoarded ? Border.all(color: const Color(0xFF81C784), width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                passenger['title'] ?? 'Passenger ${index + 1}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              if (isBoarded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF2E7D32)),
                      SizedBox(width: 4),
                      Text(
                        'Boarded',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isBoarded ? const Color(0xFFE8F5E9) : const Color(0xFFF3EDF7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: isBoarded ? const Color(0xFF2E7D32) : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passenger['name'] ?? '',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      passenger['route'] ?? '',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    Text(
                      passenger['time'] ?? '',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSmallButton(
                  'Message',
                  Icons.chat_bubble_outline_rounded,
                  const Color(0xFFFFF8E1),
                  const Color(0xFF8D6E63),
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening chat with ${passenger['name']}...')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildSmallButton(
                  'Call',
                  Icons.phone_outlined,
                  const Color(0xFFFFF8E1),
                  const Color(0xFF8D6E63),
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${passenger['name']}...')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: isBoarded
                    ? _buildSmallButton(
                        'Verified ✓',
                        Icons.check_circle_rounded,
                        const Color(0xFFE8F5E9),
                        const Color(0xFF2E7D32),
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${passenger['name']} is already verified and boarded.')),
                          );
                        },
                      )
                    : _buildSmallButton(
                        'Verify PIN',
                        Icons.lock_outline_rounded,
                        const Color(0xFFFFF8E1),
                        const Color(0xFF8D6E63),
                        () => _verifyPassengerPin(index),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(
    String label,
    IconData icon,
    Color bg,
    Color textColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
