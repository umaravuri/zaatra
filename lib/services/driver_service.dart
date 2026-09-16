import 'package:shared_preferences/shared_preferences.dart';
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
      'password': password ?? 'DriverSecretPassword123',
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

  // 9. Driver Upcoming Rides List API (Mobile)
  // Endpoint: GET /rides?status=scheduled (fallback to /drivers/upcoming-rides)
  static Future<Map<String, dynamic>> getUpcomingRides() async {
    try {
      final res = await ApiService.get('/rides?status=scheduled');
      if (res['success'] == true && res['rides'] is List) {
        return {
          'success': true,
          'upcomingRides': res['rides'],
          'rides': res['rides'],
        };
      }
      final fallbackRes = await ApiService.get('/drivers/upcoming-rides');
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

  // 19. Get Driver Notifications API
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
}
