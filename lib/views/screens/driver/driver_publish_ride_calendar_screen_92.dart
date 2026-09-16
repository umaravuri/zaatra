import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import 'driver_customer_preferences_screen_93.dart';

class DriverPublishRideCalendarScreen extends StatefulWidget {
  final Map<String, dynamic>? rideDetails;

  const DriverPublishRideCalendarScreen({
    super.key,
    this.rideDetails,
  });

  @override
  State<DriverPublishRideCalendarScreen> createState() => _DriverPublishRideCalendarScreenState();
}

class _DriverPublishRideCalendarScreenState extends State<DriverPublishRideCalendarScreen> {
  int _selectedSeats = 4;
  late DateTime _selectedDate;
  List<Map<String, dynamic>> _existingDriverRides = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _loadExistingDriverRides();
  }

  Future<void> _loadExistingDriverRides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = await AuthService.getCurrentUser();
      final phone = prefs.getString('currentPhone') ?? user?['phone']?.toString() ?? '';
      final cleanDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');

      final res = await ApiService.get('/rides');
      if (res['success'] == true && res['rides'] is List) {
        final allRides = List<Map<String, dynamic>>.from(res['rides']);
        final filtered = allRides.where((r) {
          final driverPhone = (r['driverPhone'] ?? r['phone'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
          if (cleanDigits.isNotEmpty && driverPhone.isNotEmpty) {
            return driverPhone.contains(cleanDigits) || cleanDigits.contains(driverPhone);
          }
          return true;
        }).toList();

        if (mounted) {
          setState(() {
            _existingDriverRides = filtered;
          });
        }
      }
    } catch (_) {}
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[(month - 1) % 12];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final pickupName = widget.rideDetails?['pickupLocation'] ?? 'Mangalagiri Road';
    final destinationName = widget.rideDetails?['destinationLocation'] ?? 'Tirupati';
    final intermediateCities = List<String>.from(widget.rideDetails?['selectedCities'] ?? ['Guntur', 'Ongole']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Date & Passengers',
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
            SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Month Calendar Header
              _buildMonthHeader('${_getMonthName(now.month)} ${now.year}'),
              const SizedBox(height: 12),
              _buildCalendarGrid(year: now.year, month: now.month),

              const SizedBox(height: 24),

              // Next Month Calendar Header
              _buildMonthHeader('${_getMonthName(nextMonth.month)} ${nextMonth.year}'),
              const SizedBox(height: 12),
              _buildCalendarGrid(year: nextMonth.year, month: nextMonth.month),

              const SizedBox(height: 24),

              // Passengers Section Title matching 92.png
              const Text(
                'Available Passenger Seats',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  ...List.generate(
                    _selectedSeats,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildPassengerIcon(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDF7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            if (_selectedSeats > 1) {
                              setState(() => _selectedSeats--);
                            }
                          },
                          child: const Icon(Icons.remove, size: 18, color: AppColors.primary),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '$_selectedSeats',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (_selectedSeats < 6) {
                              setState(() => _selectedSeats++);
                            }
                          },
                          child: const Icon(Icons.add, size: 18, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Instructions Section matching 92.png
              const Text(
                'Instructions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text('• Prefer max 2 members in back seats', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text('• Instant booking review for every request', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),

              const SizedBox(height: 24),

              // Prices List Section matching 92.png
              const Text(
                'Prices List (Auto-Calculated by Distance)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              _buildPriceTile(pickupName, '₹850'),
              const SizedBox(height: 8),
              ...intermediateCities.map((city) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildPriceTile(city, '₹750'),
                  )),
              _buildPriceTile(destinationName, '₹850'),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Prices are auto calculated and adjusted to nearby highway toll rates',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 24),

              // Primary CTA Button "Next" matching 92.png
              CustomButton(
                text: 'Next',
                onPressed: _handleNext,
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    // 1. Check if driver already has an active or scheduled ride on the same calendar date
    Map<String, dynamic>? duplicateRide;

    for (final ride in _existingDriverRides) {
      final status = (ride['status']?.toString().toLowerCase()) ?? '';
      if (status == 'cancelled' || status == 'completed' || status == 'finished' || status == 'rejected') {
        continue;
      }

      DateTime? rideDate;
      if (ride['departs'] != null) {
        rideDate = DateTime.tryParse(ride['departs'].toString());
      }
      if (rideDate == null && ride['departureDate'] != null) {
        final parts = ride['departureDate'].toString().split(RegExp(r'[\s\-/]+'));
        if (parts.length >= 3) {
          final d = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final y = int.tryParse(parts[2]);
          if (d != null && m != null && y != null) {
            rideDate = DateTime(y, m, d);
          }
        }
      }

      if (rideDate != null) {
        if (rideDate.year == _selectedDate.year &&
            rideDate.month == _selectedDate.month &&
            rideDate.day == _selectedDate.day) {
          duplicateRide = ride;
          break;
        }
      }
    }

    if (duplicateRide != null) {
      final pickup = (duplicateRide['pickupLocation'] ?? duplicateRide['from'] ?? 'Origin').toString().split(',').first;
      final destination = (duplicateRide['destinationLocation'] ?? duplicateRide['to'] ?? 'Destination').toString().split(',').first;
      final time = duplicateRide['departureTime'] ?? '';
      final formattedDate = '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';

      _showDuplicateRideDialog(
        dateStr: formattedDate,
        routeSummary: '$pickup ➔ $destination${time.isNotEmpty ? " ($time)" : ""}',
      );
    } else {
      _navigateToPreferences();
    }
  }

  void _showDuplicateRideDialog({
    required String dateStr,
    required String routeSummary,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Ride Already Scheduled',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You already have a ride scheduled on $dateStr:',
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDF7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      routeSummary,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to publish another ride on the same date?',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Change Date', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _navigateToPreferences();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Proceed Anyway', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToPreferences() {
    final updatedDetails = Map<String, dynamic>.from(widget.rideDetails ?? {});
    updatedDetails['seats'] = _selectedSeats;
    updatedDetails['departs'] = _selectedDate.toIso8601String();
    updatedDetails['departureDate'] = '${_selectedDate.day} - ${_selectedDate.month} - ${_selectedDate.year}';
    updatedDetails['pricePerSeat'] = 850;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverCustomerPreferencesScreen(
          rideDetails: updatedDetails,
        ),
      ),
    );
  }

  Widget _buildMonthHeader(String monthTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
        Text(monthTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary),
      ],
    );
  }

  Widget _buildCalendarGrid({required int year, required int month}) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday % 7;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.map((d) => SizedBox(width: 32, child: Text(d, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)))).toList(),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            ...List.generate(firstWeekday, (_) => const SizedBox(width: 32, height: 32)),
            ...List.generate(daysInMonth, (index) {
              final dayNumber = index + 1;
              final thisDate = DateTime(year, month, dayNumber);
              final isPast = thisDate.isBefore(today);
              final isSelected = _selectedDate.year == year &&
                  _selectedDate.month == month &&
                  _selectedDate.day == dayNumber;

              return GestureDetector(
                onTap: isPast
                    ? null
                    : () {
                        setState(() {
                          _selectedDate = thisDate;
                        });
                      },
                child: _buildDayCell(
                  '$dayNumber',
                  isSelected: isSelected,
                  isPast: isPast,
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildDayCell(String day, {bool isSelected = false, bool isPast = false}) {
    Color textColor = AppColors.textPrimary;
    Color bgColor = Colors.transparent;

    if (isSelected) {
      bgColor = AppColors.primary;
      textColor = Colors.white;
    } else if (isPast) {
      textColor = Colors.grey.shade400;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerIcon() {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
    );
  }

  Widget _buildPriceTile(String city, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDF7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Text(city, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          Row(
            children: [
              Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(width: 6),
              const Icon(Icons.unfold_more_rounded, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
