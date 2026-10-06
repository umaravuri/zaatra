class RideDriver {
  final String id;
  final String name;
  final double rating;
  final String ratingText;
  final int reviewCount;
  final int tripsCount;
  final double pricePerSeat;
  final String carModel;
  final String vehicleNumber;
  final int seatsAvailable;
  final String departureTime;
  final String pickupPoint;
  final String destinationPoint;
  final List<String> amenities;
  final String avatarImage;
  final String phone;
  final String about;
  final String tripsText;
  final String driverSummary;
  final bool isOnline;

  const RideDriver({
    this.id = '',
    this.name = '',
    this.rating = 0.0,
    this.ratingText = '',
    this.reviewCount = 0,
    this.tripsCount = 0,
    this.pricePerSeat = 0.0,
    this.carModel = '',
    this.vehicleNumber = '',
    this.seatsAvailable = 0,
    this.departureTime = '',
    this.pickupPoint = '',
    this.destinationPoint = '',
    this.amenities = const [],
    this.avatarImage = '',
    this.phone = '',
    this.about = '',
    this.tripsText = '',
    this.driverSummary = '',
    this.isOnline = true,
  });

  factory RideDriver.fromJson(Map<String, dynamic> json, {String? defaultCar, String? defaultPlate, double? defaultPrice}) {
    final driverMap = json['driver'] is Map<String, dynamic> ? json['driver'] as Map<String, dynamic> : (json['driver'] is Map ? Map<String, dynamic>.from(json['driver'] as Map) : null);
    final vehicleMap = json['vehicle'] is Map<String, dynamic> ? json['vehicle'] as Map<String, dynamic> : (json['vehicle'] is Map ? Map<String, dynamic>.from(json['vehicle'] as Map) : null);
    final pricingMap = json['pricing'] is Map<String, dynamic> ? json['pricing'] as Map<String, dynamic> : (json['pricing'] is Map ? Map<String, dynamic>.from(json['pricing'] as Map) : null);
    final tripMap = json['trip'] is Map<String, dynamic> ? json['trip'] as Map<String, dynamic> : (json['trip'] is Map ? Map<String, dynamic>.from(json['trip'] as Map) : null);

    final ratingVal = json['rating'] ?? json['ratings'] ?? driverMap?['rating'] ?? driverMap?['ratings'];
    final ratingNum = ratingVal is num ? ratingVal.toDouble() : (double.tryParse(ratingVal?.toString() ?? '') ?? 0.0);
    final ratingTxt = json['ratingText']?.toString() ?? driverMap?['ratingText']?.toString() ?? (ratingNum > 0 ? '★ ${ratingNum.toStringAsFixed(1)}' : '');

    final tripsVal = json['trips'] ?? json['tripsCount'] ?? json['driverTrips'] ?? json['reviewCount'] ?? json['totalReviews'] ?? driverMap?['trips'] ?? driverMap?['tripsCount'] ?? driverMap?['reviewCount'];
    final tripsNum = tripsVal is num ? tripsVal.toInt() : (int.tryParse(tripsVal?.toString() ?? '') ?? 0);
    final tripsTxt = json['tripsText']?.toString() ?? driverMap?['tripsText']?.toString() ?? (tripsNum > 0 ? '🚗 $tripsNum trips' : '');

    final avatar = json['avatar']?.toString() ??
        json['avatarImage']?.toString() ??
        json['photo']?.toString() ??
        json['driverPhoto']?.toString() ??
        json['profilePicture']?.toString() ??
        driverMap?['avatar']?.toString() ??
        driverMap?['avatarImage']?.toString() ??
        driverMap?['photo']?.toString() ??
        driverMap?['driverPhoto']?.toString() ??
        '';

    final name = json['name']?.toString() ?? json['driverName']?.toString() ?? driverMap?['name']?.toString() ?? driverMap?['driverName']?.toString() ?? '';
    final car = json['carModel']?.toString() ??
        json['vehicleModel']?.toString() ??
        vehicleMap?['model']?.toString() ??
        vehicleMap?['name']?.toString() ??
        defaultCar ?? '';
    final plate = json['vehicleNumber']?.toString() ??
        json['numberPlate']?.toString() ??
        vehicleMap?['numberPlate']?.toString() ??
        defaultPlate ?? '';

    final summary = json['driverSummary']?.toString() ??
        driverMap?['driverSummary']?.toString() ??
        (name.isNotEmpty ? '$name , $tripsNum trips , $plate'.replaceAll(RegExp(r'\s*,\s*,'), ',').trim() : '');

    final rawPrice = json['pricePerSeat'] ?? pricingMap?['pricePerSeat'] ?? json['price'] ?? pricingMap?['price'] ?? defaultPrice;
    final price = rawPrice is num ? rawPrice.toDouble() : (double.tryParse(rawPrice?.toString() ?? '') ?? 0.0);

    final rawSeats = json['seatsAvailable'] ?? json['availableSeats'] ?? (json['seats'] is Map ? json['seats']['available'] : null) ?? json['totalSeats'] ?? 0;
    final seats = rawSeats is num ? rawSeats.toInt() : (int.tryParse(rawSeats.toString()) ?? 0);

    return RideDriver(
      id: json['id']?.toString() ?? json['driverId']?.toString() ?? json['rideId']?.toString() ?? driverMap?['id']?.toString() ?? '',
      name: name,
      rating: ratingNum,
      ratingText: ratingTxt,
      reviewCount: tripsNum,
      tripsCount: tripsNum,
      tripsText: tripsTxt,
      driverSummary: summary,
      pricePerSeat: price,
      carModel: car,
      vehicleNumber: plate,
      seatsAvailable: seats,
      departureTime: json['departureTime']?.toString() ?? tripMap?['departureTime']?.toString() ?? '',
      pickupPoint: json['pickupPoint']?.toString() ?? json['pickupLocation']?.toString() ?? tripMap?['pickupLocation']?.toString() ?? '',
      destinationPoint: json['destinationPoint']?.toString() ?? json['destinationLocation']?.toString() ?? tripMap?['destinationLocation']?.toString() ?? '',
      amenities: json['amenities'] is List ? List<String>.from(json['amenities'].map((e) => e.toString())) : const [],
      avatarImage: avatar,
      phone: json['phone']?.toString() ?? driverMap?['phone']?.toString() ?? '',
      about: json['about']?.toString() ?? driverMap?['about']?.toString() ?? '',
      isOnline: json['isOnline'] != false && driverMap?['isOnline'] != false,
    );
  }

  RideDriver copyWith({
    String? id,
    String? name,
    double? rating,
    String? ratingText,
    int? reviewCount,
    int? tripsCount,
    double? pricePerSeat,
    String? carModel,
    String? vehicleNumber,
    int? seatsAvailable,
    String? departureTime,
    String? pickupPoint,
    String? destinationPoint,
    List<String>? amenities,
    String? avatarImage,
    String? phone,
    String? about,
    String? tripsText,
    String? driverSummary,
    bool? isOnline,
  }) {
    return RideDriver(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      ratingText: ratingText ?? this.ratingText,
      reviewCount: reviewCount ?? this.reviewCount,
      tripsCount: tripsCount ?? this.tripsCount,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      carModel: carModel ?? this.carModel,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      seatsAvailable: seatsAvailable ?? this.seatsAvailable,
      departureTime: departureTime ?? this.departureTime,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      destinationPoint: destinationPoint ?? this.destinationPoint,
      amenities: amenities ?? this.amenities,
      avatarImage: avatarImage ?? this.avatarImage,
      phone: phone ?? this.phone,
      about: about ?? this.about,
      tripsText: tripsText ?? this.tripsText,
      driverSummary: driverSummary ?? this.driverSummary,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class BoardingPointItem {
  final String id;
  final String location;
  final String time;
  final String landmark;
  final String pincode;
  final bool isStartPoint;
  final bool isSelectable;
  final double price;

  const BoardingPointItem({
    required this.id,
    required this.location,
    required this.time,
    required this.landmark,
    required this.pincode,
    this.isStartPoint = false,
    this.isSelectable = true,
    this.price = 250.0,
  });

  factory BoardingPointItem.fromJson(Map<String, dynamic> json) {
    return BoardingPointItem(
      id: json['id']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      isStartPoint: json['isStartPoint'] == true,
      isSelectable: json['isSelectable'] != false,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : (double.tryParse(json['price']?.toString() ?? '') ?? 250.0),
    );
  }
}

class RouteTimelinePassenger {
  final String name;
  final String avatar;

  const RouteTimelinePassenger({required this.name, required this.avatar});

  factory RouteTimelinePassenger.fromJson(Map<String, dynamic> json) {
    return RouteTimelinePassenger(
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
    );
  }
}

class RouteTimelineStop {
  final String time;
  final String location;
  final String type;
  final String title;
  final String landmark;
  final String pincode;
  final int stopNumber;
  final double price;
  final String amountText;
  final double priceFromOrigin;
  final String amountFromOriginText;
  final int pickCount;
  final String passengerLabel;
  final List<RouteTimelinePassenger> passengers;

  const RouteTimelineStop({
    required this.time,
    required this.location,
    required this.type,
    this.title = '',
    this.landmark = '',
    this.pincode = '',
    this.stopNumber = 0,
    this.price = 0.0,
    this.amountText = '',
    this.priceFromOrigin = 0.0,
    this.amountFromOriginText = '',
    this.pickCount = 0,
    this.passengerLabel = '',
    this.passengers = const [],
  });

  factory RouteTimelineStop.fromJson(Map<String, dynamic> json) {
    final pList = (json['passengers'] as List?)
            ?.map((p) => RouteTimelinePassenger.fromJson(p is Map<String, dynamic> ? p : {}))
            .toList() ??
        [];

    final pCount = json['pickCount'] is num
        ? (json['pickCount'] as num).toInt()
        : (int.tryParse(json['pickCount']?.toString() ?? '') ?? (pList.isNotEmpty ? pList.length : 0));

    final rawPrice = json['price'] is num
        ? (json['price'] as num).toDouble()
        : (double.tryParse(json['price']?.toString() ?? '') ?? 0.0);

    final fromOriginPrice = json['priceFromOrigin'] is num
        ? (json['priceFromOrigin'] as num).toDouble()
        : (double.tryParse(json['priceFromOrigin']?.toString() ?? '') ?? 0.0);

    return RouteTimelineStop(
      time: json['time']?.toString() ?? '',
      location: json['location']?.toString() ?? json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      stopNumber: json['stopNumber'] is num ? (json['stopNumber'] as num).toInt() : (int.tryParse(json['stopNumber']?.toString() ?? '') ?? 0),
      price: rawPrice,
      amountText: json['amountText']?.toString() ?? (rawPrice > 0 ? '₹ ${rawPrice.toInt()}' : ''),
      priceFromOrigin: fromOriginPrice,
      amountFromOriginText: json['amountFromOriginText']?.toString() ?? (fromOriginPrice > 0 ? '₹ ${fromOriginPrice.toInt()}' : ''),
      pickCount: pCount,
      passengerLabel: json['passengerLabel']?.toString() ?? (pCount > 0 ? 'Pick $pCount' : ''),
      passengers: pList,
    );
  }
}

class RideDetailData {
  final String rideId;
  final RideDriver driver;
  final String vehicleName;
  final String vehicleSummary;
  final String vehicleNumberPlate;
  final String vehicleColor;
  final String fuelType;
  final String from;
  final String to;
  final String departureDate;
  final String departureTime;
  final String arrivalDateFormatted;
  final String arrivalTime;
  final String duration;
  final String distance;
  final int totalSeats;
  final int availableSeats;
  final int bookedSeats;
  final String availableSeatsText;
  final double pricePerSeat;
  final String costPerSeatText;
  final String luggageText;
  final List<RouteTimelineStop> routeTimeline;
  final String staticMapUrl;
  final List<String> instructions;
  final bool canContactDriver;
  final bool canShareRide;
  final bool canBook;

  const RideDetailData({
    required this.rideId,
    required this.driver,
    required this.vehicleName,
    required this.vehicleSummary,
    required this.vehicleNumberPlate,
    this.vehicleColor = '',
    this.fuelType = '',
    required this.from,
    required this.to,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalDateFormatted,
    required this.arrivalTime,
    required this.duration,
    required this.distance,
    this.totalSeats = 4,
    required this.availableSeats,
    this.bookedSeats = 0,
    required this.availableSeatsText,
    required this.pricePerSeat,
    required this.costPerSeatText,
    this.luggageText = '1 Medium Bag',
    required this.routeTimeline,
    required this.staticMapUrl,
    required this.instructions,
    this.canContactDriver = true,
    this.canShareRide = true,
    this.canBook = true,
  });

  factory RideDetailData.fromJson(
    Map<String, dynamic> json, {
    String? pickup,
    String? destination,
    double? fallbackPrice,
  }) {
    final root = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    final rideId = root['rideId']?.toString() ?? root['id']?.toString() ?? '';
    final vehicle = root['vehicle'] is Map<String, dynamic> ? root['vehicle'] as Map<String, dynamic> : <String, dynamic>{};
    final trip = root['trip'] is Map<String, dynamic> ? root['trip'] as Map<String, dynamic> : <String, dynamic>{};
    final seats = root['seats'] is Map<String, dynamic> ? root['seats'] as Map<String, dynamic> : <String, dynamic>{};
    final pricing = root['pricing'] is Map<String, dynamic> ? root['pricing'] as Map<String, dynamic> : <String, dynamic>{};
    final map = root['map'] is Map<String, dynamic> ? root['map'] as Map<String, dynamic> : <String, dynamic>{};
    final luggage = root['luggage'] is Map<String, dynamic> ? root['luggage'] as Map<String, dynamic> : <String, dynamic>{};
    final actions = root['actions'] is Map<String, dynamic> ? root['actions'] as Map<String, dynamic> : <String, dynamic>{};

    final timelineList = (root['routeTimeline'] as List?)
            ?.map((item) => RouteTimelineStop.fromJson(item is Map<String, dynamic> ? item : {}))
            .toList() ??
        [];

    final firstTimelinePrice = timelineList.isNotEmpty && timelineList.first.price > 0 ? timelineList.first.price : 0.0;

    // 1. Explicit backend segment price fields returned for customer's queried segment
    final dynamic rawSegmentPrice = pricing['segmentPrice'] ??
        pricing['segmentFare'] ??
        pricing['priceForSegment'] ??
        root['segmentFare'] ??
        root['calculatedFare'] ??
        (root['segmentPricing'] is Map ? (root['segmentPricing']['pricePerSeat'] ?? root['segmentPricing']['fare']) : null);
    final num? parsedSegmentPrice = rawSegmentPrice is num
        ? rawSegmentPrice
        : (double.tryParse(rawSegmentPrice?.toString() ?? ''));

    // 2. Timeline stop differential calculation if stop prices are provided by backend
    double? timelineDifferentialPrice;
    if (pickup != null && destination != null && timelineList.isNotEmpty) {
      final pNorm = pickup.trim().toLowerCase();
      final dNorm = destination.trim().toLowerCase();
      int pIndex = -1;
      int dIndex = -1;
      for (int i = 0; i < timelineList.length; i++) {
        final loc = timelineList[i].location.toLowerCase();
        if (pIndex == -1 && loc.contains(pNorm)) pIndex = i;
        if (loc.contains(dNorm)) dIndex = i;
      }
      if (pIndex != -1 && dIndex != -1 && pIndex < dIndex) {
        final pStop = timelineList[pIndex];
        final dStop = timelineList[dIndex];
        if (dStop.priceFromOrigin > 0 && pStop.priceFromOrigin >= 0 && dStop.priceFromOrigin > pStop.priceFromOrigin) {
          timelineDifferentialPrice = dStop.priceFromOrigin - pStop.priceFromOrigin;
        }
      }
    }

    final fullRoutePrice = (pricing['pricePerSeat'] is num
        ? (pricing['pricePerSeat'] as num).toDouble()
        : (double.tryParse(pricing['pricePerSeat']?.toString() ?? '') ??
            (root['pricePerSeat'] is num
                ? (root['pricePerSeat'] as num).toDouble()
                : (double.tryParse(root['pricePerSeat']?.toString() ?? '') ??
                    (root['price'] is num
                        ? (root['price'] as num).toDouble()
                        : (double.tryParse(root['price']?.toString() ?? '') ?? firstTimelinePrice))))));

    // Priority hierarchy for customer segment fare:
    // 1. Explicit backend-calculated segment price returned in response
    // 2. Calculated timeline stop differential (destination - pickup cumulative)
    // 3. Customer search session validated segment fare (fallbackPrice)
    // 4. Default to full-route master price if booking whole route
    final rawPrice = parsedSegmentPrice?.toDouble() ??
        timelineDifferentialPrice ??
        (fallbackPrice != null && fallbackPrice > 0 ? fallbackPrice : fullRoutePrice);

    final pricePerSeat = rawPrice > 0 ? rawPrice : fullRoutePrice;

    final driverJson = root['driver'] is Map<String, dynamic> ? root['driver'] as Map<String, dynamic> : <String, dynamic>{};
    final driver = RideDriver.fromJson(
      driverJson,
      defaultCar: vehicle['model']?.toString() ?? vehicle['name']?.toString() ?? vehicle['summary']?.toString() ?? '',
      defaultPlate: vehicle['numberPlate']?.toString() ?? '',
      defaultPrice: pricePerSeat,
    );

    final instrList = (root['instructions'] as List?)?.map((e) => e.toString()).toList() ?? [];

    final availSeats = seats['available'] is num
        ? (seats['available'] as num).toInt()
        : (int.tryParse(seats['available']?.toString() ?? '') ??
            (root['availableSeats'] is num
                ? (root['availableSeats'] as num).toInt()
                : (root['seatsAvailable'] is num ? (root['seatsAvailable'] as num).toInt() : 0)));

    final totSeats = seats['total'] is num
        ? (seats['total'] as num).toInt()
        : (int.tryParse(seats['total']?.toString() ?? '') ??
            (root['totalSeats'] is num ? (root['totalSeats'] as num).toInt() : 4));

    final bkdSeats = seats['booked'] is num
        ? (seats['booked'] as num).toInt()
        : (int.tryParse(seats['booked']?.toString() ?? '') ??
            (root['bookedSeats'] is num ? (root['bookedSeats'] as num).toInt() : 0));

    final vehicleSummary = vehicle['vehicleSummary']?.toString() ??
        vehicle['summary']?.toString() ??
        (vehicle['model'] != null || vehicle['name'] != null
            ? '${vehicle['model'] ?? vehicle['name'] ?? ''}${vehicle['color'] != null ? " • ${vehicle['color']}" : ""}${vehicle['numberPlate'] != null ? " • ${vehicle['numberPlate']}" : ""}'.trim()
            : (driver.driverSummary.isNotEmpty ? driver.driverSummary : ''));

    final startLocation = trip['from']?.toString() ??
        trip['pickupLocation']?.toString() ??
        root['pickupLocation']?.toString() ??
        root['from']?.toString() ??
        (timelineList.isNotEmpty ? timelineList.first.location : '');

    final destLocation = trip['to']?.toString() ??
        trip['destinationLocation']?.toString() ??
        root['destinationLocation']?.toString() ??
        root['to']?.toString() ??
        (timelineList.isNotEmpty ? timelineList.last.location : '');

    final depDate = trip['departureDate']?.toString() ??
        root['departureDate']?.toString() ??
        root['date']?.toString() ??
        '';

    final depTime = trip['departureTime']?.toString() ??
        root['departureTime']?.toString() ??
        root['time']?.toString() ??
        (timelineList.isNotEmpty ? timelineList.first.time : '');

    final arrTime = trip['arrivalTime']?.toString() ??
        root['arrivalTime']?.toString() ??
        (timelineList.isNotEmpty ? timelineList.last.time : '');

    return RideDetailData(
      rideId: rideId,
      driver: driver,
      vehicleName: vehicle['model']?.toString() ?? vehicle['name']?.toString() ?? '',
      vehicleSummary: vehicleSummary,
      vehicleNumberPlate: vehicle['numberPlate']?.toString() ?? '',
      vehicleColor: vehicle['color']?.toString() ?? '',
      fuelType: vehicle['fuelType']?.toString() ?? '',
      from: startLocation,
      to: destLocation,
      departureDate: depDate,
      departureTime: depTime,
      arrivalDateFormatted: trip['arrivalDateFormatted']?.toString() ?? root['arrivalDateFormatted']?.toString() ?? '',
      arrivalTime: arrTime,
      duration: trip['duration']?.toString() ?? root['duration']?.toString() ?? '',
      distance: trip['distance']?.toString() ?? root['distance']?.toString() ?? '',
      totalSeats: totSeats,
      availableSeats: availSeats,
      bookedSeats: bkdSeats,
      availableSeatsText: seats['availableSeatsText']?.toString() ??
          root['availableSeatsText']?.toString() ??
          (availSeats > 0 ? 'Available $availSeats seats' : 'No seats available'),
      pricePerSeat: pricePerSeat,
      costPerSeatText: pricing['costPerSeatText']?.toString() ??
          root['costPerSeatText']?.toString() ??
          (pricePerSeat > 0 ? 'Cost Per Seat ₹ ${pricePerSeat.toInt()}' : ''),
      luggageText: luggage['luggageText']?.toString() ?? root['luggage']?.toString() ?? '1 Medium Bag',
      routeTimeline: timelineList,
      staticMapUrl: map['interactiveMapUrl']?.toString() ?? map['routeMapUrl']?.toString() ?? '',
      instructions: instrList,
      canContactDriver: actions['canContactDriver'] != false,
      canShareRide: actions['canShareRide'] != false,
      canBook: actions['canBook'] != false,
    );
  }
}

class RideBookingSession {
  final String rideId;
  final String bookingId;
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
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
  final RideDetailData? rideDetailData;

  const RideBookingSession({
    this.rideId = '',
    this.bookingId = '',
    this.driver = const RideDriver(),
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
    this.perKmDetourRate = 0.0,
    this.passengerName = '',
    this.passengerPhone = '',
    this.passengerEmail = '',
    this.luggage = '',
    this.paymentMethod = 'UPI',
    this.totalAmount = 0.0,
    this.boardingPin = '',
    this.razorpayOrderId = '',
    this.razorpayPaymentId = '',
    this.razorpaySignature = '',
    this.rideDetailData,
  });

  RideBookingSession copyWith({
    String? rideId,
    String? bookingId,
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
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
    RideDetailData? rideDetailData,
  }) {
    return RideBookingSession(
      rideId: rideId ?? this.rideId,
      bookingId: bookingId ?? this.bookingId,
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
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpaySignature: razorpaySignature ?? this.razorpaySignature,
      rideDetailData: rideDetailData ?? this.rideDetailData,
    );
  }

  Map<String, dynamic> toBookPayload() {
    final parts = passengerName.trim().split(' ');
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : (parts.isNotEmpty ? parts.first : '');

    return {
      'rideId': rideId.isNotEmpty ? rideId : driver.id,
      'fullName': passengerName,
      'lastName': lastName,
      'phoneNumber': passengerPhone,
      'emailID': passengerEmail,
      'numberOfSeats': seatsCount,
      'boardingPoint': boardingPoint.isNotEmpty ? boardingPoint : pickup,
      'destination': destination,
    };
  }

  Map<String, dynamic> toJson() => toBookPayload();
}

class IntermediateStopFare {
  final int stopNumber;
  final String location;
  final double price;
  final double priceFromOrigin;
  final double priceToDestination;
  final double suggestedPriceFromOrigin;
  final double suggestedPriceToDestination;
  final double distanceFromOriginKm;
  final double distanceToDestinationKm;
  final String amountText;

  const IntermediateStopFare({
    this.stopNumber = 0,
    this.location = '',
    this.price = 0.0,
    this.priceFromOrigin = 0.0,
    this.priceToDestination = 0.0,
    this.suggestedPriceFromOrigin = 0.0,
    this.suggestedPriceToDestination = 0.0,
    this.distanceFromOriginKm = 0.0,
    this.distanceToDestinationKm = 0.0,
    this.amountText = '',
  });

  factory IntermediateStopFare.fromJson(Map<String, dynamic> json) {
    num getNum(dynamic v) => v is num ? v : (num.tryParse(v?.toString() ?? '') ?? 0);
    final p = getNum(json['price']).toDouble();
    final pFromOrigin = getNum(json['priceFromOrigin'] ?? json['suggestedPriceFromOrigin']).toDouble();
    final pToDest = getNum(json['priceToDestination'] ?? json['suggestedPriceToDestination']).toDouble();

    return IntermediateStopFare(
      stopNumber: (json['stopNumber'] is num) ? (json['stopNumber'] as num).toInt() : (int.tryParse(json['stopNumber']?.toString() ?? '') ?? 0),
      location: json['location']?.toString() ?? '',
      price: p,
      priceFromOrigin: pFromOrigin,
      priceToDestination: pToDest,
      suggestedPriceFromOrigin: pFromOrigin,
      suggestedPriceToDestination: pToDest,
      distanceFromOriginKm: getNum(json['distanceFromOriginKm']).toDouble(),
      distanceToDestinationKm: getNum(json['distanceToDestinationKm']).toDouble(),
      amountText: json['amountText']?.toString() ?? (p > 0 ? '₹ ${p.toInt()}' : (pFromOrigin > 0 ? '₹ ${pFromOrigin.toInt()}' : '')),
    );
  }
}

class RouteSegmentFare {
  final String from;
  final String to;
  final double distanceKm;
  final double price;

  const RouteSegmentFare({
    this.from = '',
    this.to = '',
    this.distanceKm = 0.0,
    this.price = 0.0,
  });

  factory RouteSegmentFare.fromJson(Map<String, dynamic> json) {
    num getNum(dynamic v) => v is num ? v : (num.tryParse(v?.toString() ?? '') ?? 0);
    return RouteSegmentFare(
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      distanceKm: getNum(json['distanceKm']).toDouble(),
      price: getNum(json['price']).toDouble(),
    );
  }
}

class IntermediateFareResult {
  final String origin;
  final String destination;
  final String totalDistance;
  final double totalPrice;
  final double ratePerKm;
  final String ratePerKmText;
  final List<IntermediateStopFare> intermediatePickups;
  final List<RouteSegmentFare> allSegments;

  const IntermediateFareResult({
    this.origin = '',
    this.destination = '',
    this.totalDistance = '',
    this.totalPrice = 0.0,
    this.ratePerKm = 0.0,
    this.ratePerKmText = '',
    this.intermediatePickups = const [],
    this.allSegments = const [],
  });

  factory IntermediateFareResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json);

    num getNum(dynamic v) => v is num ? v : (num.tryParse(v?.toString() ?? '') ?? 0);

    final stopsList = (data['intermediatePickups'] as List?)
            ?.map((e) => IntermediateStopFare.fromJson(e is Map<String, dynamic> ? e : (e is Map ? Map<String, dynamic>.from(e) : {})))
            .toList() ??
        [];

    final segmentsList = (data['allSegments'] as List?)
            ?.map((e) => RouteSegmentFare.fromJson(e is Map<String, dynamic> ? e : (e is Map ? Map<String, dynamic>.from(e) : {})))
            .toList() ??
        [];

    final rateNum = getNum(data['ratePerKm']).toDouble();

    return IntermediateFareResult(
      origin: data['origin']?.toString() ?? data['from']?.toString() ?? '',
      destination: data['destination']?.toString() ?? data['to']?.toString() ?? '',
      totalDistance: data['totalDistance']?.toString() ?? '',
      totalPrice: getNum(data['totalPrice'] ?? data['price']).toDouble(),
      ratePerKm: rateNum,
      ratePerKmText: data['ratePerKmText']?.toString() ?? (rateNum > 0 ? '₹ $rateNum/km' : ''),
      intermediatePickups: stopsList,
      allSegments: segmentsList,
    );
  }
}

class SeatGridItem {
  final String seat;
  final String status; // "Booked", "Available", "Boarded", "Selected"
  final String passengerName;
  final bool isPassengerSeat;

  const SeatGridItem({
    required this.seat,
    this.status = 'Available',
    this.passengerName = '',
    this.isPassengerSeat = false,
  });

  bool get isBooked => status.toLowerCase() == 'booked';
  bool get isAvailable => status.toLowerCase() == 'available';
  bool get isBoarded => status.toLowerCase() == 'boarded';

  factory SeatGridItem.fromJson(Map<String, dynamic> json) {
    return SeatGridItem(
      seat: json['seat']?.toString() ?? json['seatNumber']?.toString() ?? 'S-1',
      status: json['status']?.toString() ?? (json['isBooked'] == true ? 'Booked' : 'Available'),
      passengerName: json['passengerName']?.toString() ?? json['name']?.toString() ?? '',
      isPassengerSeat: json['isPassengerSeat'] == true,
    );
  }
}

class PassengerBoardingVerifyDetails {
  final String bookingId;
  final String rideId;
  final String passengerName;
  final String pickupLocation;
  final String dropoffLocation;
  final String seatNumber;
  final int pinLength;
  final String expectedPin;
  final bool isBoarded;
  final List<SeatGridItem> seatGrid;

  const PassengerBoardingVerifyDetails({
    this.bookingId = '',
    this.rideId = '',
    this.passengerName = '',
    this.pickupLocation = '',
    this.dropoffLocation = '',
    this.seatNumber = 'S-1',
    this.pinLength = 4,
    this.expectedPin = '',
    this.isBoarded = false,
    this.seatGrid = const [],
  });

  factory PassengerBoardingVerifyDetails.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json);

    final gridList = (data['seatGrid'] as List?)
            ?.map((e) => SeatGridItem.fromJson(e is Map<String, dynamic> ? e : (e is Map ? Map<String, dynamic>.from(e) : {})))
            .toList() ??
        const [
          SeatGridItem(seat: 'S-1', status: 'Booked'),
          SeatGridItem(seat: 'S-2', status: 'Booked', isPassengerSeat: true),
          SeatGridItem(seat: 'S-3', status: 'Booked'),
          SeatGridItem(seat: 'S-4', status: 'Available'),
        ];

    return PassengerBoardingVerifyDetails(
      bookingId: data['bookingId']?.toString() ?? '',
      rideId: data['rideId']?.toString() ?? '',
      passengerName: data['passengerName']?.toString() ?? data['name']?.toString() ?? data['fullName']?.toString() ?? 'Passenger',
      pickupLocation: data['pickupLocation']?.toString() ?? data['pickup']?.toString() ?? data['boardingPoint']?.toString() ?? '',
      dropoffLocation: data['dropoffLocation']?.toString() ?? data['destination']?.toString() ?? '',
      seatNumber: data['seatNumber']?.toString() ?? data['seat']?.toString() ?? 'S-2',
      pinLength: data['pinLength'] is int ? data['pinLength'] as int : 4,
      expectedPin: data['expectedPin']?.toString() ?? data['pin']?.toString() ?? data['boardingPin']?.toString() ?? '',
      isBoarded: data['isBoarded'] == true,
      seatGrid: gridList,
    );
  }
}

class StartRideLockStatus {
  final bool canStartRide;
  final bool isLocked;
  final String departureDateTime;
  final String departureFormatted;
  final String startRideAllowedFrom;
  final String startRideAllowedFromFormatted;
  final double hoursRemainingUntilStart;
  final int minutesRemainingUntilStart;
  final String lockReason;
  final String buttonText;
  final bool preTripAlertSent;

  const StartRideLockStatus({
    this.canStartRide = true,
    this.isLocked = false,
    this.departureDateTime = '',
    this.departureFormatted = '',
    this.startRideAllowedFrom = '',
    this.startRideAllowedFromFormatted = '',
    this.hoursRemainingUntilStart = 0.0,
    this.minutesRemainingUntilStart = 0,
    this.lockReason = '',
    this.buttonText = 'Start Navigation',
    this.preTripAlertSent = false,
  });

  factory StartRideLockStatus.fromJson(Map<String, dynamic> json) {
    num getNum(dynamic v) => (v is num) ? v : (num.tryParse(v?.toString() ?? '') ?? 0);
    return StartRideLockStatus(
      canStartRide: json['canStartRide'] == true || json['canStartNavigation'] == true,
      isLocked: json['isLocked'] == true,
      departureDateTime: json['departureDateTime']?.toString() ?? '',
      departureFormatted: json['departureFormatted']?.toString() ?? '',
      startRideAllowedFrom: json['startRideAllowedFrom']?.toString() ?? '',
      startRideAllowedFromFormatted: json['startRideAllowedFromFormatted']?.toString() ?? '',
      hoursRemainingUntilStart: getNum(json['hoursRemainingUntilStart']).toDouble(),
      minutesRemainingUntilStart: getNum(json['minutesRemainingUntilStart']).toInt(),
      lockReason: json['lockReason']?.toString() ?? json['startRideLockReason']?.toString() ?? json['message']?.toString() ?? '',
      buttonText: json['buttonText']?.toString() ?? json['startRideButtonText']?.toString() ?? (json['isLocked'] == true ? 'Locked' : 'Start Navigation'),
      preTripAlertSent: json['preTripAlertSent'] == true,
    );
  }
}

class PreTripAlertResponse {
  final bool success;
  final String message;
  final String rideId;
  final bool preTripAlertSent;
  final String preTripAlertSentAt;
  final bool driverNotified;
  final int passengersCount;

  const PreTripAlertResponse({
    this.success = false,
    this.message = '',
    this.rideId = '',
    this.preTripAlertSent = false,
    this.preTripAlertSentAt = '',
    this.driverNotified = false,
    this.passengersCount = 0,
  });

  factory PreTripAlertResponse.fromJson(Map<String, dynamic> json) {
    final notifs = json['notificationsSent'] is Map ? json['notificationsSent'] as Map : {};
    num getNum(dynamic v) => (v is num) ? v : (num.tryParse(v?.toString() ?? '') ?? 0);
    return PreTripAlertResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      rideId: json['rideId']?.toString() ?? '',
      preTripAlertSent: json['preTripAlertSent'] == true,
      preTripAlertSentAt: json['preTripAlertSentAt']?.toString() ?? '',
      driverNotified: notifs['driver'] == true,
      passengersCount: getNum(notifs['passengersCount']).toInt(),
    );
  }
}

const List<RideDriver> mockRideDrivers = [];

