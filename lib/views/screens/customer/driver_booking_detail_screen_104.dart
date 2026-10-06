import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/ride_booking_model.dart';
import '../../../services/api_service.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_button.dart';
import 'passenger_details_screen_107.dart';

class DriverBookingDetailScreen extends StatefulWidget {
  final RideBookingSession? session;

  const DriverBookingDetailScreen({
    super.key,
    this.session,
  });

  @override
  State<DriverBookingDetailScreen> createState() => _DriverBookingDetailScreenState();
}

class _DriverBookingDetailScreenState extends State<DriverBookingDetailScreen> {
  late RideBookingSession _session;
  RideDetailData? _detailData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session ?? const RideBookingSession();
    _loadRideDetails();
  }

  Future<void> _loadRideDetails() async {
    final rideId = _session.rideId.isNotEmpty ? _session.rideId : _session.driver.id;
    if (rideId.isEmpty) return;

    setState(() => _isLoading = true);
    final res = await RideService.getRideDetails(
      rideId,
      pickup: _session.pickup,
      destination: _session.destination,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res['success'] == true) {
          _detailData = RideDetailData.fromJson(
            res,
            pickup: _session.pickup,
            destination: _session.destination,
            fallbackPrice: _session.driver.pricePerSeat,
          );
          final effectivePrice = _detailData!.pricePerSeat > 0
              ? _detailData!.pricePerSeat
              : (_session.driver.pricePerSeat > 0 ? _session.driver.pricePerSeat : 0.0);
          final updatedDriver = _detailData!.driver.copyWith(
            pricePerSeat: effectivePrice,
          );
          _session = _session.copyWith(
            rideId: _detailData!.rideId,
            driver: updatedDriver,
            totalAmount: effectivePrice * _session.seatsCount,
            rideDetailData: _detailData,
          );
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
    final active = _session;
    final driver = _detailData?.driver ?? active.driver;
    final vehicleSummary = _detailData?.vehicleSummary ?? '${driver.carModel} , ${driver.vehicleNumber}'.trim();
    final tripsText = driver.tripsText.isNotEmpty ? driver.tripsText : (driver.reviewCount > 0 ? '${driver.reviewCount} trips' : '');
    final timelineStops = _detailData?.routeTimeline ?? [];
    final avatarProvider = _getAvatarProvider(driver.avatarImage);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Driver Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded, color: AppColors.textPrimary),
            onPressed: () {},
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
            Column(
              children: [
                if (_isLoading)
                  const LinearProgressIndicator(
                    color: AppColors.primary,
                    backgroundColor: Color(0xFFF3EDF7),
                    minHeight: 3,
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Driver Profile Card matching 104.png
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: const Color(0xFFF3EDF7),
                                    backgroundImage: avatarProvider,
                                    onBackgroundImageError: avatarProvider != null ? (_, __) {} : null,
                                    child: avatarProvider == null
                                        ? const Icon(Icons.person, color: AppColors.primary, size: 28)
                                        : null,
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
                                        if (vehicleSummary.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            vehicleSummary,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // 3 Badges row: Rating, Trips, About
                              Row(
                                children: [
                                  if (driver.rating > 0) ...[
                                    _buildBadge(Icons.star_rounded, '${driver.rating}', const Color(0xFFFFB800), const Color(0xFFFFF7EC)),
                                    const SizedBox(width: 8),
                                  ],
                                  if (tripsText.isNotEmpty) ...[
                                    _buildBadge(Icons.directions_car_rounded, tripsText, AppColors.primary, const Color(0xFFF3EDF7)),
                                    const SizedBox(width: 8),
                                  ],
                                  _buildBadge(
                                    Icons.info_outline_rounded,
                                    'About',
                                    AppColors.textSecondary,
                                    const Color(0xFFF5F5F5),
                                    onTap: () => _showDriverAboutModal(context, driver),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Ride Info Header
                        const Text(
                          'Ride Info',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),

                        const SizedBox(height: 12),

                        // Ride Info Vertical Timeline Card with Dynamic Customer Segment Highlighting
                        Builder(
                          builder: (context) {
                            final selectedPickup = active.boardingPoint.isNotEmpty
                                ? active.boardingPoint
                                : (active.pickup.isNotEmpty ? active.pickup : driver.pickupPoint);
                            final selectedDestination = active.destination.isNotEmpty
                                ? active.destination
                                : driver.destinationPoint;

                            int pickupIdx = -1;
                            int destIdx = -1;

                            if (timelineStops.isNotEmpty) {
                              pickupIdx = timelineStops.indexWhere((s) => _isLocationMatch(s.location, selectedPickup));
                              if (pickupIdx == -1) {
                                pickupIdx = timelineStops.indexWhere((s) => s.type == 'start');
                                if (pickupIdx == -1) pickupIdx = 0;
                              }

                              destIdx = timelineStops.indexWhere((s) => _isLocationMatch(s.location, selectedDestination));
                              if (destIdx == -1) {
                                destIdx = timelineStops.lastIndexWhere((s) => s.type == 'destination');
                                if (destIdx == -1) destIdx = timelineStops.length - 1;
                              }

                              if (pickupIdx > destIdx) {
                                final temp = pickupIdx;
                                pickupIdx = destIdx;
                                destIdx = temp;
                              }
                            }

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (timelineStops.isNotEmpty) ...[
                                    for (int i = 0; i < timelineStops.length; i++) ...[
                                      _buildTimelineRow(
                                        stop: timelineStops[i],
                                        isFirst: i == 0,
                                        isLast: i == timelineStops.length - 1,
                                        isCustomerPickup: i == pickupIdx,
                                        isCustomerDestination: i == destIdx,
                                        isSegmentLineActive: i >= pickupIdx && i < destIdx,
                                      ),
                                    ],
                                  ] else ...[
                                    // Fallback: Selected origin & destination
                                    _buildTimelineRow(
                                      stop: RouteTimelineStop(
                                        time: active.time.isNotEmpty ? active.time : (_detailData?.departureTime ?? ''),
                                        location: selectedPickup.isNotEmpty ? selectedPickup : (_detailData?.from ?? 'Pickup'),
                                        type: 'start',
                                      ),
                                      isFirst: true,
                                      isLast: false,
                                      isCustomerPickup: true,
                                      isCustomerDestination: false,
                                      isSegmentLineActive: true,
                                    ),
                                    _buildTimelineRow(
                                      stop: RouteTimelineStop(
                                        time: _detailData?.arrivalTime ?? '',
                                        location: selectedDestination.isNotEmpty ? selectedDestination : (_detailData?.to ?? 'Destination'),
                                        type: 'destination',
                                      ),
                                      isFirst: false,
                                      isLast: true,
                                      isCustomerPickup: false,
                                      isCustomerDestination: true,
                                      isSegmentLineActive: false,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Interactive Map Preview Container matching 104.png
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3EDF7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.map_rounded,
                                  size: 64,
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                ),
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.navigation_rounded, color: AppColors.primary, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        'View live map route',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Bottom Next Full-Width Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
                    ],
                  ),
                  child: CustomButton(
                    text: 'Next',
                    onPressed: () {
                      final effectivePickup = _session.boardingPoint.isNotEmpty
                          ? _session.boardingPoint
                          : (_session.pickup.isNotEmpty ? _session.pickup : _session.driver.pickupPoint);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PassengerDetailsScreen(
                            session: _session.copyWith(
                              boardingPoint: effectivePickup,
                              pickup: effectivePickup,
                            ),
                          ),
                        ),
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

  void _showDriverAboutModal(BuildContext context, RideDriver driver) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFF3EDF7),
                      backgroundImage: _getAvatarProvider(driver.avatarImage),
                      child: driver.avatarImage.isEmpty
                          ? const Icon(Icons.person, color: AppColors.primary, size: 26)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.name.isNotEmpty ? driver.name : 'Driver',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF2E7D32)),
                              const SizedBox(width: 4),
                              Text(
                                'Verified Zaatra Driver',
                                style: TextStyle(fontSize: 13, color: Colors.green.shade800, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'About Driver',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  driver.about.isNotEmpty
                      ? driver.about
                      : 'Verified commercial driver on Zaatra platform with extensive driving experience and high safety ratings.',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                if (driver.phone.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.phone_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        driver.phone,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isLocationMatch(String stopLoc, String targetLoc) {
    if (stopLoc.trim().isEmpty || targetLoc.trim().isEmpty) return false;
    final cleanStop = stopLoc.toLowerCase().trim();
    final cleanTarget = targetLoc.toLowerCase().trim();
    if (cleanStop == cleanTarget) return true;

    final tokenStop = cleanStop.split(RegExp(r'[, -]')).first.trim();
    final tokenTarget = cleanTarget.split(RegExp(r'[, -]')).first.trim();
    if (tokenStop.isNotEmpty && tokenTarget.isNotEmpty && tokenStop == tokenTarget) return true;

    return cleanStop.contains(cleanTarget) || cleanTarget.contains(cleanStop);
  }

  Widget _buildTimelineRow({
    required RouteTimelineStop stop,
    required bool isFirst,
    required bool isLast,
    bool isCustomerPickup = false,
    bool isCustomerDestination = false,
    bool isSegmentLineActive = false,
  }) {
    final double dotSize = (isCustomerPickup || isCustomerDestination) ? 16.0 : 12.0;

    BoxDecoration dotDecoration;
    if (isCustomerPickup) {
      // Customer's Selected Pickup Point (Blue Dot with Shadow)
      dotDecoration = BoxDecoration(
        color: const Color(0xFF1976D2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withValues(alpha: 0.35),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      );
    } else if (isCustomerDestination) {
      // Customer's Selected Destination Point (Green Dot with Shadow)
      dotDecoration = BoxDecoration(
        color: const Color(0xFF2E7D32),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      );
    } else if (stop.type == 'start' || isFirst) {
      dotDecoration = const BoxDecoration(
        color: Color(0xFF9E9E9E),
        shape: BoxShape.circle,
      );
    } else if (stop.type == 'destination' || isLast) {
      dotDecoration = const BoxDecoration(
        color: Color(0xFF9E9E9E),
        shape: BoxShape.circle,
      );
    } else {
      dotDecoration = BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBDBDBD), width: 2),
        shape: BoxShape.circle,
      );
    }

    final double lineHeight = stop.landmark.isNotEmpty ? 54.0 : 40.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              Container(
                width: dotSize,
                height: dotSize,
                decoration: dotDecoration,
                child: (isCustomerPickup || isCustomerDestination)
                    ? Center(
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              if (!isLast)
                Container(
                  width: isSegmentLineActive ? 4.0 : 2.0,
                  height: lineHeight,
                  decoration: BoxDecoration(
                    color: isSegmentLineActive ? const Color(0xFF1976D2) : const Color(0xFFDCDCDC),
                    borderRadius: isSegmentLineActive ? BorderRadius.circular(2) : null,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      stop.location,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: (isCustomerPickup || isCustomerDestination)
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isCustomerPickup
                            ? const Color(0xFF1565C0)
                            : (isCustomerDestination ? const Color(0xFF1B5E20) : AppColors.textPrimary),
                      ),
                    ),
                  ),
                  if (isCustomerPickup) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Pickup',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                  ] else if (isCustomerDestination) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Destination',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (stop.landmark.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  stop.landmark,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 2),
              Text(
                stop.time,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (stop.amountText.isNotEmpty || stop.price > 0) ...[
              Text(
                stop.amountText.isNotEmpty ? stop.amountText : '₹ ${stop.price.toInt()}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
            ],
            if (stop.pickCount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EDF7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${stop.passengerLabel.isNotEmpty ? stop.passengerLabel : "Pick ${stop.pickCount}"} ',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    for (int i = 0; i < stop.pickCount; i++)
                      const Icon(Icons.person, size: 12, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label, Color iconColor, Color bgColor, {VoidCallback? onTap}) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }
    return content;
  }
}
