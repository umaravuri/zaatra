import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../host_add_property_step5_80.dart';
import '../villa/host_add_villa_step5_amenities_screen.dart';
import '../resort/host_add_resort_step5_amenities_screen.dart';
import '../farmhouse/host_add_farmhouse_step5_amenities_screen.dart';
import '../guesthouse/host_add_guesthouse_step5_amenities_screen.dart';

class HostAddPropertyStep4CommonScreen extends StatefulWidget {
  final String selectedCategory;
  final String propertyName;
  final Map<String, dynamic> propertyDetails;
  final Map<String, dynamic> addressMap;
  final String formattedAddress;

  const HostAddPropertyStep4CommonScreen({
    Key? key,
    required this.selectedCategory,
    required this.propertyName,
    required this.propertyDetails,
    required this.addressMap,
    required this.formattedAddress,
  }) : super(key: key);

  @override
  State<HostAddPropertyStep4CommonScreen> createState() => _HostAddPropertyStep4CommonScreenState();
}

class _HostAddPropertyStep4CommonScreenState extends State<HostAddPropertyStep4CommonScreen> {
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  void _navigateToStep5() {
    final cat = widget.selectedCategory.trim();
    final desc = _descriptionController.text.trim();

    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description for your property.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (cat.toLowerCase() == 'resort') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HostAddResortStep5AmenitiesScreen(
            selectedCategory: widget.selectedCategory,
            propertyName: widget.propertyName,
            propertyDetails: widget.propertyDetails,
            addressMap: widget.addressMap,
            formattedAddress: widget.formattedAddress,
            description: desc,
          ),
        ),
      );
    } else if (cat.toLowerCase() == 'farmhouse') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HostAddFarmhouseStep5AmenitiesScreen(
            selectedCategory: widget.selectedCategory,
            propertyName: widget.propertyName,
            propertyDetails: widget.propertyDetails,
            addressMap: widget.addressMap,
            formattedAddress: widget.formattedAddress,
            description: desc,
          ),
        ),
      );
    } else if (cat.toLowerCase() == 'guest house' || cat.toLowerCase() == 'guesthouse') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HostAddGuestHouseStep5AmenitiesScreen(
            selectedCategory: widget.selectedCategory,
            propertyName: widget.propertyName,
            propertyDetails: widget.propertyDetails,
            addressMap: widget.addressMap,
            formattedAddress: widget.formattedAddress,
            description: desc,
          ),
        ),
      );
    } else if (cat.toLowerCase() == 'villa') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HostAddVillaStep5AmenitiesScreen(
            villaName: widget.propertyName,
            bedrooms: widget.propertyDetails['bedrooms'] ?? 4,
            bathrooms: widget.propertyDetails['bathrooms'] ?? 3,
            formattedAddress: widget.formattedAddress,
            description: desc,
            selectedCategory: widget.selectedCategory,
          ),
        ),
      );
    } else {
      // Hotel (Default)
      final propertyData = {
        'selectedCategory': widget.selectedCategory,
        'propertyName': widget.propertyName,
        'propertyDetails': widget.propertyDetails,
        'addressMap': widget.addressMap,
        'formattedAddress': widget.formattedAddress,
        'description': desc,
      };
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HostAddPropertyStep5Screen(
            propertyData: propertyData,
          ),
        ),
      );
    }
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
          children: [
            const Text('Add new property', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
            const SizedBox(height: 2),
            Text('Set 4 by 9 (${widget.selectedCategory})', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                _buildProgressBar(4),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.selectedCategory} Description', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Tell guests about the highlights & unique features of your ${widget.selectedCategory.toLowerCase()}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE8DEF8)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextField(
                                controller: _descriptionController,
                                maxLines: 8,
                                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.45),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter your property description...',
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text('1000/1000', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
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
                          onPressed: _navigateToStep5,
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
