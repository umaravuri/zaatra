import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../common/host_add_property_step9_upload_common.dart';

class HostAddVillaStep8TimesScreen extends StatefulWidget {
  final String villaName;
  final int totalVillas;
  final int bedrooms;
  final int bathrooms;
  final String formattedAddress;
  final String description;
  final List<String> selectedAmenities;
  final String villaPrice;
  final String selectedCategory;

  const HostAddVillaStep8TimesScreen({
    Key? key,
    required this.villaName,
    this.totalVillas = 1,
    required this.bedrooms,
    required this.bathrooms,
    required this.formattedAddress,
    required this.description,
    required this.selectedAmenities,
    required this.villaPrice,
    this.selectedCategory = 'Villa',
  }) : super(key: key);

  @override
  State<HostAddVillaStep8TimesScreen> createState() => _HostAddVillaStep8TimesScreenState();
}

class _HostAddVillaStep8TimesScreenState extends State<HostAddVillaStep8TimesScreen> {
  String? _checkInTime;
  String? _checkOutTime;

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
            Text('Set 8 by 9 (Villa Flow)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                _buildProgressBar(8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Check-in and Check-out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Set timing policies for villa guests', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 24),

                        // Check-in Time
                        const Text('Check-in time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 14, minute: 0));
                            if (time != null) {
                              setState(() => _checkInTime = time.format(context));
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
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
                                  _checkInTime ?? 'Select Check-in Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _checkInTime != null ? FontWeight.bold : FontWeight.normal,
                                    color: _checkInTime != null ? AppColors.textPrimary : AppColors.textMuted,
                                  ),
                                ),
                                const Icon(Icons.access_time_rounded, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Check-out Time
                        const Text('Check-out time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 11, minute: 0));
                            if (time != null) {
                              setState(() => _checkOutTime = time.format(context));
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
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
                                  _checkOutTime ?? 'Select Check-out Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _checkOutTime != null ? FontWeight.bold : FontWeight.normal,
                                    color: _checkOutTime != null ? AppColors.textPrimary : AppColors.textMuted,
                                  ),
                                ),
                                const Icon(Icons.access_time_rounded, color: AppColors.primary),
                              ],
                            ),
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
                            if (_checkInTime == null || _checkOutTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select both check-in and check-out times.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            final double parsedPrice = double.tryParse(widget.villaPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddPropertyStep9UploadCommonScreen(
                                  selectedCategory: widget.selectedCategory,
                                  propertyName: widget.villaName,
                                  propertyDetails: {
                                    'totalVillas': widget.totalVillas,
                                    'villas': widget.totalVillas,
                                    'totalUnits': widget.totalVillas,
                                    'bedrooms': widget.bedrooms,
                                    'bathrooms': widget.bathrooms,
                                    'bedroomsPerVilla': widget.bedrooms,
                                    'bathroomsPerVilla': widget.bathrooms,
                                    'guests': widget.bedrooms * 2 * widget.totalVillas,
                                  },
                                  addressMap: {
                                    'streetRoad': widget.formattedAddress,
                                    'address': widget.formattedAddress,
                                  },
                                  formattedAddress: widget.formattedAddress,
                                  description: widget.description,
                                  amenities: widget.selectedAmenities,
                                  houseRules: const [],
                                  pricing: {
                                    'basePricePerNight': parsedPrice,
                                    'wholeVillaPricePerNight': parsedPrice,
                                  },
                                  checkInTime: _checkInTime!,
                                  checkOutTime: _checkOutTime!,
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
