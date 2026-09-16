import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import 'host_add_villa_review_screen.dart';

class HostAddVillaStep9PhotosScreen extends StatelessWidget {
  final String villaName;
  final int bedrooms;
  final int bathrooms;
  final String formattedAddress;
  final String description;
  final List<String> selectedAmenities;
  final String villaPrice;
  final String checkInTime;
  final String checkOutTime;
  final String selectedCategory;

  const HostAddVillaStep9PhotosScreen({
    Key? key,
    required this.villaName,
    required this.bedrooms,
    required this.bathrooms,
    required this.formattedAddress,
    required this.description,
    required this.selectedAmenities,
    required this.villaPrice,
    required this.checkInTime,
    required this.checkOutTime,
    this.selectedCategory = 'Villa',
  }) : super(key: key);

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
            Text('Set 9 by 9 (Villa Flow)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                _buildProgressBar(9),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Villa Photos & Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Upload photos of villa exterior, lawn, pool and rooms', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 24),

                        // Upload Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9FB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.add_photo_alternate_rounded, size: 48, color: AppColors.primary),
                              SizedBox(height: 12),
                              Text('Upload Villa Photos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              SizedBox(height: 4),
                              Text('Add at least 5 photos showing pool, bedrooms & lawn', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // KYC Document status row
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.verified_user_rounded, color: AppColors.success, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text('Ownership / Property Tax Document attached', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              ),
                              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
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
                          text: 'Review Listing',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddVillaReviewScreen(
                                  villaName: villaName,
                                  bedrooms: bedrooms,
                                  bathrooms: bathrooms,
                                  formattedAddress: formattedAddress,
                                  description: description,
                                  selectedAmenities: selectedAmenities,
                                  villaPrice: villaPrice,
                                  checkInTime: checkInTime,
                                  checkOutTime: checkOutTime,
                                  selectedCategory: selectedCategory,
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
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
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
