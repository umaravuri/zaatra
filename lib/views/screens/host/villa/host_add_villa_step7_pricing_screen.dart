import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import 'host_add_villa_step8_times_screen.dart';

class HostAddVillaStep7PricingScreen extends StatefulWidget {
  final String villaName;
  final int bedrooms;
  final int bathrooms;
  final String formattedAddress;
  final String description;
  final List<String> selectedAmenities;
  final String selectedCategory;

  const HostAddVillaStep7PricingScreen({
    Key? key,
    required this.villaName,
    required this.bedrooms,
    required this.bathrooms,
    required this.formattedAddress,
    required this.description,
    required this.selectedAmenities,
    this.selectedCategory = 'Villa',
  }) : super(key: key);

  @override
  State<HostAddVillaStep7PricingScreen> createState() => _HostAddVillaStep7PricingScreenState();
}

class _HostAddVillaStep7PricingScreenState extends State<HostAddVillaStep7PricingScreen> {
  final TextEditingController _villaPriceController = TextEditingController();
  final TextEditingController _guestPriceController = TextEditingController();
  final TextEditingController _cleaningFeeController = TextEditingController();
  final TextEditingController _securityDepositController = TextEditingController();
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
            Text('Set 7 by 9 (Villa Flow)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                        const Text('Villa Pricing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Set entire villa rate per night, extra guest fee & security deposit', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 22),

                        // Entire Villa Price / Night
                        CustomTextField(
                          label: 'Price per Night ( Entire Villa )',
                          hint: 'Enter villa price e.g. ₹ 12500',
                          controller: _villaPriceController,
                        ),
                        const SizedBox(height: 18),

                        // Extra Guest Fee
                        CustomTextField(
                          label: 'Guest Price ( per extra guest / night )',
                          hint: 'Enter extra guest price e.g. ₹ 1200',
                          controller: _guestPriceController,
                        ),
                        const SizedBox(height: 18),

                        // Cleaning Fee & Security Deposit Row
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Cleaning Fee',
                                hint: 'e.g. ₹ 1500',
                                controller: _cleaningFeeController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: 'Security Deposit (Refundable)',
                                hint: 'e.g. ₹ 5000',
                                controller: _securityDepositController,
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
                            final priceText = _villaPriceController.text.replaceAll(RegExp(r'[^0-9.]'), '').trim();
                            if (priceText.isEmpty || (double.tryParse(priceText) ?? 0) <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid price per night for the villa.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddVillaStep8TimesScreen(
                                  villaName: widget.villaName,
                                  bedrooms: widget.bedrooms,
                                  bathrooms: widget.bathrooms,
                                  formattedAddress: widget.formattedAddress,
                                  description: widget.description,
                                  selectedAmenities: widget.selectedAmenities,
                                  villaPrice: _villaPriceController.text.trim(),
                                  selectedCategory: widget.selectedCategory,
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
