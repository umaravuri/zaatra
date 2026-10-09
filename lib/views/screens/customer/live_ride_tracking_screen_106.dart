import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/ride_booking_model.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_image_placeholder.dart';

class LiveRideTrackingScreen extends StatefulWidget {
  final RideBookingSession? session;
  final String? bookingId;

  const LiveRideTrackingScreen({
    super.key,
    this.session,
    this.bookingId,
  });

  @override
  State<LiveRideTrackingScreen> createState() => _LiveRideTrackingScreenState();
}

class _LiveRideTrackingScreenState extends State<LiveRideTrackingScreen> {
  RideBookingSession get _session => widget.session ?? const RideBookingSession();
  
  List<RoutePropertyItem> _nearbyProperties = [];
  bool _isLoadingProperties = false;

  // Live vehicle coordinates (defaults to route checkpoint or session coordinates)
  final double _vehicleLat = 17.1439;
  final double _vehicleLng = 79.6239;

  @override
  void initState() {
    super.initState();
    _fetchLiveNearbyStays();
  }

  Future<void> _fetchLiveNearbyStays() async {
    setState(() => _isLoadingProperties = true);
    try {
      final res = await RideService.getNearbyLiveProperties(
        lat: _vehicleLat,
        lng: _vehicleLng,
        radiusKm: 15,
        limit: 5,
      );

      if (res['success'] == true && res['properties'] is List) {
        final list = (res['properties'] as List)
            .map((p) => RoutePropertyItem.fromJson(p as Map<String, dynamic>))
            .toList();
        if (mounted) {
          setState(() {
            _nearbyProperties = list;
            _isLoadingProperties = false;
          });
        }
      } else {
        // Fallback default nearby stay along NH65
        if (mounted) {
          setState(() {
            _nearbyProperties = [
              const RoutePropertyItem(
                propertyId: 'PR-1002',
                title: 'Highway Grand Palm Resort',
                type: 'Resort',
                city: 'Suryapet',
                location: 'NH65 Highway, Suryapet',
                price: 3200,
                pricePerHour: 270,
                priceFormatted: '₹3,200/night',
                pricePerHourFormatted: '₹270/hr',
                rating: 4.7,
                distanceKm: 0.8,
                distanceFormatted: '800 m away',
                bookUrl: '/api/bookings/stay?propertyId=PR-1002',
              ),
            ];
            _isLoadingProperties = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingProperties = false);
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:${clean.isNotEmpty ? clean : '+919876543210'}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Calling $phoneNumber...')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch phone app for $phoneNumber')),
        );
      }
    }
  }

  Future<void> _sendSms(BuildContext context, String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('sms:${clean.isNotEmpty ? clean : '+919876543210'}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Messaging $phoneNumber...')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch messaging app for $phoneNumber')),
        );
      }
    }
  }

  void _showStayBookingDialog(RoutePropertyItem property) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.hotel_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                property.title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${property.type} • ${property.city.isNotEmpty ? property.city : property.location}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hourly Rate', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        property.pricePerHourFormatted.isNotEmpty ? property.pricePerHourFormatted : '₹${property.pricePerHour.toInt()}/hr',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Full Night', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        property.priceFormatted.isNotEmpty ? property.priceFormatted : '₹${property.price.toInt()}/night',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.near_me_rounded, size: 14, color: Color(0xFF4CAF50)),
                const SizedBox(width: 4),
                Text(
                  property.distanceFormatted.isNotEmpty ? property.distanceFormatted : '${property.distanceKm} km away from car',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primary,
                  content: Text('Reservation request sent for ${property.title}!'),
                ),
              );
            },
            child: const Text('Book Hourly Stay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _session;
    final driver = s.driver;

    final driverName = driver.name.isNotEmpty ? driver.name : 'vikaram';
    final vehiclePlate = driver.vehicleNumber.isNotEmpty ? driver.vehicleNumber : (driver.carModel.isNotEmpty ? driver.carModel : 'Seltos • AP40GH6666');
    final driverRating = driver.rating > 0 ? driver.rating.toStringAsFixed(1) : '4.9';
    final driverPhone = driver.phone.isNotEmpty ? driver.phone : '+91 9639879639';

    final pickupLocation = s.boardingPoint.isNotEmpty
        ? s.boardingPoint
        : (s.pickup.isNotEmpty ? s.pickup : 'Miyapur, Telangana');
    final destinationLocation = s.destination.isNotEmpty ? s.destination : 'Guntur, Andhra Pradesh';

    final departureDate = s.date.isNotEmpty ? s.date : 'Today';
    final departureTime = s.time.isNotEmpty ? s.time : (driver.departureTime.isNotEmpty ? driver.departureTime : '03:00 PM');
    final arrivalTime = s.rideDetailData?.arrivalTime.isNotEmpty == true ? s.rideDetailData!.arrivalTime : '10:30 AM';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Route Map',
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
                // Full Live Tracking Map Container matching Screen 106
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDF7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: _LiveTrackingMapPainter(
                            properties: _nearbyProperties,
                          ),
                        ),

                        // Live vehicle pin pulse
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.25),
                                      blurRadius: 16,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary, size: 34),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Live on Route',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Floating Live GPS Nearby Stays Radar Card
                        if (_isLoadingProperties)
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Scanning nearby stays along route...', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          )
                        else if (_nearbyProperties.isNotEmpty)
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8DEF8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.hotel_rounded, size: 16, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Nearby Stays (< 15 km): ${_nearbyProperties.first.title}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${_nearbyProperties.first.distanceFormatted} • ${_nearbyProperties.first.pricePerHourFormatted}',
                                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _showStayBookingDialog(_nearbyProperties.first),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Book Stay',
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Driver Card & Actions matching Screen 106
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
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
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CustomImagePlaceholder(
                              width: 54,
                              height: 54,
                              imageUrl: driver.avatarImage,
                              icon: Icons.person_rounded,
                              borderRadius: const BorderRadius.all(Radius.circular(27)),
                            ),
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(radius: 6, backgroundColor: Color(0xFF4CAF50)),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driverName,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vehiclePlate,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    driverRating,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFFB800)),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.phone_rounded, color: AppColors.primary),
                              onPressed: () => _makePhoneCall(context, driverPhone),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
                              onPressed: () => _sendSms(context, driverPhone),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Route Timings Info matching Screen 106
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pickupLocation,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(departureDate, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Text(departureTime, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('• • • • • •', style: TextStyle(color: AppColors.border, fontSize: 16)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              destinationLocation,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(departureDate, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Text(arrivalTime, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveTrackingMapPainter extends CustomPainter {
  final List<RoutePropertyItem> properties;

  _LiveTrackingMapPainter({this.properties = const []});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF0EBF8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = const Color(0xFFD0BCFF).withValues(alpha: 0.6)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadPath = Path();
    roadPath.moveTo(size.width * 0.15, size.height * 0.85);
    roadPath.cubicTo(
      size.width * 0.3,
      size.height * 0.6,
      size.width * 0.4,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.5,
    );
    roadPath.cubicTo(
      size.width * 0.6,
      size.height * 0.6,
      size.width * 0.7,
      size.height * 0.3,
      size.width * 0.85,
      size.height * 0.15,
    );

    canvas.drawPath(roadPath, roadPaint);

    final innerRoad = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(roadPath, innerRoad);

    // Origin Pin
    final originPaint = Paint()..color = Colors.green;
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.85), 8, originPaint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.85), 4, Paint()..color = Colors.white);

    // Destination Pin
    final destPaint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 8, destPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 4, Paint()..color = Colors.white);

    // Property Pins along route if any
    for (int i = 0; i < properties.length; i++) {
      final pinPaint = Paint()..color = const Color(0xFFFF9800);
      final propOffset = Offset(size.width * (0.45 + i * 0.15), size.height * (0.42 + i * 0.08));
      canvas.drawCircle(propOffset, 6, pinPaint);
      canvas.drawCircle(propOffset, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _LiveTrackingMapPainter oldDelegate) =>
      oldDelegate.properties != properties;
}
