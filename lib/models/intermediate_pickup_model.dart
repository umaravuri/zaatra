import 'place_location_model.dart';

/// Data model representing an intermediate pickup point added by a driver.
class IntermediatePickupModel {
  String location;
  String pinCode;
  String? landmark;
  String time;
  String price;
  LocationPoint? locationPoint;

  IntermediatePickupModel({
    required this.location,
    required this.pinCode,
    this.landmark,
    required this.time,
    required this.price,
    this.locationPoint,
  });

  /// Formatted JSON map for future backend POST API payload
  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'pinCode': pinCode,
      'landmark': landmark ?? '',
      'time': time,
      'price': double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? price,
      if (locationPoint != null) ...{
        'latitude': locationPoint!.latitude,
        'longitude': locationPoint!.longitude,
        'formattedAddress': locationPoint!.formattedAddress,
      },
    };
  }

  factory IntermediatePickupModel.fromJson(Map<String, dynamic> json) {
    return IntermediatePickupModel(
      location: json['location']?.toString() ?? '',
      pinCode: json['pinCode']?.toString() ?? '',
      landmark: json['landmark']?.toString(),
      time: json['time']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      locationPoint: json['latitude'] != null && json['longitude'] != null
          ? LocationPoint(
              name: json['location']?.toString() ?? '',
              formattedAddress: json['formattedAddress']?.toString() ?? '',
              latitude: (json['latitude'] as num).toDouble(),
              longitude: (json['longitude'] as num).toDouble(),
            )
          : null,
    );
  }
}
