import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/location_autocomplete_picker_modal.dart';
import 'ride_selection_screen_21.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({Key? key}) : super(key: key);

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final _pickupController = TextEditingController(text: 'Madhapur, Hitech City');
  final _dropoffController = TextEditingController(text: 'Secunderabad Railway Station');

  Future<void> _selectPickup() async {
    final picked = await LocationAutocompletePickerModal.show(
      context,
      title: 'Select Pickup Location',
      initialQuery: _pickupController.text,
    );

    if (picked != null && mounted) {
      setState(() {
        _pickupController.text = picked.formattedAddress.isNotEmpty ? picked.formattedAddress : picked.name;
      });
    }
  }

  Future<void> _selectDropoff() async {
    final picked = await LocationAutocompletePickerModal.show(
      context,
      title: 'Select Destination',
      initialQuery: _dropoffController.text,
    );

    if (picked != null && mounted) {
      setState(() {
        _dropoffController.text = picked.formattedAddress.isNotEmpty ? picked.formattedAddress : picked.name;
      });
    }
  }

  void _findRides() {
    if (_pickupController.text.isEmpty || _dropoffController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup and destination locations.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideSelectionScreen(
          pickupAddress: _pickupController.text,
          dropoffAddress: _dropoffController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Location'),
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
            Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup & Dropoff Inputs Container matching Screen 20
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: _selectPickup,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pickup Location', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _pickupController.text.isNotEmpty ? _pickupController.text : 'Enter Pickup Location',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 20,
                          child: VerticalDivider(color: AppColors.primary, thickness: 2),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _selectDropoff,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Destination', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _dropoffController.text.isNotEmpty ? _dropoffController.text : 'Where to?',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Recent Searches',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),

              const SizedBox(height: 12),

              _buildRecentTile('Kukatpally Housing Board (KPHB)', 'Hyderabad, Telangana'),
              _buildRecentTile('Rajiv Gandhi International Airport', 'Shamshabad, Hyderabad'),
              _buildRecentTile('Gachibowli Financial District', 'Nanakramguda, Hyderabad'),

              const Spacer(),

              CustomButton(
                text: 'Find Available Rides',
                icon: Icons.search_rounded,
                onPressed: _findRides,
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTile(String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _dropoffController.text = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.history_rounded, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
