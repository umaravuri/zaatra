import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/app_env.dart';
import 'api_service.dart';

class DriverService {
  // 1. Driver Registration API (KYC & Personal Info)
  // Endpoint: POST /drivers/register
  static Future<Map<String, dynamic>> registerDriver({
    required String name,
    required String email,
    required String phone,
    String? password,
    String? location,
    String? city,
    String? state,
    String? country,
    String? drivingLicenseNumber,
    String? drivingLicenseDocument,
    String? aadharNumber,
    String? aadharDocument,
    String? panNumber,
    String? panDocument,
    String? driverPhoto,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password ?? AppEnv.defaultDriverPassword,
      'location': (location != null && location.isNotEmpty) ? location : 'MI Road, C-Scheme',
      'city': (city != null && city.isNotEmpty) ? city : 'Jaipur',
      'state': (state != null && state.isNotEmpty) ? state : 'Rajasthan',
      'country': (country != null && country.isNotEmpty) ? country : 'India',
      'drivingLicenseNumber': (drivingLicenseNumber != null && drivingLicenseNumber.isNotEmpty) ? drivingLicenseNumber : 'RJ-142023004561',
      'drivingLicenseDocument': (drivingLicenseDocument != null && drivingLicenseDocument.isNotEmpty) ? drivingLicenseDocument : '/uploads/sample_dl.png',
      'driverPhoto': (driverPhoto != null && driverPhoto.isNotEmpty) ? driverPhoto : '/uploads/sample_driver.png',
    };

    if (aadharNumber != null && aadharNumber.isNotEmpty) {
      body['aadharNumber'] = aadharNumber;
    }
    if (aadharDocument != null && aadharDocument.isNotEmpty) {
      body['aadharDocument'] = aadharDocument;
    }
    if (panNumber != null && panNumber.isNotEmpty) {
      body['panNumber'] = panNumber;
    }
    if (panDocument != null && panDocument.isNotEmpty) {
      body['panDocument'] = panDocument;
    }

    return await ApiService.post('/drivers/register', body);
  }

  // 2. Register Driver & Vehicle (Onboarding API)
  // Endpoint: POST /drivers/onboarding
  static Future<Map<String, dynamic>> onboardDriverVehicle({
    required String name,
    required String email,
    required String phone,
    String? location,
    String? vehicle,
    required String vehicleMake,
    required String vehicleModel,
    required String vehicleType,
    required String vehicleYear,
    required String vehicleFuelType,
    String? fuelType,
    required String vehicleNumberPlate,
    String? vehicleColor,
    String? carImage,
    List<String>? carImages,
    String? vehiclePhotos,
    String? drivingLicenseNumber,
    String? drivingLicenseDocument,
    String? rcDocument,
    String? pollutionDocument,
    String? driverPhoto,
  }) async {
    final effectiveFuelType = fuelType ?? vehicleFuelType;
    final effectiveCarImage = carImage ?? vehiclePhotos ?? '/uploads/kia_front.png';
    final effectiveCarImages = carImages ?? [effectiveCarImage];

    final body = {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location ?? 'Mangalagiri Road, Vijayawada, Andhra Pradesh, India',
      'vehicle': vehicle ?? '$vehicleMake $vehicleModel',
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleType': vehicleType,
      'vehicleYear': vehicleYear,
      'fuelType': effectiveFuelType,
      'vehicleFuelType': effectiveFuelType,
      'vehicleNumberPlate': vehicleNumberPlate,
      'vehicleColor': vehicleColor ?? 'Grey',
      'carImage': effectiveCarImage,
      'carImages': effectiveCarImages,
      'vehiclePhotos': effectiveCarImage,
      'drivingLicenseNumber': drivingLicenseNumber ?? 'DL-AP-202600110',
      'drivingLicenseDocument': drivingLicenseDocument ?? '/uploads/dl_vamsi.png',
      'rcDocument': rcDocument ?? '/uploads/rc_vamsi.png',
      'pollutionDocument': pollutionDocument ?? '/uploads/pollution_vamsi.png',
      'driverPhoto': driverPhoto ?? '/uploads/photo_vamsi.png',
    };

    return await ApiService.post('/drivers/onboarding', body);
  }

  // 3. Driver Status Check API (Mobile App Flow)
  // Endpoint: GET /drivers/status?id=... or GET /drivers/status?phone=...
  static Future<Map<String, dynamic>> getDriverApprovalStatus({
    String? driverId,
    String? phone,
  }) async {
    try {
      String queryParam = '';
      if (driverId != null && driverId.isNotEmpty) {
        queryParam = '?id=$driverId';
      } else if (phone != null && phone.isNotEmpty) {
        final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
        final tenDigitPhone = cleanPhone.length >= 10 ? cleanPhone.substring(cleanPhone.length - 10) : cleanPhone;
        queryParam = '?phone=$tenDigitPhone';
      }

      final res = await ApiService.get('/drivers/status$queryParam');
      if (res['success'] == true) {
        final isApproved = res['isApproved'] == true ||
            (res['status']?.toString().toLowerCase() == 'active' &&
                res['kyc']?.toString().toLowerCase() == 'verified');
        return {
          'success': true,
          'status': res['status'] ?? 'pending',
          'kyc': res['kyc'] ?? 'pending',
          'isApproved': isApproved,
          'canAccessDashboard': isApproved,
          'message': res['message'] ?? (isApproved ? 'Approved' : 'Under Review'),
          'driver': res['driver'],
        };
      }
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch driver approval status: $e',
        'isApproved': false,
      };
    }
  }

  // 4. Quick Check Driver Admin Approval Status (Boolean)
  static Future<bool> checkAdminApproval(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final tenDigitPhone = cleanPhone.length >= 10 ? cleanPhone.substring(cleanPhone.length - 10) : cleanPhone;

    // 🚀 Check Backend API endpoint: GET /drivers/status?phone=...
    final statusResult = await getDriverApprovalStatus(phone: tenDigitPhone);
    if (statusResult['success'] == true) {
      return statusResult['isApproved'] == true;
    }

    // 🚀 Check persistent approval state in SharedPreferences fallback
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('driver_approved_$cleanPhone')) {
        return prefs.getBool('driver_approved_$cleanPhone') ?? false;
      }
      if (prefs.containsKey('driver_approved_$tenDigitPhone')) {
        return prefs.getBool('driver_approved_$tenDigitPhone') ?? false;
      }
      return prefs.getBool('driver_onboarded_$cleanPhone') ?? false;
    } catch (_) {
      return false;
    }
  }

  // 5. Admin Approval / Rejection API (Admin Panel Action)
  // Endpoint: PATCH /drivers/:id/kyc
  static Future<Map<String, dynamic>> updateDriverKYCByAdmin({
    required String driverId,
    required String kyc, // "verified" | "rejected" | "pending"
    required String status, // "active" | "suspended" | "pending"
  }) async {
    final body = {
      'kyc': kyc,
      'status': status,
    };
    return await ApiService.patch('/drivers/$driverId/kyc', body);
  }

  // 7. Driver Home Dashboard Summary API (Mobile)
  // Endpoint: GET /drivers/dashboard-summary
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final res = await ApiService.get('/drivers/dashboard-summary');
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch dashboard summary: $e',
      };
    }
  }

  // 8. Driver Availability Switch API (Online / Offline Toggle)
  // Endpoints: PATCH /drivers/availability | POST /drivers/availability | POST /drivers/toggle-availability
  static Future<Map<String, dynamic>> switchAvailability({
    required bool isOnline,
    String? phone,
    String? userId,
    String? driverId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'isOnline': isOnline,
      };
      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone;
        body['mobileNumber'] = phone;
      }
      if (userId != null && userId.isNotEmpty) {
        body['userId'] = userId;
        body['id'] = userId;
      }
      if (driverId != null && driverId.isNotEmpty) {
        body['driverId'] = driverId;
      }

      var res = await ApiService.patch('/drivers/availability', body);
      if (res['success'] != true) {
        res = await ApiService.post('/drivers/availability', body);
      }
      if (res['success'] != true) {
        res = await ApiService.post('/drivers/toggle-availability', body);
      }
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to toggle availability: $e',
      };
    }
  }

  // 9. Dedicated Driver Rides List API (Scoped by Driver & Tab)
  // Endpoint: GET /api/drivers/:driverId/rides?tab=[active|upcoming|completed|cancelled]
  static Future<Map<String, dynamic>> getDriverRides({
    required String driverId,
    String tab = 'active',
  }) async {
    try {
      final cleanDriverId = driverId.trim();
      final cleanTab = tab.trim().toLowerCase();
      final endpoint = '/drivers/$cleanDriverId/rides?tab=$cleanTab';

      final res = await ApiService.get(endpoint);
      if (res['success'] == true) {
        return res;
      }
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch driver rides: $e',
        'count': 0,
        'rides': [],
        'tabs': [],
      };
    }
  }

  /// Helper to resolve the authenticated driver ID from SharedPreferences or fallback sources
  static Future<String> resolveCurrentDriverId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('driverId') ??
          prefs.getString('driver_id') ??
          prefs.getString('currentDriverId') ??
          prefs.getString('userId');
      if (savedId != null && savedId.trim().isNotEmpty) {
        return savedId.trim();
      }

      final currentPhone = prefs.getString('currentPhone') ?? '';
      if (currentPhone.isNotEmpty) {
        final statusRes = await getDriverApprovalStatus(phone: currentPhone);
        if (statusRes['success'] == true && statusRes['driver'] != null) {
          final driverObj = statusRes['driver'];
          final id = driverObj['id'] ?? driverObj['_id'] ?? driverObj['driverId'];
          if (id != null && id.toString().isNotEmpty) {
            final strId = id.toString().trim();
            await prefs.setString('driverId', strId);
            return strId;
          }
        }
      }

      // Fallback to Dashboard Summary query
      final summary = await getDashboardSummary();
      if (summary['success'] == true) {
        final profile = summary['driverProfile'] ?? summary['driver'] ?? summary;
        if (profile is Map) {
          final id = profile['driverId'] ?? profile['id'] ?? profile['_id'];
          if (id != null && id.toString().isNotEmpty) {
            final strId = id.toString().trim();
            await prefs.setString('driverId', strId);
            return strId;
          }
        }
      }
    } catch (_) {}

    return 'DRV-MADHAV-001'; // Default active driver fallback
  }

  // 9b. Driver Upcoming Rides List API (Mobile Fallback)
  // Endpoint: GET /drivers/upcoming-rides?driverId=:driverId&tab=:tab (fallback to /rides?status=scheduled)
  static Future<Map<String, dynamic>> getUpcomingRides({String? driverId, String tab = 'upcoming'}) async {
    try {
      if (driverId != null && driverId.isNotEmpty) {
        final scopedRes = await getDriverRides(driverId: driverId, tab: tab);
        if (scopedRes['success'] == true && scopedRes['rides'] is List) {
          return {
            'success': true,
            'upcomingRides': scopedRes['rides'],
            'rides': scopedRes['rides'],
          };
        }
      }

      final queryParams = <String>[];
      if (driverId != null && driverId.isNotEmpty) queryParams.add('driverId=${Uri.encodeComponent(driverId)}');
      if (tab.isNotEmpty) queryParams.add('tab=${Uri.encodeComponent(tab)}');
      final qs = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';

      var res = await ApiService.get('/drivers/upcoming-rides$qs');
      if (res['success'] == true) {
        return res;
      }

      final rideQuery = <String>['status=scheduled'];
      if (driverId != null && driverId.isNotEmpty) rideQuery.add('driverId=${Uri.encodeComponent(driverId)}');
      final rideQs = '?${rideQuery.join('&')}';

      final fallbackRes = await ApiService.get('/rides$rideQs');
      if (fallbackRes['success'] == true && fallbackRes['rides'] is List) {
        return {
          'success': true,
          'upcomingRides': fallbackRes['rides'],
          'rides': fallbackRes['rides'],
        };
      }
      return fallbackRes;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch upcoming rides: $e',
      };
    }
  }

  // 10. GET Driver Personal Information (View Profile)
  // Endpoint: GET /drivers/profile/personal
  static Future<Map<String, dynamic>> getPersonalInfo({String? phone}) async {
    try {
      String query = '';
      if (phone != null && phone.isNotEmpty) {
        final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
        final ten = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
        query = '?phone=$ten';
      }
      final res = await ApiService.get('/drivers/profile/personal$query');
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch personal info: $e',
      };
    }
  }

  // 11. PUT Update Driver Personal Information (Edit Profile)
  // Endpoint: PUT /drivers/profile/personal
  static Future<Map<String, dynamic>> updatePersonalInfo({
    required String fullName,
    required String phoneNumber,
    required String email,
    String? location,
    String? city,
    String? state,
    String? country,
  }) async {
    try {
      final body = {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'email': email,
        if (location != null) 'location': location,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (country != null) 'country': country,
      };
      final res = await ApiService.put('/drivers/profile/personal', body);
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update personal info: $e',
      };
    }
  }

  // 12. GET Driver Vehicle Information
  // Endpoint: GET /drivers/profile/vehicle
  static Future<Map<String, dynamic>> getVehicleInfo({String? phone}) async {
    try {
      String query = '';
      if (phone != null && phone.isNotEmpty) {
        final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
        final ten = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
        query = '?phone=$ten';
      }
      final res = await ApiService.get('/drivers/profile/vehicle$query');
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch vehicle info: $e',
      };
    }
  }

  // 13. PUT Update Driver Vehicle Information
  // Endpoint: PUT /drivers/profile/vehicle
  static Future<Map<String, dynamic>> updateVehicleInfo({
    String? vehicleName,
    String? vehicleMake,
    String? vehicleModel,
    String? vehicleType,
    String? vehicleNumberPlate,
    String? fuelType,
    String? capacity,
    String? vehicleYear,
  }) async {
    try {
      final body = {
        if (vehicleName != null) 'vehicleName': vehicleName,
        if (vehicleMake != null) 'vehicleMake': vehicleMake,
        if (vehicleModel != null) 'vehicleModel': vehicleModel,
        if (vehicleType != null) 'vehicleType': vehicleType,
        if (vehicleNumberPlate != null) 'vehicleNumberPlate': vehicleNumberPlate,
        if (fuelType != null) 'fuelType': fuelType,
        if (capacity != null) 'capacity': capacity,
        if (vehicleYear != null) 'vehicleYear': vehicleYear,
      };
      final res = await ApiService.put('/drivers/profile/vehicle', body);
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update vehicle info: $e',
      };
    }
  }

  // 14. GET Driver Driving License Information
  // Endpoint: GET /drivers/profile/license
  static Future<Map<String, dynamic>> getDrivingLicenseInfo({String? phone}) async {
    try {
      String query = '';
      if (phone != null && phone.isNotEmpty) {
        final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
        final ten = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
        query = '?phone=$ten';
      }
      final res = await ApiService.get('/drivers/profile/license$query');
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch license info: $e',
      };
    }
  }

  // 15. PUT Update Driver Driving License Information
  // Endpoint: PUT /drivers/profile/license
  static Future<Map<String, dynamic>> updateDrivingLicenseInfo({
    required String licenseNumber,
    String? licenseType,
    String? validity,
    String? documentUrl,
  }) async {
    try {
      final body = {
        'licenseNumber': licenseNumber,
        if (licenseType != null) 'licenseType': licenseType,
        if (validity != null) 'validity': validity,
        if (documentUrl != null) 'documentUrl': documentUrl,
      };
      final res = await ApiService.put('/drivers/profile/license', body);
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update license info: $e',
      };
    }
  }

  // 16. GET Driver Bank Account Information
  // Endpoint: GET /drivers/profile/bank
  static Future<Map<String, dynamic>> getBankAccountInfo({String? phone}) async {
    try {
      String query = '';
      if (phone != null && phone.isNotEmpty) {
        final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
        final ten = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
        query = '?phone=$ten';
      }
      final res = await ApiService.get('/drivers/profile/bank$query');
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch bank account info: $e',
      };
    }
  }

  // 17. PUT Update Driver Bank Account Information
  // Endpoint: PUT /drivers/profile/bank
  static Future<Map<String, dynamic>> updateBankAccountInfo({
    required String accountHolder,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
  }) async {
    try {
      final body = {
        'accountHolder': accountHolder,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'ifscCode': ifscCode,
      };
      final res = await ApiService.put('/drivers/profile/bank', body);
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update bank account info: $e',
      };
    }
  }

  // 18. Change Password API
  // Endpoint: PUT /drivers/profile/change-password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final body = {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };
      final res = await ApiService.put('/drivers/profile/change-password', body);
      if (res['success'] != true) {
        // Fallback to /auth/change-password if driver endpoint returns 404
        return await ApiService.post('/auth/change-password', body);
      }
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to change password: $e',
      };
    }
  }

  // 19. Get Driver Notifications API (Generic)
  // Endpoint: GET /drivers/notifications or GET /notifications
  static Future<Map<String, dynamic>> getDriverNotifications({String? filter}) async {
    try {
      final queryParam = filter != null && filter != 'ALL' ? '?type=${filter.toLowerCase()}' : '';
      final res = await ApiService.get('/drivers/notifications$queryParam');
      if (res['success'] == true) {
        return res;
      }
      return await ApiService.get('/notifications$queryParam');
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch notifications: $e',
        'notifications': [],
      };
    }
  }

  // 20. Screen 99: Get Driver Notifications & Booking Requests by Tab
  // Endpoint: GET /drivers/notifications?tab=booking_requests | confirmed | denied | other
  static Future<Map<String, dynamic>> getDriverNotificationsByTab({required String tab}) async {
    try {
      final res = await ApiService.get('/drivers/notifications?tab=${Uri.encodeComponent(tab)}');
      if (res['success'] == true) {
        return res;
      }
      // Fallback
      return await ApiService.get('/notifications?tab=${Uri.encodeComponent(tab)}');
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch $tab tab data: $e',
        'items': [],
      };
    }
  }

  // 21. Screen 99: Accept Booking Request
  // Endpoint: POST /drivers/booking-requests/:bookingId/accept
  static Future<Map<String, dynamic>> acceptBookingRequest({required String bookingId}) async {
    try {
      var res = await ApiService.post('/drivers/booking-requests/$bookingId/accept', {});
      if (res['success'] != true) {
        res = await ApiService.patch('/drivers/booking-requests/$bookingId/accept', {});
      }
      if (res['success'] != true) {
        res = await ApiService.patch('/bookings/$bookingId/status', {'status': 'confirmed'});
      }
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to accept booking: $e',
      };
    }
  }

  // 22. Screen 99: Decline Booking Request
  // Endpoint: POST /drivers/booking-requests/:bookingId/decline
  static Future<Map<String, dynamic>> declineBookingRequest({
    required String bookingId,
    String reason = 'Seat capacity full or route unavailable',
  }) async {
    try {
      final body = {'reason': reason};
      var res = await ApiService.post('/drivers/booking-requests/$bookingId/decline', body);
      if (res['success'] != true) {
        res = await ApiService.patch('/drivers/booking-requests/$bookingId/decline', body);
      }
      if (res['success'] != true) {
        res = await ApiService.post('/drivers/booking-requests/$bookingId/deny', body);
      }
      if (res['success'] != true) {
        res = await ApiService.patch('/bookings/$bookingId/status', {'status': 'cancelled'});
      }
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to decline booking: $e',
      };
    }
  }

  // 23. Screen 99: View Booking Request Details
  // Endpoint: GET /drivers/booking-requests/:bookingId
  static Future<Map<String, dynamic>> getBookingRequestDetails({required String bookingId}) async {
    try {
      final res = await ApiService.get('/drivers/booking-requests/$bookingId');
      if (res['success'] == true) {
        return res;
      }
      return await ApiService.get('/drivers/bookings/$bookingId');
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch booking details: $e',
      };
    }
  }

  // 24. Screen 82: Driver Fuel Share & Earnings History API
  // Endpoint: GET /drivers/fuel-share?filter=...&startDate=...&endDate=...&page=...&limit=...&search=...
  static Future<Map<String, dynamic>> getFuelShareHistory({
    String filter = 'this_month',
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 5,
    String? search,
  }) async {
    try {
      final queryParams = <String>[];
      if (filter.isNotEmpty) {
        queryParams.add('filter=${Uri.encodeComponent(filter)}');
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams.add('startDate=${Uri.encodeComponent(startDate)}');
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams.add('endDate=${Uri.encodeComponent(endDate)}');
      }
      queryParams.add('page=$page');
      queryParams.add('limit=$limit');
      if (search != null && search.isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(search)}');
      }

      final qs = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final res = await ApiService.get('/drivers/fuel-share$qs');
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch fuel share history: $e',
      };
    }
  }

  // 25. Delete / Cancel Upcoming Ride API
  // Endpoints: DELETE /rides/:id | DELETE /drivers/rides/:id | POST /rides/:id/cancel
  static Future<Map<String, dynamic>> deleteRide(String rideId, {String? reason}) async {
    try {
      if (rideId.isEmpty) {
        return {'success': false, 'message': 'Invalid ride ID.'};
      }

      // 1. Try primary REST DELETE /rides/:id
      var res = await ApiService.delete('/rides/$rideId');
      if (res['success'] == true) return res;

      // 2. Try DELETE /drivers/rides/:id
      res = await ApiService.delete('/drivers/rides/$rideId');
      if (res['success'] == true) return res;

      // 3. Try POST /rides/:id/cancel
      res = await ApiService.post('/rides/$rideId/cancel', {
        'reason': reason ?? 'Driver deleted upcoming ride',
        'status': 'cancelled',
      });
      if (res['success'] == true) return res;

      // 4. Try PATCH /rides/:id
      res = await ApiService.patch('/rides/$rideId', {
        'status': 'cancelled',
      });
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete ride: $e',
      };
    }
  }
}

