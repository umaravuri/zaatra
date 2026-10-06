import 'package:flutter/material.dart';

class HotelRoom {
  final String id;
  final String title;
  final String priceFormatted;
  final double pricePerNight;
  final String specs;
  final String amenities;
  final String image;
  final IconData icon;

  const HotelRoom({
    required this.id,
    required this.title,
    required this.priceFormatted,
    required this.pricePerNight,
    required this.specs,
    required this.amenities,
    required this.image,
    this.icon = Icons.bedroom_parent_rounded,
  });

  factory HotelRoom.fromJson(Map<String, dynamic> json) {
    return HotelRoom(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Deluxe Room',
      priceFormatted: json['priceFormatted']?.toString() ?? '₹ ${(json['pricePerNight'] ?? 2500)}/-',
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 2500.0,
      specs: json['specs']?.toString() ?? '2 guests • 1 King bed',
      amenities: json['amenities']?.toString() ?? 'Wi-Fi • AC • TV',
      image: json['image']?.toString() ?? 'assets/images/image 27.png',
      icon: Icons.bedroom_parent_rounded,
    );
  }
}

class HotelSpecs {
  final String guests;
  final String kids;
  final String beds;
  final String baths;

  const HotelSpecs({
    required this.guests,
    required this.kids,
    required this.beds,
    required this.baths,
  });

  factory HotelSpecs.fromJson(Map<String, dynamic> json) {
    return HotelSpecs(
      guests: json['guests']?.toString() ?? '2 Guests',
      kids: json['kids']?.toString() ?? '1 Kid',
      beds: json['beds']?.toString() ?? '1 Bed',
      baths: json['baths']?.toString() ?? '1 Bathroom',
    );
  }
}

class Hotel {
  final String id;
  final String title;
  final String type;
  final String location;
  final String city;
  final String state;
  final double rating;
  final int reviewCount;
  final double basePrice;
  final String image;
  final String description;
  final HotelSpecs specs;
  final List<String> amenities;
  final List<HotelRoom> rooms;
  final String? distanceFormatted;
  final double? distanceKm;

  const Hotel({
    required this.id,
    required this.title,
    required this.type,
    required this.location,
    required this.city,
    required this.state,
    required this.rating,
    required this.reviewCount,
    required this.basePrice,
    required this.image,
    required this.description,
    required this.specs,
    required this.amenities,
    required this.rooms,
    this.distanceFormatted,
    this.distanceKm,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    // Parse distance fields if provided
    String? formattedDist = json['distanceFormatted']?.toString();
    double? distKm = (json['distanceKm'] as num?)?.toDouble() ??
        (json['distance'] as num?)?.toDouble();

    if (formattedDist == null && distKm != null) {
      if (distKm < 1.0) {
        formattedDist = '${(distKm * 1000).toInt()} m away';
      } else {
        formattedDist = '${distKm.toStringAsFixed(1)} km away';
      }
    }

    // Extract price from varied backend schemas
    final parsedPrice = (json['basePrice'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        (json['pricePerNight'] as num?)?.toDouble() ??
        (json['startingPrice'] as num?)?.toDouble() ??
        3000.0;

    return Hotel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? json['propertyId']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? json['propertyName']?.toString() ?? 'Hotel',
      type: json['type']?.toString() ?? json['propertyType']?.toString() ?? 'Hotel',
      location: json['location']?.toString() ?? json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? (json['reviewsCount'] as num?)?.toInt() ?? 100,
      basePrice: parsedPrice,
      image: json['image']?.toString() ?? (json['images'] is List && (json['images'] as List).isNotEmpty ? json['images'][0].toString() : 'assets/images/image 27.png'),
      description: json['description']?.toString() ?? '',
      specs: json['specs'] is Map<String, dynamic>
          ? HotelSpecs.fromJson(json['specs'] as Map<String, dynamic>)
          : const HotelSpecs(guests: '2 Guests', kids: '1 Kid', beds: '1 Bed', baths: '1 Bathroom'),
      amenities: json['amenities'] is List
          ? (json['amenities'] as List).map((e) => e.toString()).toList()
          : const ['Wi-Fi', 'AC', 'TV', 'Parking'],
      rooms: json['rooms'] is List
          ? (json['rooms'] as List).map((r) => HotelRoom.fromJson(r as Map<String, dynamic>)).toList()
          : const [],
      distanceFormatted: formattedDist,
      distanceKm: distKm,
    );
  }
}

/// Helper to get hotels filtered by city
List<Hotel> getHotelsForCity(String city) {
  final query = city.trim().toLowerCase();
  if (query.isEmpty) return mockHotels;
  final matched = mockHotels.where((h) {
    return h.city.toLowerCase().contains(query) ||
        h.location.toLowerCase().contains(query) ||
        query.contains(h.city.toLowerCase());
  }).toList();
  return matched.isNotEmpty ? matched : mockHotels;
}

// 🏨 4 Diverse, Curated Hotel Options for Dynamic Customer Flow
const List<Hotel> mockHotels = [
  Hotel(
    id: 'HT-101',
    title: 'Grand Royal Hotel',
    type: 'Hotel',
    location: 'OM Sri Sai Nagar, Road No 2, Tirupati',
    city: 'Tirupati',
    state: 'Andhra Pradesh',
    rating: 4.8,
    reviewCount: 1240,
    basePrice: 3500.0,
    image: 'assets/images/image 27.png',
    description:
        'Premium 50-room hotel featuring modern single, double, triple, and quad occupancy rooms, in-house multi-cuisine restaurant, 24/7 room service, and complimentary parking.',
    specs: HotelSpecs(
      guests: '4 Guests',
      kids: '2 Kids',
      beds: '2 Beds',
      baths: '2 Bathrooms',
    ),
    amenities: [
      'Wi-Fi',
      'AC',
      'TV',
      'Restaurant',
      'Room Service',
      'Parking',
      'Elevator',
      'Hot water',
      'Breakfast',
    ],
    rooms: [
      HotelRoom(
        id: 'RM-101-1',
        title: 'Single Occupancy - Normal',
        priceFormatted: '₹ 2,000/-',
        pricePerNight: 2000.0,
        specs: '1 guest • 1 Single bed',
        amenities: 'Wi-Fi • AC • TV',
        image: 'assets/images/image 27.png',
        icon: Icons.single_bed_rounded,
      ),
      HotelRoom(
        id: 'RM-101-2',
        title: 'Double Occupancy - Deluxe',
        priceFormatted: '₹ 3,500/-',
        pricePerNight: 3500.0,
        specs: '2 guests • 1 King bed',
        amenities: 'Wi-Fi • AC • Mini Fridge • Free Breakfast',
        image: 'assets/images/Rectangle 127.png',
        icon: Icons.king_bed_rounded,
      ),
      HotelRoom(
        id: 'RM-101-3',
        title: 'Triple Occupancy - Deluxe',
        priceFormatted: '₹ 4,500/-',
        pricePerNight: 4500.0,
        specs: '3 guests • 1 King + 1 Single bed',
        amenities: 'Wi-Fi • AC • Balcony • Free Breakfast',
        image: 'assets/images/Rectangle 128.png',
        icon: Icons.bedroom_parent_rounded,
      ),
      HotelRoom(
        id: 'RM-101-4',
        title: 'Quad Family Suite - Deluxe',
        priceFormatted: '₹ 5,500/-',
        pricePerNight: 5500.0,
        specs: '4 guests • 2 Queen beds',
        amenities: 'Wi-Fi • AC • Mini Bar • 24/7 Room Service',
        image: 'assets/images/Rectangle 108.png',
        icon: Icons.family_restroom_rounded,
      ),
    ],
  ),
  Hotel(
    id: 'VL-202',
    title: 'Sunset Luxury Villa Goa',
    type: 'Villa',
    location: 'Candolim Beach Road, Baga Beach, Goa',
    city: 'Goa',
    state: 'Goa',
    rating: 4.9,
    reviewCount: 890,
    basePrice: 8500.0,
    image: 'assets/images/Rectangle 108.png',
    description:
        'Exclusive beachfront luxury villa with private infinity pool, direct beach access, gaming zone, open BBQ deck, and private chef services overlooking the Arabian Sea.',
    specs: HotelSpecs(
      guests: '8 Guests',
      kids: '4 Kids',
      beds: '4 King Beds',
      baths: '4 Bathrooms',
    ),
    amenities: [
      'Private Pool',
      'Beach Access',
      'Kitchen',
      'Wi-Fi',
      'AC',
      'BBQ Grill',
      'Gaming Zone',
      'Parking',
      'Butler',
    ],
    rooms: [
      HotelRoom(
        id: 'RM-202-1',
        title: 'Entire 4-BHK Luxury Villa',
        priceFormatted: '₹ 8,500/-',
        pricePerNight: 8500.0,
        specs: '8 guests • 4 King beds • Private Pool',
        amenities: 'Private Plunge Pool • Jacuzzi • Butler Service',
        image: 'assets/images/Rectangle 108.png',
        icon: Icons.villa_rounded,
      ),
      HotelRoom(
        id: 'RM-202-2',
        title: 'Master Oceanfront Suite',
        priceFormatted: '₹ 4,200/-',
        pricePerNight: 4200.0,
        specs: '2 guests • 1 King bed • Ocean View',
        amenities: 'Sea View Balcony • Bathtub • Breakfast Incl.',
        image: 'assets/images/Rectangle 127.png',
        icon: Icons.king_bed_rounded,
      ),
      HotelRoom(
        id: 'RM-202-3',
        title: 'Poolside Deluxe Room',
        priceFormatted: '₹ 3,200/-',
        pricePerNight: 3200.0,
        specs: '2 guests • 1 Queen bed • Pool Access',
        amenities: 'Direct Pool Deck • AC • Free WiFi',
        image: 'assets/images/image 27.png',
        icon: Icons.pool_rounded,
      ),
    ],
  ),
  Hotel(
    id: 'HT-303',
    title: 'Aranya Heritage Haveli',
    type: 'Heritage Stay',
    location: 'MI Road, C-Scheme, Jaipur',
    city: 'Jaipur',
    state: 'Rajasthan',
    rating: 4.7,
    reviewCount: 640,
    basePrice: 4000.0,
    image: 'assets/images/Rectangle 127.png',
    description:
        'A 174-year-old restored royal heritage haveli featuring handcrafted Rajasthani architecture, central courtyard dining, live folk music evenings, and regal antique suites.',
    specs: HotelSpecs(
      guests: '4 Guests',
      kids: '2 Kids',
      beds: '2 Royal Beds',
      baths: '2 Bathrooms',
    ),
    amenities: [
      'Heritage Courtyard',
      'Folk Music',
      'Wi-Fi',
      'AC',
      'Royal Dining',
      'Hot water',
      'Breakfast',
      'Parking',
      'Garden',
    ],
    rooms: [
      HotelRoom(
        id: 'RM-303-1',
        title: 'Maharaja Royal Suite',
        priceFormatted: '₹ 5,800/-',
        pricePerNight: 5800.0,
        specs: '2 guests • 1 Grand King bed',
        amenities: 'Courtyard View • Royal Decor • Butler',
        image: 'assets/images/Rectangle 127.png',
        icon: Icons.king_bed_rounded,
      ),
      HotelRoom(
        id: 'RM-303-2',
        title: 'Heritage Deluxe Room',
        priceFormatted: '₹ 4,000/-',
        pricePerNight: 4000.0,
        specs: '2 guests • 1 King bed',
        amenities: 'Traditional Jharokha • AC • Free WiFi',
        image: 'assets/images/image 27.png',
        icon: Icons.bedroom_parent_rounded,
      ),
      HotelRoom(
        id: 'RM-303-3',
        title: 'Haveli Family Room',
        priceFormatted: '₹ 4,900/-',
        pricePerNight: 4900.0,
        specs: '4 guests • 2 Queen beds',
        amenities: 'Garden View • Meals Included • Living Area',
        image: 'assets/images/Rectangle 128.png',
        icon: Icons.family_restroom_rounded,
      ),
    ],
  ),
  Hotel(
    id: 'FM-404',
    title: 'Green Meadows Eco Farmhouse',
    type: 'Farmhouse',
    location: 'Vikarabad Forest Road, Hyderabad',
    city: 'Hyderabad',
    state: 'Telangana',
    rating: 4.6,
    reviewCount: 410,
    basePrice: 6200.0,
    image: 'assets/images/Rectangle 128.png',
    description:
        'Lush 5-acre organic farm stay featuring private swimming pool, campfire zone, outdoor gazebo, fruit orchards, cycling trails, and organic farm-to-table dining.',
    specs: HotelSpecs(
      guests: '6 Guests',
      kids: '3 Kids',
      beds: '3 Queen Beds',
      baths: '3 Bathrooms',
    ),
    amenities: [
      'Swimming Pool',
      'Campfire',
      'Organic Dining',
      'Wi-Fi',
      'AC',
      'Gazebo',
      'Pet Friendly',
      'Free Parking',
      'Kitchen',
    ],
    rooms: [
      HotelRoom(
        id: 'RM-404-1',
        title: 'Full Farmhouse Cottage',
        priceFormatted: '₹ 6,200/-',
        pricePerNight: 6200.0,
        specs: '6 guests • 3 Queen beds • Entire Property',
        amenities: 'Private Pool • Campfire • Kitchen Access',
        image: 'assets/images/Rectangle 128.png',
        icon: Icons.cottage_rounded,
      ),
      HotelRoom(
        id: 'RM-404-2',
        title: 'Campfire Pool Suite',
        priceFormatted: '₹ 3,600/-',
        pricePerNight: 3600.0,
        specs: '2 guests • 1 King bed',
        amenities: 'Pool View • Gazebo Access • Breakfast',
        image: 'assets/images/image 27.png',
        icon: Icons.pool_rounded,
      ),
      HotelRoom(
        id: 'RM-404-3',
        title: 'Orchard View Deluxe Room',
        priceFormatted: '₹ 2,800/-',
        pricePerNight: 2800.0,
        specs: '2 guests • 1 Queen bed',
        amenities: 'Fruit Orchard View • AC • Free WiFi',
        image: 'assets/images/Rectangle 127.png',
        icon: Icons.nature_people_rounded,
      ),
    ],
  ),
  Hotel(
    id: 'HT-505',
    title: 'Taj Heritage View Palace',
    type: 'Heritage Hotel',
    location: 'Taj East Gate Road, Fatehabad, Agra',
    city: 'Agra',
    state: 'Uttar Pradesh',
    rating: 4.9,
    reviewCount: 1520,
    basePrice: 4800.0,
    image: 'assets/images/Rectangle 127.png',
    description:
        'Regal 5-star heritage experience located only 600m from the iconic Taj Mahal, featuring Mughal-style suites, rooftop infinity pool with Taj view, and traditional fine dining.',
    specs: HotelSpecs(
      guests: '4 Guests',
      kids: '2 Kids',
      beds: '2 King Beds',
      baths: '2 Bathrooms',
    ),
    amenities: [
      'Taj Mahal View',
      'Rooftop Pool',
      'Mughal Dining',
      'Wi-Fi',
      'AC',
      'Spa',
      'Free Parking',
      'Breakfast',
    ],
    rooms: [
      HotelRoom(
        id: 'RM-505-1',
        title: 'Mughal Monument View Suite',
        priceFormatted: '₹ 6,500/-',
        pricePerNight: 6500.0,
        specs: '2 guests • 1 King bed • Taj View',
        amenities: 'Balcony with Taj View • Luxury Bathtub • Breakfast',
        image: 'assets/images/Rectangle 127.png',
        icon: Icons.king_bed_rounded,
      ),
      HotelRoom(
        id: 'RM-505-2',
        title: 'Heritage Deluxe Room',
        priceFormatted: '₹ 4,800/-',
        pricePerNight: 4800.0,
        specs: '2 guests • 1 Queen bed',
        amenities: 'City View • AC • High-speed WiFi',
        image: 'assets/images/image 27.png',
        icon: Icons.bedroom_parent_rounded,
      ),
    ],
  ),
  Hotel(
    id: 'HT-606',
    title: 'Royal Mysuru Palace Residency',
    type: 'Palace Resort',
    location: 'Lalitha Mahal Nagar, Siddhartha Layout, Mysuru',
    city: 'Mysuru',
    state: 'Karnataka',
    rating: 4.8,
    reviewCount: 980,
    basePrice: 4200.0,
    image: 'assets/images/Rectangle 108.png',
    description:
        'Stunning royal heritage palace hotel surrounded by Chamundi Hill views and Italian marble architecture, offering vintage suites and royal high tea experiences.',
    specs: HotelSpecs(
      guests: '4 Guests',
      kids: '2 Kids',
      beds: '2 Royal Beds',
      baths: '2 Bathrooms',
    ),
    amenities: [
      'Palace Architecture',
      'Hill View',
      'Royal High Tea',
      'Wi-Fi',
      'AC',
      'Swimming Pool',
      'Free Parking',
      'Breakfast',
    ],
    rooms: [
      HotelRoom(
        id: 'RM-606-1',
        title: 'Maharaja Heritage Suite',
        priceFormatted: '₹ 5,800/-',
        pricePerNight: 5800.0,
        specs: '2 guests • 1 Grand King bed',
        amenities: 'Palace Garden View • Antique Decor • Butler',
        image: 'assets/images/Rectangle 108.png',
        icon: Icons.king_bed_rounded,
      ),
      HotelRoom(
        id: 'RM-606-2',
        title: 'Royal Deluxe Room',
        priceFormatted: '₹ 4,200/-',
        pricePerNight: 4200.0,
        specs: '2 guests • 1 Queen bed',
        amenities: 'Garden View • AC • Free Breakfast',
        image: 'assets/images/Rectangle 128.png',
        icon: Icons.bedroom_parent_rounded,
      ),
    ],
  ),
];
