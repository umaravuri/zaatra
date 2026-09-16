class PlaceAutocompletePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const PlaceAutocompletePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceAutocompletePrediction.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'] as Map<String, dynamic>?;
    return PlaceAutocompletePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structured?['main_text'] ?? json['description'] ?? '',
      secondaryText: structured?['secondary_text'] ?? '',
    );
  }
}

class LocationPoint {
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String? placeId;

  const LocationPoint({
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.placeId,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json, {String? placeId}) {
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;

    return LocationPoint(
      name: json['name'] ?? json['formatted_address'] ?? 'Selected Location',
      formattedAddress: json['formatted_address'] ?? '',
      latitude: (location?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (location?['lng'] as num?)?.toDouble() ?? 0.0,
      placeId: placeId,
    );
  }
}

class RouteResult {
  final String distanceText;
  final int distanceMeters;
  final String durationText;
  final int durationSeconds;
  final String overviewPolyline;
  final String startAddress;
  final String endAddress;

  const RouteResult({
    required this.distanceText,
    required this.distanceMeters,
    required this.durationText,
    required this.durationSeconds,
    required this.overviewPolyline,
    required this.startAddress,
    required this.endAddress,
  });

  factory RouteResult.fromJson(Map<String, dynamic> json) {
    final routes = json['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      return const RouteResult(
        distanceText: '0 km',
        distanceMeters: 0,
        durationText: '0 mins',
        durationSeconds: 0,
        overviewPolyline: '',
        startAddress: '',
        endAddress: '',
      );
    }

    final firstRoute = routes[0] as Map<String, dynamic>;
    final legs = firstRoute['legs'] as List<dynamic>?;
    final firstLeg = (legs != null && legs.isNotEmpty) ? legs[0] as Map<String, dynamic> : <String, dynamic>{};

    final distance = firstLeg['distance'] as Map<String, dynamic>?;
    final duration = firstLeg['duration'] as Map<String, dynamic>?;
    final polyline = firstRoute['overview_polyline'] as Map<String, dynamic>?;

    return RouteResult(
      distanceText: distance?['text'] ?? '0 km',
      distanceMeters: (distance?['value'] as num?)?.toInt() ?? 0,
      durationText: duration?['text'] ?? '0 mins',
      durationSeconds: (duration?['value'] as num?)?.toInt() ?? 0,
      overviewPolyline: polyline?['points'] ?? '',
      startAddress: firstLeg['start_address'] ?? '',
      endAddress: firstLeg['end_address'] ?? '',
    );
  }
}
