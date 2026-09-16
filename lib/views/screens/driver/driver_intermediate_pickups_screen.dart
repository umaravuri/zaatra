import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/intermediate_pickup_model.dart';
import '../../../models/place_location_model.dart';
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

  const DriverIntermediatePickupsScreen({
    Key? key,
    this.pickup,
    this.destination,
    this.route,
    this.date,
    this.selectedDateTime,
    this.time,
    this.seats,
    this.fare,
    this.luggage,
  }) : super(key: key);

  @override
  State<DriverIntermediatePickupsScreen> createState() => _DriverIntermediatePickupsScreenState();
}

/// Helper controller container for managing dynamic intermediate pickup cards
class _PickupCardControllers {
  final TextEditingController locationController;
  final TextEditingController pinCodeController;
  final TextEditingController landmarkController;
  final TextEditingController priceController;
  String? selectedTime;
  LocationPoint? resolvedLocation;

  _PickupCardControllers({
    String initialLocation = '',
    String initialPinCode = '',
    String initialLandmark = '',
    String initialPrice = '',
    this.selectedTime,
  })  : locationController = TextEditingController(text: initialLocation),
        pinCodeController = TextEditingController(text: initialPinCode),
        landmarkController = TextEditingController(text: initialLandmark),
        priceController = TextEditingController(text: initialPrice);

  void dispose() {
    locationController.dispose();
    pinCodeController.dispose();
    landmarkController.dispose();
    priceController.dispose();
  }

  IntermediatePickupModel toModel() {
    return IntermediatePickupModel(
      location: locationController.text.trim(),
      pinCode: pinCodeController.text.trim(),
      landmark: landmarkController.text.trim().isNotEmpty ? landmarkController.text.trim() : null,
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

  @override
  void initState() {
    super.initState();
    // Initialize with 1 intermediate pickup card
    _addNewPickup(scrollToBottom: false);
  }

  @override
  void dispose() {
    for (final card in _pickups) {
      card.dispose();
    }
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
          card.pinCodeController.text.trim().isNotEmpty ||
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
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.alt_route_rounded, color: AppColors.primary, size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Add pickup points along your route to pick up more passengers and earn extra.',
                            style: TextStyle(
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
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

          // 1. Location Field
          _buildFieldLabel('Location'),
          const SizedBox(height: 6),
          TextFormField(
            controller: card.locationController,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter pickup location',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFF4CAF50), size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                onPressed: () => _pickLocationForCard(index),
              ),
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

          const SizedBox(height: 12),

          // 2. PIN Code Field (Numeric, 6 Digits)
          _buildFieldLabel('PIN Code'),
          const SizedBox(height: 6),
          TextFormField(
            controller: card.pinCodeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter PIN code',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.pin_drop_outlined, color: AppColors.primary, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter PIN code';
              }
              if (val.trim().length != 6) {
                return 'PIN code must be exactly 6 digits';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // 3. Landmark Field (Optional)
          _buildFieldLabel('Landmark (Optional)', isOptional: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: card.landmarkController,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter landmark',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.flag_outlined, color: AppColors.textSecondary, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),

          const SizedBox(height: 12),

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
                    _buildFieldLabel('Price'),
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

  Widget _buildFieldLabel(String label, {bool isOptional = false}) {
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
