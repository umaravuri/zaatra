import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/place_location_model.dart';

class GoogleMapsService {
  static const String apiKey = 'AIzaSyBeecni1nLIOjHAWCb3Jof73kI1IeIyz2o';

  static const String _autocompleteBaseUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String _placeDetailsBaseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
  static const String _directionsBaseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  /// 1. Address Search Autocomplete (Live Google Places API)
  /// Endpoint: GET https://maps.googleapis.com/maps/api/place/autocomplete/json
  static Future<List<PlaceAutocompletePrediction>> getAutocompleteSuggestions(
    String query, {
    String countryCode = 'in',
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    try {
      final url = Uri.parse(
        '$_autocompleteBaseUrl?input=${Uri.encodeComponent(trimmed)}&key=$apiKey&components=country:$countryCode',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (status == 'OK' || status == 'ZERO_RESULTS') {
          final predictions = data['predictions'] as List<dynamic>? ?? [];
          return predictions
              .map((p) => PlaceAutocompletePrediction.fromJson(p as Map<String, dynamic>))
              .toList();
        } else {
          debugPrint('Google Autocomplete API: status=$status, message=${data['error_message']}');
        }
      }
    } catch (e) {
      debugPrint('Error calling Google Autocomplete API: $e');
    }
    return [];
  }

  /// 2. Place Details API (Live Google Places Details API)
  /// Endpoint: GET https://maps.googleapis.com/maps/api/place/details/json
  static Future<LocationPoint?> getPlaceDetails(String placeId) async {
    if (placeId.trim().isEmpty) return null;

    try {
      final url = Uri.parse(
        '$_placeDetailsBaseUrl?place_id=$placeId&fields=name,formatted_address,geometry&key=$apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (status == 'OK' && data['result'] != null) {
          return LocationPoint.fromJson(data['result'] as Map<String, dynamic>, placeId: placeId);
        } else {
          debugPrint('Google Place Details API: status=$status, message=${data['error_message']}');
        }
      }
    } catch (e) {
      debugPrint('Error calling Google Place Details API: $e');
    }
    return null;
  }

  /// 3. Google Directions API (Live Google Directions API)
  /// Endpoint: GET https://maps.googleapis.com/maps/api/directions/json
  static Future<RouteResult?> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final url = Uri.parse(
        '$_directionsBaseUrl?origin=$originLat,$originLng&destination=$destLat,$destLng&mode=driving&key=$apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (status == 'OK') {
          return RouteResult.fromJson(data);
        } else {
          debugPrint('Google Directions API: status=$status, message=${data['error_message']}');
        }
      }
    } catch (e) {
      debugPrint('Error calling Google Directions API: $e');
    }
    return null;
  }
}


