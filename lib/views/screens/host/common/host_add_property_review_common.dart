import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/host_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_image_placeholder.dart';
import '../host_property_submitted_thankyou_screen.dart';

class HostAddPropertyReviewCommonScreen extends StatelessWidget {
  final String selectedCategory;
  final String propertyName;
  final Map<String, dynamic> propertyDetails;
  final Map<String, dynamic> addressMap;
  final String formattedAddress;
  final String description;
  final dynamic amenities;
  final List<String> houseRules;
  final Map<String, dynamic> pricing;
  final String checkInTime;
  final String checkOutTime;
  final List<String> photos;
  final Map<String, dynamic> documents;

  const HostAddPropertyReviewCommonScreen({
    Key? key,
    required this.selectedCategory,
    required this.propertyName,
    required this.propertyDetails,
    required this.addressMap,
    required this.formattedAddress,
    required this.description,
    required this.amenities,
    required this.houseRules,
    required this.pricing,
    required this.checkInTime,
    required this.checkOutTime,
    required this.photos,
    required this.documents,
  }) : super(key: key);

  String get _pricingDisplay {
    final basePrice = pricing['basePricePerNight'] ?? 4500;
    return '₹ $basePrice / night';
  }

  String get _detailsSummary {
    if (selectedCategory == 'Resort') {
      final cottages = propertyDetails['cottages'] ?? 12;
      final capacity = propertyDetails['capacity'] ?? 60;
      return '$cottages Cottages/Suites • Max $capacity Guests';
    } else if (selectedCategory == 'Farmhouse') {
      final area = propertyDetails['farmArea'] ?? '2.5 Acres';
      final eventCap = propertyDetails['eventCapacity'] ?? 150;
      return '$area Farm • Event Capacity $eventCap Guests';
    } else if (selectedCategory == 'Guest House') {
      final rooms = propertyDetails['rooms'] ?? 6;
      return '$rooms Private Rooms • Shared Lounge';
    } else if (selectedCategory == 'Villa') {
      final bed = propertyDetails['bedrooms'] ?? 4;
      final bath = propertyDetails['bathrooms'] ?? 3;
      return '$bed Bedrooms • $bath Bathrooms';
    } else {
      return 'Multi-Room Inventory';
    }
  }

  IconData get _categoryIcon {
    switch (selectedCategory.toLowerCase()) {
      case 'resort':
        return Icons.holiday_village_rounded;
      case 'farmhouse':
        return Icons.agriculture_rounded;
      case 'guest house':
      case 'guesthouse':
        return Icons.home_work_rounded;
      case 'villa':
        return Icons.villa_rounded;
      default:
        return Icons.hotel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> summaryRows = [
      {'title': '$selectedCategory Details', 'value': _detailsSummary},
      {'title': 'Address', 'value': formattedAddress},
      {'title': 'Pricing', 'value': _pricingDisplay},
      {'title': 'Check-in / Check-out', 'value': '$checkInTime / $checkOutTime'},
      {'title': 'Uploaded Media', 'value': '${photos.length} Photos (JPEG/PNG) • 4 KYC Documents (PDF/PNG/JPEG)'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Review & Submit $selectedCategory',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16),
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Review Your $selectedCategory Listing', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Please review all details before submitting for admin verification', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 20),

                        // Property Card Preview
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.primary.withOpacity(0.35)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CustomImagePlaceholder(
                                width: 90,
                                height: 75,
                                icon: _categoryIcon,
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(propertyName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text('$selectedCategory • $_detailsSummary', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    const SizedBox(height: 6),
                                    Text(_pricingDisplay, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Summary Rows with Edit Buttons
                        ...summaryRows.map((sec) {
                          final title = sec['title']!;
                          return InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9FB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE8DEF8)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                        const SizedBox(height: 4),
                                        Text(sec['value']!, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_square, color: AppColors.primary, size: 18),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    text: 'Submit for review',
                    onPressed: () async {
                      final numericPrice = (pricing['basePricePerNight'] as num?)?.toDouble() ?? 4500.0;

                      // Fetch host phone & name for status checking & registration
                      final prefs = await SharedPreferences.getInstance();
                      final currentPhone = prefs.getString('currentPhone') ?? '';
                      final currentName = await AuthService.getUserName(phone: currentPhone);

                      // 🚀 Submit to Backend (POST /api/properties/register)
                      await HostService.registerProperty(
                        propertyType: selectedCategory,
                        propertyName: propertyName,
                        title: propertyName,
                        type: selectedCategory,
                        propertyDetails: propertyDetails,
                        address: addressMap,
                        location: formattedAddress,
                        city: addressMap['city'] ?? 'Hyderabad',
                        state: addressMap['state'] ?? 'Telangana',
                        country: 'India',
                        description: description,
                        amenities: amenities,
                        houseRules: houseRules,
                        pricing: pricing,
                        pricePerNight: numericPrice,
                        checkInCheckOut: {
                          'checkInTime': checkInTime,
                          'checkOutTime': checkOutTime,
                        },
                        checkInTime: checkInTime,
                        checkOutTime: checkOutTime,
                        photos: photos,
                        documents: documents,
                        hostPhone: currentPhone,
                        hostName: currentName,
                        status: 'pending',
                      );

                      // Navigate to Thank You screen
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HostPropertySubmittedThankYouScreen(
                            propertyTitle: propertyName,
                            propertyType: selectedCategory,
                            pricePerNight: _pricingDisplay,
                            hostPhone: currentPhone,
                            hostName: currentName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
