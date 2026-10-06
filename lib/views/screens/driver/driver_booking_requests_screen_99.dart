import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/booking_model.dart';
import '../../../services/driver_service.dart';
import '../../../services/ride_service.dart';
import 'driver_my_ride_screen_30.dart';

class DriverBookingRequestsScreen extends StatefulWidget {
  final int initialTabIndex;

  const DriverBookingRequestsScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<DriverBookingRequestsScreen> createState() => _DriverBookingRequestsScreenState();
}

class _DriverBookingRequestsScreenState extends State<DriverBookingRequestsScreen> {
  late int _selectedTabIndex; // 0: booking_requests, 1: confirmed, 2: denied, 3: other
  bool _isLoading = true;

  final List<String> _tabIds = [
    'booking_requests',
    'confirmed',
    'denied',
    'other',
  ];

  final List<String> _tabTitles = [
    'Booking requests',
    'Confirmed',
    'Denied',
    'Other',
  ];

  DriverTabCounts _counts = const DriverTabCounts();
  List<DriverBookingRequestItem> _bookingItems = [];
  List<DriverOtherNotificationItem> _otherItems = [];
  String? _emptyTitle;
  String? _emptyDescription;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _fetchTabData();
  }

  String get _currentTabId => _tabIds[_selectedTabIndex];

  Future<void> _fetchTabData() async {
    setState(() => _isLoading = true);

    try {
      final res = await DriverService.getDriverNotificationsByTab(tab: _currentTabId);
      final responseObj = DriverNotificationResponse.fromJson(res);

      if (mounted) {
        setState(() {
          _counts = responseObj.counts;
          _bookingItems = responseObj.bookingItems;
          _otherItems = responseObj.otherItems;
          _emptyTitle = responseObj.emptyStateTitle;
          _emptyDescription = responseObj.emptyStateDescription;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _acceptBooking(DriverBookingRequestItem item) async {
    final titleText = item.isDetour ? 'Accept Doorstep Detour Request' : 'Accept Booking Request';
    final descText = item.isDetour
        ? 'Accept ${item.customerName}\'s doorstep detour (+${item.detourDistanceKm} km)? Extra earning: ₹${item.detourExtraFare.toInt()}'
        : 'Are you sure you want to accept ${item.customerName}\'s booking for ${item.seats} seat(s) on ${item.routeText.isNotEmpty ? item.routeText : "this ride"}?';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(descText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Accept Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final Map<String, dynamic> res;
      if (item.isDetour) {
        res = await RideService.respondToDetourRequest(
          requestId: item.id.isNotEmpty ? item.id : item.bookingId,
          rideId: item.rideId,
          action: 'accept',
          customerName: item.customerName,
          customerPhone: item.customerPhone,
          pickupAddress: item.detourPickup.isNotEmpty ? item.detourPickup : item.pickup,
          destinationAddress: item.detourDestination.isNotEmpty ? item.detourDestination : item.destination,
          detourDistanceKm: item.detourDistanceKm,
          seats: item.seats,
        );
      } else {
        res = await DriverService.acceptBookingRequest(bookingId: item.bookingId);
      }

      if (!mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']?.toString() ?? 'Booking request accepted successfully! 🎉'),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 3),
          ),
        );
        _fetchTabData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']?.toString() ?? 'Failed to accept booking.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _declineBooking(DriverBookingRequestItem item) async {
    String selectedReason = 'Seat capacity full or route unavailable';
    final customReasonController = TextEditingController();

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final reasons = [
              'Seat capacity full or route unavailable',
              'Detour too far from main route',
              'Pickup time mismatch',
              'Vehicle issue or maintenance',
              'Other reason',
            ];

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Decline Booking Request',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a reason for declining ${item.customerName}\'s request:',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ...reasons.map((r) {
                    final isSel = selectedReason == r;
                    return InkWell(
                      onTap: () => setModalState(() => selectedReason = r),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSel ? Colors.redAccent : Colors.grey.shade400,
                                  width: isSel ? 6 : 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                r,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                                  color: isSel ? AppColors.textPrimary : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (selectedReason == 'Other reason') ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: customReasonController,
                      decoration: InputDecoration(
                        hintText: 'Enter specific reason...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            final finalReason = selectedReason == 'Other reason' && customReasonController.text.trim().isNotEmpty
                                ? customReasonController.text.trim()
                                : selectedReason;
                            Navigator.pop(ctx, finalReason);
                          },
                          child: const Text('Confirm Decline', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null || result.isEmpty) return;

    try {
      final Map<String, dynamic> res;
      if (item.isDetour) {
        res = await RideService.respondToDetourRequest(
          requestId: item.id.isNotEmpty ? item.id : item.bookingId,
          rideId: item.rideId,
          action: 'decline',
          customerName: item.customerName,
          customerPhone: item.customerPhone,
          pickupAddress: item.detourPickup.isNotEmpty ? item.detourPickup : item.pickup,
          destinationAddress: item.detourDestination.isNotEmpty ? item.detourDestination : item.destination,
          detourDistanceKm: item.detourDistanceKm,
          seats: item.seats,
        );
      } else {
        res = await DriverService.declineBookingRequest(
          bookingId: item.bookingId,
          reason: result,
        );
      }

      if (!mounted) return;

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']?.toString() ?? 'Booking request declined and moved to Denied.'),
            backgroundColor: Colors.grey[800],
            duration: const Duration(seconds: 3),
          ),
        );
        _fetchTabData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']?.toString() ?? 'Failed to decline booking.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _viewBookingDetails(DriverBookingRequestItem item) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return FutureBuilder<Map<String, dynamic>>(
          future: DriverService.getBookingRequestDetails(bookingId: item.bookingId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }

            final res = snapshot.data ?? {};
            final detail = DriverBookingDetail.fromJson(res);

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header with Passenger Info
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundColor: Color(0xFFF3EDF7),
                            child: Icon(Icons.person, color: AppColors.primary, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail.customer.name.isNotEmpty ? detail.customer.name : item.customerName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  detail.customer.phone.isNotEmpty ? detail.customer.phone : item.customerPhone,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: detail.status.toLowerCase() == 'confirmed'
                                  ? const Color(0xFFE8F5E9)
                                  : detail.status.toLowerCase() == 'declined'
                                      ? const Color(0xFFFFEBEE)
                                      : const Color(0xFFF3EDF7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              detail.statusBadge.isNotEmpty ? detail.statusBadge : item.statusBadge,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: detail.status.toLowerCase() == 'confirmed'
                                    ? const Color(0xFF2E7D32)
                                    : detail.status.toLowerCase() == 'declined'
                                        ? Colors.redAccent
                                        : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 14),

                      // Route & Ride Section
                      const Text('Trip Route', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF9FD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.radio_button_checked, color: Color(0xFF4CAF50), size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    detail.ride.from.isNotEmpty ? detail.ride.from : item.pickup,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 7),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(height: 16, width: 2, color: Colors.grey[300]),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    detail.ride.to.isNotEmpty ? detail.ride.to : item.destination,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Boarding Details
                      const Text('Boarding Location', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(
                        detail.boarding.boardingPoint.isNotEmpty ? detail.boarding.boardingPoint : (item.boardingPoint.isNotEmpty ? item.boardingPoint : item.pickup),
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                      if (detail.boarding.customerPickupLandmark.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Landmark: ${detail.boarding.customerPickupLandmark}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],

                      const SizedBox(height: 18),

                      // Pricing & Seats
                      const Text('Fare & Payment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${detail.pricing.seats > 0 ? detail.pricing.seats : item.seats} Seat(s)', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Text(detail.pricing.formattedAmount.isNotEmpty ? detail.pricing.formattedAmount : item.formattedAmount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Status', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(detail.pricing.paymentStatus.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                        ],
                      ),

                      if (detail.security.boardingPin.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        const Text('Security PIN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3EDF7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('PIN: ${detail.security.boardingPin}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 2)),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Quick Action Buttons inside Sheet if Pending
                      if (item.isPending) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _declineBooking(item);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Decline', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _acceptBooking(item);
                                },
                                child: const Text('Accept Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  int _getTabCount(int index) {
    if (index == 0) return _counts.bookingRequests;
    if (index == 1) return _counts.confirmed;
    if (index == 2) return _counts.denied;
    return _counts.other;
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
          'Notification',
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
                // Horizontal Segmented Tabs Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(_tabTitles.length, (index) {
                        final title = _tabTitles[index];
                        final count = _getTabCount(index);
                        final label = (index == 0 && count > 0)
                            ? '$title ($count)'
                            : title;

                        return Padding(
                          padding: EdgeInsets.only(right: index < _tabTitles.length - 1 ? 8.0 : 0.0),
                          child: _buildTabButton(label, index),
                        );
                      }),
                    ),
                  ),
                ),

                // Main Booking Requests / Notifications List or Empty State
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _fetchTabData,
                          child: _isCurrentTabEmpty()
                              ? _buildEmptyState()
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                                  itemCount: _selectedTabIndex == 3 ? _otherItems.length : _bookingItems.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    if (_selectedTabIndex == 3) {
                                      return _buildOtherNotificationCard(_otherItems[index]);
                                    }
                                    return _buildBookingCard(_bookingItems[index]);
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

  bool _isCurrentTabEmpty() {
    if (_selectedTabIndex == 3) {
      return _otherItems.isEmpty;
    }
    return _bookingItems.isEmpty;
  }

  Widget _buildEmptyState() {
    String emptyTitle = _emptyTitle ?? 'No Notifications';
    String emptyDesc = _emptyDescription ?? 'You do not have any notifications at the moment.';

    if (_emptyTitle == null) {
      if (_selectedTabIndex == 0) {
        emptyTitle = 'No Booking Requests';
        emptyDesc = 'You do not have any pending booking requests right now.';
      } else if (_selectedTabIndex == 1) {
        emptyTitle = 'No Confirmed Bookings';
        emptyDesc = 'You do not have any confirmed co-traveler bookings yet.';
      } else if (_selectedTabIndex == 2) {
        emptyTitle = 'No Denied Requests';
        emptyDesc = 'You have not denied or cancelled any booking requests.';
      } else if (_selectedTabIndex == 3) {
        emptyTitle = 'No Other Notifications';
        emptyDesc = 'You are all caught up on system updates and announcements.';
      }
    }

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
              child: Icon(
                _selectedTabIndex == 3 ? Icons.notifications_none_rounded : Icons.inbox_rounded,
                size: 54,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              emptyTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              emptyDesc,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(DriverBookingRequestItem item) {
    return Container(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.customerName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              if (item.isConfirmed)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.statusBadge.isNotEmpty ? item.statusBadge : 'Confirmed',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                  ),
                                )
                              else if (item.isDenied)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.statusBadge.isNotEmpty ? item.statusBadge : 'Denied',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.pickup,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 14),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  item.destination,
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
                if (item.isDetour) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.alt_route_rounded, size: 16, color: Colors.deepOrange),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Doorstep Detour (+${item.detourDistanceKm} km)${item.detourExtraFare > 0 ? ' · Extra: ₹${item.detourExtraFare.toInt()}' : ''}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Text(
                  item.timeAgo.isNotEmpty ? item.timeAgo : (item.createdAt.isNotEmpty ? item.createdAt : '-'),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  item.seatPriceText.isNotEmpty ? item.seatPriceText : '${item.seats} Seat · ${item.formattedAmount}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _viewBookingDetails(item),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('View', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (item.isPending) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _declineBooking(item),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Decline', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _acceptBooking(item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Accept', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    item.publishNewRideCta?['title']?.toString() ?? '+ Publish new ride',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherNotificationCard(DriverOtherNotificationItem notif) {
    IconData icon = Icons.notifications_rounded;
    Color color = AppColors.primary;

    final t = notif.iconType.toLowerCase();
    if (t.contains('payout') || t.contains('payment')) {
      icon = Icons.account_balance_wallet_rounded;
      color = const Color(0xFF2E7D32);
    } else if (t.contains('rating') || t.contains('star')) {
      icon = Icons.star_rounded;
      color = const Color(0xFFFFA000);
    } else if (t.contains('policy') || t.contains('safety')) {
      icon = Icons.verified_user_rounded;
      color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: notif.unread ? const Color(0xFFF9F7FD) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: notif.unread ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (notif.unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (notif.body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  notif.timeAgo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedTabIndex != index) {
          setState(() {
            _selectedTabIndex = index;
          });
          _fetchTabData();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF3EDF7),
          borderRadius: BorderRadius.circular(20),
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
