import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../common/host_add_property_step8_common.dart';

class HostAddResortStep7PricingScreen extends StatefulWidget {
  final String selectedCategory;
  final String propertyName;
  final Map<String, dynamic> propertyDetails;
  final Map<String, dynamic> addressMap;
  final String formattedAddress;
  final String description;
  final dynamic amenities;
  final List<String> houseRules;

  const HostAddResortStep7PricingScreen({
    Key? key,
    required this.selectedCategory,
    required this.propertyName,
    required this.propertyDetails,
    required this.addressMap,
    required this.formattedAddress,
    required this.description,
    required this.amenities,
    required this.houseRules,
  }) : super(key: key);

  @override
  State<HostAddResortStep7PricingScreen> createState() => _HostAddResortStep7PricingScreenState();
}

class _HostAddResortStep7PricingScreenState extends State<HostAddResortStep7PricingScreen> {
  final TextEditingController _cottageRateController = TextEditingController();
  final TextEditingController _dayPassController = TextEditingController();
  final TextEditingController _extraGuestController = TextEditingController();
  final TextEditingController _spaActivityController = TextEditingController();
  String _selectedCurrency = 'INR - Indian Rupee (₹)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: const [
            Text('Add new property', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
            SizedBox(height: 2),
            Text('Set 7 by 9 (Resort Pricing)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
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
                _buildProgressBar(7),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Resort Package & Tariff', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Set all-inclusive cottage stay rates, buffet pass & activity charges', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 22),

                        // Cottage Rate per Night
                        CustomTextField(
                          label: 'All-Inclusive Cottage Rate / Night',
                          hint: 'e.g. ₹ 18000',
                          controller: _cottageRateController,
                        ),
                        const SizedBox(height: 18),

                        // Day Pass / Buffet Inclusion
                        CustomTextField(
                          label: 'Day Pass / Buffet Inclusion Rate (Per Person)',
                          hint: 'e.g. ₹ 2500',
                          controller: _dayPassController,
                        ),
                        const SizedBox(height: 18),

                        // Extra Guest & Spa Surcharge Row
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Extra Adult / Child Tariff',
                                hint: 'e.g. ₹ 1500',
                                controller: _extraGuestController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: 'Spa & Adventure Pass',
                                hint: 'e.g. ₹ 3000',
                                controller: _spaActivityController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Currency Selector
                        const Text('Currency', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedCurrency, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Back',
                          isOutlined: true,
                          backgroundColor: Colors.white,
                          textColor: AppColors.primary,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomButton(
                          text: 'Next',
                          onPressed: () {
                            final rawRate = double.tryParse(_cottageRateController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                            if (rawRate <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid cottage rate per night.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            final pricingData = {
                              'basePricePerNight': rawRate,
                              'allInclusiveCottageRate': rawRate,
                              'dayPassRate': double.tryParse(_dayPassController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 2500.0,
                              'additionalCharges': {
                                'guestPricePerExtraGuestPerNight': double.tryParse(_extraGuestController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 1500.0,
                                'spaAdventurePass': double.tryParse(_spaActivityController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 3000.0,
                              },
                              'currency': 'INR',
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddPropertyStep8CommonScreen(
                                  selectedCategory: widget.selectedCategory,
                                  propertyName: widget.propertyName,
                                  propertyDetails: widget.propertyDetails,
                                  addressMap: widget.addressMap,
                                  formattedAddress: widget.formattedAddress,
                                  description: widget.description,
                                  amenities: widget.amenities,
                                  houseRules: widget.houseRules,
                                  pricing: pricingData,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(9, (index) {
          final isCompleted = index < currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    color: isCompleted ? AppColors.primary : const Color(0xFFF3EDF7),
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primary : const Color(0xFFF3EDF7),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
