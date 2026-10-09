import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/host_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_image_placeholder.dart';
import '../host_property_submitted_thankyou_screen.dart';

class HostAddPropertyReviewCommonScreen extends StatefulWidget {
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
    super.key,
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
  });

  @override
  State<HostAddPropertyReviewCommonScreen> createState() => _HostAddPropertyReviewCommonScreenState();
}

class _HostAddPropertyReviewCommonScreenState extends State<HostAddPropertyReviewCommonScreen> {
  bool _isSubmitting = false;

  String get _pricingDisplay {
    if (widget.selectedCategory == 'Resort') {
      final cottageRate = widget.pricing['cottageRatePerNight'] ?? widget.pricing['allInclusiveCottageRate'];
      final suiteRate = widget.pricing['luxurySuiteRatePerNight'];
      if (cottageRate != null && suiteRate != null && (suiteRate is num && suiteRate > 0)) {
        return '₹$cottageRate (Cottage) | ₹$suiteRate (Suite)';
      }
    }
    final basePrice = widget.pricing['basePricePerNight'] ?? 4500;
    return '₹ $basePrice / night';
  }

  String get _detailsSummary {
    if (widget.selectedCategory == 'Resort') {
      final cottages = widget.propertyDetails['cottages'] ?? 0;
      final suites = widget.propertyDetails['luxurySuites'] ?? 0;
      final capacity = widget.propertyDetails['totalCapacity'] ?? widget.propertyDetails['capacity'] ?? 0;
      final parts = <String>[];
      if (cottages is num && cottages > 0) parts.add('$cottages Cottage(s)');
      if (suites is num && suites > 0) parts.add('$suites Luxury Suite(s)');
      final unitsText = parts.isNotEmpty ? parts.join(' + ') : 'Resort Units';
      return '$unitsText • Max $capacity Guests';
    } else if (widget.selectedCategory == 'Farmhouse') {
      final area = widget.propertyDetails['farmArea'] ?? '2.5 Acres';
      final overnight = widget.propertyDetails['overnightCapacity'] ?? widget.propertyDetails['guests'] ?? 15;
      final eventCap = widget.propertyDetails['dayEventCapacity'] ?? widget.propertyDetails['eventCapacity'] ?? 100;
      final bed = widget.propertyDetails['bedrooms'] ?? 3;
      final parking = widget.propertyDetails['parkingCapacity'] ?? 10;
      return '$area • $bed Bed • $overnight Stay / $eventCap Event Guests • $parking Cars';
    } else if (widget.selectedCategory == 'Guest House') {
      final rooms = widget.propertyDetails['rooms'] ?? 6;
      final parking = widget.propertyDetails['parkingCapacity'] ?? 4;
      return '$rooms Private Rooms • Shared Lounge • $parking Cars Parking';
    } else if (widget.selectedCategory == 'Villa') {
      final villas = widget.propertyDetails['totalVillas'] ?? widget.propertyDetails['villas'] ?? 1;
      final bed = widget.propertyDetails['bedroomsPerVilla'] ?? widget.propertyDetails['bedrooms'] ?? 1;
      final bath = widget.propertyDetails['bathroomsPerVilla'] ?? widget.propertyDetails['bathrooms'] ?? 1;
      final parking = widget.propertyDetails['parkingCapacity'] ?? (villas * 2);
      return '$villas Villa(s) • $bed Bed / Villa • $bath Bath / Villa • $parking Cars Parking';
    } else {
      return 'Multi-Room Inventory';
    }
  }

  IconData get _categoryIcon {
    switch (widget.selectedCategory.toLowerCase()) {
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
      {'title': '${widget.selectedCategory} Details', 'value': _detailsSummary},
      {'title': 'Address', 'value': widget.formattedAddress},
      {'title': 'Pricing', 'value': _pricingDisplay},
      {'title': 'Check-in / Check-out', 'value': '${widget.checkInTime} / ${widget.checkOutTime}'},
      {'title': 'Uploaded Media', 'value': '${widget.photos.length} Photos (JPEG/PNG) • 4 KYC Documents (PDF/PNG/JPEG)'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
        title: Text(
          'Review & Submit ${widget.selectedCategory}',
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
                        Text('Review Your ${widget.selectedCategory} Listing', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Please review all details before submitting for admin verification', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 20),

                        // Property Card Preview
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.06),
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
                                    Text(widget.propertyName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text('${widget.selectedCategory} • $_detailsSummary', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                            onTap: _isSubmitting ? null : () => Navigator.pop(context),
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
                                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _isSubmitting
                      ? Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            ),
                          ),
                        )
                      : CustomButton(
                          text: 'Submit for review',
                          onPressed: () async {
                            setState(() => _isSubmitting = true);

                            final numericPrice = (widget.pricing['basePricePerNight'] as num?)?.toDouble() ?? 4500.0;

                            // Fetch host phone & name for status checking & registration
                            final prefs = await SharedPreferences.getInstance();
                            final currentPhone = prefs.getString('currentPhone') ?? '';
                            final currentName = await AuthService.getUserName(phone: currentPhone);

                            // 🚀 Submit to Backend (POST /api/properties/register)
                            final result = await HostService.registerProperty(
                              propertyType: widget.selectedCategory,
                              propertyName: widget.propertyName,
                              title: widget.propertyName,
                              type: widget.selectedCategory,
                              propertyDetails: widget.propertyDetails,
                              address: widget.addressMap,
                              location: widget.formattedAddress,
                              city: widget.addressMap['city'] ?? 'Hyderabad',
                              state: widget.addressMap['state'] ?? 'Telangana',
                              country: 'India',
                              description: widget.description,
                              amenities: widget.amenities,
                              houseRules: widget.houseRules,
                              pricing: widget.pricing,
                              pricePerNight: numericPrice,
                              checkInCheckOut: {
                                'checkInTime': widget.checkInTime,
                                'checkOutTime': widget.checkOutTime,
                              },
                              checkInTime: widget.checkInTime,
                              checkOutTime: widget.checkOutTime,
                              photos: widget.photos,
                              documents: widget.documents,
                              hostPhone: currentPhone,
                              hostName: currentName,
                              status: 'pending',
                            );

                            if (!mounted) return;
                            setState(() => _isSubmitting = false);

                            if (result['success'] != true && result['message'] != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'].toString()),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }

                            // Navigate to Thank You screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostPropertySubmittedThankYouScreen(
                                  propertyTitle: widget.propertyName,
                                  propertyType: widget.selectedCategory,
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

