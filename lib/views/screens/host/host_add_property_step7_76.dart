import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'host_add_property_step8_77.dart';

class HostAddPropertyStep7Screen extends StatefulWidget {
  final Map<String, dynamic>? propertyData;
  const HostAddPropertyStep7Screen({Key? key, this.propertyData}) : super(key: key);

  @override
  State<HostAddPropertyStep7Screen> createState() => _HostAddPropertyStep7ScreenState();
}

class _HostAddPropertyStep7ScreenState extends State<HostAddPropertyStep7Screen> {
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _singleRegPriceController = TextEditingController();
  final TextEditingController _singleLuxPriceController = TextEditingController();
  final TextEditingController _doubleRegPriceController = TextEditingController();
  final TextEditingController _doubleLuxPriceController = TextEditingController();
  final TextEditingController _guestPriceController = TextEditingController();
  final TextEditingController _cleaningFeeController = TextEditingController();
  final TextEditingController _roomServicesFeeController = TextEditingController();
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
            Text('Set 7 by 9', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                _buildProgressBar(7),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pricing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Set your room rates, guest pricing, and service fees', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),

                        const SizedBox(height: 22),

                        // Base Price / Night
                        CustomTextField(
                          label: 'Base Price ( per night )',
                          hint: 'Enter base price e.g. ₹ 4500',
                          controller: _basePriceController,
                        ),
                        const SizedBox(height: 20),

                        // Section 1: Room-Specific Rates
                        const Text('Room Category Pricing', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 12),

                        // Single Sharing Regular & Luxury Row
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Single Reg ( / night )',
                                hint: 'e.g. ₹ 1500',
                                controller: _singleRegPriceController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: 'Single Lux ( / night )',
                                hint: 'e.g. ₹ 2500',
                                controller: _singleLuxPriceController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Double Sharing Regular & Luxury Row
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Double Reg ( / night )',
                                hint: 'e.g. ₹ 2800',
                                controller: _doubleRegPriceController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: 'Double Lux ( / night )',
                                hint: 'e.g. ₹ 4200',
                                controller: _doubleLuxPriceController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Section 2: Additional Charges & Fees
                        const Text('Additional Charges & Services', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 12),

                        CustomTextField(
                          label: 'Guest Price ( per extra guest / night )',
                          hint: 'Enter guest price e.g. ₹ 900',
                          controller: _guestPriceController,
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Cleaning Fee',
                                hint: 'e.g. ₹ 1000',
                                controller: _cleaningFeeController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: 'Room Services Fee',
                                hint: 'e.g. ₹ 500',
                                controller: _roomServicesFeeController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

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
                              Text(
                                _selectedCurrency,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Dual Buttons Row matching 76.png
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
                            final basePriceText = _basePriceController.text.replaceAll(RegExp(r'[^0-9.]'), '').trim();
                            if (basePriceText.isEmpty || (double.tryParse(basePriceText) ?? 0) <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid base price per night.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            final updatedData = Map<String, dynamic>.from(widget.propertyData ?? {});
                            updatedData['pricing'] = {
                              'basePrice': _basePriceController.text.trim(),
                              'singleRegPrice': _singleRegPriceController.text.trim(),
                              'singleLuxPrice': _singleLuxPriceController.text.trim(),
                              'doubleRegPrice': _doubleRegPriceController.text.trim(),
                              'doubleLuxPrice': _doubleLuxPriceController.text.trim(),
                              'guestPrice': _guestPriceController.text.trim(),
                              'cleaningFee': _cleaningFeeController.text.trim(),
                              'serviceFee': _roomServicesFeeController.text.trim(),
                              'currency': _selectedCurrency,
                            };
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddPropertyStep8Screen(
                                  propertyData: updatedData,
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
