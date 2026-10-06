import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/intermediate_pickup_model.dart';
import '../../../models/place_location_model.dart';
import '../../../models/ride_booking_model.dart';
import '../../../services/ride_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/location_autocomplete_picker_modal.dart';
import 'driver_route_preview_screen_32.dart';

/// Screen allowing the driver to add one or more intermediate pickup points
/// along the route before reaching the final destination.
class DriverIntermediatePickupsScreen extends StatefulWidget {
  final LocationPoint? pickup;
  final LocationPoint? destination;
  final RouteResult? route;
  final String? date;
  final DateTime? selectedDateTime;
  final String? time;
  final String? seats;
  final String? fare;
  final String? luggage;
  final double? basePricePerKm;
  final double? pricePerSeat;
  final bool? offerDoorstepPickupDrop;
  final double? detourRadiusKm;
  final double? detourRatePerKm;

  const DriverIntermediatePickupsScreen({
    super.key,
    this.pickup,
    this.destination,
    this.route,
    this.date,
    this.selectedDateTime,
    this.time,
    this.seats,
    this.fare,
    this.luggage,
    this.basePricePerKm,
    this.pricePerSeat,
    this.offerDoorstepPickupDrop,
    this.detourRadiusKm,
    this.detourRatePerKm,
  });

  @override
  State<DriverIntermediatePickupsScreen> createState() => _DriverIntermediatePickupsScreenState();
}

/// Helper controller container for managing dynamic intermediate pickup cards
class _PickupCardControllers {
  final TextEditingController locationController;
  final TextEditingController priceController;
  String? selectedTime;
  LocationPoint? resolvedLocation;
  String? suggestedFareText;
  double? suggestedPrice;

  _PickupCardControllers({
    String initialLocation = '',
    String initialPrice = '',
    this.selectedTime,
  })  : locationController = TextEditingController(text: initialLocation),
        priceController = TextEditingController(text: initialPrice);

  void dispose() {
    locationController.dispose();
    priceController.dispose();
  }

  IntermediatePickupModel toModel() {
    return IntermediatePickupModel(
      location: locationController.text.trim(),
      time: selectedTime ?? '',
      price: priceController.text.trim(),
      locationPoint: resolvedLocation,
    );
  }
}

class _DriverIntermediatePickupsScreenState extends State<DriverIntermediatePickupsScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final List<_PickupCardControllers> _pickups = [];
  bool _isCalculatingFares = false;
  IntermediateFareResult? _fareResult;

  // Offer Doorstep Pickup & Drop State
  bool _offerDoorstep = false;
  final TextEditingController _detourRadiusController = TextEditingController();
  final TextEditingController _detourRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _offerDoorstep = widget.offerDoorstepPickupDrop ?? false;
    if (widget.detourRadiusKm != null && widget.detourRadiusKm! > 0) {
      _detourRadiusController.text = widget.detourRadiusKm.toString().replaceAll(RegExp(r'\.0$'), '');
    }
    if (widget.detourRatePerKm != null && widget.detourRatePerKm! > 0) {
      _detourRateController.text = widget.detourRatePerKm.toString().replaceAll(RegExp(r'\.0$'), '');
    }
    // Initialize with 1 intermediate pickup card
    _addNewPickup(scrollToBottom: false);
  }

  @override
  void dispose() {
    for (final card in _pickups) {
      card.dispose();
    }
    _detourRadiusController.dispose();
    _detourRateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addNewPickup({bool scrollToBottom = true}) {
    setState(() {
      _pickups.add(
        _PickupCardControllers(
          selectedTime: widget.time ?? '09:30 AM',
        ),
      );
    });

    if (scrollToBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 220,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _removePickup(int index) {
    if (_pickups.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one pickup point card is required. You can leave fields empty to skip intermediate stops.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      final removed = _pickups.removeAt(index);
      removed.dispose();
    });
    _autoCalculateFares();
  }

  Future<void> _pickLocationForCard(int index) async {
    final picked = await LocationAutocompletePickerModal.show(
      context,
      title: 'Select Intermediate Pickup',
      initialQuery: _pickups[index].locationController.text,
    );

    if (picked != null && mounted) {
      setState(() {
        _pickups[index].locationController.text = picked.name;
        _pickups[index].resolvedLocation = picked;
      });
      _autoCalculateFares();
    }
  }

  Future<void> _autoCalculateFares() async {
    final from = widget.pickup?.name ?? (widget.route?.startAddress.isNotEmpty == true ? widget.route!.startAddress : 'Origin');
    final to = widget.destination?.name ?? (widget.route?.endAddress.isNotEmpty == true ? widget.route!.endAddress : 'Destination');
    final basePrice = double.tryParse(widget.fare?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '') ?? 500.0;

    final stopsPayload = _pickups
        .where((p) => p.locationController.text.trim().isNotEmpty)
        .map((p) => {'location': p.locationController.text.trim()})
        .toList();

    if (stopsPayload.isEmpty) return;

    setState(() => _isCalculatingFares = true);

    final res = await RideService.calculateIntermediateFares(
      from: from,
      to: to,
      price: basePrice,
      intermediatePickups: stopsPayload,
    );

    if (mounted) {
      setState(() {
        _isCalculatingFares = false;
        if (res['success'] == true) {
          _fareResult = IntermediateFareResult.fromJson(res);
          for (int i = 0; i < _pickups.length; i++) {
            final cardLoc = _pickups[i].locationController.text.trim().toLowerCase();
            if (cardLoc.isEmpty) continue;

            final matched = _fareResult!.intermediatePickups.firstWhere(
              (stop) => stop.location.toLowerCase() == cardLoc || cardLoc.contains(stop.location.toLowerCase()),
              orElse: () => (i < _fareResult!.intermediatePickups.length)
                  ? _fareResult!.intermediatePickups[i]
                  : const IntermediateStopFare(),
            );

            if (matched.price > 0 || matched.suggestedPriceToDestination > 0) {
              final targetPrice = matched.price > 0 ? matched.price : matched.suggestedPriceToDestination;
              _pickups[i].suggestedPrice = targetPrice;
              _pickups[i].suggestedFareText = matched.amountText.isNotEmpty ? matched.amountText : '₹ ${targetPrice.toInt()}';
              if (_pickups[i].priceController.text.trim().isEmpty) {
                _pickups[i].priceController.text = targetPrice.toInt().toString();
              }
            }
          }
        }
      });
    }
  }

  Future<void> _pickTimeForCard(int index) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
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
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      setState(() {
        _pickups[index].selectedTime = '${hour.toString().padLeft(2, '0')}:$minute $period';
      });
    }
  }

  void _handleContinue() {
    // Check if any card has been partially filled
    bool hasAnyEntry = false;
    for (final card in _pickups) {
      if (card.locationController.text.trim().isNotEmpty ||
          card.priceController.text.trim().isNotEmpty) {
        hasAnyEntry = true;
        break;
      }
    }

    List<IntermediatePickupModel> validPickups = [];

    if (hasAnyEntry) {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete all required fields for intermediate pickups.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Check time selection
      for (int i = 0; i < _pickups.length; i++) {
        if (_pickups[i].selectedTime == null || _pickups[i].selectedTime!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select time for Intermediate Pickup ${i + 1}.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
      }

      validPickups = _pickups.map((c) => c.toModel()).toList();
    }

    // =========================================================================
    // 🚀 FUTURE BACKEND API INTEGRATION POINT:
    // When the backend developer provides the POST endpoint for intermediate pickups:
    //
    // Endpoint: POST /api/driver/rides/intermediate-pickups
    // Payload Structure:
    // {
    //    "intermediatePickups": [
    //        {
    //            "location": "Ameerpet Metro",
    //            "pinCode": "500038",
    //            "landmark": "Near Gate 2",
    //            "time": "09:30 AM",
    //            "price": 150.0
    //        }
    //    ]
    // }
    // =========================================================================
    final Map<String, dynamic> structuredPayload = {
      'intermediatePickups': validPickups.map((p) => p.toJson()).toList(),
    };
    debugPrint('Intermediate Pickups Ready for POST API: $structuredPayload');

    if (_offerDoorstep) {
      final detourRadius = double.tryParse(_detourRadiusController.text.trim()) ?? 0;
      if (_detourRadiusController.text.trim().isEmpty || detourRadius <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter detour radius (km).'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final detourRate = double.tryParse(_detourRateController.text.trim()) ?? 0;
      if (_detourRateController.text.trim().isEmpty || detourRate <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter detour rate (Rs/km).'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    final detourRadiusVal = _offerDoorstep ? (double.tryParse(_detourRadiusController.text.trim()) ?? 0.0) : 0.0;
    final detourRateVal = _offerDoorstep ? (double.tryParse(_detourRateController.text.trim()) ?? 0.0) : 0.0;

    // Forward seamlessly to Route Preview Screen (Screen 32)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverRoutePreviewScreen(
          pickup: widget.pickup,
          destination: widget.destination,
          route: widget.route,
          date: widget.date,
          selectedDateTime: widget.selectedDateTime,
          time: widget.time,
          seats: widget.seats,
          fare: widget.fare,
          luggage: widget.luggage,
          basePricePerKm: widget.basePricePerKm,
          pricePerSeat: widget.pricePerSeat,
          offerDoorstepPickupDrop: _offerDoorstep,
          detourRadiusKm: detourRadiusVal,
          detourRatePerKm: detourRateVal,
          intermediatePickups: validPickups,
        ),
      ),
    );
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
          'Intermediate Pickups',
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
            // Bottom Background Graphic matching driver flow style
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

            // Scrollable Content
            Form(
              key: _formKey,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                children: [
                  // Subtitle info card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDF7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        if (_isCalculatingFares)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        else
                          const Icon(Icons.alt_route_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isCalculatingFares
                                ? 'Calculating suggested fares based on route distance...'
                                : 'Add pickup points along your route to pick up more passengers and earn extra.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Dynamic list of Pickup Cards
                  ...List.generate(_pickups.length, (index) {
                    return _buildPickupCard(index);
                  }),

                  const SizedBox(height: 8),

                  // "+ Add another pickup" Button
                  InkWell(
                    onTap: () => _addNewPickup(scrollToBottom: true),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '+ Add another pickup',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🚗 Offer Doorstep Pickup & Drop Card (Dynamically positioned below pickups)
                  _buildDoorstepCard(),

                  const SizedBox(height: 28),

                  // Bottom Continue Button
                  CustomButton(
                    text: 'Continue',
                    onPressed: _handleContinue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoorstepCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _offerDoorstep ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offer Doorstep Pickup & Drop',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Allow passengers pickup/drop at their doorstep',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch.adaptive(
                  value: _offerDoorstep,
                  activeTrackColor: AppColors.primary,
                  activeThumbColor: Colors.white,
                  onChanged: (val) {
                    setState(() {
                      _offerDoorstep = val;
                      if (_offerDoorstep) {
                        if (_detourRadiusController.text.trim().isEmpty) {
                          _detourRadiusController.text = '5';
                        }
                        if (_detourRateController.text.trim().isEmpty) {
                          _detourRateController.text = '15';
                        }
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Detour radius (km)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _offerDoorstep ? Colors.white : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _offerDoorstep ? AppColors.border : Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detour radius (km)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _offerDoorstep ? AppColors.textSecondary : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      TextField(
                        controller: _detourRadiusController,
                        enabled: _offerDoorstep,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _offerDoorstep ? AppColors.textPrimary : Colors.grey.shade500,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 2),
                          hintText: 'e.g. 5',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: _offerDoorstep ? AppColors.textSecondary : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Detour rate (Rs/km)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _offerDoorstep ? Colors.white : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _offerDoorstep ? AppColors.border : Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detour rate (Rs/km)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _offerDoorstep ? AppColors.textSecondary : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '₹ ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _offerDoorstep ? AppColors.textPrimary : Colors.grey.shade500,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _detourRateController,
                              enabled: _offerDoorstep,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _offerDoorstep ? AppColors.textPrimary : Colors.grey.shade500,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 2),
                                hintText: 'e.g. 15',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  color: _offerDoorstep ? AppColors.textSecondary : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard(int index) {
    final card = _pickups[index];
    final cardNum = index + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with Title & Delete Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#$cardNum',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Intermediate Pickup $cardNum',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (_pickups.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Remove pickup',
                  onPressed: () => _removePickup(index),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // 1. Location Field (Tap to open Autocomplete Search)
          _buildFieldLabel('Location'),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _pickLocationForCard(index),
            borderRadius: BorderRadius.circular(12),
            child: IgnorePointer(
              child: TextFormField(
                controller: card.locationController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search or select pickup location',
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFF4CAF50), size: 20),
                  suffixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter pickup location';
                  }
                  return null;
                },
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 4. Time & Price Row
          Row(
            children: [
              // Expected Pickup Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Time'),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _pickTimeForCard(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                card.selectedTime ?? 'Select time',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: card.selectedTime != null ? AppColors.textPrimary : AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Pickup Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildFieldLabel('Price'),
                        if (card.suggestedFareText != null && card.suggestedFareText!.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${card.suggestedFareText})',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: card.priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Enter price',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 12, right: 4),
                          child: Center(
                            widthFactor: 0.0,
                            child: Text('₹', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter price';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
