import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/intermediate_pickup_model.dart';
import '../../../models/place_location_model.dart';
import '../../../services/google_maps_service.dart';
import '../../widgets/custom_button.dart';
// import '../../widgets/location_autocomplete_picker_modal.dart';
// import '../../widgets/route_map_webview.dart';
import 'driver_customer_preferences_screen_93.dart';

class DriverRoutePreviewScreen extends StatefulWidget {
  final LocationPoint? pickup;
  final LocationPoint? destination;
  final RouteResult? route;
  final String? date;
  final DateTime? selectedDateTime;
  final String? time;
  final String? seats;
  final String? fare;
  final String? luggage;
  final String? preference;
  final double? basePricePerKm;
  final double? pricePerSeat;
  final bool? offerDoorstepPickupDrop;
  final double? detourRadiusKm;
  final double? detourRatePerKm;
  final List<IntermediatePickupModel>? intermediatePickups;

  const DriverRoutePreviewScreen({
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
    this.preference,
    this.basePricePerKm,
    this.pricePerSeat,
    this.offerDoorstepPickupDrop,
    this.detourRadiusKm,
    this.detourRatePerKm,
    this.intermediatePickups,
  });

  @override
  State<DriverRoutePreviewScreen> createState() => _DriverRoutePreviewScreenState();
}

class _DriverRoutePreviewScreenState extends State<DriverRoutePreviewScreen> {
  late LocationPoint _pickup;
  late LocationPoint _destination;
  RouteResult? _routeResult;
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _pickup = widget.pickup ??
        const LocationPoint(
          name: 'Pickup Location',
          formattedAddress: '',
          latitude: 0.0,
          longitude: 0.0,
        );

    _destination = widget.destination ??
        const LocationPoint(
          name: 'Destination Location',
          formattedAddress: '',
          latitude: 0.0,
          longitude: 0.0,
        );

    _routeResult = widget.route;

    if (_routeResult == null && _pickup.latitude != 0.0 && _destination.latitude != 0.0) {
      _fetchDirections();
    }
  }

  Future<void> _fetchDirections() async {
    setState(() {
      _isLoadingRoute = true;
    });

    final result = await GoogleMapsService.getDirections(
      originLat: _pickup.latitude,
      originLng: _pickup.longitude,
      destLat: _destination.latitude,
      destLng: _destination.longitude,
    );

    if (!mounted) return;
    setState(() {
      _isLoadingRoute = false;
      if (result != null) {
        _routeResult = result;
      }
    });
  }

  /*
  Future<void> _searchAlongRoute(String category) async {
    final picked = await LocationAutocompletePickerModal.show(
      context,
      title: 'Find $category along route',
      initialQuery: category == 'Custom' ? '' : '$category near ${_pickup.name}',
      hintText: 'Search $category near route...',
    );

    if (picked != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected stop: ${picked.name}'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
  */

  Future<void> _goToNext() async {
    // Parse seats count
    int seatCount = 3;
    if (widget.seats != null) {
      final digits = RegExp(r'\d+').stringMatch(widget.seats!);
      if (digits != null) seatCount = int.tryParse(digits) ?? 3;
    }

    // Parse fare value
    double parsedFare = 500;
    if (widget.fare != null) {
      final digits = RegExp(r'\d+').stringMatch(widget.fare!);
      if (digits != null) parsedFare = double.tryParse(digits) ?? 500;
    }

    // Build intermediate pickups array
    final List<Map<String, dynamic>> dynamicIntermediatePickups = (widget.intermediatePickups ?? []).map((p) {
      return {
        'location': p.location,
        'pincode': p.pinCode.isNotEmpty ? p.pinCode : '500038',
        'landmark': p.landmark ?? '',
        'time': p.time.isNotEmpty ? p.time : (widget.time ?? '09:30 AM'),
        'price': double.tryParse(p.price) ?? (parsedFare > 100 ? parsedFare - 100 : parsedFare),
      };
    }).toList();

    // Build route timeline plan
    final List<Map<String, dynamic>> routePlan = [];
    routePlan.add({
      'location': _pickup.formattedAddress.isNotEmpty ? _pickup.formattedAddress : _pickup.name,
      'pincode': '522503',
      'time': widget.time ?? '06:00 AM',
      'type': 'start',
    });

    for (final p in (widget.intermediatePickups ?? [])) {
      routePlan.add({
        'location': p.location,
        'pincode': p.pinCode.isNotEmpty ? p.pinCode : '500038',
        'time': p.time.isNotEmpty ? p.time : (widget.time ?? '07:30 AM'),
        'type': 'pickup',
        'landmark': p.landmark ?? '',
      });
    }

    routePlan.add({
      'location': _destination.formattedAddress.isNotEmpty ? _destination.formattedAddress : _destination.name,
      'pincode': '517501',
      'time': '10:30 AM',
      'type': 'destination',
    });

    final displayDistance = _routeResult?.distanceText ?? '15.4 km';
    final displayDuration = _routeResult?.durationText ?? '40 min';

    final ridePayload = <String, dynamic>{
      'from': _pickup.formattedAddress.isNotEmpty ? _pickup.formattedAddress : _pickup.name,
      'pickupLocation': _pickup.name,
      'pickupPincode': '522503',
      'pickupLandmark': 'Near Pickup Point',
      'to': _destination.formattedAddress.isNotEmpty ? _destination.formattedAddress : _destination.name,
      'destinationLocation': _destination.name,
      'destinationPincode': '517501',
      'destinationLandmark': 'Near Destination Point',
      'duration': displayDuration,
      'distance': displayDistance,
      'seats': seatCount,
      'booked': 0,
      'price': widget.pricePerSeat ?? parsedFare,
      'pricePerSeat': widget.pricePerSeat ?? parsedFare,
      'basePricePerKm': widget.basePricePerKm ?? 10.0,
      'offerDoorstepPickupDrop': widget.offerDoorstepPickupDrop ?? false,
      'detourRadiusKm': widget.detourRadiusKm ?? 0.0,
      'detourRatePerKm': widget.detourRatePerKm ?? 0.0,
      'maxLuggagePerPassenger': 2,
      'departs': widget.selectedDateTime?.toIso8601String() ?? widget.date ?? DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'date': widget.selectedDateTime?.toIso8601String() ?? widget.date ?? DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'departureDate': widget.date ?? (widget.selectedDateTime != null ? '${widget.selectedDateTime!.day}-${widget.selectedDateTime!.month}-${widget.selectedDateTime!.year}' : ''),
      'departureTime': widget.time ?? '06:00 AM',
      'arrivalTime': '10:30 AM',
      'intermediatePickups': dynamicIntermediatePickups,
      'routePlan': routePlan,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverCustomerPreferencesScreen(rideDetails: ridePayload),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayDistance = _isLoadingRoute ? 'Calculating...' : (_routeResult?.distanceText ?? '15.4 km');
    final displayDuration = _isLoadingRoute ? 'Calculating...' : (_routeResult?.durationText ?? '40 min');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Route Preview',
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
                children: [
                  // Pickup Badge matching Image 3
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Color(0xFF4CAF50), size: 14),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _pickup.formattedAddress.isNotEmpty ? _pickup.formattedAddress : _pickup.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Intermediate Pickups Badges (if any)
                  if (widget.intermediatePickups != null && widget.intermediatePickups!.isNotEmpty) ...[
                    ...widget.intermediatePickups!.map((stop) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withAlpha(77)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.radio_button_checked_rounded, color: AppColors.primary, size: 16),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stop: ${stop.location}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (stop.landmark != null && stop.landmark!.isNotEmpty)
                                      Text(
                                        'Near ${stop.landmark}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3EDF7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '₹ ${stop.price}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],

                  // Destination Badge matching Image 3
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Color(0xFFE53935), size: 14),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _destination.formattedAddress.isNotEmpty ? _destination.formattedAddress : _destination.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Map route container (commented out for now)
                  /*
                  SizedBox(
                    height: 380,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Live Interactive Google Map WebView
                        Positioned.fill(
                          child: RouteMapWebView(
                            pickup: _pickup.name,
                            destination: _destination.name,
                            height: 380,
                            borderRadius: 20,
                            interactive: true,
                          ),
                        ),

                        if (_isLoadingRoute)
                          const Positioned.fill(
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          ),

                        // Along the route chips bar matching Image 3
                        Positioned(
                          top: 14,
                          left: 14,
                          right: 14,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _searchAlongRoute('Custom'),
                                  child: _buildMapChip(Icons.search_rounded, 'Search along the route...'),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _searchAlongRoute('Petrol Pump'),
                                  child: _buildMapChip(Icons.local_gas_station_rounded, 'Gas'),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _searchAlongRoute('EV Charging Station'),
                                  child: _buildMapChip(Icons.ev_station_rounded, 'EV charging'),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _searchAlongRoute('Hotel'),
                                  child: _buildMapChip(Icons.hotel_rounded, 'Hotels'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  */

                  // Distance & Duration Metrics Row matching Image 3
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard('Distance', displayDistance),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard('Durations', displayDuration),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Next CTA Button
                  CustomButton(
                    text: 'Next',
                    onPressed: _goToNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*
  Widget _buildMapChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
  */

  Widget _buildMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

