import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/ride_booking_model.dart';
import '../../../services/api_service.dart';
import '../../../services/ride_service.dart';
import 'driver_booking_detail_screen_104.dart';

class TripPreparationDriversScreen extends StatefulWidget {
  final String pickup;
  final String destination;
  final String date;
  final String time;
  final String passengers;
  final String paidForSeat;
  final String luggage;
  final bool isDoorstepEnabled;
  final String? doorstepPickup;
  final String? doorstepDrop;

  const TripPreparationDriversScreen({
    super.key,
    this.pickup = '',
    this.destination = '',
    this.date = '',
    this.time = '',
    this.passengers = '',
    this.paidForSeat = '',
    this.luggage = '',
    this.isDoorstepEnabled = false,
    this.doorstepPickup,
    this.doorstepDrop,
  });

  @override
  State<TripPreparationDriversScreen> createState() => _TripPreparationDriversScreenState();
}

class _TripPreparationDriversScreenState extends State<TripPreparationDriversScreen> {
  List<RideDriver> _drivers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    setState(() => _isLoading = true);
    final count = int.tryParse(widget.passengers.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    final res = await RideService.searchRides(
      pickupLocation: widget.pickup,
      destination: widget.destination,
      date: widget.date,
      passengers: count,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        final rawList = (res['data'] is List)
            ? res['data'] as List
            : ((res['rides'] is List) ? res['rides'] as List : []);

        if (rawList.isNotEmpty) {
          if (rawList.first is RideDriver) {
            _drivers = List<RideDriver>.from(rawList);
          } else {
            _drivers = rawList
                .whereType<Map<String, dynamic>>()
                .map((item) => RideDriver.fromJson(item))
                .toList();
          }
        } else {
          _drivers = [];
        }
      });
    }
  }

  ImageProvider? _getAvatarProvider(String avatar) {
    if (avatar.isEmpty) return null;
    if (avatar.startsWith('assets/')) return AssetImage(avatar);
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) return NetworkImage(avatar);
    if (avatar.startsWith('/')) {
      final base = ApiService.serverBaseUrl;
      return NetworkImage('$base$avatar');
    }
    return null;
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
          'Trip Preparation',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Route Info Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.pickup.isNotEmpty ? widget.pickup : 'Pickup',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 18),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      widget.destination.isNotEmpty ? widget.destination : 'Destination',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${widget.date}${widget.time.isNotEmpty ? " - ${widget.time}" : ""}'.trim(),
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Sort / Filter / Map Chips Row
                        Row(
                          children: [
                            Expanded(child: _buildChip(Icons.swap_vert_rounded, 'Sort')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildChip(Icons.filter_list_rounded, 'Filter')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildChip(Icons.map_outlined, 'Map')),
                          ],
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Available drivers',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),

                        const SizedBox(height: 16),

                        // Driver Cards List
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        else if (_drivers.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9FB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_car_outlined, size: 50, color: AppColors.textSecondary.withValues(alpha: 0.6)),
                                const SizedBox(height: 12),
                                const Text(
                                  'No drivers available',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'There are no active drivers scheduled for this route and date. Please try different dates or search again.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _drivers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final driver = _drivers[index];

                              void navigateToDetails() {
                                final count = int.tryParse(widget.passengers.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
                                final effectiveSeats = count > 0 ? count : 1;
                                final session = RideBookingSession(
                                  driver: driver,
                                  pickup: widget.pickup,
                                  destination: widget.destination,
                                  date: widget.date,
                                  time: widget.time,
                                  seatsCount: effectiveSeats,
                                  totalAmount: driver.pricePerSeat * effectiveSeats,
                                  luggage: widget.luggage,
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DriverBookingDetailScreen(session: session),
                                  ),
                                );
                              }

                              final summaryParts = <String>[];
                              if (driver.carModel.isNotEmpty) summaryParts.add(driver.carModel);
                              if (driver.tripsText.isNotEmpty) {
                                summaryParts.add(driver.tripsText);
                              } else if (driver.reviewCount > 0) {
                                summaryParts.add('${driver.reviewCount} trips');
                              }
                              if (driver.vehicleNumber.isNotEmpty) summaryParts.add(driver.vehicleNumber);
                              final vehicleSummaryText = summaryParts.join(' , ');

                              final originPoint = driver.pickupPoint.isNotEmpty ? driver.pickupPoint : (widget.pickup.isNotEmpty ? widget.pickup : 'Pickup');
                              final destPoint = driver.destinationPoint.isNotEmpty ? driver.destinationPoint : (widget.destination.isNotEmpty ? widget.destination : 'Destination');
                              final originTime = driver.departureTime.isNotEmpty ? driver.departureTime : widget.time;
                              final originSubText = '${widget.date.isNotEmpty ? "${widget.date}, " : ""}$originTime'.trim();

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top Row: Avatar + Info + View Details Button
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Builder(
                                              builder: (context) {
                                                final avatarProvider = _getAvatarProvider(driver.avatarImage);
                                                return CircleAvatar(
                                                  radius: 28,
                                                  backgroundColor: const Color(0xFFF3EDF7),
                                                  backgroundImage: avatarProvider,
                                                  onBackgroundImageError: avatarProvider != null ? (_, __) {} : null,
                                                  child: avatarProvider == null
                                                      ? const Icon(Icons.person, color: AppColors.primary, size: 28)
                                                      : null,
                                                );
                                              },
                                            ),
                                            if (driver.rating > 0)
                                              Positioned(
                                                bottom: -4,
                                                left: 4,
                                                right: 4,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: const Color(0xFFFFB800), width: 1),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: 0.08),
                                                        blurRadius: 3,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 12),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${driver.rating}',
                                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                driver.name.isNotEmpty ? driver.name : 'Driver',
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                              ),
                                              if (vehicleSummaryText.isNotEmpty) ...[
                                                const SizedBox(height: 3),
                                                Text(
                                                  vehicleSummaryText,
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          onPressed: navigateToDetails,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            side: const BorderSide(color: AppColors.primary, width: 1.2),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: const Text(
                                            'View Details',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),
                                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                                    const SizedBox(height: 14),

                                    // Timeline Row: Origin -> Destination
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Origin
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: const BoxDecoration(
                                                      color: AppColors.primary,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      originPoint,
                                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (originSubText.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  originSubText,
                                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        // Dotted Arrow Line
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(width: 24, height: 1.5, color: const Color(0xFFCCCCCC)),
                                              const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFFCCCCCC)),
                                            ],
                                          ),
                                        ),
                                        // Destination
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFF2E7D32),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      destPoint,
                                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (widget.date.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  widget.date,
                                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // Dynamic seat indicator
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F5E9),
                                            border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.event_seat_rounded, size: 15, color: Color(0xFF2E7D32)),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          driver.seatsAvailable > 0
                                              ? '${driver.seatsAvailable} ${driver.seatsAvailable == 1 ? "seat" : "seats"} available'
                                              : 'Seats info available on booking',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: driver.seatsAvailable > 0 ? const Color(0xFF2E7D32) : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Cost Per Seat Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 46,
                                      child: ElevatedButton(
                                        onPressed: navigateToDetails,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        child: Text(
                                          'Cost Per Seat ₹ ${driver.pricePerSeat.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
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

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDF7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.textPrimary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
