import 'dart:math' as math;
import 'hotel_model.dart';

/// Available Sorting Options for Heritage Places
enum HeritageSortOption {
  topRated('rating_desc', 'Top Rated', 'Highest customer ratings first'),
  mostVisited('popular', 'Most Visited', 'Most popular & visited monuments'),
  mustVisit('must_visit', 'Must-Visit First', 'Editor recommended must-see places'),
  nameAsc('name_asc', 'Name (A to Z)', 'Alphabetical order');

  final String apiValue;
  final String label;
  final String description;

  const HeritageSortOption(this.apiValue, this.label, this.description);

  static HeritageSortOption fromString(String? val) {
    if (val == null) return HeritageSortOption.topRated;
    return HeritageSortOption.values.firstWhere(
      (opt) => opt.apiValue == val || opt.name == val,
      orElse: () => HeritageSortOption.topRated,
    );
  }
}

/// Monument / Heritage Categories for Filtering
enum HeritageMonumentType {
  all('All', 'All Heritage Sites'),
  historicalMonuments('Historical Monument', 'Historical Monuments'),
  forts('Fort', 'Forts & Fortresses'),
  palaces('Palace', 'Royal Palaces'),
  unescoSites('UNESCO World Heritage Site', 'UNESCO World Heritage Sites'),
  temples('Temple & Pilgrimage', 'Temples & Pilgrimages'),
  museums('Museum', 'Museums & Galleries'),
  natureCaves('Nature & Caves', 'Nature & Caves'),
  archaeologicalSites('Archaeological Site', 'Archaeological Sites');

  final String apiCategory;
  final String displayName;

  const HeritageMonumentType(this.apiCategory, this.displayName);

  static HeritageMonumentType fromCategory(String? category) {
    if (category == null || category.isEmpty || category.toLowerCase() == 'all') {
      return HeritageMonumentType.all;
    }
    return HeritageMonumentType.values.firstWhere(
      (type) => type.apiCategory.toLowerCase() == category.toLowerCase(),
      orElse: () => HeritageMonumentType.historicalMonuments,
    );
  }
}

/// Comprehensive Filter State for Heritage Search & Exploration
class HeritageFilterState {
  final HeritageMonumentType selectedType;
  final String? city;
  final List<String> selectedCities;
  final bool mustVisitOnly;
  final double? minRating;
  final String? searchQuery;
  final HeritageSortOption sortOption;

  const HeritageFilterState({
    this.selectedType = HeritageMonumentType.all,
    this.city,
    this.selectedCities = const [],
    this.mustVisitOnly = false,
    this.minRating,
    this.searchQuery,
    this.sortOption = HeritageSortOption.topRated,
  });

  HeritageFilterState copyWith({
    HeritageMonumentType? selectedType,
    String? city,
    List<String>? selectedCities,
    bool? mustVisitOnly,
    double? minRating,
    String? searchQuery,
    HeritageSortOption? sortOption,
  }) {
    return HeritageFilterState(
      selectedType: selectedType ?? this.selectedType,
      city: city ?? this.city,
      selectedCities: selectedCities ?? this.selectedCities,
      mustVisitOnly: mustVisitOnly ?? this.mustVisitOnly,
      minRating: minRating ?? this.minRating,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  Map<String, String> toQueryParams({int page = 1, int limit = 50}) {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort': sortOption.apiValue,
    };

    if (selectedType != HeritageMonumentType.all) {
      params['category'] = selectedType.apiCategory;
    }
    if (selectedCities.isNotEmpty) {
      params['city'] = selectedCities.join(',');
    } else if (city != null && city!.isNotEmpty && city!.toLowerCase() != 'all') {
      params['city'] = city!;
    }
    if (searchQuery != null && searchQuery!.trim().isNotEmpty) {
      params['search'] = searchQuery!.trim();
    }
    if (mustVisitOnly) {
      params['mustVisit'] = 'true';
    }
    if (minRating != null && minRating! > 0) {
      params['minRating'] = minRating!.toString();
    }

    return params;
  }
}

/// Map, Coordinates & Navigation Model for Heritage Places
class HeritageMapLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String country;

  const HeritageMapLocation({
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = 'India',
  });

  factory HeritageMapLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HeritageMapLocation();
    return HeritageMapLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? 'India',
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
      };

  bool get hasValidCoordinates => latitude != 0.0 && longitude != 0.0;

  /// Generate Google Maps Navigation URL
  String get googleMapsUrl {
    if (hasValidCoordinates) {
      return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    }
    final encodedAddr = Uri.encodeComponent('$address, $city, $state');
    return 'https://www.google.com/maps/search/?api=1&query=$encodedAddr';
  }

  /// Approximate Haversine Distance in Kilometers
  double? calculateDistance(double userLat, double userLng) {
    if (!hasValidCoordinates || userLat == 0.0 || userLng == 0.0) return null;

    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(latitude - userLat);
    final dLng = _degreesToRadians(longitude - userLng);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(userLat)) *
            math.cos(_degreesToRadians(latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  String formattedDistance(double userLat, double userLng) {
    final dist = calculateDistance(userLat, userLng);
    if (dist == null) return '';
    if (dist < 1) {
      return '${(dist * 1000).toInt()} m away';
    }
    return '${dist.toStringAsFixed(1)} km away';
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}

class HeritageTimings {
  final String openTime;
  final String closeTime;
  final String openDays;
  final String bestTimeToVisit;
  final String averageVisitDuration;

  const HeritageTimings({
    this.openTime = '09:00 AM',
    this.closeTime = '06:00 PM',
    this.openDays = 'All Days',
    this.bestTimeToVisit = '',
    this.averageVisitDuration = '1-2 Hours',
  });

  factory HeritageTimings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HeritageTimings();
    return HeritageTimings(
      openTime: json['openTime']?.toString() ?? '09:00 AM',
      closeTime: json['closeTime']?.toString() ?? '06:00 PM',
      openDays: json['openDays']?.toString() ?? 'All Days',
      bestTimeToVisit: json['bestTimeToVisit']?.toString() ?? '',
      averageVisitDuration: json['averageVisitDuration']?.toString() ?? '1-2 Hours',
    );
  }

  Map<String, dynamic> toJson() => {
        'openTime': openTime,
        'closeTime': closeTime,
        'openDays': openDays,
        'bestTimeToVisit': bestTimeToVisit,
        'averageVisitDuration': averageVisitDuration,
      };
}

class HeritageEntryFee {
  final bool isFreeEntry;
  final double domestic;
  final double foreigner;
  final double children;
  final double cameraFee;
  final String currency;

  const HeritageEntryFee({
    this.isFreeEntry = false,
    this.domestic = 0.0,
    this.foreigner = 0.0,
    this.children = 0.0,
    this.cameraFee = 0.0,
    this.currency = 'INR',
  });

  factory HeritageEntryFee.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HeritageEntryFee();
    return HeritageEntryFee(
      isFreeEntry: json['isFreeEntry'] == true,
      domestic: (json['domestic'] as num?)?.toDouble() ?? 0.0,
      foreigner: (json['foreigner'] as num?)?.toDouble() ?? 0.0,
      children: (json['children'] as num?)?.toDouble() ?? 0.0,
      cameraFee: (json['cameraFee'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() => {
        'isFreeEntry': isFreeEntry,
        'domestic': domestic,
        'foreigner': foreigner,
        'children': children,
        'cameraFee': cameraFee,
        'currency': currency,
      };
}

class HeritagePlace {
  final String id;
  final String placeId;
  final String title;
  final String tagline;
  final String category;
  final String city;
  final String state;
  final String country;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final String history;
  final String architectureDetails;
  final String significance;
  final String coverImage;
  final List<String> images;
  final HeritageTimings timings;
  final HeritageEntryFee entryFee;
  final List<String> famousHighlights;
  final List<String> guidelines;
  final bool isFeatured;
  final bool isPopular;
  final bool mustVisit;
  final double rating;
  final int reviewsCount;
  final String status;
  final List<Hotel> nearbyProperties;
  final int nearbyPropertiesCount;

  const HeritagePlace({
    required this.id,
    required this.placeId,
    required this.title,
    this.tagline = '',
    this.category = '',
    this.city = '',
    this.state = '',
    this.country = 'India',
    this.address = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.description = '',
    this.history = '',
    this.architectureDetails = '',
    this.significance = '',
    this.coverImage = '',
    this.images = const [],
    this.timings = const HeritageTimings(),
    this.entryFee = const HeritageEntryFee(),
    this.famousHighlights = const [],
    this.guidelines = const [],
    this.isFeatured = false,
    this.isPopular = false,
    this.mustVisit = false,
    this.rating = 4.5,
    this.reviewsCount = 0,
    this.status = 'active',
    this.nearbyProperties = const [],
    this.nearbyPropertiesCount = 0,
  });

  /// Location and Map Representation Helper
  HeritageMapLocation get mapLocation => HeritageMapLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
        city: city,
        state: state,
        country: country,
      );

  /// Structured Monument Type Helper
  HeritageMonumentType get monumentType => HeritageMonumentType.fromCategory(category);

  factory HeritagePlace.fromJson(Map<String, dynamic> json) {
    // Parse embedded nearby properties if provided by GET /api/heritage/:id
    final rawProps = json['nearbyProperties'] ?? json['properties'];
    final List<Hotel> parsedProps = [];
    if (rawProps is List) {
      for (final item in rawProps) {
        if (item is Map<String, dynamic>) {
          parsedProps.add(Hotel.fromJson(item));
        } else if (item is Map) {
          parsedProps.add(Hotel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return HeritagePlace(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      placeId: json['placeId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Heritage Spot',
      tagline: json['tagline']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Historical Monument',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? 'India',
      address: json['address']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      history: json['history']?.toString() ?? '',
      architectureDetails: json['architectureDetails']?.toString() ?? '',
      significance: json['significance']?.toString() ?? '',
      coverImage: json['coverImage']?.toString() ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      timings: HeritageTimings.fromJson(json['timings'] as Map<String, dynamic>?),
      entryFee: HeritageEntryFee.fromJson(json['entryFee'] as Map<String, dynamic>?),
      famousHighlights: (json['famousHighlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      guidelines: (json['guidelines'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isFeatured: json['isFeatured'] == true,
      isPopular: json['isPopular'] == true,
      mustVisit: json['mustVisit'] == true,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'active',
      nearbyProperties: parsedProps,
      nearbyPropertiesCount: (json['nearbyPropertiesCount'] as num?)?.toInt() ??
          (json['count'] as num?)?.toInt() ??
          parsedProps.length,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'placeId': placeId,
        'title': title,
        'tagline': tagline,
        'category': category,
        'city': city,
        'state': state,
        'country': country,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'history': history,
        'architectureDetails': architectureDetails,
        'significance': significance,
        'coverImage': coverImage,
        'images': images,
        'timings': timings.toJson(),
        'entryFee': entryFee.toJson(),
        'famousHighlights': famousHighlights,
        'guidelines': guidelines,
        'isFeatured': isFeatured,
        'isPopular': isPopular,
        'mustVisit': mustVisit,
        'rating': rating,
        'reviewsCount': reviewsCount,
        'status': status,
        'nearbyPropertiesCount': nearbyPropertiesCount,
      };
}

class HeritagePlacesResponse {
  final bool success;
  final int count;
  final int total;
  final int page;
  final int totalPages;
  final List<HeritagePlace> places;

  const HeritagePlacesResponse({
    this.success = false,
    this.count = 0,
    this.total = 0,
    this.page = 1,
    this.totalPages = 1,
    this.places = const [],
  });

  factory HeritagePlacesResponse.fromJson(Map<String, dynamic> json) {
    return HeritagePlacesResponse(
      success: json['success'] == true,
      count: (json['count'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      places: (json['places'] as List<dynamic>?)
              ?.map((p) => HeritagePlace.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Dynamic categories and cities response model from GET /api/heritage/categories
class HeritageCategoriesResponse {
  final bool success;
  final List<String> categories;
  final List<String> cities;

  const HeritageCategoriesResponse({
    this.success = false,
    this.categories = const [],
    this.cities = const [],
  });

  factory HeritageCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final rawCats = json['categories'] as List<dynamic>?;
    final rawCities = json['cities'] as List<dynamic>?;

    return HeritageCategoriesResponse(
      success: json['success'] == true,
      categories: rawCats?.map((e) => e.toString()).toList() ?? [],
      cities: rawCities?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
