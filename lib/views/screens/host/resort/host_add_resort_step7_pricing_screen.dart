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
    super.key,
    required this.selectedCategory,
    required this.propertyName,
    required this.propertyDetails,
    required this.addressMap,
    required this.formattedAddress,
    required this.description,
    required this.amenities,
    required this.houseRules,
  });

  @override
  State<HostAddResortStep7PricingScreen> createState() => _HostAddResortStep7PricingScreenState();
}

class _HostAddResortStep7PricingScreenState extends State<HostAddResortStep7PricingScreen> {
  final TextEditingController _cottageRateController = TextEditingController();
  final TextEditingController _luxurySuiteRateController = TextEditingController();
  final TextEditingController _dayPassController = TextEditingController();
  final TextEditingController _extraGuestController = TextEditingController();
  final TextEditingController _spaActivityController = TextEditingController();
  final String _selectedCurrency = 'INR - Indian Rupee (₹)';

  int get _cottagesCount => int.tryParse(widget.propertyDetails['cottages']?.toString() ?? '0') ?? 0;
  int get _luxurySuitesCount => int.tryParse(widget.propertyDetails['luxurySuites']?.toString() ?? '0') ?? 0;
  int get _guestsPerCottage => int.tryParse(widget.propertyDetails['guestsPerCottage']?.toString() ?? '4') ?? 4;
  int get _guestsPerSuite => int.tryParse(widget.propertyDetails['guestsPerSuite']?.toString() ?? '2') ?? 2;

  @override
  void initState() {
    super.initState();
    if (_cottagesCount > 0) {
      _cottageRateController.text = '12000';
    }
    if (_luxurySuitesCount > 0) {
      _luxurySuiteRateController.text = '18000';
    }
  }

  @override
  void dispose() {
    _cottageRateController.dispose();
    _luxurySuiteRateController.dispose();
    _dayPassController.dispose();
    _extraGuestController.dispose();
    _spaActivityController.dispose();
    super.dispose();
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
        title: const Column(
          children: [
            Text('Add new property', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
            SizedBox(height: 2),
            Text('Step 7 of 9 (Resort Pricing)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                        const Text('Set nightly stay rates for cottages & luxury suites, day pass & activities', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 22),

                        // 1. Cottage Pricing Field
                        if (_cottagesCount > 0) ...[
                          _buildInventoryPriceCard(
                            title: 'Standard Cottage Rate / Night',
                            subtitle: '$_cottagesCount Cottage(s) configured • Max $_guestsPerCottage Guests each',
                            icon: Icons.cabin_rounded,
                            controller: _cottageRateController,
                            hint: 'e.g. ₹ 12,000',
                          ),
                          const SizedBox(height: 18),
                        ],

                        // 2. Luxury Suite Pricing Field
                        if (_luxurySuitesCount > 0) ...[
                          _buildInventoryPriceCard(
                            title: 'Luxury Suite Rate / Night',
                            subtitle: '$_luxurySuitesCount Suite(s) configured • Max $_guestsPerSuite Guests each',
                            icon: Icons.villa_rounded,
                            controller: _luxurySuiteRateController,
                            hint: 'e.g. ₹ 18,000',
                          ),
                          const SizedBox(height: 18),
                        ],

                        // If neither was explicitly > 0, fallback to general stay rate
                        if (_cottagesCount == 0 && _luxurySuitesCount == 0) ...[
                          CustomTextField(
                            label: 'All-Inclusive Stay Rate / Night',
                            hint: 'e.g. ₹ 15,000',
                            controller: _cottageRateController,
                          ),
                          const SizedBox(height: 18),
                        ],

                        // 3. Day Pass / Buffet Inclusion
                        CustomTextField(
                          label: 'Day Pass / Buffet Inclusion Rate (Per Person)',
                          hint: 'e.g. ₹ 2500',
                          controller: _dayPassController,
                        ),
                        const SizedBox(height: 18),

                        // 4. Extra Guest & Spa Surcharge Row
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Extra Adult/Child Tariff',
                                hint: 'e.g. ₹ 1500',
                                controller: _extraGuestController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: 'Spa & Activity Pass',
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
                            final cottageRate = double.tryParse(_cottageRateController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                            final suiteRate = double.tryParse(_luxurySuiteRateController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

                            if (_cottagesCount > 0 && cottageRate <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid cottage rate per night.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            if (_luxurySuitesCount > 0 && suiteRate <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid luxury suite rate per night.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            final primaryBaseRate = cottageRate > 0 ? cottageRate : (suiteRate > 0 ? suiteRate : 12000.0);

                            final pricingData = {
                              'basePricePerNight': primaryBaseRate,
                              'allInclusiveCottageRate': cottageRate,
                              'cottageRatePerNight': cottageRate,
                              'luxurySuiteRatePerNight': suiteRate,
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

  Widget _buildInventoryPriceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Rate / Night (₹)',
            hint: hint,
            controller: controller,
          ),
        ],
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
