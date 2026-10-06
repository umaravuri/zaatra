import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_button.dart';
import 'ride_search_map_screen_44.dart';

class RideSearchScreen extends StatefulWidget {
  final String? initialDestination;
  final String? initialPickup;

  const RideSearchScreen({
    super.key,
    this.initialDestination,
    this.initialPickup,
  });

  @override
  State<RideSearchScreen> createState() => _RideSearchScreenState();
}

class _RideSearchScreenState extends State<RideSearchScreen> {
  bool _isRideSelected = true;
  late final TextEditingController _pickupController;
  late final TextEditingController _destinationController;
  late String _date;
  late String _time;
  String _passengers = '2 Passengers';
  String _pickupPlaceholder = 'Enter pickup location';
  String _destPlaceholder = 'Enter destination location';
  List<Map<String, dynamic>> _popularRoutes = [];

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: widget.initialPickup ?? '');
    _destinationController = TextEditingController(text: widget.initialDestination ?? '');
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    _date = '${now.day} ${months[now.month - 1]} ${now.year}';
    _time = '09:30 AM';
    _loadSearchConfig();
  }

  Future<void> _loadSearchConfig() async {
    try {
      final res = await RideService.getSearchConfig();
      if (res['success'] == true && mounted) {
        setState(() {
          final p = res['placeholders'] ?? (res['data'] is Map ? res['data']['placeholders'] : null);
          if (p is Map) {
            _pickupPlaceholder = p['pickupLocation'] ?? p['pickup'] ?? _pickupPlaceholder;
            _destPlaceholder = p['destination'] ?? _destPlaceholder;
          }
          final defs = res['defaultValues'] ?? (res['data'] is Map ? res['data']['defaultValues'] : null);
          if (defs is Map && defs['passengers'] != null) {
            final pCount = defs['passengers'];
            _passengers = '$pCount Passenger${pCount > 1 ? 's' : ''}';
          }
          final q = res['quickOptions'] ?? (res['data'] is Map ? res['data']['quickOptions'] : null);
          if (q is Map && q['popularRoutes'] is List) {
            _popularRoutes = List<Map<String, dynamic>>.from(q['popularRoutes']);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
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

    if (picked != null) {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      setState(() {
        _date = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 30),
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

    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      setState(() {
        _time = '${hour.toString().padLeft(2, '0')}:$minute $period';
      });
    }
  }

  void _selectPassengers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                const SizedBox(height: 18),
                const Text(
                  'Select Number of Passengers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 14),
                ...[1, 2, 3, 4, 5, 6].map((count) {
                  final label = '$count ${count == 1 ? 'Passenger' : 'Passengers'}';
                  final isSelected = _passengers == label;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.inputBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_rounded, size: 20, color: isSelected ? Colors.white : AppColors.textSecondary),
                    ),
                    title: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _passengers = label;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isRideSelected = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: !_isRideSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Stay',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: !_isRideSelected ? AppColors.primary : Colors.white,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isRideSelected = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isRideSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Ride',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _isRideSelected ? AppColors.primary : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
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
                      children: [
                        // Pickup Location Input Card matching 42.png
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFF4CAF50), size: 24),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Pickup location', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _pickupController,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      decoration: InputDecoration(
                                        hintText: _pickupPlaceholder,
                                        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.normal),
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Destination Input Card matching 42.png
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFFE53935), size: 24),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Destination', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _destinationController,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      decoration: InputDecoration(
                                        hintText: _destPlaceholder,
                                        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.normal),
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Popular Quick-Routes Chips (from /api/rides/search-config)
                        if (_popularRoutes.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 34,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _popularRoutes.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, idx) {
                                final r = _popularRoutes[idx];
                                final from = r['from']?.toString() ?? '';
                                final to = r['to']?.toString() ?? '';
                                return ActionChip(
                                  label: Text(
                                    '$from → $to',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                                  ),
                                  backgroundColor: const Color(0xFFF3EDF7),
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  onPressed: () {
                                    setState(() {
                                      _pickupController.text = from;
                                      _destinationController.text = to;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Date & Time Row matching 42.png (Interactive)
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDate(context),
                                child: _buildPickerCard(
                                  title: 'Date',
                                  value: _date,
                                  icon: Icons.calendar_today_rounded,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectTime(context),
                                child: _buildPickerCard(
                                  title: 'Time',
                                  value: _time,
                                  icon: Icons.access_time_rounded,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Passenger Selector matching 42.png (Interactive)
                        GestureDetector(
                          onTap: () => _selectPassengers(context),
                          child: _buildSelectionRow('Passenger', _passengers),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Search Ride CTA
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    text: 'Search Ride',
                    onPressed: () {
                      final pickupText = _pickupController.text.trim();
                      final destText = _destinationController.text.trim();

                      if (pickupText.isEmpty || destText.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter pickup and destination locations.'), backgroundColor: Colors.red),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RideSearchMapScreen(
                            pickup: pickupText,
                            destination: destText,
                            date: _date,
                            time: _time,
                            passengers: _passengers,
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

  Widget _buildPickerCard({required String title, required String value, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (icon != null) Icon(icon, size: 16, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}
