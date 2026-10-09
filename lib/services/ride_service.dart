import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/ride_booking_model.dart';

class RideService {
  /// Ride Search API: POST /api/rides/search or GET /api/rides/search
  static Future<Map<String, dynamic>> searchRides({
    required String pickupLocation,
    required String destination,
    String? date,
    int? passengers,
  }) async {
    try {
      final seatCount = (passengers != null && passengers > 0) ? passengers : 1;
      final body = <String, dynamic>{
        'pickup': pickupLocation,
        'pickupLocation': pickupLocation,
        'destination': destination,
        if (date != null && date.isNotEmpty) 'date': date,
        'seats': seatCount,
        'passengers': seatCount,
      };

      final postRes = await ApiService.post('/rides/search', body);
      if (postRes['success'] == true) return postRes;

      // Fallback to GET query params
      final queryParams = <String>[
        'pickupLocation=${Uri.encodeComponent(pickupLocation)}',
        'destination=${Uri.encodeComponent(destination)}',
      ];
      if (date != null && date.isNotEmpty) {
        queryParams.add('date=${Uri.encodeComponent(date)}');
      }
      queryParams.add('passengers=$seatCount');

      final url = '/rides/search?${queryParams.join('&')}';
      return await ApiService.get(url);
    } catch (e) {
      try {
        final seatCount = (passengers != null && passengers > 0) ? passengers : 1;
        final queryParams = <String>[
          'pickupLocation=${Uri.encodeComponent(pickupLocation)}',
          'destination=${Uri.encodeComponent(destination)}',
        ];
        if (date != null && date.isNotEmpty) {
          queryParams.add('date=${Uri.encodeComponent(date)}');
        }
        queryParams.add('passengers=$seatCount');

        final url = '/rides/search?${queryParams.join('&')}';
        return await ApiService.get(url);
      } catch (_) {
        return {
          'success': false,
          'message': 'Failed to search rides: $e',
          'rides': [],
        };
      }
    }
  }

  /// Driver Details & Timeline API: GET /api/rides/:id (or /api/rides/:id/details)
  /// Supports optional segment query parameters (pickup, destination) for dynamic segment fare calculation.
  static Future<Map<String, dynamic>> getRideDetails(
    String rideId, {
    String? pickup,
    String? destination,
  }) async {
    final queryParams = <String>[];
    if (pickup != null && pickup.trim().isNotEmpty) {
      queryParams.add('pickup=${Uri.encodeComponent(pickup.trim())}');
      queryParams.add('pickupLocation=${Uri.encodeComponent(pickup.trim())}');
    }
    if (destination != null && destination.trim().isNotEmpty) {
      queryParams.add('destination=${Uri.encodeComponent(destination.trim())}');
    }
    final qs = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';

    try {
      final response = await ApiService.get('/rides/$rideId$qs');
      if (response['success'] == true) return response;
      return await ApiService.get('/rides/$rideId/details$qs');
    } catch (e) {
      try {
        return await ApiService.get('/rides/$rideId/details$qs');
      } catch (_) {
        return {
          'success': false,
          'message': 'Failed to get ride details: $e',
        };
      }
    }
  }

  /// Select Boarding Point API: GET /api/rides/:id/boarding-points
  static Future<Map<String, dynamic>> getBoardingPoints(String rideId) async {
    try {
      final response = await ApiService.get('/rides/$rideId/boarding-points');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get boarding points: $e',
        'boardingPoints': [],
      };
    }
  }

  /// Search Configuration & Placeholders API: GET /api/rides/search-config (or /api/rides/search-metadata)
  static Future<Map<String, dynamic>> getSearchConfig() async {
    try {
      final res = await ApiService.get('/rides/search-config');
      if (res['success'] == true) return res;
      return await ApiService.get('/rides/search-metadata');
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get search config: $e',
      };
    }
  }

  /// Step 1: Submit Passenger Details API: POST /api/rides/book
  static Future<Map<String, dynamic>> createBooking({
    required String rideId,
    required String fullName,
    required String lastName,
    required String phoneNumber,
    required String emailID,
    required int numberOfSeats,
    required String boardingPoint,
    required String destination,
    String? pickup,
    String? customerPickupAddress,
    String? customerPickupPincode,
    String? customerPickupLandmark,
    String? custPickupLandmark,
    String? customerDropLandmark,
    String? paymentMethod,
    bool? doorstepPickupRequested,
    num? extraPickupCharge,
    num? pricePerSeat,
    num? totalAmount,
    String? luggage,
  }) async {
    try {
      final landmark = customerPickupLandmark ?? custPickupLandmark ?? "";
      final payload = <String, dynamic>{
        "rideId": rideId,
        "fullName": fullName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "emailID": emailID,
        "numberOfSeats": numberOfSeats,
        "boardingPoint": boardingPoint,
        "destination": destination,
        "pickup": (pickup != null && pickup.isNotEmpty) ? pickup : boardingPoint,
        "customerPickupAddress": (customerPickupAddress != null && customerPickupAddress.isNotEmpty) ? customerPickupAddress : boardingPoint,
        "customerPickupPincode": customerPickupPincode ?? "",
        "customerPickupLandmark": landmark,
        "custPickupLandmark": landmark,
        if (customerDropLandmark != null && customerDropLandmark.isNotEmpty) "customerDropLandmark": customerDropLandmark,
        if (paymentMethod != null && paymentMethod.isNotEmpty) "paymentMethod": paymentMethod,
        "doorstepPickupRequested": doorstepPickupRequested ?? false,
        "extraPickupCharge": extraPickupCharge ?? 0,
        "pricePerSeat": pricePerSeat ?? 0,
        "totalAmount": totalAmount ?? 0,
        "luggage": luggage ?? "1 Medium Bag",
      };

      final response = await ApiService.post('/rides/book', payload);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create booking: $e',
      };
    }
  }

  /// Step 2: Payment Verification & Confirmation API: POST /api/payments/verify
  static Future<Map<String, dynamic>> verifyPayment({
    required String bookingId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String method,
  }) async {
    try {
      final payload = {
        "bookingId": bookingId,
        "razorpayOrderId": razorpayOrderId,
        "razorpayPaymentId": razorpayPaymentId,
        "razorpaySignature": razorpaySignature,
        "method": method,
      };

      final response = await ApiService.post('/payments/verify', payload);
      debugPrint('🔍 [Payment Verify Response] $response');
      return response;
    } catch (e) {
      debugPrint('❌ [Payment Verify Error] $e');
      return {
        'success': false,
        'message': 'Payment verification failed: $e',
      };
    }
  }

  /// API 1: Get Ride Confirmation Screen Payload: GET /api/rides/bookings/:id/confirmation (or /api/bookings/:id/confirmation)
  static Future<Map<String, dynamic>> getRideConfirmation(String bookingId) async {
    try {
      final cleanId = bookingId.trim().replaceAll('#', '');
      var res = await ApiService.get('/rides/bookings/$cleanId/confirmation');
      if (res['success'] == true) return res;

      res = await ApiService.get('/bookings/$cleanId/confirmation');
      if (res['success'] == true) return res;

      return await ApiService.get('/bookings/$cleanId');
    } catch (e) {
      try {
        final cleanId = bookingId.trim().replaceAll('#', '');
        return await ApiService.get('/bookings/$cleanId/confirmation');
      } catch (_) {
        return {
          'success': false,
          'message': 'Failed to fetch ride confirmation: $e',
        };
      }
    }
  }

  /// API 2: Get View Trip Details & Digital Pass: GET /api/rides/bookings/:id/pass (or /api/bookings/:id/trip-details)
  static Future<Map<String, dynamic>> getTripPassDetails(String bookingId) async {
    try {
      final cleanId = bookingId.trim().replaceAll('#', '');
      var res = await ApiService.get('/rides/bookings/$cleanId/pass');
      if (res['success'] == true) return res;

      res = await ApiService.get('/bookings/$cleanId/trip-details');
      if (res['success'] == true) return res;

      return await ApiService.get('/rides/bookings/$cleanId/trip-details');
    } catch (e) {
      try {
        final cleanId = bookingId.trim().replaceAll('#', '');
        return await ApiService.get('/bookings/$cleanId/trip-details');
      } catch (_) {
        return {
          'success': false,
          'message': 'Failed to fetch trip pass details: $e',
        };
      }
    }
  }

  /// API 3: Cancel Booking: POST /api/bookings/:id/cancel
  static Future<Map<String, dynamic>> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final cleanId = bookingId.trim().replaceAll('#', '');
      final body = <String, dynamic>{
        'reason': reason ?? 'Cancelled by passenger',
      };
      var res = await ApiService.post('/bookings/$cleanId/cancel', body);
      if (res['success'] == true) return res;

      res = await ApiService.post('/rides/bookings/$cleanId/cancel', body);
      if (res['success'] == true) return res;

      return await ApiService.delete('/bookings/$cleanId');
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to cancel booking: $e',
      };
    }
  }

  /// Scenario 1: Pre-Trip / Scheduled Route Stays: GET /api/properties/along-route?from=...&to=...&limit=10
  static Future<Map<String, dynamic>> getPropertiesAlongRoute({
    required String from,
    required String to,
    int limit = 10,
  }) async {
    try {
      final queryParams = [
        'from=${Uri.encodeComponent(from)}',
        'to=${Uri.encodeComponent(to)}',
        'limit=$limit',
      ];
      final res = await ApiService.get('/properties/along-route?${queryParams.join('&')}');
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch properties along route: $e',
        'properties': [],
      };
    }
  }

  /// Scenario 2: Live In-Trip Real-Time GPS Tracking: GET /api/properties/nearby-live?lat=...&lng=...&radiusKm=15
  static Future<Map<String, dynamic>> getNearbyLiveProperties({
    required double lat,
    required double lng,
    double radiusKm = 15,
    int limit = 5,
  }) async {
    try {
      final queryParams = [
        'lat=$lat',
        'lng=$lng',
        'radiusKm=$radiusKm',
        'limit=$limit',
      ];
      final res = await ApiService.get('/properties/nearby-live?${queryParams.join('&')}');
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch live nearby properties: $e',
        'properties': [],
        'propertyMarkers': [],
      };
    }
  }

  /// Helper for session-based booking
  static Future<Map<String, dynamic>> bookRide(RideBookingSession session) async {
    return createBooking(
      rideId: session.rideId,
      fullName: session.passengerName,
      lastName: session.passengerName.split(' ').length > 1 ? session.passengerName.split(' ').sublist(1).join(' ') : '',
      phoneNumber: session.passengerPhone,
      emailID: session.passengerEmail,
      numberOfSeats: session.seatsCount,
      boardingPoint: session.boardingPoint.isNotEmpty ? session.boardingPoint : session.pickup,
      destination: session.destination,
      pickup: session.pickup,
      customerPickupAddress: session.customerPickupAddress,
      customerPickupPincode: session.customerPickupPincode,
      customerPickupLandmark: session.customerPickupLandmark,
      custPickupLandmark: session.customerPickupLandmark,
      doorstepPickupRequested: session.isDoorstepPickup,
      extraPickupCharge: session.detourCharge,
      pricePerSeat: session.driver.pricePerSeat,
      totalAmount: session.totalAmount,
      luggage: session.luggage,
    );
  }

  /// Calls POST /api/rides to publish a new intercity shared ride
  static Future<Map<String, dynamic>> createRide(Map<String, dynamic> rideData) async {
    try {
      final response = await ApiService.post('/rides', rideData);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create ride: $e',
      };
    }
  }

  /// Calls PUT /api/rides/:rideId to update ride details (price, pickup, seats, etc.)
  static Future<Map<String, dynamic>> updateRide({
    required String rideId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final response = await ApiService.put('/rides/$rideId', updateData);
      if (response['success'] == true) return response;
      // Fallback to PATCH if PUT is not defined
      final patchResponse = await ApiService.patch('/rides/$rideId', updateData);
      return patchResponse;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update ride: $e',
      };
    }
  }

  /// Unified API: GET /api/rides with query filtering (?status=, ?driverId=, ?search=)
  static Future<Map<String, dynamic>> getRides({
    String? status,
    String? driverId,
    String? from,
    String? to,
    String? search,
  }) async {
    try {
      final queryParams = <String>[];
      if (status != null && status.isNotEmpty) queryParams.add('status=${Uri.encodeComponent(status)}');
      if (driverId != null && driverId.isNotEmpty) queryParams.add('driverId=${Uri.encodeComponent(driverId)}');
      if (from != null && from.isNotEmpty) queryParams.add('from=${Uri.encodeComponent(from)}');
      if (to != null && to.isNotEmpty) queryParams.add('to=${Uri.encodeComponent(to)}');
      if (search != null && search.isNotEmpty) queryParams.add('search=${Uri.encodeComponent(search)}');

      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final res = await ApiService.get('/rides$queryString');
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch rides: $e',
        'rides': [],
      };
    }
  }

  /// API 1 & 2: GET /api/rides/active/start-details or /api/rides/{rideId}/start-details
  static Future<Map<String, dynamic>> getRideStartDetails({String? rideId}) async {
    final endpoint = (rideId != null && rideId.isNotEmpty && rideId != 'active')
        ? '/rides/$rideId/start-details'
        : '/rides/active/start-details';

    try {
      final res = await ApiService.get(endpoint);
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get ride start details: $e',
      };
    }
  }

  /// API 3: POST /api/rides/{rideId}/send-message-all
  static Future<Map<String, dynamic>> sendBroadcastMessage({
    required String rideId,
    required String message,
  }) async {
    try {
      final res = await ApiService.post('/rides/$rideId/send-message-all', {'message': message});
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send broadcast message: $e',
      };
    }
  }

  /// Price per Seat Calculation: computes formula: distanceKm * basePricePerKm
  static Future<Map<String, dynamic>> calculatePricePerSeat({
    required double distanceKm,
    required double basePricePerKm,
    int? seats,
    String? from,
    String? to,
  }) async {
    final calculated = (distanceKm * basePricePerKm).roundToDouble();
    return {
      'success': true,
      'pricePerSeat': calculated,
      'totalDistanceKm': distanceKm,
      'basePricePerKm': basePricePerKm,
    };
  }

  /// Calculate Route, Distance & Polyline: POST /api/rides/calculate-route
  static Future<Map<String, dynamic>> calculateRoute({
    required String from,
    required String to,
    List<Map<String, dynamic>>? intermediatePickups,
  }) async {
    try {
      final payload = {
        'from': from,
        'to': to,
        if (intermediatePickups != null && intermediatePickups.isNotEmpty)
          'intermediatePickups': intermediatePickups,
      };
      final res = await ApiService.post('/rides/calculate-route', payload);
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to calculate route: $e',
      };
    }
  }

  /// Auto-Suggest Intermediate Stop Fares API: POST /api/rides/calculate-intermediate-fares

  static Future<Map<String, dynamic>> calculateIntermediateFares({
    required String from,
    required String to,
    required num price,
    required List<Map<String, dynamic>> intermediatePickups,
  }) async {
    try {
      final payload = {
        'from': from,
        'to': to,
        'price': price,
        'intermediatePickups': intermediatePickups,
      };
      final res = await ApiService.post('/rides/calculate-intermediate-fares', payload);
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to calculate intermediate fares: $e',
      };
    }
  }

  /// Driver Detour Decision: POST /api/rides/detour-response
  /// Driver accepts or declines customer's doorstep detour request (> 10 km)
  static Future<Map<String, dynamic>> respondToDetourRequest({
    required String requestId,
    required String rideId,
    required String action, // 'accept' or 'decline'
    String? customerName,
    String? customerPhone,
    String? pickupAddress,
    String? destinationAddress,
    num? detourDistanceKm,
    int? seats,
  }) async {
    try {
      final payload = <String, dynamic>{
        'requestId': requestId,
        'rideId': rideId,
        'action': action,
        if (customerName != null) 'customerName': customerName,
        if (customerPhone != null) 'customerPhone': customerPhone,
        if (pickupAddress != null) 'pickupAddress': pickupAddress,
        if (destinationAddress != null) 'destinationAddress': destinationAddress,
        if (detourDistanceKm != null) 'detourDistanceKm': detourDistanceKm,
        if (seats != null) 'seats': seats,
      };

      final response = await ApiService.post('/rides/detour-response', payload);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to submit detour decision: $e',
      };
    }
  }

  /// Contactless QR Code Pass Boarding: POST /api/rides/verify-qr-pass
  /// Driver scans passenger's live QR pass token for instant boarding and payment validation
  static Future<Map<String, dynamic>> verifyQrPass({
    required String token,
    String? bookingId,
    String? rideId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'token': token,
        'qrPassToken': token,
        if (bookingId != null && bookingId.isNotEmpty) 'bookingId': bookingId,
        if (rideId != null && rideId.isNotEmpty) 'rideId': rideId,
      };

      final response = await ApiService.post('/rides/verify-qr-pass', payload);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to verify QR Code Pass: $e',
      };
    }
  }

  /// Driver Arrival Notification: POST /api/rides/:id/driver-arrived
  /// Driver signals arrival at passenger's pickup location
  static Future<Map<String, dynamic>> driverArrivedAtPickup({
    required String rideId,
  }) async {
    try {
      final response = await ApiService.post('/rides/$rideId/driver-arrived', {});
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to signal driver arrival: $e',
      };
    }
  }

  /// Passenger Verification Details: GET /api/rides/:id/passengers/:bookingId/verify-details
  static Future<Map<String, dynamic>> getPassengerVerifyDetails({
    String? rideId,
    required String bookingId,
    String? passengerName,
  }) async {
    try {
      if (rideId != null && rideId.isNotEmpty) {
        final res = await ApiService.get('/rides/$rideId/passengers/$bookingId/verify-details');
        if (res['success'] == true) return res;
      }
      final fallbackRes = await ApiService.get('/rides/passengers/$bookingId/verify-details');
      return fallbackRes;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get passenger verification details: $e',
      };
    }
  }

  /// Validate 4-digit PIN: POST /api/rides/{rideId}/verify-pin
  static Future<Map<String, dynamic>> verifyPassengerPin({
    required String rideId,
    String? bookingId,
    required String pin,
    String? seatNumber,
    String? passengerName,
    String? expectedPin,
  }) async {
    try {
      final payload = {
        if (bookingId != null && bookingId.isNotEmpty) 'bookingId': bookingId,
        'pin': pin,
        if (seatNumber != null && seatNumber.isNotEmpty) 'seatNumber': seatNumber,
        if (passengerName != null && passengerName.isNotEmpty) 'passengerName': passengerName,
      };
      final response = await ApiService.post('/rides/$rideId/verify-pin', payload);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to verify PIN: $e',
      };
    }
  }

  /// API 6: POST /api/rides/{rideId}/start-ride or /api/rides/{rideId}/start-navigation
  static Future<Map<String, dynamic>> startNavigation({
    required String rideId,
    String? origin,
    String? destination,
  }) async {
    try {
      var res = await ApiService.post('/rides/$rideId/start-ride', {});
      if (res['statusCode'] == 404) {
        res = await ApiService.post('/rides/$rideId/start-navigation', {});
      }
      
      final data = res['data'] is Map ? res['data'] as Map<String, dynamic> : res;
      final isLocked = data['isLocked'] == true || res['isLocked'] == true;
      
      return {
        ...res,
        ...data,
        'isLocked': isLocked,
        'lockReason': data['lockReason'] ?? data['message'] ?? res['message'] ?? '',
        'startRideAllowedFrom': data['startRideAllowedFrom'] ?? '',
        'startRideAllowedFromFormatted': data['startRideAllowedFromFormatted'] ?? '',
        'hoursRemainingUntilStart': data['hoursRemainingUntilStart'],
        'minutesRemainingUntilStart': data['minutesRemainingUntilStart'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to start navigation: $e',
      };
    }
  }

  /// Alias for startNavigation: POST /api/rides/{rideId}/start-ride
  static Future<Map<String, dynamic>> startRide({required String rideId}) async {
    return await startNavigation(rideId: rideId);
  }

  /// Automated 5-Hour Pre-Trip Alarm Dispatch: POST /api/rides/{rideId}/send-pre-trip-alert
  static Future<Map<String, dynamic>> sendPreTripAlert({required String rideId}) async {
    try {
      final res = await ApiService.post('/rides/$rideId/send-pre-trip-alert', {});
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send pre-trip alert: $e',
      };
    }
  }

  /// Batch/Cron Pre-Trip Alarm Dispatch Scanner: GET /api/rides/check-pre-trip-alerts
  static Future<Map<String, dynamic>> checkPreTripAlerts() async {
    try {
      final res = await ApiService.get('/rides/check-pre-trip-alerts');
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to check pre-trip alerts: $e',
      };
    }
  }

  /// API 7: POST /api/rides/{rideId}/complete-ride
  static Future<Map<String, dynamic>> completeRide({
    required String rideId,
  }) async {
    try {
      final res = await ApiService.post('/rides/$rideId/complete-ride', {});
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to complete ride: $e',
      };
    }
  }

  /// API 8 & 9: GET /api/rides/trip-shared or /api/rides/{rideId}/trip-card
  static Future<Map<String, dynamic>> getTripSharedCard({String? rideId}) async {
    final endpoint = (rideId != null && rideId.isNotEmpty && rideId != 'active')
        ? '/rides/$rideId/trip-card'
        : '/rides/trip-shared';

    try {
      final res = await ApiService.get(endpoint);
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get trip card: $e',
      };
    }
  }

  /// API 10: GET /api/rides/next-pickup
  static Future<Map<String, dynamic>> getNextPickupDetails() async {
    try {
      final res = await ApiService.get('/rides/next-pickup');
      return res;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get next pickup details: $e',
      };
    }
  }

  /// API 11: DELETE /api/rides/:id (Delete/Cancel Ride)
  static Future<Map<String, dynamic>> deleteRide(String rideId, {String? reason}) async {
    try {
      if (rideId.isEmpty) {
        return {'success': false, 'message': 'Invalid ride ID.'};
      }

      var res = await ApiService.delete('/rides/$rideId');
      if (res['success'] == true) return res;

      res = await ApiService.delete('/drivers/rides/$rideId');
      if (res['success'] == true) return res;

      res = await ApiService.post('/rides/$rideId/cancel', {
        'reason': reason ?? 'Driver deleted upcoming ride',
        'status': 'cancelled',
      });
      if (res['success'] == true) return res;

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

