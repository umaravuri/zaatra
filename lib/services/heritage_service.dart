import 'package:flutter/foundation.dart';
import '../models/heritage_place_model.dart';
import '../models/hotel_model.dart';
import 'api_service.dart';

class HeritageService {
  /// Available Monument Types for Filtering
  static List<HeritageMonumentType> get filterTypes => HeritageMonumentType.values;

  /// Default Supported Heritage Cities
  static const List<String> defaultCities = ['Agra', 'Hyderabad', 'Jaipur', 'Mysuru'];

  /// Returns a map of city name to number of monuments
  static Map<String, int> getAvailableCitiesWithCounts([List<HeritagePlace>? places]) {
    final list = (places != null && places.isNotEmpty) ? places : _getFallbackPlaces();
    final counts = <String, int>{};
    for (final p in list) {
      final c = p.city.trim();
      if (c.isNotEmpty) {
        counts[c] = (counts[c] ?? 0) + 1;
      }
    }
    for (final defCity in defaultCities) {
      counts.putIfAbsent(defCity, () => 0);
    }
    return counts;
  }

  /// 1. Get All Places (City-Wise / Multi-City / Search / Filters / Sorting)
  /// Endpoint: GET /api/heritage?city=...&category=...&search=...&sort=...&page=...&limit=...
  static Future<HeritagePlacesResponse> getPlaces({
    HeritageFilterState? filterState,
    String? city,
    List<String>? selectedCities,
    HeritageMonumentType? monumentType,
    String? category,
    String? search,
    HeritageSortOption sort = HeritageSortOption.topRated,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final state = filterState ??
          HeritageFilterState(
            selectedType: monumentType ??
                (category != null
                    ? HeritageMonumentType.fromCategory(category)
                    : HeritageMonumentType.all),
            city: city,
            selectedCities: selectedCities ?? const [],
            searchQuery: search,
            sortOption: sort,
          );

      final queryParams = state.toQueryParams(page: page, limit: limit);
      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/heritage${queryString.isNotEmpty ? '?$queryString' : ''}';

      final response = await ApiService.get(endpoint);
      if (response['success'] == true) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        var resObj = HeritagePlacesResponse.fromJson(data);
        if (state.selectedCities.isNotEmpty) {
          final lowerSelected = state.selectedCities.map((c) => c.toLowerCase().trim()).toSet();
          final filteredPlaces = resObj.places.where((p) => lowerSelected.contains(p.city.toLowerCase().trim())).toList();
          resObj = HeritagePlacesResponse(
            success: resObj.success,
            count: filteredPlaces.length,
            total: filteredPlaces.length,
            page: resObj.page,
            totalPages: resObj.totalPages,
            places: filteredPlaces,
          );
        }
        return resObj;
      }
    } catch (e) {
      debugPrint('HeritageService.getPlaces error: $e');
    }

    // Fallback places list
    final fallbackList = _getFallbackPlaces();
    var filtered = List<HeritagePlace>.from(fallbackList);

    final activeSelectedCities = filterState?.selectedCities ?? selectedCities ?? const [];
    if (activeSelectedCities.isNotEmpty) {
      final lowerSelected = activeSelectedCities.map((c) => c.toLowerCase().trim()).toSet();
      filtered = filtered.where((p) => lowerSelected.contains(p.city.toLowerCase().trim())).toList();
    } else {
      final activeCity = filterState?.city ?? city;
      if (activeCity != null && activeCity.isNotEmpty && activeCity.toLowerCase() != 'all') {
        filtered = filtered.where((p) => p.city.toLowerCase().trim() == activeCity.toLowerCase().trim()).toList();
      }
    }

    final activeType = filterState?.selectedType ?? monumentType ?? (category != null ? HeritageMonumentType.fromCategory(category) : HeritageMonumentType.all);
    if (activeType != HeritageMonumentType.all) {
      filtered = filtered.where((p) => p.monumentType == activeType || p.category.toLowerCase() == activeType.apiCategory.toLowerCase()).toList();
    }

    final activeSearch = filterState?.searchQuery ?? search;
    if (activeSearch != null && activeSearch.isNotEmpty) {
      filtered = filtered.where((p) =>
          p.title.toLowerCase().contains(activeSearch.toLowerCase()) ||
          p.city.toLowerCase().contains(activeSearch.toLowerCase()) ||
          p.tagline.toLowerCase().contains(activeSearch.toLowerCase())).toList();
    }

    final activeSort = filterState?.sortOption ?? sort;
    switch (activeSort) {
      case HeritageSortOption.topRated:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case HeritageSortOption.mostVisited:
        filtered.sort((a, b) => b.reviewsCount.compareTo(a.reviewsCount));
        break;
      case HeritageSortOption.mustVisit:
        filtered.sort((a, b) => (b.mustVisit ? 1 : 0).compareTo(a.mustVisit ? 1 : 0));
        break;
      case HeritageSortOption.nameAsc:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return HeritagePlacesResponse(
      success: true,
      count: filtered.length,
      total: filtered.length,
      page: 1,
      totalPages: 1,
      places: filtered,
    );
  }

  /// 2. Get Famous & Featured Places (For App Home Screen & Carousel)
  /// Endpoint: GET /api/heritage/famous
  static Future<List<HeritagePlace>> getFamousPlaces() async {
    try {
      final response = await ApiService.get('/heritage/famous');
      if (response['success'] == true) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        final placesList = data['places'] as List<dynamic>?;
        if (placesList != null) {
          return placesList
              .map((p) => HeritagePlace.fromJson(p as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('HeritageService.getFamousPlaces error: $e');
    }

    return _getFallbackPlaces().where((p) => p.isFeatured || p.isPopular).toList();
  }

  /// 3. Get Full Place Details (For Detail / Profile Screen)
  /// Endpoint: GET /api/heritage/:id
  static Future<HeritagePlace?> getPlaceDetails(String id) async {
    try {
      final response = await ApiService.get('/heritage/$id');
      if (response['success'] == true) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        final placeJson = data['place'] ?? data['data'] ?? data;
        if (placeJson is Map<String, dynamic>) {
          return HeritagePlace.fromJson(placeJson);
        }
      }
    } catch (e) {
      debugPrint('HeritageService.getPlaceDetails error: $e');
    }

    // Try finding in fallback list
    final fallback = _getFallbackPlaces().firstWhere(
      (p) => p.placeId == id || p.id == id,
      orElse: () => _getFallbackPlaces().first,
    );
    return fallback;
  }

  /// 4. Get Nearby Hotels / Stays for a Heritage Destination (GET API endpoint)
  /// Endpoint: GET /api/heritage/:id/nearby-properties?radius=5&limit=10&sort=distance_asc
  static Future<List<Hotel>> getNearbyHotels({
    required String city,
    String? placeId,
    double radius = 5,
    int limit = 10,
    String sort = 'distance_asc',
  }) async {
    try {
      if (placeId != null && placeId.isNotEmpty) {
        final endpoint = '/heritage/$placeId/nearby-properties?radius=$radius&limit=$limit&sort=$sort';
        final response = await ApiService.get(endpoint);
        if (response['success'] == true) {
          final data = response['data'] is Map<String, dynamic>
              ? response['data'] as Map<String, dynamic>
              : response;
          final rawList = data['properties'] as List? ??
              data['hotels'] as List? ??
              (data['data'] is List ? data['data'] as List : []);
          if (rawList.isNotEmpty) {
            return rawList
                .map((item) => Hotel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
      }

      // Fallback to city-wide hotels if no landmark-specific properties found
      final queryCity = Uri.encodeComponent(city.trim());
      final response = await ApiService.get('/hotels?city=$queryCity');
      if (response['success'] == true && response['data'] != null) {
        final rawList = response['data'] is List
            ? response['data'] as List
            : (response['data']['hotels'] as List? ?? []);
        final parsed = rawList
            .map((item) => Hotel.fromJson(item as Map<String, dynamic>))
            .toList();
        if (parsed.isNotEmpty) return parsed;
      }
    } catch (e) {
      debugPrint('HeritageService.getNearbyHotels (using curated fallback): $e');
    }

    return getHotelsForCity(city);
  }

  /// 5. Get Nearby Properties by Arbitrary GPS Coordinates
  /// Endpoint: GET /api/heritage/nearby-properties?lat=17.3616&lng=78.4747&radius=5
  static Future<List<Hotel>> getNearbyPropertiesByCoordinates({
    required double lat,
    required double lng,
    double radius = 5,
    int limit = 10,
    String sort = 'distance_asc',
  }) async {
    try {
      final endpoint = '/heritage/nearby-properties?lat=$lat&lng=$lng&radius=$radius&limit=$limit&sort=$sort';
      final response = await ApiService.get(endpoint);
      if (response['success'] == true) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        final rawList = data['properties'] as List? ??
            data['hotels'] as List? ??
            (data['data'] is List ? data['data'] as List : []);
        if (rawList.isNotEmpty) {
          return rawList
              .map((item) => Hotel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('HeritageService.getNearbyPropertiesByCoordinates error: $e');
    }
    return [];
  }

  /// 6. Get Dynamic Categories and Supported Cities Metadata
  /// Endpoint: GET /api/heritage/categories
  static Future<HeritageCategoriesResponse> getCategoriesAndCities() async {
    try {
      final response = await ApiService.get('/heritage/categories');
      if (response['success'] == true) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        return HeritageCategoriesResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('HeritageService.getCategoriesAndCities error: $e');
    }

    // Static fallback categories and cities
    return const HeritageCategoriesResponse(
      success: true,
      categories: [
        'All',
        'Historical Monument',
        'Fort',
        'Palace',
        'UNESCO World Heritage Site',
        'Temple & Pilgrimage',
        'Museum',
        'Nature & Caves',
        'Archaeological Site',
      ],
      cities: ['Agra', 'Hyderabad', 'Jaipur', 'Mysuru'],
    );
  }

  static List<HeritagePlace> _getFallbackPlaces() {
    return [
      const HeritagePlace(
        id: '6ab283a7a8cdf659e5655258',
        placeId: 'HP-1001',
        title: 'Charminar',
        tagline: 'The monumental global icon of Hyderabad',
        category: 'Historical Monument',
        city: 'Hyderabad',
        state: 'Telangana',
        address: 'Charminar Rd, Char Kaman, Ghansi Bazaar, Hyderabad, Telangana 500002',
        latitude: 17.3616,
        longitude: 78.4747,
        description: 'Charminar is a monument and mosque in Hyderabad, India. Listed among the most recognized structures in India.',
        history: 'Constructed in 1591 CE by Muhammad Quli Qutb Shah, the fifth ruler of the Qutb Shahi dynasty.',
        architectureDetails: 'Indo-Islamic architectural style with Persian influences. Four grand arches facing cardinal directions.',
        significance: 'Commemorates the founding of Hyderabad city and eradication of a deadly plague.',
        coverImage: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=800&q=80',
        images: [
          'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1608958435020-e8a7109ba809?auto=format&fit=crop&w=800&q=80',
        ],
        timings: HeritageTimings(
          openTime: '09:30 AM',
          closeTime: '05:30 PM',
          openDays: 'All Days',
          bestTimeToVisit: 'October to March (Evening for lighting)',
          averageVisitDuration: '1-2 Hours',
        ),
        entryFee: HeritageEntryFee(
          isFreeEntry: false,
          domestic: 25,
          foreigner: 300,
          children: 0,
          cameraFee: 25,
        ),
        famousHighlights: [
          'Panoramic views of Old Hyderabad from the top balcony',
          'Laad Bazaar (famous for pearls & bangles)',
          'Irani Chai & Osmania biscuits at Nimrah Cafe adjacent to Charminar',
          'Illuminated night view',
        ],
        guidelines: [
          'Entry allowed up to 5:00 PM',
          'Footwear allowed on outer premises',
          'Bags and luggage subject to security inspection',
        ],
        isFeatured: true,
        isPopular: true,
        mustVisit: true,
        rating: 4.8,
        reviewsCount: 1420,
      ),
      const HeritagePlace(
        id: '6ab283a7a8cdf659e5655259',
        placeId: 'HP-1002',
        title: 'Golconda Fort',
        tagline: 'Magnificent medieval fortress and diamond trade capital',
        category: 'Fort',
        city: 'Hyderabad',
        state: 'Telangana',
        address: 'Khair Complex, Ibrahim Bagh, Hyderabad, Telangana 500008',
        latitude: 17.3833,
        longitude: 78.4011,
        description: 'Golconda Fort was the capital of the medieval sultanate of the Qutb Shahi dynasty.',
        history: 'Originally built by the Kakatiyas in the 13th century, later expanded by the Qutb Shahi kings.',
        architectureDetails: 'Acoustic architecture where a hand clap at the entrance dome can be heard 1 km away at the hilltop pavilion.',
        significance: 'Source of legendary diamonds including the Koh-i-Noor and Hope Diamond.',
        coverImage: 'https://images.unsplash.com/photo-1608958435020-e8a7109ba809?auto=format&fit=crop&w=800&q=80',
        images: [
          'https://images.unsplash.com/photo-1608958435020-e8a7109ba809?auto=format&fit=crop&w=800&q=80',
        ],
        timings: HeritageTimings(
          openTime: '09:00 AM',
          closeTime: '05:30 PM',
          openDays: 'All Days',
          bestTimeToVisit: 'Afternoon till sunset for the Sound & Light show',
          averageVisitDuration: '3-4 Hours',
        ),
        entryFee: HeritageEntryFee(
          isFreeEntry: false,
          domestic: 25,
          foreigner: 300,
          children: 0,
          cameraFee: 25,
        ),
        famousHighlights: [
          'Acoustic Clap Phenomenon at Fateh Darwaza',
          'Sunset view from the Baradari topmost pavilion',
          'Evening Sound & Light show',
        ],
        guidelines: [
          'Comfortable walking shoes recommended',
          'Carry drinking water and umbrella',
        ],
        isFeatured: true,
        isPopular: true,
        mustVisit: true,
        rating: 4.9,
        reviewsCount: 2310,
      ),
      const HeritagePlace(
        id: '6ab283a7a8cdf659e5655260',
        placeId: 'HP-1003',
        title: 'Taj Mahal',
        tagline: 'An eternal symbol of love and UNESCO World Wonder',
        category: 'UNESCO World Heritage Site',
        city: 'Agra',
        state: 'Uttar Pradesh',
        address: 'Dharmapuri, Forest Colony, Tajganj, Agra, Uttar Pradesh 282001',
        latitude: 27.1751,
        longitude: 78.0421,
        description: 'An immense mausoleum of white marble, built in Agra between 1631 and 1648 by order of Mughal Emperor Shah Jahan.',
        history: 'Built in memory of Emperor Shah Jahan\'s favorite wife Mumtaz Mahal.',
        architectureDetails: 'The jewel of Muslim art in India and one of the universally admired masterpieces of the world\'s heritage.',
        significance: 'UNESCO World Heritage Site and one of the New 7 Wonders of the World.',
        coverImage: 'https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=800&q=80',
        images: [
          'https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=800&q=80',
        ],
        timings: HeritageTimings(
          openTime: '06:00 AM',
          closeTime: '06:30 PM',
          openDays: 'Saturday to Thursday (Closed on Friday)',
          bestTimeToVisit: 'Sunrise or Full Moon Nights',
          averageVisitDuration: '2-3 Hours',
        ),
        entryFee: HeritageEntryFee(
          isFreeEntry: false,
          domestic: 50,
          foreigner: 1100,
          children: 0,
          cameraFee: 0,
        ),
        famousHighlights: [
          'Pietra Dura marble inlay artwork',
          'Symmetrical Charbagh Mughal gardens',
          'Reflecting pool view from main gate',
        ],
        guidelines: [
          'Closed on Fridays for prayers',
          'Shoe covers provided at entrance',
          'No large bags or food items inside',
        ],
        isFeatured: true,
        isPopular: true,
        mustVisit: true,
        rating: 5.0,
        reviewsCount: 9800,
      ),
      const HeritagePlace(
        id: '6ab283a7a8cdf659e5655263',
        placeId: 'HP-1004',
        title: 'Hawa Mahal',
        tagline: 'The iconic Palace of Winds with 953 ornate jharokhas',
        category: 'Palace',
        city: 'Jaipur',
        state: 'Rajasthan',
        address: 'Hawa Mahal Rd, Badi Choupad, J.D.A. Market, Pink City, Jaipur, Rajasthan 302002',
        latitude: 26.9239,
        longitude: 75.8267,
        description: 'A five-storey pink and red sandstone palace constructed in 1799 in the form of Lord Krishna\'s crown.',
        history: 'Built by Maharaja Sawai Pratap Singh for royal women to observe festivals unseen.',
        architectureDetails: 'Rajput and Mughal architectural fusion with 953 honeycomb windows generating natural cooling.',
        significance: 'Iconic landmark of Jaipur Pink City World Heritage site.',
        coverImage: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=800&q=80',
        images: [
          'https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=800&q=80',
        ],
        timings: HeritageTimings(
          openTime: '09:00 AM',
          closeTime: '05:00 PM',
          openDays: 'All Days',
          bestTimeToVisit: 'Morning when golden sunlight illuminates the facade',
          averageVisitDuration: '1-2 Hours',
        ),
        entryFee: HeritageEntryFee(
          isFreeEntry: false,
          domestic: 50,
          foreigner: 200,
          children: 20,
          cameraFee: 50,
        ),
        famousHighlights: [
          '953 carved sandstone Jharokhas (balconies)',
          'Rooftop view of City Palace and Jantar Mantar',
          'Tattoo Cafe & Wind View Cafe opposite for postcard photography',
        ],
        guidelines: [
          'Ramps are used inside instead of stairs',
          'Early morning visit recommended',
        ],
        isFeatured: true,
        isPopular: true,
        mustVisit: true,
        rating: 4.7,
        reviewsCount: 3890,
      ),
    ];
  }
}
