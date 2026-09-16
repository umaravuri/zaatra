import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/ride_option_model.dart';
import '../../widgets/custom_button.dart';
import 'customer_payment_screen_22.dart';

class RideSelectionScreen extends StatefulWidget {
  final String pickupAddress;
  final String dropoffAddress;

  const RideSelectionScreen({
    Key? key,
    this.pickupAddress = 'Airport / Station',
    this.dropoffAddress = 'Calangute Beach, Goa',
  }) : super(key: key);

  @override
  State<RideSelectionScreen> createState() => _RideSelectionScreenState();
}

class _RideSelectionScreenState extends State<RideSelectionScreen> {
  final List<RideOptionModel> _options = RideOptionModel.sampleOptions;
  late RideOptionModel _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = _options.first;
  }

  void _proceedToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerPaymentScreen(
          pickupAddress: widget.pickupAddress,
          dropoffAddress: widget.dropoffAddress,
          selectedRide: _selectedOption,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Choose a Ride')),
      body: SafeArea(
        child: Column(
          children: [
            // Map Preview Card matching Screen 21
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE8E5F4),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_rounded, size: 64, color: AppColors.primary.withAlpha(128)),
                          const SizedBox(height: 8),
                          const Text(
                            'GPS Route Preview (8.5 km • 18 mins)',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(widget.pickupAddress, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(widget.dropoffAddress, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Vehicle Category Bottom Sheet matching Screen 21
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Available Vehicle Tiers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  ..._options.map((option) => _buildOptionCard(option)),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Select ${_selectedOption.name} (\$${_selectedOption.estimatedFare.toStringAsFixed(2)})',
                    onPressed: _proceedToPayment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(RideOptionModel option) {
    final isSelected = _selectedOption.id == option.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = option;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBackground : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(option.icon, color: isSelected ? Colors.white : AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('${option.description} • ${option.etaMinutes} min away', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${option.estimatedFare.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text('${option.capacity} seats', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
