import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/ride_service.dart';
import 'driver_live_ride_id_screen_96.dart';

class DriverLiveNextPickupScreen extends StatefulWidget {
  final String? rideId;
  final String? statusBadge;
  final List<Map<String, dynamic>>? routeTimeline;
  final List<Map<String, dynamic>>? seatsAvailable;
  final String? fuelContribution;
  final String? driverName;
  final String? driverCode;
  final String? bookingSeatZaatraId;
  final Map<String, dynamic>? nextPickup;
  final String? nextPickupLocation;
  final Map<String, dynamic>? tripData;

  const DriverLiveNextPickupScreen({
    super.key,
    this.rideId,
    this.statusBadge,
    this.routeTimeline,
    this.seatsAvailable,
    this.fuelContribution,
    this.driverName,
    this.driverCode,
    this.bookingSeatZaatraId,
    this.nextPickup,
    this.nextPickupLocation,
    this.tripData,
  });

  @override
  State<DriverLiveNextPickupScreen> createState() => _DriverLiveNextPickupScreenState();
}

class _DriverLiveNextPickupScreenState extends State<DriverLiveNextPickupScreen> {
  late String _badge;
  late String _fuel;
  late String _driver;
  late String _code;
  late String _bookingId;
  late String _pickupLoc;
  late List<Map<String, dynamic>> _timeline;
  late List<Map<String, dynamic>> _seats;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _data = widget.tripData ?? {};
    _badge = widget.statusBadge ?? _data?['statusBadge'] ?? 'Seats Open';
    _fuel = widget.fuelContribution ?? _data?['tripDetails']?['fuelContributionFormatted'] ?? '₹358';
    _driver = widget.driverName ?? _data?['tripDetails']?['driverName'] ?? 'Ravi kumar';
    _code = widget.driverCode ?? _data?['tripDetails']?['driverCode'] ?? '#1245';
    _bookingId = widget.bookingSeatZaatraId ?? _data?['tripDetails']?['bookingSeatZaatraId'] ?? '20124568';
    _pickupLoc = widget.nextPickupLocation ??
        widget.nextPickup?['location'] ??
        _data?['nextPickup']?['location'] ??
        'hitech city metro';

    _timeline = widget.routeTimeline ??
        (_data?['routeTimeline'] is List
            ? List<Map<String, dynamic>>.from(_data!['routeTimeline'])
            : [
                {'time': '9 : 00', 'location': 'Madhapur', 'isStart': true},
                {'time': '10 : 00', 'location': 'Ameerpet', 'isStart': false},
                {'time': '12 : 00', 'location': 'Begumpet', 'isStart': false},
                {'time': '01 : 00', 'location': 'Secundrabad', 'isStart': false},
              ]);

    _seats = widget.seatsAvailable ??
        (_data?['seatsAvailable'] is List
            ? List<Map<String, dynamic>>.from(_data!['seatsAvailable'])
            : [
                {'label': 'S-1 Booked', 'isBooked': true},
                {'label': 'S-2 Booked', 'isBooked': true},
                {'label': 'S-3 Booked', 'isBooked': true},
                {'label': 'Available', 'isBooked': false},
              ]);

    _loadNextPickup();
  }

  Future<void> _loadNextPickup() async {
    try {
      final res = await RideService.getNextPickupDetails();
      if (res['success'] == true && mounted) {
        final np = res['nextPickup'];
        if (np != null && np['location'] != null) {
          setState(() {
            _pickupLoc = np['location'];
          });
        }
      }
    } catch (_) {}
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
          'Live',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.textPrimary, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing live tracking for Ride ${widget.rideId ?? "RD-101"}...'),
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
                  // Dynamic Header Pill "Seats Open" matching 95.png
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        _badge,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Dynamic Waypoint Timeline matching 95.png
                  ...List.generate(_timeline.length, (i) {
                    final item = _timeline[i];
                    final isStart = item['isStart'] == true || item['type'] == 'start' || i == 0;
                    final isLast = i == _timeline.length - 1;
                    final time = item['time'] ?? '09:00';
                    final station = item['location'] ?? item['station'] ?? '';

                    return _buildWaypointTile(
                      time: time,
                      station: station,
                      isStart: isStart,
                      isLast: isLast,
                    );
                  }),

                  const SizedBox(height: 24),

                  // Seats Available Section matching 95.png
                  const Text(
                    'Seats Available',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(_seats.length, (i) {
                        final seat = _seats[i];
                        final label = seat['label'] ?? seat['seatNumber'] ?? 'S-${i + 1}';
                        final isBooked = seat['isBooked'] == true || seat['status'] == 'booked' || seat['status'] == 'boarding';
                        return _buildSeatBox(label, isBooked: isBooked);
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildInfoRow(Icons.local_gas_station_outlined, 'Fuel Contribution $_fuel'),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.directions_car_outlined, '$_driver - zaatra code $_code'),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.phone_outlined, 'Booking seat zaatra id : $_bookingId'),

                  const SizedBox(height: 28),

                  // Dynamic Next Pickup Banner Section matching 95.png
                  const Text(
                    'Next Pickup',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DriverLiveRideIdScreen(
                            rideId: widget.rideId ?? 'RD-202524578',
                            routeTimeline: _timeline,
                            seatsAvailable: _seats,
                            tripData: _data,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFE0B2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: Color(0xFFE65100), size: 22),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Next Pick up available : $_pickupLoc',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                            ),
                          ),
                        ],
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

  Widget _buildSeatBox(String label, {required bool isBooked}) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isBooked ? const Color(0xFFE8DEF8) : const Color(0xFFC4D5C5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              isBooked ? Icons.person_rounded : Icons.check_box_outline_blank_rounded,
              color: isBooked ? AppColors.primary : Colors.transparent,
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFFF3EDF7),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
