import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/host_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_image_placeholder.dart';
import '../host_property_submitted_thankyou_screen.dart';

class HostAddVillaReviewScreen extends StatelessWidget {
  final String villaName;
  final int totalVillas;
  final int bedrooms;
  final int bathrooms;
  final String formattedAddress;
  final String description;
  final List<String> selectedAmenities;
  final String villaPrice;
  final String checkInTime;
  final String checkOutTime;
  final String selectedCategory;

  const HostAddVillaReviewScreen({
    Key? key,
    required this.villaName,
    this.totalVillas = 1,
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
    final List<Map<String, dynamic>> summarySections = [
      {'title': 'Villa Details', 'value': '$totalVillas Villa(s) • $bedrooms Bed / Villa • $bathrooms Bath / Villa • Entire $selectedCategory'},
      {'title': 'Address', 'value': formattedAddress},
      {'title': 'Pricing', 'value': '$villaPrice / night'},
      {'title': 'Check-in / Check-out', 'value': '$checkInTime / $checkOutTime'},
      {'title': 'Amenities (${selectedAmenities.length})', 'value': selectedAmenities.take(6).join(', ') + '...'},
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
                        const Text('Review Villa Listing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Please review all details before submitting for review', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 20),

                        // Villa Preview Card
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
                              const CustomImagePlaceholder(
                                width: 90,
                                height: 75,
                                icon: Icons.villa_rounded,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(villaName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text('$selectedCategory • $bedrooms Bedrooms • $bathrooms Baths', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    const SizedBox(height: 6),
                                    Text('$villaPrice / night', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Summary Rows
                        ...summarySections.map((sec) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9FB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE8DEF8)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sec['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                const SizedBox(height: 4),
                                Text(sec['value'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35)),
                              ],
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
                      // 🚀 Call Backend Property Registration API (POST /api/properties/register)
                      final rawPrice = double.tryParse(villaPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 12500.0;

                      // Fetch host phone & name for status checking & registration
                      final prefs = await SharedPreferences.getInstance();
                      final currentPhone = prefs.getString('currentPhone') ?? '';
                      final currentName = await AuthService.getUserName(phone: currentPhone);

                      await HostService.registerProperty(
                        propertyType: selectedCategory,
                        propertyName: villaName,
                        title: villaName,
                        type: selectedCategory,
                        propertyDetails: {
                          'totalVillas': totalVillas,
                          'villas': totalVillas,
                          'totalUnits': totalVillas,
                          'bedrooms': bedrooms,
                          'bathrooms': bathrooms,
                          'bedroomsPerVilla': bedrooms,
                          'bathroomsPerVilla': bathrooms,
                          'guests': bedrooms * 2 * totalVillas,
                        },
                        bedrooms: bedrooms,
                        bathrooms: bathrooms,
                        address: {
                          'doorFlatNo': 'D.No 4-56/A',
                          'streetRoad': 'Road No 2, Child Park Street',
                          'landmark': 'Near Child Park / Opposite Axis Bank',
                          'district': 'Rangareddy',
                          'city': 'Hyderabad',
                          'state': 'Telangana',
                          'pincode': '500081',
                        },
                        location: formattedAddress,
                        city: 'Hyderabad',
                        state: 'Telangana',
                        country: 'India',
                        description: description,
                        amenities: selectedAmenities,
                        houseRules: const [
                          'No Smoking Indoors',
                          'Pets Allowed on Lawn',
                          'Events Allowed with Prior Notice',
                          'Suitable for Children & Families',
                          'Quiet Hours (11:00 PM – 06:00 AM)',
                        ],
                        pricing: {
                          'basePricePerNight': rawPrice,
                          'additionalCharges': {
                            'guestPricePerExtraGuestPerNight': 1200,
                            'cleaningFee': 1500,
                            'securityDeposit': 5000,
                          },
                          'currency': 'INR',
                        },
                        pricePerNight: rawPrice,
                        checkInCheckOut: {
                          'checkInTime': checkInTime,
                          'checkOutTime': checkOutTime,
                        },
                        checkInTime: checkInTime,
                        checkOutTime: checkOutTime,
                        photos: const [
                          '/uploads/property/photo1.jpg',
                          '/uploads/property/photo2.jpg',
                          '/uploads/property/photo3.jpg',
                          '/uploads/property/photo4.jpg',
                          '/uploads/property/photo5.jpg',
                        ],
                        documents: const {
                          'propertyOwnershipProof': '/uploads/documents/ownership-proof.pdf',
                          'identityProof': '/uploads/documents/identity-proof.pdf',
                          'taxRegistrationDocuments': '/uploads/documents/tax-registration.pdf',
                          'nocOtherDocuments': '/uploads/documents/noc.pdf',
                        },
                        hostPhone: currentPhone,
                        hostName: currentName,
                        status: 'PENDING_REVIEW',
                      );

                      // Navigate to the Thank You Screen
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HostPropertySubmittedThankYouScreen(
                            propertyTitle: villaName,
                            propertyType: selectedCategory,
                            pricePerNight: '$villaPrice / night',
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
