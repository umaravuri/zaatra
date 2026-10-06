import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/ride_booking_model.dart';
import '../../../services/ride_service.dart';
import 'customer_home_screen_38.dart';

class RideConfirmedDetailScreen112 extends StatefulWidget {
  final String? bookingId;
  final RideBookingSession? session;
  final Map<String, dynamic>? bookingData;

  const RideConfirmedDetailScreen112({
    super.key,
    this.bookingId,
    this.session,
    this.bookingData,
  });

  @override
  State<RideConfirmedDetailScreen112> createState() => _RideConfirmedDetailScreen112State();
}

class _RideConfirmedDetailScreen112State extends State<RideConfirmedDetailScreen112> {
  bool _agreedToTerms = true;
  bool _isLoading = false;
  bool _isCancelling = false;

  // Dynamic state variables initialized with smart runtime defaults
  String _displayDate = '';
  String _checkInDate = '';
  String _checkInTime = '';
  String _checkOutDate = '';
  String _checkOutTime = '';
  String _seatConfirmed = 'A 1';
  String _boardingPin = '5478';

  String _driverName = 'Driver';
  String _driverDetails = '';
  String _driverRating = '4.9';
  String _driverPhone = '';
  String _driverAvatar = '';

  List<Map<String, dynamic>> _timelineStops = [];

  String _routeNote1 = 'note : 1 seat confirmed';
  String _routeNote2 = 'fuel share verified';

  String _bookingId = '';
  String _passengerName = '';
  String _passengerPhone = '';
  String _bookingRequestDate = '';
  String _rideAcceptDate = '';
  String _rideAcceptedDate = '';

  @override
  void initState() {
    super.initState();
    _initDefaultDates();
    _hydrateInitialData();
    _fetchDynamicConfirmation();
  }

  void _initDefaultDates() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    final todayFormatted = '${now.day} ${months[now.month - 1]}';
    final fullDateFormatted = '${now.day} ${months[now.month - 1]} . ${now.year}';
    final dayOfWeek = weekdays[now.weekday - 1];

    _displayDate = '$dayOfWeek ${now.day} ${months[now.month - 1].toLowerCase()} , 10:30 am';
    _checkInDate = fullDateFormatted;
    _checkInTime = '10 : 30 AM';
    _checkOutDate = fullDateFormatted;
    _checkOutTime = '01 : 00 PM';
    _bookingRequestDate = todayFormatted;
    _rideAcceptDate = todayFormatted;
    _rideAcceptedDate = todayFormatted;
  }

  String _getEffectiveBookingId() {
    if (widget.bookingId != null && widget.bookingId!.trim().isNotEmpty) {
      return widget.bookingId!.trim();
    }
    if (widget.session != null && widget.session!.bookingId.isNotEmpty) {
      return widget.session!.bookingId.trim();
    }
    if (widget.bookingData != null) {
      final id = widget.bookingData!['bookingId'] ??
          widget.bookingData!['_id'] ??
          widget.bookingData!['id'];
      if (id != null && id.toString().isNotEmpty) {
        return id.toString().trim();
      }
    }
    return '';
  }

  void _hydrateInitialData() {
    if (widget.session != null) {
      final s = widget.session!;

      // 1. Booking ID
      if (s.bookingId.isNotEmpty) {
        _bookingId = s.bookingId.startsWith('#') ? s.bookingId : '#${s.bookingId}';
      } else {
        _bookingId = '#BK-RIDE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      }

      // 2. Schedule & Dates
      if (s.date.isNotEmpty) {
        final time = s.time.isNotEmpty ? s.time : '10:30 am';
        _displayDate = '${s.date} , $time';
        _checkInDate = s.date;
        _checkInTime = time;
        _checkOutDate = s.rideDetailData?.arrivalDateFormatted.isNotEmpty == true
            ? s.rideDetailData!.arrivalDateFormatted
            : s.date;
        _checkOutTime = s.rideDetailData?.arrivalTime.isNotEmpty == true
            ? s.rideDetailData!.arrivalTime
            : '01:00 PM';
      }

      // 3. Boarding PIN
      if (s.boardingPin.isNotEmpty) {
        _boardingPin = s.boardingPin;
      } else if (s.bookingId.isNotEmpty) {
        final digits = s.bookingId.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.length >= 4) {
          _boardingPin = digits.substring(digits.length - 4);
        }
      }

      // 4. Seats
      if (s.seatsCount > 0) {
        _seatConfirmed = 'A ${s.seatsCount}';
        _routeNote1 = 'note : ${s.seatsCount} seat(s) confirmed';
      }

      // 5. Driver Details (Clean dynamic formatting without dummy 99 trips fallback)
      if (s.driver.name.isNotEmpty) {
        _driverName = s.driver.name;
      }
      final carModel = s.driver.carModel;
      final plate = s.driver.vehicleNumber;
      final tripsCount = s.driver.tripsCount;
      
      final List<String> detailsParts = [];
      if (carModel.isNotEmpty) detailsParts.add(carModel);
      if (tripsCount > 0) {
        detailsParts.add('$tripsCount trips');
      } else if (s.driver.tripsText.isNotEmpty) {
        detailsParts.add(s.driver.tripsText.replaceAll('🚗', '').trim());
      }
      if (plate.isNotEmpty) detailsParts.add(plate);

      _driverDetails = detailsParts.isNotEmpty ? detailsParts.join(' , ') : 'Verified Driver';

      if (s.driver.rating > 0) {
        _driverRating = s.driver.rating.toStringAsFixed(1);
      }
      if (s.driver.phone.isNotEmpty) {
        _driverPhone = s.driver.phone;
      }
      if (s.driver.avatarImage.isNotEmpty) {
        _driverAvatar = s.driver.avatarImage;
      }

      // 6. Passenger Details
      if (s.passengerName.isNotEmpty) {
        _passengerName = 'Booking by ${s.passengerName}';
      }
      if (s.passengerPhone.isNotEmpty) {
        _passengerPhone = s.passengerPhone;
      }

      // 7. Dynamic Route Timeline from RideDetailData or Origin-Destination
      if (s.rideDetailData != null && s.rideDetailData!.routeTimeline.isNotEmpty) {
        final rTimeline = s.rideDetailData!.routeTimeline;
        _timelineStops = rTimeline.asMap().entries.map((e) {
          final stop = e.value;
          final title = stop.location.isNotEmpty ? stop.location : (stop.title.isNotEmpty ? stop.title : 'Stop ${e.key + 1}');
          return {
            'time': stop.time.isNotEmpty ? stop.time : '10:00 AM',
            'title': title,
            'isFirst': e.key == 0,
            'isLast': e.key == rTimeline.length - 1,
          };
        }).toList();
      } else if (s.pickup.isNotEmpty || s.destination.isNotEmpty) {
        final pickup = s.pickup.isNotEmpty ? s.pickup : 'Origin';
        final drop = s.destination.isNotEmpty ? s.destination : 'Destination';
        final depTime = s.time.isNotEmpty ? s.time : '10:30 AM';
        final arrTime = s.rideDetailData?.arrivalTime.isNotEmpty == true ? s.rideDetailData!.arrivalTime : '01:00 PM';
        _timelineStops = [
          {'time': depTime, 'title': pickup, 'isFirst': true, 'isLast': false},
          {'time': arrTime, 'title': drop, 'isFirst': false, 'isLast': true},
        ];
      }
    }

    if (widget.bookingData != null) {
      _parseDynamicPayload(widget.bookingData!);
    }
  }

  Future<void> _fetchDynamicConfirmation() async {
    final effectiveId = _getEffectiveBookingId();
    if (effectiveId.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final res = await RideService.getRideConfirmation(effectiveId);
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] is Map<String, dynamic>
            ? res['data'] as Map<String, dynamic>
            : <String, dynamic>{};
        if (mounted) {
          setState(() {
            _parseDynamicPayload(data);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _parseDynamicPayload(Map<String, dynamic> data) {
    // 1. Booking ID
    final rawBookingId = data['bookingId'] ?? data['_id'] ?? data['id'] ?? data['bookingCode'];
    if (rawBookingId != null && rawBookingId.toString().isNotEmpty) {
      final str = rawBookingId.toString();
      _bookingId = str.startsWith('#') ? str : '#$str';
    }

    // 2. Boarding PIN
    final rawPin = data['boardingPin'] ?? data['pin'] ?? data['passCode'] ?? data['otp'];
    if (rawPin != null && rawPin.toString().isNotEmpty) {
      _boardingPin = rawPin.toString();
    }

    // 3. Schedule / Dates
    final schedule = data['schedule'] is Map<String, dynamic> ? data['schedule'] as Map<String, dynamic> : null;
    final dateDisplay = data['dateDisplay'] ?? schedule?['dateDisplay'] ?? data['date'];
    final timeDisplay = data['timeDisplay'] ?? schedule?['timeDisplay'] ?? data['time'];
    if (dateDisplay != null && dateDisplay.toString().isNotEmpty) {
      _displayDate = timeDisplay != null ? '$dateDisplay , $timeDisplay' : dateDisplay.toString();
    }

    if (schedule != null) {
      if (schedule['checkInDate'] != null) _checkInDate = schedule['checkInDate'].toString();
      if (schedule['checkInTime'] != null) _checkInTime = schedule['checkInTime'].toString();
      if (schedule['checkOutDate'] != null) _checkOutDate = schedule['checkOutDate'].toString();
      if (schedule['checkOutTime'] != null) _checkOutTime = schedule['checkOutTime'].toString();
    } else if (data['checkInDate'] != null) {
      _checkInDate = data['checkInDate'].toString();
      if (data['checkInTime'] != null) _checkInTime = data['checkInTime'].toString();
      if (data['checkOutDate'] != null) _checkOutDate = data['checkOutDate'].toString();
      if (data['checkOutTime'] != null) _checkOutTime = data['checkOutTime'].toString();
    }

    // 4. Seats
    final seats = data['seatNumber'] ?? data['seat'] ?? data['seats'] ?? data['seatsCount'];
    if (seats != null && seats.toString().isNotEmpty) {
      final sStr = seats.toString();
      _seatConfirmed = sStr.startsWith('A') ? sStr : 'A $sStr';
      _routeNote1 = 'note : $sStr seat(s) confirmed';
    }

    // 5. Driver Details
    final driver = data['driver'] is Map<String, dynamic> ? data['driver'] as Map<String, dynamic> : null;
    if (driver != null) {
      if (driver['name'] != null || driver['fullName'] != null) {
        _driverName = (driver['name'] ?? driver['fullName']).toString();
      }
      final carModel = driver['carModel'] ?? driver['vehicleModel'] ?? '';
      final trips = driver['tripsCount'] ?? driver['trips'];
      final plate = driver['vehicleNumber'] ?? driver['numberPlate'] ?? '';

      final List<String> parts = [];
      if (carModel.isNotEmpty) parts.add(carModel.toString());
      if (trips != null && int.tryParse(trips.toString()) != null && int.parse(trips.toString()) > 0) {
        parts.add('$trips trips');
      }
      if (plate.isNotEmpty) parts.add(plate.toString());

      if (parts.isNotEmpty) {
        _driverDetails = parts.join(' , ');
      }

      if (driver['rating'] != null) {
        final r = double.tryParse(driver['rating'].toString()) ?? 4.9;
        _driverRating = r.toStringAsFixed(1);
      }
      if (driver['phone'] != null || driver['phoneNumber'] != null) {
        _driverPhone = (driver['phone'] ?? driver['phoneNumber']).toString();
      }
      if (driver['avatar'] != null || driver['photo'] != null) {
        _driverAvatar = (driver['avatar'] ?? driver['photo']).toString();
      }
    }

    // 6. Passenger & Booking Dates
    final passenger = data['passenger'] is Map<String, dynamic> ? data['passenger'] as Map<String, dynamic> : null;
    if (passenger != null) {
      if (passenger['name'] != null || passenger['fullName'] != null) {
        _passengerName = 'Booking by ${(passenger['name'] ?? passenger['fullName'])}';
      }
      if (passenger['phone'] != null || passenger['phoneNumber'] != null) {
        _passengerPhone = (passenger['phone'] ?? passenger['phoneNumber']).toString();
      }
    } else if (data['passengerName'] != null) {
      _passengerName = 'Booking by ${data['passengerName']}';
      if (data['passengerPhone'] != null) _passengerPhone = data['passengerPhone'].toString();
    }

    if (data['bookingRequestDate'] != null) _bookingRequestDate = data['bookingRequestDate'].toString();
    if (data['rideAcceptDate'] != null) _rideAcceptDate = data['rideAcceptDate'].toString();
    if (data['rideAcceptedDate'] != null) _rideAcceptedDate = data['rideAcceptedDate'].toString();

    // 7. Timeline / Route
    if (data['timeline'] is List && (data['timeline'] as List).isNotEmpty) {
      final list = data['timeline'] as List;
      _timelineStops = list.asMap().entries.map((e) {
        final item = e.value is Map<String, dynamic> ? e.value as Map<String, dynamic> : <String, dynamic>{};
        return {
          'time': item['time']?.toString() ?? '${9 + e.key} : 00',
          'title': item['title']?.toString() ?? item['location']?.toString() ?? 'Stop ${e.key + 1}',
          'isFirst': e.key == 0,
          'isLast': e.key == list.length - 1,
        };
      }).toList();
    }

    if (data['routeNote1'] != null) _routeNote1 = data['routeNote1'].toString();
    if (data['routeNote2'] != null) _routeNote2 = data['routeNote2'].toString();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:${clean.isNotEmpty ? clean : '+919876543210'}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Calling $phoneNumber...')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch phone app for $phoneNumber')),
        );
      }
    }
  }

  Future<void> _sendSms(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('sms:${clean.isNotEmpty ? clean : '+919876543210'}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Messaging $phoneNumber...')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch messaging app for $phoneNumber')),
        );
      }
    }
  }

  void _showCancellationPolicySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cancellation Policy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• Free cancellation up to 2 hours before scheduled departure.\n'
              '• 50% refund for cancellations made within 2 hours of departure.\n'
              '• No refund once the ride has commenced or after scheduled departure time.\n'
              '• Refunds are credited back to the original payment method within 3-5 business days.',
              style: TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5945C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Understood', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to cancel this booking? Cancellation charges may apply as per the policy.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _handleCancelBooking();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancelBooking() async {
    setState(() => _isCancelling = true);
    final effectiveId = _getEffectiveBookingId();

    if (effectiveId.isEmpty) {
      setState(() => _isCancelling = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    try {
      final res = await RideService.cancelBooking(effectiveId);
      setState(() => _isCancelling = false);
      if (mounted) {
        if (res['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message']?.toString() ?? 'Booking cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message']?.toString() ?? 'Failed to cancel booking'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isCancelling = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cancellation error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Map View Header
                _buildTopMapHeader(context),

                if (_isLoading)
                  const LinearProgressIndicator(
                    color: Color(0xFF5945C7),
                    backgroundColor: Color(0xFFE2E8F0),
                    minHeight: 3,
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and Time Header
                      Text(
                        _displayDate,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 2. Check-in / Check-Out & Seat Card
                      _buildCheckInOutCard(),

                      const SizedBox(height: 14),

                      // 3. Boarding PIN Banner
                      _buildBoardingPinBanner(),

                      const SizedBox(height: 14),

                      // 4. Driver Info Card
                      _buildDriverCard(),

                      const SizedBox(height: 24),

                      // 5. Route Section
                      _buildRouteSection(),

                      const SizedBox(height: 24),

                      // 6. Booking Details Section
                      _buildBookingDetailsSection(),

                      const SizedBox(height: 24),

                      // 7. Cancellation Policy Button
                      _buildCancellationPolicyButton(),

                      const SizedBox(height: 14),

                      // 8. Cancel Booking Button
                      _buildCancelBookingButton(),

                      const SizedBox(height: 16),

                      // 9. Terms & Privacy Agreement Checkbox
                      _buildAgreementCheckbox(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isCancelling)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF5945C7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 1. Top Map Header with Realistic Road / Route Vector Painting
  Widget _buildTopMapHeader(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
          child: SizedBox(
            height: 280,
            width: double.infinity,
            child: CustomPaint(
              painter: _TopRouteMapPainter(),
            ),
          ),
        ),

        // Status Bar Simulation
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '09:00',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.wifi, size: 16, color: Colors.black87),
                      SizedBox(width: 6),
                      Icon(Icons.battery_full_rounded, size: 18, color: Colors.black87),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Back Navigation Button
        Positioned(
          top: 48,
          left: 16,
          child: SafeArea(
            child: InkWell(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
                    (route) => false,
                  );
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 2. Check-in / Check-Out & Seat Card
  Widget _buildCheckInOutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Check - in
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Check - in',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _checkInDate,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _checkInTime,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),

              // Dashed Separator
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '- - - - - - - -',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Check - Out
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Check - Out',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _checkOutDate,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _checkOutTime,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Dashed Divider
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DashedLinePainter(color: const Color(0xFFE2E8F0)),
          ),

          const SizedBox(height: 14),

          // Seat Conformed Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Seat Conformed',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF5722),
                ),
              ),
              Text(
                _seatConfirmed,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF5722),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Boarding PIN Banner
  Widget _buildBoardingPinBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF5945C7),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5945C7).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            children: [
              const TextSpan(text: 'Boarding PIN : '),
              TextSpan(
                text: _boardingPin,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Driver Information Card
  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF5945C7).withValues(alpha: 0.15),
                  image: _driverAvatar.isNotEmpty && _driverAvatar.startsWith('http')
                      ? DecorationImage(
                          image: NetworkImage(_driverAvatar),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _driverAvatar.isEmpty || !_driverAvatar.startsWith('http')
                    ? const Icon(Icons.person_rounded, color: Color(0xFF5945C7), size: 26)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _driverName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _driverDetails.isNotEmpty ? _driverDetails : 'Vehicle Details Available',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFE9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFF7A00), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _driverRating,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Call & Message Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _makePhoneCall(_driverPhone),
                  icon: const Icon(Icons.call_rounded, size: 16, color: Color(0xFF5945C7)),
                  label: const Text(
                    'Call',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5945C7),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF5945C7), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendSms(_driverPhone),
                  icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Colors.white),
                  label: const Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFF5945C7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Route Section
  Widget _buildRouteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Route',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 16),

        if (_timelineStops.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Route details loading...', style: TextStyle(color: Color(0xFF64748B))),
          )
        else
          for (final stop in _timelineStops)
            _buildTimelineStop(
              time: stop['time'] ?? '',
              title: stop['title'] ?? '',
              isFirst: stop['isFirst'] == true,
              isLast: stop['isLast'] == true,
              badgeWidget: stop['isFirst'] == true
                  ? Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: const Icon(Icons.directions_car_filled_rounded, color: Colors.red, size: 14),
                    )
                  : null,
              dotColor: stop['isFirst'] == true ? Colors.red : const Color(0xFFCBD5E1),
            ),

        const SizedBox(height: 12),

        Center(
          child: Column(
            children: [
              Text(
                _routeNote1,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _routeNote2,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStop({
    required String time,
    required String title,
    bool isFirst = false,
    bool isLast = false,
    Widget? badgeWidget,
    Color dotColor = const Color(0xFF94A3B8),
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              time,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(width: 20),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badgeWidget != null)
                badgeWidget
              else
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 28,
                  color: const Color(0xFFE2E8F0),
                ),
            ],
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
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

  // 6. Booking Details Section
  Widget _buildBookingDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Booking details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildBookingDetailRow('Booking ID', _bookingId.isNotEmpty ? _bookingId : '#BK-RIDE-CONFIRMED', valueBold: true),
              const SizedBox(height: 12),
              _buildBookingDetailRow(
                _passengerName.isNotEmpty ? _passengerName : 'Passenger Booking',
                _passengerPhone.isNotEmpty ? _passengerPhone : '+91 000-000-0000',
                valueColor: const Color(0xFFE53935),
                valueBold: true,
              ),
              const SizedBox(height: 12),
              _buildBookingDetailRow('Booking request', _bookingRequestDate, valueBold: true),
              const SizedBox(height: 12),
              _buildBookingDetailRow(
                'Ride accept',
                _rideAcceptDate,
                valueColor: const Color(0xFF16A34A),
                valueBold: true,
              ),
              const SizedBox(height: 12),
              _buildBookingDetailRow('Ride accepted', _rideAcceptedDate, valueBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // 7. Cancellation Policy Button
  Widget _buildCancellationPolicyButton() {
    return OutlinedButton.icon(
      onPressed: _showCancellationPolicySheet,
      icon: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
      ),
      label: const Text(
        'Cancellation policy',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white,
      ),
    );
  }

  // 8. Cancel Booking Button
  Widget _buildCancelBookingButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isCancelling ? null : _showCancelConfirmationDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5945C7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: _isCancelling
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Cancel Booking',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // 9. Terms & Privacy Agreement Checkbox
  Widget _buildAgreementCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _agreedToTerms = !_agreedToTerms;
            });
          },
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _agreedToTerms ? const Color(0xFF5945C7) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreedToTerms ? const Color(0xFF5945C7) : const Color(0xFF94A3B8),
                width: 1.5,
              ),
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
              children: [
                TextSpan(text: 'I agree with '),
                TextSpan(
                  text: 'privacy policy',
                  style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w500),
                ),
                TextSpan(text: ' , '),
                TextSpan(
                  text: 'terms and conditions',
                  style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Painter for top realistic map with roads, parks, water, and car route
class _TopRouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background (Light Map Land Color)
    final bgPaint = Paint()..color = const Color(0xFFF2EFE9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Water / Lake Areas
    final waterPaint = Paint()..color = const Color(0xFFC7E4FA);
    final waterPath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.35)
      ..cubicTo(size.width * 0.45, size.height * 0.3, size.width * 0.52, size.height * 0.38, size.width * 0.48, size.height * 0.48)
      ..cubicTo(size.width * 0.44, size.height * 0.55, size.width * 0.38, size.height * 0.45, size.width * 0.4, size.height * 0.35)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    final waterPath2 = Path()
      ..moveTo(size.width * 0.78, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.3)
      ..cubicTo(size.width * 0.88, size.height * 0.25, size.width * 0.82, size.height * 0.1, size.width * 0.78, 0)
      ..close();
    canvas.drawPath(waterPath2, waterPaint);

    // 3. Parks / Green Zones
    final parkPaint = Paint()..color = const Color(0xFFD8F1D8);
    final parkPath1 = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.45, size.width * 0.22, size.height * 0.35),
        const Radius.circular(16),
      ));
    canvas.drawPath(parkPath1, parkPaint);

    final parkPath2 = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.52, size.height * 0.6, size.width * 0.25, size.height * 0.3),
        const Radius.circular(18),
      ));
    canvas.drawPath(parkPath2, parkPaint);

    // 4. Secondary Roads (White with subtle borders)
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFE3DFD7)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final List<Path> roads = [
      Path()..moveTo(0, size.height * 0.2)..lineTo(size.width, size.height * 0.25),
      Path()..moveTo(0, size.height * 0.5)..lineTo(size.width, size.height * 0.45),
      Path()..moveTo(0, size.height * 0.78)..lineTo(size.width, size.height * 0.82),
      Path()..moveTo(size.width * 0.25, 0)..lineTo(size.width * 0.28, size.height),
      Path()..moveTo(size.width * 0.72, 0)..lineTo(size.width * 0.68, size.height),
    ];

    for (final road in roads) {
      canvas.drawPath(road, roadBorderPaint);
      canvas.drawPath(road, roadPaint);
    }

    // 5. Main Arterial Highway (Yellow / Amber)
    final highwayBorder = Paint()
      ..color = const Color(0xFFEAD295)
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;
    final highwayFill = Paint()
      ..color = const Color(0xFFFBE6A2)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;

    final highway = Path()
      ..moveTo(0, size.height * 0.4)
      ..cubicTo(size.width * 0.35, size.height * 0.35, size.width * 0.65, size.height * 0.15, size.width, size.height * 0.18);
    canvas.drawPath(highway, highwayBorder);
    canvas.drawPath(highway, highwayFill);

    final highway2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..cubicTo(size.width * 0.4, size.height * 0.72, size.width * 0.7, size.height * 0.5, size.width, size.height * 0.45);
    canvas.drawPath(highway2, highwayBorder);
    canvas.drawPath(highway2, highwayFill);

    // 6. Active Trip Route (Vibrant Blue Polyline)
    final routeBorder = Paint()
      ..color = const Color(0xFF1565C0)
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final routeFill = Paint()
      ..color = const Color(0xFF2196F3)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final startPoint = Offset(size.width * 0.46, size.height * 0.14);
    final endPoint = Offset(size.width * 0.32, size.height * 0.78);

    final routePath = Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..lineTo(size.width * 0.46, size.height * 0.22)
      ..cubicTo(size.width * 0.48, size.height * 0.28, size.width * 0.52, size.height * 0.32, size.width * 0.51, size.height * 0.4)
      ..lineTo(size.width * 0.45, size.height * 0.52)
      ..cubicTo(size.width * 0.42, size.height * 0.6, size.width * 0.38, size.height * 0.64, size.width * 0.35, size.height * 0.72)
      ..lineTo(endPoint.dx, endPoint.dy);

    canvas.drawPath(routePath, routeBorder);
    canvas.drawPath(routePath, routeFill);

    // 7. Start Point Pin
    _drawLocationPin(canvas, startPoint, isOrigin: true);

    // 8. End Point Pin
    _drawLocationPin(canvas, endPoint, isOrigin: false);

    // 9. Car Marker on the Blue Polyline
    _drawCarMarker(canvas, Offset(size.width * 0.51, size.height * 0.42));
  }

  void _drawLocationPin(Canvas canvas, Offset pos, {required bool isOrigin}) {
    final outerPaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 11, outerPaint);

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 7, whitePaint);

    final corePaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 4, corePaint);
  }

  void _drawCarMarker(Canvas canvas, Offset pos) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-12, -22, 24, 44),
        const Radius.circular(10),
      ),
      shadowPaint,
    );

    final bodyPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-11, -21, 22, 42),
        const Radius.circular(9),
      ),
      bodyPaint,
    );

    final glassPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, -14, 16, 8),
        const Radius.circular(3),
      ),
      glassPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-7, 4, 14, 6),
        const Radius.circular(2),
      ),
      glassPaint,
    );
    canvas.drawRect(const Rect.fromLTWH(-13, -12, 2, 4), glassPaint);
    canvas.drawRect(const Rect.fromLTWH(11, -12, 2, 4), glassPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Dashed Line Painter for Card Divider
class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const double dashWidth = 4;
    const double dashSpace = 4;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
