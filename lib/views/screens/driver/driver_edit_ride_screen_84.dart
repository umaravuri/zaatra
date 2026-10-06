import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/ride_service.dart';
import '../../widgets/location_autocomplete_picker_modal.dart';

class DriverEditRideScreen extends StatefulWidget {
  final Map<String, dynamic>? rideData;
  final String? rideId;

  const DriverEditRideScreen({
    super.key,
    this.rideData,
    this.rideId,
  });

  @override
  State<DriverEditRideScreen> createState() => _DriverEditRideScreenState();
}

class _DriverEditRideScreenState extends State<DriverEditRideScreen> {
  late TextEditingController _pickupController;
  late TextEditingController _pickupLandmarkController;
  late TextEditingController _destinationController;
  late TextEditingController _destinationLandmarkController;
  late TextEditingController _priceController;

  late int _price;
  late int _seats;
  late int _luggage;

  late DateTime _departureDate;
  late TimeOfDay _departureTime;

  // Preferences
  bool _autoApproval = true;
  bool _doorstepPickupDrop = true;
  bool _wifi = true;
  bool _usb = true;
  final List<Map<String, dynamic>> _customPreferences = [];

  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final ride = widget.rideData ?? {};

    // Price
    final rawPrice = ride['price'] ?? ride['pricePerSeat'] ?? 580;
    _price = int.tryParse(rawPrice.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 580;
    _priceController = TextEditingController(text: '$_price');

    // Seats & Luggage
    _seats = int.tryParse((ride['seats'] ?? 4).toString()) ?? 4;
    _luggage = int.tryParse((ride['maxLuggagePerPassenger'] ?? ride['luggageCount'] ?? 0).toString()) ?? 0;

    // Route / Address controllers
    final from = (ride['from'] ?? ride['pickupLocation'] ?? 'Mangalagiri Road, Vijayawada').toString();
    final pickupLandmark = (ride['pickupLandmark'] ?? '').toString();
    final to = (ride['to'] ?? ride['destinationLocation'] ?? 'Tirupati').toString();
    final destinationLandmark = (ride['destinationLandmark'] ?? '').toString();

    _pickupController = TextEditingController(text: from);
    _pickupLandmarkController = TextEditingController(text: pickupLandmark);
    _destinationController = TextEditingController(text: to);
    _destinationLandmarkController = TextEditingController(text: destinationLandmark);

    // Parse Departure Date
    _departureDate = _parseRideDateTime(ride) ?? DateTime.now().add(const Duration(days: 1));

    // Parse Departure Time
    _departureTime = _parseRideTimeOfDay(ride['departureTime']?.toString() ?? '09:00 AM');

    // Initial Preferences from ride data
    if (ride['preferences'] is Map) {
      final p = ride['preferences'] as Map;
      _autoApproval = p['autoApproval'] ?? p['auto_approval'] ?? _autoApproval;
      _doorstepPickupDrop = p['doorstepPickupDrop'] ?? p['doorstep_pickup_drop'] ?? _doorstepPickupDrop;
      _wifi = p['wifi'] ?? _wifi;
      _usb = p['usbCharging'] ?? p['usb_charging'] ?? p['usb'] ?? _usb;

      if (p['customPreferences'] is List) {
        for (final item in p['customPreferences'] as List) {
          if (item is Map) {
            _customPreferences.add({
              'title': item['title']?.toString() ?? '',
              'enabled': item['enabled'] == true,
            });
          }
        }
      }
    }

    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('driver_pref_save_enabled') && prefs.getBool('driver_pref_save_enabled') == true) {
        if (!mounted) return;
        setState(() {
          if (widget.rideData?['preferences'] == null) {
            _autoApproval = prefs.getBool('driver_pref_auto_approval') ?? _autoApproval;
            _doorstepPickupDrop = prefs.getBool('driver_pref_doorstep_pickup_drop') ?? _doorstepPickupDrop;
            _wifi = prefs.getBool('driver_pref_wifi') ?? _wifi;
            _usb = prefs.getBool('driver_pref_usb_charging') ?? _usb;
          }

          // Merge custom driver & customer preferences
          final List<String> listKeys = [
            'driver_pref_custom_driver_list',
            'driver_pref_custom_customer_list',
            'driver_pref_custom_features_list',
          ];

          for (final key in listKeys) {
            final raw = prefs.getString(key);
            if (raw != null && raw.isNotEmpty) {
              final decoded = jsonDecode(raw);
              if (decoded is List) {
                for (final item in decoded) {
                  if (item is Map && item['title'] != null) {
                    final title = item['title'].toString();
                    final bool alreadyExists = _customPreferences.any((e) => e['title'] == title);
                    if (!alreadyExists) {
                      _customPreferences.add({
                        'title': title,
                        'enabled': item['enabled'] == true,
                      });
                    }
                  }
                }
              }
            }
          }
        });
      }
    } catch (_) {}
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

  TimeOfDay _parseRideTimeOfDay(String timeStr) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPm = clean.contains('PM');
      final isAm = clean.contains('AM');

      final parts = clean.replaceAll(RegExp(r'[^0-9:]'), '').split(':');
      if (parts.isNotEmpty) {
        int hour = int.tryParse(parts[0]) ?? 9;
        int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

        if (isPm && hour < 12) hour += 12;
        if (isAm && hour == 12) hour = 0;

        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return const TimeOfDay(hour: 9, minute: 0);
  }

  String _formatDateDisplay(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '${dt.day.toString().padLeft(2, '0')} $monthName, ${dt.year} ( $dayName )';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _pickupLandmarkController.dispose();
    _destinationController.dispose();
    _destinationLandmarkController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupLocation() async {
    final picked = await LocationAutocompletePickerModal.show(
      context,
      title: 'Select Pickup Location',
      initialQuery: _pickupController.text,
      hintText: 'Search pickup area, landmark, or street...',
    );

    if (picked != null && mounted) {
      setState(() {
        _pickupController.text = picked.formattedAddress.isNotEmpty ? picked.formattedAddress : picked.name;
      });
    }
  }

  Future<void> _selectDestinationLocation() async {
    final picked = await LocationAutocompletePickerModal.show(
      context,
      title: 'Select Destination Location',
      initialQuery: _destinationController.text,
      hintText: 'Search destination city, area, or street...',
    );

    if (picked != null && mounted) {
      setState(() {
        _destinationController.text = picked.formattedAddress.isNotEmpty ? picked.formattedAddress : picked.name;
      });
    }
  }

  Future<void> _selectDepartureDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate.isBefore(DateTime.now()) ? DateTime.now() : _departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _departureDate = picked;
      });
    }
  }

  Future<void> _selectDepartureTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _departureTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _departureTime = picked;
      });
    }
  }

  void _showAddCustomPreferenceDialog() {
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final keyboardPadding = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: keyboardPadding + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add Custom Preference',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: textController,
                autofocus: true,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. Pet Friendly, Women Only, AC Non-Stop',
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.normal),
                  fillColor: const Color(0xFFFAFAFA),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        _customPreferences.add({
                          'title': text,
                          'enabled': true,
                        });
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add Preference', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updatePrice(int newPrice) {
    if (newPrice < 50) return;
    setState(() {
      _price = newPrice;
      _priceController.text = '$_price';
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    final effectiveRideId = widget.rideId ?? widget.rideData?['rideId'] ?? widget.rideData?['id'] ?? '';
    final departureTimeFormatted = _formatTimeOfDay(_departureTime);
    final departureDateIso = _departureDate.toIso8601String();
    final dateDisplayFormatted = _formatDateDisplay(_departureDate);

    final updatePayload = <String, dynamic>{
      'price': _price,
      'pricePerSeat': _price,
      'from': _pickupController.text.trim(),
      'pickupLocation': _pickupController.text.trim(),
      'pickupLandmark': _pickupLandmarkController.text.trim(),
      'to': _destinationController.text.trim(),
      'destinationLocation': _destinationController.text.trim(),
      'destinationLandmark': _destinationLandmarkController.text.trim(),
      'departureTime': departureTimeFormatted,
      'departureDate': departureDateIso,
      'date': dateDisplayFormatted,
      'dateDisplay': dateDisplayFormatted,
      'scheduledDate': departureDateIso,
      'seats': _seats,
      'maxLuggagePerPassenger': _luggage,
      'preferences': {
        'autoApproval': _autoApproval,
        'doorstepPickupDrop': _doorstepPickupDrop,
        'wifi': _wifi,
        'usbCharging': _usb,
        'luggageCount': _luggage,
        'customPreferences': _customPreferences,
      },
    };

    try {
      if (effectiveRideId.isNotEmpty) {
        await RideService.updateRide(
          rideId: effectiveRideId.toString(),
          updateData: updatePayload,
        );
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ride details updated successfully! 🎉'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context, {
      'edited': true,
      'rideId': effectiveRideId,
      'updatedPayload': updatePayload,
    });
  }

  Future<void> _confirmCancelRide() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Cancel Ride', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel and delete this upcoming ride? Passengers will be notified.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Ride', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel Ride', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      final effectiveRideId = widget.rideId ?? widget.rideData?['rideId'] ?? widget.rideData?['id'] ?? '';

      try {
        if (effectiveRideId.isNotEmpty) {
          await RideService.deleteRide(effectiveRideId.toString());
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() => _isDeleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upcoming Ride has been cancelled.'),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.pop(context, {
        'deleted': true,
        'rideId': effectiveRideId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.rideData ?? {};
    final fromName = _pickupController.text.isNotEmpty ? _pickupController.text.split(',').first : 'Origin';
    final toName = _destinationController.text.isNotEmpty ? _destinationController.text.split(',').first : 'Destination';
    final durationStr = (ride['duration'] ?? '5h 30m').toString();
    final arrivalTime = (ride['arrivalTime'] ?? '10:30 AM').toString();

    final dateDisplay = _formatDateDisplay(_departureDate);
    final departureTimeFormatted = _formatTimeOfDay(_departureTime);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
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
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Cancel Ride',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),

                  // Main Details Container
                  Container(
                    transform: Matrix4.translationValues(0, -12, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Route Overview Card
                        const Text(
                          'Route Overview',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F5FE),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withAlpha(30)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        dateDisplay,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(20),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      departureTimeFormatted,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      fromName,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(durationStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                  ),
                                  Expanded(
                                    child: Text(
                                      toName,
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(departureTimeFormatted, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                  const Text('• • • • • • •', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                  Text(arrivalTime, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Section 2: Edit Ride Date & Time
                        const Text(
                          'Ride Schedule (Date & Time)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            // Date Picker Card
                            Expanded(
                              child: InkWell(
                                onTap: _selectDepartureDate,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F5FE),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.primary.withAlpha(20)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Date', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${_departureDate.day} ${_getMonthAbbr(_departureDate.month)}, ${_departureDate.year}',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Time Picker Card
                            Expanded(
                              child: InkWell(
                                onTap: _selectDepartureTime,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F5FE),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.primary.withAlpha(20)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Time', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                            const SizedBox(height: 2),
                                            Text(
                                              departureTimeFormatted,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Section 3: Price Editing
                        const Text('Price per Seat (₹)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F5FE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => _updatePrice(_price - 20),
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.remove, color: AppColors.primary, size: 20),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('₹ ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  SizedBox(
                                    width: 90,
                                    child: TextField(
                                      controller: _priceController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (val) {
                                        final parsed = int.tryParse(val);
                                        if (parsed != null && parsed > 0) {
                                          _price = parsed;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () => _updatePrice(_price + 20),
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add, color: AppColors.primary, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Section 4: Location & Landmark Editing (Google Places Autocomplete Integrated)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pickup & Drop Locations',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, size: 12, color: AppColors.primary),
                                  SizedBox(width: 4),
                                  Text(
                                    'Google Maps',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        _buildLocationInputField(
                          label: 'Pickup Address',
                          controller: _pickupController,
                          icon: Icons.my_location_rounded,
                          hint: 'Search or enter pickup address',
                          onTapSearch: _selectPickupLocation,
                        ),
                        const SizedBox(height: 10),

                        _buildEditableInputField(
                          label: 'Pickup Landmark (Optional)',
                          controller: _pickupLandmarkController,
                          icon: Icons.pin_drop_outlined,
                          hint: 'e.g. Near bus stop, metro pillar',
                        ),
                        const SizedBox(height: 10),

                        _buildLocationInputField(
                          label: 'Destination Address',
                          controller: _destinationController,
                          icon: Icons.location_on_rounded,
                          hint: 'Search or enter destination address',
                          onTapSearch: _selectDestinationLocation,
                        ),
                        const SizedBox(height: 10),

                        _buildEditableInputField(
                          label: 'Destination Landmark (Optional)',
                          controller: _destinationLandmarkController,
                          icon: Icons.flag_outlined,
                          hint: 'e.g. Near railway station, airport',
                        ),

                        const SizedBox(height: 20),

                        // Section 5: Seats & Luggage
                        const Text('Available Seats & Luggage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _buildCounterTile(
                                label: 'Seats',
                                value: _seats,
                                icon: Icons.event_seat_rounded,
                                onIncrement: () => setState(() => _seats++),
                                onDecrement: () => setState(() {
                                  if (_seats > 1) _seats--;
                                }),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildCounterTile(
                                label: 'Luggage/pax',
                                value: _luggage,
                                icon: Icons.luggage_rounded,
                                onIncrement: () => setState(() => _luggage++),
                                onDecrement: () => setState(() {
                                  if (_luggage > 0) _luggage--;
                                }),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Section 6: Driver & Ride Preferences
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Driver & Ride Preferences',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            TextButton.icon(
                              onPressed: _showAddCustomPreferenceDialog,
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.primary),
                              label: const Text(
                                'Add Custom',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F5FE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildCheckboxRow('Auto approval of passenger', _autoApproval, (val) => setState(() => _autoApproval = val ?? false)),
                              const Divider(height: 16, color: Color(0xFFEADBFF)),
                              _buildCheckboxRow('Doorstep Pickup & Drop', _doorstepPickupDrop, (val) => setState(() => _doorstepPickupDrop = val ?? false)),
                              const Divider(height: 16, color: Color(0xFFEADBFF)),
                              _buildCheckboxRow('Wi-Fi Available', _wifi, (val) => setState(() => _wifi = val ?? false)),
                              const Divider(height: 16, color: Color(0xFFEADBFF)),
                              _buildCheckboxRow('USB Charging Port', _usb, (val) => setState(() => _usb = val ?? false)),

                              // Dynamic Custom Preferences loaded from preference page / added dynamically
                              if (_customPreferences.isNotEmpty) ...[
                                const Divider(height: 16, color: Color(0xFFEADBFF)),
                                ..._customPreferences.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final pref = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            pref['title']?.toString() ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            setState(() {
                                              _customPreferences.removeAt(idx);
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 6),
                                        Checkbox(
                                          value: pref['enabled'] == true,
                                          activeColor: AppColors.primary,
                                          onChanged: (val) {
                                            setState(() {
                                              _customPreferences[idx]['enabled'] = val ?? false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Save Changes Primary CTA Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            onPressed: _isSaving || _isDeleting ? null : _saveChanges,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Cancel/Delete Ride Secondary Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFBFA),
                              side: const BorderSide(color: Color(0xFFFFCDD2)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _isSaving || _isDeleting ? null : _confirmCancelRide,
                            icon: _isDeleting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2),
                                  )
                                : const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                            label: Text(
                              _isDeleting ? 'Cancelling Ride...' : 'Cancel & Delete Ride',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
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

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  Widget _buildLocationInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required VoidCallback onTapSearch,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        onTap: onTapSearch,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
            tooltip: 'Search with Google Maps',
            onPressed: onTapSearch,
          ),
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.normal),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEditableInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.normal),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCounterTile({
    required String label,
    required int value,
    required IconData icon,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onDecrement,
                child: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: AppColors.textSecondary),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text('$value', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
              InkWell(
                onTap: onIncrement,
                child: const Icon(Icons.add_circle_outline_rounded, size: 20, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ),
        Checkbox(
          value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
