import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/place_location_model.dart';
import '../../../services/google_maps_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/location_autocomplete_picker_modal.dart';
import '../../widgets/route_map_webview.dart';
import 'driver_publish_ride_calendar_screen_92.dart';

class DriverPostRideScreen extends StatefulWidget {
  const DriverPostRideScreen({Key? key}) : super(key: key);

  @override
  State<DriverPostRideScreen> createState() => _DriverPostRideScreenState();
}

class _DriverPostRideScreenState extends State<DriverPostRideScreen> {
  int _selectedRouteIndex = 0;
  final Set<String> _selectedCities = {};

  LocationPoint _pickupLocation = const LocationPoint(
    name: 'Mangalagiri Road, Vijayawada',
    formattedAddress: 'Mangalagiri Road, Vijayawada, Andhra Pradesh, India',
    latitude: 16.4357,
    longitude: 80.5694,
  );

  LocationPoint _destLocation = const LocationPoint(
    name: 'Tirupati',
    formattedAddress: 'Tirupati, Andhra Pradesh, India',
    latitude: 13.6288,
    longitude: 79.4192,
  );

  RouteResult? _routeResult;
  bool _isLoadingRoute = false;

  List<String> _routes = [
    '4 hours 30 mins - 330 KM (Fastest Route)',
    'Alternative via NH-16 (+25 mins)',
  ];

  final List<String> _cities = [
    'Add any citys',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDirections();
  }

  Future<void> _fetchDirections() async {
    setState(() {
      _isLoadingRoute = true;
    });

    final result = await GoogleMapsService.getDirections(
      originLat: _pickupLocation.latitude,
      originLng: _pickupLocation.longitude,
      destLat: _destLocation.latitude,
      destLng: _destLocation.longitude,
    );

    if (!mounted) return;
    setState(() {
      _isLoadingRoute = false;
      if (result != null) {
        _routeResult = result;
        _routes = [
          '${result.durationText} - ${result.distanceText} (Fastest Route)',
          'Alternative Route (+15 mins)',
        ];
      }
    });
  }

  Future<void> _selectPickup() async {
    final picked = await LocationAutocompletePickerModal.show(
      context,
      title: 'Select Pickup Location',
      initialQuery: _pickupLocation.name,
    );

    if (picked != null && mounted) {
      setState(() {
        _pickupLocation = picked;
      });
      _fetchDirections();
    }
  }

  Future<void> _selectDestination() async {
    final picked = await LocationAutocompletePickerModal.show(
      context,
      title: 'Select Destination',
      initialQuery: _destLocation.name,
    );

    if (picked != null && mounted) {
      setState(() {
        _destLocation = picked;
      });
      _fetchDirections();
    }
  }

  Future<void> _addCustomWaypoint() async {
    final picked = await LocationAutocompletePickerModal.show(
      context,
      title: 'Add Intermediate Waypoint',
      hintText: 'Search city or area to add...',
    );

    if (picked != null && mounted) {
      setState(() {
        if (!_cities.contains(picked.name)) {
          _cities.insert(_cities.length - 1, picked.name);
          _selectedCities.add(picked.name);
        }
      });
    }
  }

  List<Map<String, String>> _generateDynamicRoutePlan() {
    final plan = <Map<String, String>>[];
    plan.add({'time': '06:00 AM', 'location': _pickupLocation.name, 'type': 'start'});

    int hour = 6;
    int minute = 45;
    for (final city in _selectedCities) {
      final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} AM';
      plan.add({'time': timeStr, 'location': city, 'type': 'pickup'});
      minute += 45;
      if (minute >= 60) {
        hour += 1;
        minute -= 60;
      }
    }

    final arrivalTime = _routeResult?.durationText != null ? '10:30 AM' : '10:30 AM';
    plan.add({'time': arrivalTime, 'location': _destLocation.name, 'type': 'destination'});
    return plan;
  }

  @override
  Widget build(BuildContext context) {
    final routePlan = _generateDynamicRoutePlan();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post Ride',
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
              // Pickup Location Box matching 1.png
              InkWell(
                onTap: _selectPickup,
                borderRadius: BorderRadius.circular(14),
                child: _buildLocationBox(
                  'Pickup location',
                  _pickupLocation.formattedAddress.isNotEmpty ? _pickupLocation.formattedAddress : _pickupLocation.name,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 12),
              // Destination Location Box matching 1.png
              InkWell(
                onTap: _selectDestination,
                borderRadius: BorderRadius.circular(14),
                child: _buildLocationBox(
                  'Destination',
                  _destLocation.formattedAddress.isNotEmpty ? _destLocation.formattedAddress : _destLocation.name,
                  const Color(0xFFE53935),
                ),
              ),

              const SizedBox(height: 16),

              // Live Interactive Route Map matching 1.png
              RouteMapWebView(
                pickup: _pickupLocation.name,
                destination: _destLocation.name,
                height: 190,
                borderRadius: 18,
                interactive: true,
              ),

              const SizedBox(height: 20),

              // Select Root Section matching 1.png
              const Text(
                'Select Root',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              ...List.generate(_routes.length, (index) {
                final isSelected = _selectedRouteIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRouteIndex = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _routes[index],
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Add Passengers Section matching 1.png
              const Text(
                'Add Passengers / Waypoints',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              ...List.generate(_cities.length, (index) {
                final city = _cities[index];
                final isAddButton = city.toLowerCase().contains('add');
                final isChecked = _selectedCities.contains(city);
                return GestureDetector(
                  onTap: () {
                    if (isAddButton) {
                      _addCustomWaypoint();
                    } else {
                      setState(() {
                        if (isChecked) {
                          _selectedCities.remove(city);
                        } else {
                          _selectedCities.add(city);
                        }
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: isChecked
                              ? const Center(
                                  child: Icon(Icons.check_rounded, size: 14, color: AppColors.primary),
                                )
                              : (isAddButton ? const Icon(Icons.add, size: 14, color: AppColors.primary) : null),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            city,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isAddButton ? FontWeight.bold : FontWeight.w500,
                              color: isAddButton ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Dynamic Route Plan Waypoints Timeline matching 1.png
              const Text(
                'Route Plan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),

              ...List.generate(routePlan.length, (index) {
                final item = routePlan[index];
                final isStart = index == 0;
                final isEnd = index == routePlan.length - 1;
                return Column(
                  children: [
                    _buildWaypointItem(
                      item['time'] ?? '06:00',
                      item['location'] ?? '',
                      isStart: isStart,
                    ),
                    if (!isEnd) _buildTimelineLine(),
                  ],
                );
              }),

              const SizedBox(height: 32),

              // Primary CTA Button "Next" matching 1.png
              CustomButton(
                text: 'Next',
                onPressed: () {
                  final dynamicIntermediatePickups = _selectedCities.map((c) => {
                    'location': '$c, Andhra Pradesh',
                    'pincode': '522001',
                    'landmark': 'Near $c Bus Station',
                    'time': '06:45 AM',
                    'price': 750,
                  }).toList();

                  final dynamicRoutePlan = routePlan.map((p) => {
                    'location': p['location'] ?? '',
                    'pincode': '522503',
                    'time': p['time'] ?? '06:00 AM',
                    'type': p['type'] ?? 'pickup',
                  }).toList();

                  final rideDetails = <String, dynamic>{
                    'from': _pickupLocation.formattedAddress,
                    'pickupLocation': _pickupLocation.name,
                    'pickupPincode': '522503',
                    'pickupLandmark': 'Near Mangalagiri Bus Stand',
                    'to': _destLocation.formattedAddress,
                    'destinationLocation': _destLocation.name,
                    'destinationPincode': '517501',
                    'destinationLandmark': 'Near Tirupati Railway Station',
                    'duration': _routeResult?.durationText ?? '4 hours 30 mins',
                    'distance': _routeResult?.distanceText ?? '330 KM',
                    'selectedCities': _selectedCities.toList(),
                    'intermediatePickups': dynamicIntermediatePickups,
                    'routePlan': dynamicRoutePlan,
                    'price': 850,
                    'pricePerSeat': 850,
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverPublishRideCalendarScreen(
                        rideDetails: rideDetails,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBox(String label, String address, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.location_on_rounded, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildWaypointItem(String time, String station, {bool isStart = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 60,
          child: Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ),
        const SizedBox(width: 10),
        isStart
            ? const Icon(Icons.directions_car_rounded, color: Colors.redAccent, size: 18)
            : Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.border,
                  shape: BoxShape.circle,
                ),
              ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            station,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 74),
      child: Container(
        height: 16,
        width: 2,
        color: AppColors.border,
      ),
    );
  }
}
