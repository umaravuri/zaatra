import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import 'host_add_villa_step4_description_screen.dart';

class HostAddVillaStep3AddressScreen extends StatefulWidget {
  final String villaName;
  final int bedrooms;
  final int bathrooms;
  final String selectedCategory;

  const HostAddVillaStep3AddressScreen({
    Key? key,
    required this.villaName,
    required this.bedrooms,
    required this.bathrooms,
    this.selectedCategory = 'Villa',
  }) : super(key: key);

  @override
  State<HostAddVillaStep3AddressScreen> createState() => _HostAddVillaStep3AddressScreenState();
}

class _HostAddVillaStep3AddressScreenState extends State<HostAddVillaStep3AddressScreen> {
  final TextEditingController _dnoController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String get _formattedAddress {
    final parts = [
      if (_dnoController.text.trim().isNotEmpty) _dnoController.text.trim(),
      if (_streetController.text.trim().isNotEmpty) _streetController.text.trim(),
      if (_landmarkController.text.trim().isNotEmpty) 'Landmark: ${_landmarkController.text.trim()}',
      if (_cityController.text.trim().isNotEmpty) _cityController.text.trim(),
      if (_districtController.text.trim().isNotEmpty) '${_districtController.text.trim()} District',
      if (_stateController.text.trim().isNotEmpty) _stateController.text.trim(),
      if (_pincodeController.text.trim().isNotEmpty) 'PIN: ${_pincodeController.text.trim()}',
    ];
    return parts.join(', ');
  }

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.location_on_rounded, color: AppColors.primary, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Villa Address',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter complete address details for your villa listing',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Divider(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: 'Door / Flat No (dno)',
                          hint: 'e.g. D.No 4-56/A, Villa 12',
                          controller: _dnoController,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'Street / Road',
                          hint: 'e.g. Road No 2, Child Park Street',
                          controller: _streetController,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'Landmark',
                          hint: 'e.g. Near Child Park / Opposite Axis Bank',
                          controller: _landmarkController,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'District',
                                hint: 'e.g. Rangareddy',
                                controller: _districtController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: 'City',
                                hint: 'e.g. Hyderabad',
                                controller: _cityController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'State',
                                hint: 'e.g. Telangana',
                                controller: _stateController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: 'Pincode',
                                hint: '500081',
                                controller: _pincodeController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        isOutlined: true,
                        fontSize: 14,
                        backgroundColor: Colors.white,
                        textColor: AppColors.textSecondary,
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        text: 'Save Address',
                        fontSize: 14,
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(dialogContext);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
        title: Column(
          children: const [
            Text('Add new property', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
            SizedBox(height: 2),
            Text('Set 3 by 9 (Villa Flow)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                _buildProgressBar(3),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Villa Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Add the location and address of your villa.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: _showAddressDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.edit_location_alt_rounded, color: AppColors.primary, size: 22),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Click to edit address details (D.No, Street, Landmark...)',
                                    style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Map Box
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8DEF8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 36),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Formatted Address Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9FB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.home_work_outlined, color: AppColors.textPrimary, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Full Address',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: _showAddressDialog,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.edit_rounded, size: 14, color: AppColors.primary),
                                        SizedBox(width: 4),
                                        Text('Edit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formattedAddress,
                                style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
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
                            final pin = _pincodeController.text.trim();
                            if (_streetController.text.trim().isEmpty ||
                                _cityController.text.trim().isEmpty ||
                                _stateController.text.trim().isEmpty ||
                                pin.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill in required address fields (Street, City, State, Pincode).'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            if (pin.length != 6 || !RegExp(r'^[1-9][0-9]{5}$').hasMatch(pin)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid 6-digit Pincode.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddVillaStep4DescriptionScreen(
                                  villaName: widget.villaName,
                                  bedrooms: widget.bedrooms,
                                  bathrooms: widget.bathrooms,
                                  formattedAddress: _formattedAddress,
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
