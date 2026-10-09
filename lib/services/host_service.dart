import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'auth_service.dart';

class HostService {
  // 1. Host KYC & Profile Registration API
  // Endpoint: POST /hosts/register
  static Future<Map<String, dynamic>> registerHost({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String location,
    required String city,
    required String state,
    required String country,
    String? aadharNumber,
    String? aadharDocument,
    String? panNumber,
    String? panDocument,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'location': location,
      'city': city,
      'state': state,
      'country': country,
      'aadharNumber': aadharNumber ?? '5489 1234 9876',
      'aadharDocument': aadharDocument ?? '/uploads/sample_aadhar.png',
      'panNumber': panNumber ?? 'ABCDE1234F',
      'panDocument': panDocument ?? '/uploads/sample_pan.png',
    };

    return await ApiService.post('/hosts/register', body);
  }

  // 2. 9-Step Property Registration API
  // Endpoint: POST /properties/register (or /properties)
  static Future<Map<String, dynamic>> registerProperty({
    String? propertyType,
    String? propertyName,
    String? title,
    String? type,
    Map<String, dynamic>? propertyDetails,
    int bedrooms = 1,
    int bathrooms = 1,
    int guests = 2,
    Map<String, dynamic>? address,
    String? location,
    String? city,
    String? state,
    String? country,
    double latitude = 17.4486,
    double longitude = 78.3908,
    required String description,
    dynamic amenities,
    List<String> houseRules = const [
      'No Smoking',
      'No Pets',
      'No Parties or events',
      'Suitable for children',
      'Quick house (10PM - 7AM)',
    ],
    Map<String, dynamic>? pricing,
    double pricePerNight = 4500.0,
    double extraGuestPrice = 900.0,
    double cleaningFee = 1000.0,
    double roomServiceFee = 500.0,
    double extraHourFee = 100.0,
    String currency = 'INR',
    Map<String, dynamic>? checkInCheckOut,
    String checkInTime = '14:00',
    String checkOutTime = '11:00',
    List<String>? photos,
    List<String>? images,
    Map<String, dynamic>? documents,
    String? ownershipProof,
    String? identityProof,
    String? taxRegistrationDoc,
    String? nocDocument,
    String? hostPhone,
    String? hostId,
    String? hostEmail,
    String? hostAvatar,
    String hostName = 'Host User',
    String status = 'pending',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPhone = prefs.getString('currentPhone') ?? '';
    final resolvedPhone = hostPhone != null && hostPhone.isNotEmpty ? hostPhone : currentPhone;
    final resolvedName = hostName != 'Host User' ? hostName : (prefs.getString('currentUserName') ?? hostName);

    final resolvedType = propertyType ?? type ?? 'Hotel';
    final resolvedTitle = propertyName ?? title ?? 'See View Villas';
    final resolvedCity = city ?? (address != null ? address['city'] : null) ?? 'Hyderabad';
    final resolvedState = state ?? (address != null ? address['state'] : null) ?? 'Telangana';
    final resolvedCountry = country ?? 'India';
    final resolvedLocation = location ??
        (address != null
            ? '${address['streetRoad'] ?? ''}, ${address['city'] ?? ''}, ${address['state'] ?? ''}'
            : 'Road No 2, Child Park Street, Hyderabad, Telangana');

    final effectivePropertyDetails = propertyDetails != null
        ? Map<String, dynamic>.from(propertyDetails)
        : <String, dynamic>{
            'singleSharingRegularRooms': 1,
            'singleSharingLuxuryRooms': 1,
            'doubleSharingRegularRooms': 1,
            'doubleSharingLuxuryRooms': 1,
            'bedrooms': bedrooms,
            'bathrooms': bathrooms,
            'guests': guests,
          };

    final effectiveBedrooms = (effectivePropertyDetails['bedrooms'] is int)
        ? effectivePropertyDetails['bedrooms'] as int
        : bedrooms;
    final effectiveBathrooms = (effectivePropertyDetails['bathrooms'] is int)
        ? effectivePropertyDetails['bathrooms'] as int
        : bathrooms;
    final effectiveGuests = (effectivePropertyDetails['guests'] is int)
        ? effectivePropertyDetails['guests'] as int
        : (effectivePropertyDetails['overnightCapacity'] is int
            ? effectivePropertyDetails['overnightCapacity'] as int
            : guests);

    final Map<String, dynamic> body = {
      'propertyType': resolvedType,
      'propertyName': resolvedTitle,
      'title': resolvedTitle,
      'type': resolvedType,
      'propertyDetails': effectivePropertyDetails,
      'bedrooms': effectiveBedrooms,
      'bathrooms': effectiveBathrooms,
      'guests': effectiveGuests,
      if (effectivePropertyDetails.containsKey('totalVillas'))
        'totalVillas': effectivePropertyDetails['totalVillas'],
      if (effectivePropertyDetails.containsKey('farmArea'))
        'farmArea': effectivePropertyDetails['farmArea'],
      if (effectivePropertyDetails.containsKey('dayEventCapacity'))
        'dayEventCapacity': effectivePropertyDetails['dayEventCapacity'],
      if (effectivePropertyDetails.containsKey('parkingCapacity'))
        'parkingCapacity': effectivePropertyDetails['parkingCapacity'],
      if (effectivePropertyDetails.containsKey('vehicleParkingCapacity'))
        'vehicleParkingCapacity': effectivePropertyDetails['vehicleParkingCapacity'],
      'address': address ?? {
        'doorFlatNo': 'D.No 4-56/A',
        'streetRoad': 'Road No 2, Child Park Street',
        'landmark': 'Near Child Park / Opposite Axis Bank',
        'district': 'Rangareddy',
        'city': resolvedCity,
        'state': resolvedState,
        'pincode': '500081',
      },
      'location': resolvedLocation,
      'city': resolvedCity,
      'state': resolvedState,
      'country': resolvedCountry,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'amenities': amenities ?? {
        'luxuryRooms': [
          'Wi-Fi',
          'TV',
          'AC',
          'Pool',
          'Hot water',
          'Breakfast',
          'Mini Bar',
        ],
        'regularRooms': [
          'Wi-Fi',
          'TV',
          'AC',
          'Hot water',
          'Breakfast',
        ],
      },
      'houseRules': houseRules,
      'pricing': pricing ?? {
        'basePricePerNight': pricePerNight,
        'roomCategoryPricing': {
          'singleRegular': 1500,
          'singleLuxury': 2500,
          'doubleRegular': 2800,
          'doubleLuxury': 4200,
        },
        'additionalCharges': {
          'guestPricePerExtraGuestPerNight': extraGuestPrice,
          'cleaningFee': cleaningFee,
          'roomServicesFee': roomServiceFee,
        },
        'currency': currency,
      },
      'price': pricePerNight,
      'pricePerNight': pricePerNight,
      'extraGuestPrice': extraGuestPrice,
      'cleaningFee': cleaningFee,
      'roomServiceFee': roomServiceFee,
      'extraHourFee': extraHourFee,
      'currency': currency,
      'checkInCheckOut': checkInCheckOut ?? {
        'checkInTime': checkInTime,
        'checkOutTime': checkOutTime,
      },
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'photos': photos ?? images ?? [
        '/uploads/property/photo1.jpg',
        '/uploads/property/photo2.jpg',
        '/uploads/property/photo3.jpg',
        '/uploads/property/photo4.jpg',
        '/uploads/property/photo5.jpg',
      ],
      'images': photos ?? images ?? [
        '/uploads/property/photo1.jpg',
        '/uploads/property/photo2.jpg',
      ],
      'documents': documents ?? {
        'propertyOwnershipProof': ownershipProof ?? '/uploads/documents/ownership-proof.pdf',
        'identityProof': identityProof ?? '/uploads/documents/identity-proof.pdf',
        'taxRegistrationDocuments': taxRegistrationDoc ?? '/uploads/documents/tax-registration.pdf',
        'nocOtherDocuments': nocDocument ?? '/uploads/documents/noc.pdf',
      },
      'ownershipProof': ownershipProof ?? '/uploads/documents/ownership-proof.pdf',
      'identityProof': identityProof ?? '/uploads/documents/identity-proof.pdf',
      'taxRegistrationDoc': taxRegistrationDoc ?? '/uploads/documents/tax-registration.pdf',
      'nocDocument': nocDocument ?? '/uploads/documents/noc.pdf',
      'hostName': resolvedName,
      'hostPhone': resolvedPhone,
      'phone': resolvedPhone,
      'hostEmail': hostEmail ?? '',
      'hostId': hostId ?? (prefs.getString('currentUserId') ?? 'H-201'),
      'status': status,
    };

    // Store local registration trace
    if (resolvedPhone.isNotEmpty) {
      final cleanDigits = resolvedPhone.replaceAll(RegExp(r'[^0-9]'), '');
      await prefs.setString('host_property_title_$cleanDigits', resolvedTitle);
      await prefs.setString('host_property_type_$cleanDigits', resolvedType);
      await prefs.setBool('host_has_submitted_property_$cleanDigits', true);
    }

    // Try /properties/register first, fall back to /properties if needed
    final result = await ApiService.post('/properties/register', body);
    if (result['success'] == true) {
      return result;
    }
    return await ApiService.post('/properties', body);
  }

  // 3. Get Host Properties / Check Enlisted Properties
  // Endpoints: GET /properties/my-properties | GET /properties
  static Future<List<dynamic>> getHostProperties({String? hostId, String? hostPhone}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneToCheck = hostPhone ?? prefs.getString('currentPhone') ?? '';
      final cleanPhone = phoneToCheck.replaceAll(RegExp(r'[^0-9]'), '');
      final tenDigit = cleanPhone.length >= 10 ? cleanPhone.substring(cleanPhone.length - 10) : cleanPhone;

      List<dynamic> allFetched = [];

      // 1. Try /properties/my-properties
      try {
        final myRes = await ApiService.get('/properties/my-properties');
        if (myRes['success'] == true) {
          if (myRes['properties'] is List) {
            allFetched.addAll(myRes['properties']);
          } else if (myRes['data'] is List) {
            allFetched.addAll(myRes['data']);
          }
        }
      } catch (_) {}

      // 2. Fetch all /properties
      if (allFetched.isEmpty) {
        try {
          final res = await ApiService.get('/properties');
          if (res['success'] == true) {
            if (res['properties'] is List) {
              allFetched.addAll(res['properties']);
            } else if (res['data'] is List) {
              allFetched.addAll(res['data']);
            }
          }
        } catch (_) {}
      }

      if (allFetched.isEmpty) {
        return [];
      }

      // If no phone or hostId provided, return all properties
      if (tenDigit.isEmpty && (hostId == null || hostId.isEmpty)) {
        return allFetched;
      }

      // 3. Smart filter matching hostPhone, hostId, or title
      final registeredTitle = prefs.getString('host_property_title_$cleanPhone') ?? '';

      final matched = allFetched.where((p) {
        if (p is! Map) return false;

        // Check hostId / userId / host / owner
        if (hostId != null && hostId.isNotEmpty) {
          final pHostId = (p['hostId'] ?? p['userId'] ?? p['host'] ?? p['owner'] ?? p['createdBy'])?.toString();
          if (pHostId == hostId) return true;
        }

        // Check phone
        final pPhone = (p['hostPhone'] ?? p['phone'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
        if (pPhone.isNotEmpty && (pPhone.contains(tenDigit) || tenDigit.contains(pPhone))) {
          return true;
        }

        // Check registered property title fallback
        if (registeredTitle.isNotEmpty && p['title']?.toString().toLowerCase() == registeredTitle.toLowerCase()) {
          return true;
        }

        return false;
      }).toList();

      return matched;
    } catch (_) {
      return [];
    }
  }

  // 4. Check Host Approval Workflow State
  // Checks BOTH user-level approval (Host KYC / Account) AND property-level approval
  static Future<HostApprovalResult> checkHostApprovalStatus({
    String? hostId,
    String? hostPhone,
    Map<String, dynamic>? userProfile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final phoneToCheck = hostPhone ?? prefs.getString('currentPhone') ?? '';
    final cleanPhone = phoneToCheck.replaceAll(RegExp(r'[^0-9]'), '');
    final tenDigit = cleanPhone.length >= 10 ? cleanPhone.substring(cleanPhone.length - 10) : cleanPhone;

    // 1. Check User-Level Admin Approval (only applicable if user's registered role is host)
    final user = userProfile ?? await AuthService.getCurrentUser();
    if (user != null) {
      final userRole = (user['role'] ?? '').toString().toLowerCase();
      if (userRole == 'host') {
        final userStatus = (user['status'] ?? '').toString().toLowerCase();
        final hostStatus = (user['hostStatus'] ?? user['hostApproval'] ?? user['kyc'] ?? user['kycStatus'] ?? '').toString().toLowerCase();
        final isUserApproved = user['isApproved'] == true ||
            user['adminApproval'] == true ||
            userStatus == 'approved' ||
            userStatus == 'active' ||
            hostStatus == 'approved' ||
            hostStatus == 'active' ||
            hostStatus == 'verified';

        if (isUserApproved) {
          if (cleanPhone.isNotEmpty) {
            await prefs.setBool('host_approved_$cleanPhone', true);
          }
          final properties = await getHostProperties(hostId: hostId, hostPhone: phoneToCheck);
          return HostApprovalResult(
            status: HostApprovalStatus.approved,
            properties: properties,
            approvedProperties: properties,
          );
        }
      }
    }

    // 2. Check local persistent approval override
    if (cleanPhone.isNotEmpty) {
      if (prefs.getBool('host_approved_$cleanPhone') == true || prefs.getBool('host_approved_$tenDigit') == true) {
        final properties = await getHostProperties(hostId: hostId, hostPhone: phoneToCheck);
        return HostApprovalResult(
          status: HostApprovalStatus.approved,
          properties: properties,
          approvedProperties: properties,
        );
      }
    }

    final properties = await getHostProperties(hostId: hostId, hostPhone: phoneToCheck);

    if (properties.isEmpty) {
      // Check if user previously submitted a property locally
      final hasSubmitted = prefs.getBool('host_has_submitted_property_$cleanPhone') == true;
      if (hasSubmitted) {
        return HostApprovalResult(
          status: HostApprovalStatus.pendingApproval,
          properties: [],
        );
      }

      return HostApprovalResult(
        status: HostApprovalStatus.noProperties,
        properties: [],
      );
    }

    // 3. Check if at least one property is APPROVED by Admin
    // Supports boolean isApproved, adminApproval, approved, and case-insensitive status strings
    final approvedList = properties.where((p) {
      if (p is! Map) return false;
      if (p['isApproved'] == true || p['adminApproval'] == true || p['approved'] == true) {
        return true;
      }
      final status = (p['status'] ?? p['approvalStatus'] ?? '').toString().toUpperCase();
      return status == 'APPROVED' ||
          status == 'LISTED' ||
          status == 'ACTIVE' ||
          status == 'FEATURED' ||
          status == 'VERIFIED' ||
          status == 'PUBLISHED' ||
          status == 'LIVE';
    }).toList();

    if (approvedList.isNotEmpty) {
      if (cleanPhone.isNotEmpty) {
        await prefs.setBool('host_approved_$cleanPhone', true);
      }
      return HostApprovalResult(
        status: HostApprovalStatus.approved,
        properties: properties,
        approvedProperties: approvedList,
      );
    }

    // Has submitted properties, but none approved yet (pending admin review)
    return HostApprovalResult(
      status: HostApprovalStatus.pendingApproval,
      properties: properties,
    );
  }

  // 5. Update Property Details / Partial Schema by ID
  // Endpoint: PUT /properties/:id
  static Future<Map<String, dynamic>> updateProperty(
    String propertyId,
    Map<String, dynamic> updateData, {
    String? token,
  }) async {
    final cleanId = propertyId.trim();
    if (cleanId.isEmpty) {
      return {
        'success': false,
        'message': 'Property ID is required for update',
      };
    }
    return await ApiService.put('/properties/$cleanId', updateData, token: token);
  }

  // 6. Get Single Property Details by ID
  // Endpoint: GET /properties/:id
  static Future<Map<String, dynamic>> getPropertyById(
    String propertyId, {
    String? token,
  }) async {
    final cleanId = propertyId.trim();
    if (cleanId.isEmpty) {
      return {
        'success': false,
        'message': 'Property ID is required',
      };
    }
    return await ApiService.get('/properties/$cleanId', token: token);
  }
}

enum HostApprovalStatus {
  noProperties,
  pendingApproval,
  approved,
}

class HostApprovalResult {
  final HostApprovalStatus status;
  final List<dynamic> properties;
  final List<dynamic> approvedProperties;

  HostApprovalResult({
    required this.status,
    required this.properties,
    this.approvedProperties = const [],
  });
}
