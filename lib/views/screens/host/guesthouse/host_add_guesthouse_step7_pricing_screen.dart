import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../common/host_add_property_step8_common.dart';

class HostAddGuestHouseStep7PricingScreen extends StatefulWidget {
  final String selectedCategory;
  final String propertyName;
  final Map<String, dynamic> propertyDetails;
  final Map<String, dynamic> addressMap;
  final String formattedAddress;
  final String description;
  final dynamic amenities;
  final List<String> houseRules;

  const HostAddGuestHouseStep7PricingScreen({
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
  State<HostAddGuestHouseStep7PricingScreen> createState() => _HostAddGuestHouseStep7PricingScreenState();
}

class _HostAddGuestHouseStep7PricingScreenState extends State<HostAddGuestHouseStep7PricingScreen> {
  final TextEditingController _roomRateController = TextEditingController();
  final TextEditingController _fullHouseRateController = TextEditingController();
  final TextEditingController _mealFeeController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
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
            Text('Set 7 by 9 (Guest House Pricing)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                        const Text('Guest House Pricing & Tariff', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Set single room price, entire guest house booking & meal packages', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 22),

                        // Single Room Rate per Night
                        CustomTextField(
                          label: 'Standard Private Room Rate (Per Night)',
                          hint: 'e.g. ₹ 1800',
                          controller: _roomRateController,
                        ),
                        const SizedBox(height: 18),

                        // Full Guest House Rate per Night
                        CustomTextField(
                          label: 'Entire Guest House Booking Rate (Per Night)',
                          hint: 'e.g. ₹ 7500',
                          controller: _fullHouseRateController,
                        ),
                        const SizedBox(height: 18),

                        // Meal Package & Extended Stay Discount Row
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Home Meals Package / Day',
                                hint: 'e.g. ₹ 400',
                                controller: _mealFeeController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: 'Extended Stay Discount',
                                hint: 'e.g. 15%',
                                controller: _discountController,
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
                            final rawRate = double.tryParse(_roomRateController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                            if (rawRate <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid room rate per night.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            final pricingData = {
                              'basePricePerNight': rawRate,
                              'roomRatePerNight': rawRate,
                              'fullGuestHouseRate': double.tryParse(_fullHouseRateController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 7500.0,
                              'additionalCharges': {
                                'mealPackagePerPerson': double.tryParse(_mealFeeController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 400.0,
                                'extendedStayDiscountPercent': 15,
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
