import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/ride_booking_model.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'customer_home_screen_38.dart';
import 'ride_booking_success_screen_111.dart';

/// ============================================================================
/// RIDE AWAITING DRIVER CONFIRMATION SCREEN
/// ============================================================================
/// Displayed after a passenger submits a booking request with "Book Ride".
/// The ride is pending driver acceptance. This screen displays:
/// - Real-time animated radar pulse indicator
/// - Driver & vehicle profile preview
/// - Route & fare breakdown (pay to driver)
/// - Background polling (every 3s) for driver accept/decline state
/// - Instant navigation to Success Screen upon driver confirmation
/// - Clean dialog & search alternative upon driver rejection
/// - "Cancel Request" action
/// ============================================================================
class RideAwaitingConfirmationScreen extends StatefulWidget {
  final RideBookingSession? session;
  final String? bookingId;

  const RideAwaitingConfirmationScreen({
    super.key,
    this.session,
    this.bookingId,
  });

  @override
  State<RideAwaitingConfirmationScreen> createState() => _RideAwaitingConfirmationScreenState();
}

class _RideAwaitingConfirmationScreenState extends State<RideAwaitingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  Timer? _pollingTimer;

  bool _isCancelling = false;
  bool _hasResponded = false;

  RideBookingSession get _session => widget.session ?? const RideBookingSession();
  String get _bookingId => widget.bookingId ?? _session.bookingId;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startPolling() {
    // Poll immediately after 2 seconds, then every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted || _hasResponded || _isCancelling) return;
      await _checkBookingStatus();
    });
  }

  Future<void> _checkBookingStatus() async {
    final bId = _bookingId.trim();
    if (bId.isEmpty) return;

    try {
      final res = await RideService.getRideConfirmation(bId);
      if (!mounted || _hasResponded) return;

      if (res['success'] == true) {
        final bookingData = res['booking'] is Map<String, dynamic>
            ? res['booking'] as Map<String, dynamic>
            : (res['data'] is Map<String, dynamic> ? res['data'] as Map<String, dynamic> : res);

        final rawStatus = (bookingData['status'] ?? res['status'] ?? '').toString().toLowerCase().trim();

        if (rawStatus == 'confirmed' || rawStatus == 'accepted' || rawStatus == 'in_progress') {
          _hasResponded = true;
          _pollingTimer?.cancel();

          final boardingPin = bookingData['boardingPin']?.toString() ??
              res['boardingPin']?.toString() ??
              _session.boardingPin;

          final updatedSession = _session.copyWith(
            bookingId: bId,
            boardingPin: boardingPin.isNotEmpty ? boardingPin : _session.boardingPin,
          );

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RideBookingSuccessScreen(session: updatedSession),
              ),
            );
          }
        } else if (rawStatus == 'declined' || rawStatus == 'rejected' || rawStatus == 'cancelled') {
          _hasResponded = true;
          _pollingTimer?.cancel();

          if (mounted) {
            _showDriverDeclinedDialog(bookingData['reason']?.toString() ?? 'The driver is currently unavailable for this ride.');
          }
        }
      }
    } catch (_) {
      // Ignore network hiccup during polling
    }
  }

  void _showDriverDeclinedDialog(String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Request Declined', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver ${_session.driver.name.isNotEmpty ? _session.driver.name : "Driver"} was unable to accept your ride booking request.',
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
            ),
            const SizedBox(height: 10),
            Text(
              'Reason: $reason',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Return Home', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Go back to search results
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Search Other Rides', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancelRequest() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Ride Request?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to cancel your ride request? The driver will not be notified to accept.',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Waiting', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCancelling = true);
    _pollingTimer?.cancel();

    if (_bookingId.isNotEmpty) {
      await RideService.cancelBooking(_bookingId, reason: 'Passenger cancelled pending request');
    }

    if (!mounted) return;
    setState(() => _isCancelling = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ride request cancelled successfully.'),
        backgroundColor: Colors.orange,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final driver = session.driver;
    final totalFare = session.totalAmount > 0
        ? session.totalAmount
        : (driver.pricePerSeat * (session.seatsCount > 0 ? session.seatsCount : 1) + session.detourCharge);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => _handleCancelRequest(),
        ),
        title: const Text(
          'Awaiting Confirmation',
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
            // Bottom illustration background
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),

                        // Animated Radar Pulse Ring
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 130 + (_pulseAnimation.value * 20),
                              height: 130 + (_pulseAnimation.value * 20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(
                                  alpha: 0.08 + (0.08 * (1.0 - _pulseAnimation.value)),
                                ),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3 + (0.4 * _pulseAnimation.value),
                                  ),
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.schedule_rounded,
                                      color: AppColors.primary,
                                      size: 46,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Status Headline
                        const Text(
                          'Waiting for Driver Approval',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Your booking request has been dispatched to ${driver.name.isNotEmpty ? driver.name : "the driver"}.\nPlease keep this screen open while we await their confirmation.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Driver Profile Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9FB),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              CustomImagePlaceholder(
                                width: 56,
                                height: 56,
                                imageUrl: driver.avatarImage,
                                icon: Icons.person_rounded,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driver.name.isNotEmpty ? driver.name : 'Verified Driver',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${driver.carModel.isNotEmpty ? driver.carModel : "Car"} • ${driver.vehicleNumber.isNotEmpty ? driver.vehicleNumber : "Verified"}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          driver.rating > 0 ? driver.rating.toStringAsFixed(1) : '4.9',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (driver.tripsCount > 0) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            '(${driver.tripsCount} trips)',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Route & Booking Summary Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F4FB),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Trip Summary',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange.shade300),
                                    ),
                                    child: const Text(
                                      'Pending Approval',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildSummaryRow(
                                icon: Icons.trip_origin_rounded,
                                iconColor: Colors.green,
                                label: 'Pickup Point',
                                value: session.boardingPoint.isNotEmpty
                                    ? session.boardingPoint
                                    : (session.pickup.isNotEmpty ? session.pickup : 'Pickup Location'),
                              ),
                              const SizedBox(height: 10),
                              _buildSummaryRow(
                                icon: Icons.location_on_rounded,
                                iconColor: Colors.red,
                                label: 'Destination',
                                value: session.destination.isNotEmpty ? session.destination : 'Destination Point',
                              ),
                              const SizedBox(height: 10),
                              _buildSummaryRow(
                                icon: Icons.airline_seat_recline_normal_rounded,
                                iconColor: AppColors.primary,
                                label: 'Requested Seats',
                                value: '${session.seatsCount > 0 ? session.seatsCount : 1} Seat(s)',
                              ),
                              const Divider(height: 20, color: AppColors.border),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Fare to Pay Driver',
                                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                      ),
                                      Text(
                                        'Cash / UPI upon boarding',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '₹${totalFare.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Cancel Action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                  child: OutlinedButton(
                    onPressed: _isCancelling ? null : _handleCancelRequest,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isCancelling
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                          )
                        : const Text(
                            'Cancel Ride Request',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
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

  Widget _buildSummaryRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
