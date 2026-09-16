import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/host_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'host_property_submitted_thankyou_screen.dart';
import 'host_add_property_step2_75.dart';
import 'host_add_property_step3_78.dart';
import 'host_add_property_step4_79.dart';
import 'host_add_property_step5_80.dart';
import 'host_add_property_step6_81.dart';
import 'host_add_property_step7_76.dart';
import 'host_add_property_step8_77.dart';
import 'host_add_property_step9_72.dart';
import 'host_add_property_documents_73.dart';

class HostAddPropertyReviewScreen extends StatefulWidget {
  final List<String>? photos;
  final Map<String, dynamic>? documents;
  final Map<String, dynamic>? propertyData;
  final String? propertyName;

  const HostAddPropertyReviewScreen({
    Key? key,
    this.photos,
    this.documents,
    this.propertyData,
    this.propertyName,
  }) : super(key: key);

  @override
  State<HostAddPropertyReviewScreen> createState() => _HostAddPropertyReviewScreenState();
}

class _HostAddPropertyReviewScreenState extends State<HostAddPropertyReviewScreen> {
  // Track open/collapsed state of each accordion section
  final Set<String> _expandedSections = {
    'Location & Address',
    'Description',
    'Amenities',
    'House rules',
    'Pricing',
    'Check-in/ Check-out',
    'Photos & Documents',
  };

  void _toggleSection(String section) {
    setState(() {
      if (_expandedSections.contains(section)) {
        _expandedSections.remove(section);
      } else {
        _expandedSections.add(section);
      }
    });
  }

  void _navigateToSection(BuildContext context, String sectionName) {
    switch (sectionName) {
      case 'Property Details':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HostAddPropertyStep2Screen(),
          ),
        );
        break;
      case 'Location & Address':
      case 'Address':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostAddPropertyStep3Screen(
              selectedCategory: widget.propertyData?['propertyType'] ?? 'Hotel',
              propertyName: widget.propertyData?['propertyName'] ?? widget.propertyName,
              propertyData: widget.propertyData,
            ),
          ),
        );
        break;
      case 'Description':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostAddPropertyStep4Screen(
              propertyData: widget.propertyData,
            ),
          ),
        );
        break;
      case 'Amenities':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostAddPropertyStep5Screen(
              propertyData: widget.propertyData,
            ),
          ),
        );
        break;
      case 'House rules':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostAddPropertyStep6Screen(
              propertyData: widget.propertyData,
            ),
          ),
        );
        break;
      case 'Pricing':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostAddPropertyStep7Screen(
              propertyData: widget.propertyData,
            ),
          ),
        );
        break;
      case 'Check-in/ Check-out':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostAddPropertyStep8Screen(
              propertyData: widget.propertyData,
            ),
          ),
        );
        break;
      case 'Photos & Documents':
      case 'Photos':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostAddPropertyStep9Screen(
              propertyData: widget.propertyData,
            ),
          ),
        );
        break;
      case 'Documents':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostAddPropertyDocumentsScreen(
              photos: widget.photos,
              propertyData: widget.propertyData,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.propertyData ?? {};

    // 🏨 Task 1: Real Dynamic Property Name & Details
    final dynamicPropertyName = (data['propertyName'] as String?)?.trim().isNotEmpty == true
        ? data['propertyName'] as String
        : (widget.propertyName?.trim().isNotEmpty == true ? widget.propertyName! : 'Grand Palace Hotel');

    final dynamicPropertyType = data['propertyType'] as String? ?? 'Hotel';
    final totalRooms = data['totalRooms'] ?? 10;
    final singleReg = data['singleSharingRegularRooms'] ?? 2;
    final singleLux = data['singleSharingLuxuryRooms'] ?? 2;
    final doubleReg = data['doubleSharingRegularRooms'] ?? 3;
    final doubleLux = data['doubleSharingLuxuryRooms'] ?? 3;

    final pricingMap = data['pricing'] as Map<String, dynamic>? ?? {};
    final basePriceStr = pricingMap['basePrice'] ?? '₹ 4,500';
    final singleRegPrice = pricingMap['singleRegPrice'] ?? '₹ 1,500';
    final singleLuxPrice = pricingMap['singleLuxPrice'] ?? '₹ 2,500';
    final doubleRegPrice = pricingMap['doubleRegPrice'] ?? '₹ 2,800';
    final doubleLuxPrice = pricingMap['doubleLuxPrice'] ?? '₹ 4,200';
    final cleaningFee = pricingMap['cleaningFee'] ?? '₹ 1,000';
    final serviceFee = pricingMap['serviceFee'] ?? '₹ 500';

    final formattedAddress = data['formattedAddress'] as String? ??
        'D.No 4-56/A, Road No 2, Child Park Street, Near Child Park / Opposite Axis Bank, Hyderabad, Rangareddy District, Telangana, PIN: 500081';

    final descriptionText = data['description'] as String? ??
        'Reliable and premium hotel property featuring modern architecture, spacious rooms, 24/7 technical and concierge support, and high-speed amenities.';

    final regularAmenities = (data['regularAmenities'] as List?)?.cast<String>() ??
        ['Wi-Fi', 'Tv', 'AC', 'Hot water', 'Break fast'];

    final luxuryAmenities = (data['luxuryAmenities'] as List?)?.cast<String>() ??
        ['Wi-Fi', 'Tv', 'AC', 'Pool', 'Hot water', 'Break fast', 'Mini Bar'];

    final houseRules = (data['houseRules'] as List?)?.cast<String>() ??
        ['No Smoking', 'No Pets', 'No Parties or events', 'Suitable for children', 'Quiet Hours (10:00 PM – 07:00 AM)'];

    final checkIn = data['checkInTime'] as String? ?? '02 : 00 PM';
    final checkOut = data['checkOutTime'] as String? ?? '11 : 00 AM';

    final photoList = (data['photos'] as List?)?.cast<String>() ?? widget.photos ?? ['exterior_front.png', 'lobby_view.png', 'luxury_suite.png'];
    final docMap = widget.documents ?? (data['documents'] as Map<String, dynamic>?) ?? {
      'ownershipProof': 'ownership-proof.pdf',
      'identityProof': 'identity-proof.pdf',
      'taxRegistration': 'tax-registration.pdf',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Review & Submit',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Review Your Listing',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap any section to expand details or edit your entries',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),

                        const SizedBox(height: 20),

                        // 🏨 Real Property Summary Card with Dynamic Name
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const CustomImagePlaceholder(
                                width: 85,
                                height: 75,
                                icon: Icons.hotel_rounded,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🌟 Task 1: Real Property Name Displayed Here
                                    Text(
                                      dynamicPropertyName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$dynamicPropertyType • $totalRooms Rooms ($singleReg Reg, $singleLux Lux, $doubleReg Dbl-Reg, $doubleLux Dbl-Lux)',
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$basePriceStr / night',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_square, color: AppColors.primary, size: 22),
                                tooltip: 'Edit Property Details',
                                onPressed: () => _navigateToSection(context, 'Property Details'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 📑 Task 2: Expandable Accordion Dropdowns for Every Section

                        // 1. Location & Address Dropdown
                        _buildAccordionCard(
                          title: 'Location & Address',
                          icon: Icons.location_on_rounded,
                          isExpanded: _expandedSections.contains('Location & Address'),
                          onToggle: () => _toggleSection('Location & Address'),
                          onEdit: () => _navigateToSection(context, 'Location & Address'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedAddress,
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                              ),
                            ],
                          ),
                        ),

                        // 2. Description Dropdown
                        _buildAccordionCard(
                          title: 'Description',
                          icon: Icons.description_rounded,
                          isExpanded: _expandedSections.contains('Description'),
                          onToggle: () => _toggleSection('Description'),
                          onEdit: () => _navigateToSection(context, 'Description'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                descriptionText,
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.45),
                              ),
                            ],
                          ),
                        ),

                        // 3. Amenities Dropdown
                        _buildAccordionCard(
                          title: 'Amenities',
                          icon: Icons.room_service_rounded,
                          isExpanded: _expandedSections.contains('Amenities'),
                          onToggle: () => _toggleSection('Amenities'),
                          onEdit: () => _navigateToSection(context, 'Amenities'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Regular Room Amenities:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: regularAmenities.map((a) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3EDF7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 14),
                                        const SizedBox(width: 4),
                                        Text(a, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Luxury Room Amenities:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A)),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: luxuryAmenities.map((a) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E5F5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFBA68C8)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, color: Color(0xFF8E24AA), size: 14),
                                        const SizedBox(width: 4),
                                        Text(a, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF6A1B9A))),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        // 4. House Rules Dropdown
                        _buildAccordionCard(
                          title: 'House rules',
                          icon: Icons.rule_rounded,
                          isExpanded: _expandedSections.contains('House rules'),
                          onToggle: () => _toggleSection('House rules'),
                          onEdit: () => _navigateToSection(context, 'House rules'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: houseRules.map((rule) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFF81C784)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_rounded, color: Color(0xFF2E7D32), size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          rule,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        // 5. Pricing Dropdown
                        _buildAccordionCard(
                          title: 'Pricing',
                          icon: Icons.payments_rounded,
                          isExpanded: _expandedSections.contains('Pricing'),
                          onToggle: () => _toggleSection('Pricing'),
                          onEdit: () => _navigateToSection(context, 'Pricing'),
                          content: Column(
                            children: [
                              _buildPricingRow('Single Sharing Regular Room', singleRegPrice),
                              const Divider(height: 12),
                              _buildPricingRow('Single Sharing Luxury Room', singleLuxPrice),
                              const Divider(height: 12),
                              _buildPricingRow('Double Sharing Regular Room', doubleRegPrice),
                              const Divider(height: 12),
                              _buildPricingRow('Double Sharing Luxury Room', doubleLuxPrice),
                              const Divider(height: 12),
                              _buildPricingRow('Cleaning Fee', cleaningFee),
                              const Divider(height: 12),
                              _buildPricingRow('Room Service Fee', serviceFee),
                            ],
                          ),
                        ),

                        // 6. Check-in / Check-out Dropdown
                        _buildAccordionCard(
                          title: 'Check-in/ Check-out',
                          icon: Icons.access_time_filled_rounded,
                          isExpanded: _expandedSections.contains('Check-in/ Check-out'),
                          onToggle: () => _toggleSection('Check-in/ Check-out'),
                          onEdit: () => _navigateToSection(context, 'Check-in/ Check-out'),
                          content: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F5FE),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Check-in Time', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                      const SizedBox(height: 4),
                                      Text(checkIn, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F5FE),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Check-out Time', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                      const SizedBox(height: 4),
                                      Text(checkOut, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 7. Photos & Documents Dropdown
                        _buildAccordionCard(
                          title: 'Photos & Documents',
                          icon: Icons.photo_library_rounded,
                          isExpanded: _expandedSections.contains('Photos & Documents'),
                          onToggle: () => _toggleSection('Photos & Documents'),
                          onEdit: () => _navigateToSection(context, 'Photos & Documents'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Uploaded Photos (${photoList.length} files):',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: photoList.map((p) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3EDF7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.image_rounded, size: 14, color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        Text(p, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Verified KYC Documents (${docMap.length} files):',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 6),
                              Column(
                                children: docMap.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${entry.key}: ${entry.value}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Submit for Review CTA Button matching 74.png
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    text: 'Submit for review',
                    onPressed: () async {
                      // Fetch host phone & name for status checking & registration
                      final prefs = await SharedPreferences.getInstance();
                      final currentPhone = prefs.getString('currentPhone') ?? '';
                      final currentName = await AuthService.getUserName(phone: currentPhone);

                      // 🚀 Submit to Backend (POST /api/properties/register)
                      await HostService.registerProperty(
                        propertyType: dynamicPropertyType,
                        propertyName: dynamicPropertyName,
                        propertyDetails: {
                          'totalRooms': totalRooms,
                          'singleSharingRegularRooms': singleReg,
                          'singleSharingLuxuryRooms': singleLux,
                          'doubleSharingRegularRooms': doubleReg,
                          'doubleSharingLuxuryRooms': doubleLux,
                        },
                        address: data['address'] as Map<String, dynamic>? ?? {
                          'doorFlatNo': 'D.No 4-56/A',
                          'streetRoad': 'Road No 2, Child Park Street',
                          'landmark': 'Near Child Park / Opposite Axis Bank',
                          'district': 'Rangareddy',
                          'city': 'Hyderabad',
                          'state': 'Telangana',
                          'pincode': '500081',
                        },
                        description: descriptionText,
                        amenities: {
                          'luxuryRooms': luxuryAmenities,
                          'regularRooms': regularAmenities,
                        },
                        houseRules: houseRules,
                        pricing: {
                          'basePricePerNight': double.tryParse(basePriceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 4500,
                          'roomCategoryPricing': {
                            'singleRegular': double.tryParse(singleRegPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 1500,
                            'singleLuxury': double.tryParse(singleLuxPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 2500,
                            'doubleRegular': double.tryParse(doubleRegPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 2800,
                            'doubleLuxury': double.tryParse(doubleLuxPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 4200,
                          },
                          'additionalCharges': {
                            'cleaningFee': double.tryParse(cleaningFee.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 1000,
                            'roomServicesFee': double.tryParse(serviceFee.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 500,
                          },
                          'currency': 'INR',
                        },
                        checkInCheckOut: {
                          'checkInTime': checkIn,
                          'checkOutTime': checkOut,
                        },
                        photos: photoList,
                        documents: docMap,
                        hostPhone: currentPhone,
                        hostName: currentName,
                        status: 'pending',
                      );

                      // Navigate to the Thank You / Success Screen
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HostPropertySubmittedThankYouScreen(
                            propertyTitle: dynamicPropertyName,
                            propertyType: dynamicPropertyType,
                            pricePerNight: '$basePriceStr / night',
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

  // 📑 Accordion Dropdown Card Builder with Integrated Edit Button
  Widget _buildAccordionCard({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required VoidCallback onEdit,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? AppColors.primary.withOpacity(0.5) : AppColors.border,
          width: isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  // Edit Button
                  IconButton(
                    icon: const Icon(Icons.edit_square, color: AppColors.primary, size: 20),
                    tooltip: 'Edit $title',
                    onPressed: onEdit,
                  ),
                  // Expand / Collapse Arrow Icon
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  content,
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
                      label: Text(
                        'Edit $title',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(
          '$price / night',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

