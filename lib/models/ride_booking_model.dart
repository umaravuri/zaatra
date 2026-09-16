import 'package:flutter/material.dart';

class RideDriver {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final double pricePerSeat;
  final String carModel;
  final String vehicleNumber;
  final int seatsAvailable;
  final String departureTime;
  final String pickupPoint;
  final String destinationPoint;
  final List<String> amenities;
  final String avatarImage;

  const RideDriver({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.pricePerSeat,
    required this.carModel,
    required this.vehicleNumber,
    required this.seatsAvailable,
    required this.departureTime,
    required this.pickupPoint,
    required this.destinationPoint,
    required this.amenities,
    required this.avatarImage,
  });
}

class RideBookingSession {
  final RideDriver driver;
  final String pickup;
  final String destination;
  final String boardingPoint;
  final String customerPickupAddress;
  final String customerPickupPincode;
  final String customerPickupLandmark;
  final String date;
  final String time;
  final int seatsCount;
  final bool isDoorstepPickup;
  final double detourDistanceKm;
  final double detourCharge;
  final double perKmDetourRate;
  final String passengerName;
  final String passengerPhone;
  final String passengerEmail;
  final String luggage;
  final String paymentMethod;
  final double totalAmount;
  final String boardingPin;

  const RideBookingSession({
    required this.driver,
    this.pickup = '',
    this.destination = '',
    this.boardingPoint = '',
    this.customerPickupAddress = '',
    this.customerPickupPincode = '',
    this.customerPickupLandmark = '',
    this.date = '',
    this.time = '',
    this.seatsCount = 1,
    this.isDoorstepPickup = false,
    this.detourDistanceKm = 0.0,
    this.detourCharge = 0.0,
    this.perKmDetourRate = 5.0,
    this.passengerName = '',
    this.passengerPhone = '',
    this.passengerEmail = '',
    this.luggage = '1 Medium Bag',
    this.paymentMethod = 'UPI',
    this.totalAmount = 550.0,
    this.boardingPin = '4829',
  });

  RideBookingSession copyWith({
    RideDriver? driver,
    String? pickup,
    String? destination,
    String? boardingPoint,
    String? customerPickupAddress,
    String? customerPickupPincode,
    String? customerPickupLandmark,
    String? date,
    String? time,
    int? seatsCount,
    bool? isDoorstepPickup,
    double? detourDistanceKm,
    double? detourCharge,
    double? perKmDetourRate,
    String? passengerName,
    String? passengerPhone,
    String? passengerEmail,
    String? luggage,
    String? paymentMethod,
    double? totalAmount,
    String? boardingPin,
  }) {
    return RideBookingSession(
      driver: driver ?? this.driver,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      boardingPoint: boardingPoint ?? this.boardingPoint,
      customerPickupAddress: customerPickupAddress ?? this.customerPickupAddress,
      customerPickupPincode: customerPickupPincode ?? this.customerPickupPincode,
      customerPickupLandmark: customerPickupLandmark ?? this.customerPickupLandmark,
      date: date ?? this.date,
      time: time ?? this.time,
      seatsCount: seatsCount ?? this.seatsCount,
      isDoorstepPickup: isDoorstepPickup ?? this.isDoorstepPickup,
      detourDistanceKm: detourDistanceKm ?? this.detourDistanceKm,
      detourCharge: detourCharge ?? this.detourCharge,
      perKmDetourRate: perKmDetourRate ?? this.perKmDetourRate,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerEmail: passengerEmail ?? this.passengerEmail,
      luggage: luggage ?? this.luggage,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalAmount: totalAmount ?? this.totalAmount,
      boardingPin: boardingPin ?? this.boardingPin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideId': driver.id,
      'pickup': pickup,
      'destination': destination,
      'boardingPoint': boardingPoint,
      'customerPickupAddress': customerPickupAddress,
      'customerPickupPincode': customerPickupPincode,
      'customerPickupLandmark': customerPickupLandmark,
      'doorstepPickupRequested': isDoorstepPickup,
      'perKmDetourRate': perKmDetourRate,
      'detourDistanceKm': detourDistanceKm,
      'extraPickupCharge': detourCharge,
      'pickupTime': time,
      'fullName': passengerName,
      'phoneNumber': passengerPhone,
      'emailID': passengerEmail,
      'numberOfSeats': seatsCount,
      'pricePerSeat': driver.pricePerSeat,
      'luggage': luggage,
      'paymentMethod': paymentMethod,
      'totalAmount': totalAmount,
    };
  }
}

const List<RideDriver> mockRideDrivers = [
  RideDriver(
    id: 'DRV-101',
    name: 'Ramesh Verma',
    rating: 4.8,
    reviewCount: 342,
    pricePerSeat: 550.0,
    carModel: 'Hyundai Creta (White)',
    vehicleNumber: 'TS 09 EA 4521',
    seatsAvailable: 3,
    departureTime: '09:30 AM',
    pickupPoint: 'Madhapur Metro Station, Hyderabad',
    destinationPoint: 'Secunderabad Junction Gate 1',
    amenities: ['AC', 'Music', 'USB Charger', 'Spacious Boot'],
    avatarImage: 'assets/images/image 27.png',
  ),
  RideDriver(
    id: 'DRV-102',
    name: 'Suresh Reddy',
    rating: 4.9,
    reviewCount: 512,
    pricePerSeat: 600.0,
    carModel: 'Toyota Innova Crysta (Silver)',
    vehicleNumber: 'AP 16 GH 7890',
    seatsAvailable: 4,
    departureTime: '10:00 AM',
    pickupPoint: 'Hitec City Cyber Towers',
    destinationPoint: 'Secunderabad Station Clock Tower',
    amenities: ['AC', 'Luggage Space', 'Sanitized', 'Free Water'],
    avatarImage: 'assets/images/Rectangle 127.png',
  ),
  RideDriver(
    id: 'DRV-103',
    name: 'Anand Kumar',
    rating: 4.7,
    reviewCount: 228,
    pricePerSeat: 480.0,
    carModel: 'Maruti Suzuki Ertiga (Grey)',
    vehicleNumber: 'TS 07 HK 1142',
    seatsAvailable: 2,
    departureTime: '10:45 AM',
    pickupPoint: 'Jubilee Hills Checkpost',
    destinationPoint: 'Secunderabad Station Platform 10',
    amenities: ['AC', 'Quiet Ride', 'Phone Charger'],
    avatarImage: 'assets/images/Rectangle 128.png',
  ),
];
