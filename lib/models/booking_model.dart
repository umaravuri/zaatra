import 'ride_option_model.dart';

class BookingModel {
  final String bookingId;
  final String pickupAddress;
  final String dropoffAddress;
  final RideOptionModel selectedRide;
  final double totalFare;
  final String paymentMethod;
  final String promoCode;
  final double discountAmount;
  final String driverName;
  final String driverPhoto;
  final double driverRating;
  final String vehicleModel;
  final String licensePlate;

  BookingModel({
    required this.bookingId,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.selectedRide,
    required this.totalFare,
    required this.paymentMethod,
    this.promoCode = '',
    this.discountAmount = 0.0,
    required this.driverName,
    required this.driverPhoto,
    required this.driverRating,
    required this.vehicleModel,
    required this.licensePlate,
  });

  static BookingModel createSample({
    required String pickup,
    required String dropoff,
    required RideOptionModel ride,
    required String payment,
    double discount = 0.0,
    String promo = '',
  }) {
    return BookingModel(
      bookingId: 'ZT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      pickupAddress: pickup,
      dropoffAddress: dropoff,
      selectedRide: ride,
      totalFare: (ride.estimatedFare - discount).clamp(0.0, 9999.0),
      paymentMethod: payment,
      promoCode: promo,
      discountAmount: discount,
      driverName: 'Rafiqul Islam',
      driverPhoto: 'https://i.pravatar.cc/150?img=11',
      driverRating: 4.9,
      vehicleModel: 'Toyota Prius (White)',
      licensePlate: 'DHK-METRO-1234',
    );
  }
}

class DriverTabInfo {
  final String id;
  final String title;
  final String label;
  final int count;
  final int badge;
  final bool isSelected;

  const DriverTabInfo({
    required this.id,
    required this.title,
    required this.label,
    this.count = 0,
    this.badge = 0,
    this.isSelected = false,
  });

  factory DriverTabInfo.fromJson(Map<String, dynamic> json) {
    return DriverTabInfo(
      id: json['id']?.toString() ?? 'booking_requests',
      title: json['title']?.toString() ?? 'Booking requests',
      label: json['label']?.toString() ?? json['title']?.toString() ?? 'Booking requests',
      count: (json['count'] as num?)?.toInt() ?? (json['badge'] as num?)?.toInt() ?? 0,
      badge: (json['badge'] as num?)?.toInt() ?? (json['count'] as num?)?.toInt() ?? 0,
      isSelected: json['isSelected'] == true,
    );
  }
}

class DriverTabCounts {
  final int bookingRequests;
  final int confirmed;
  final int denied;
  final int other;
  final int unreadCount;

  const DriverTabCounts({
    this.bookingRequests = 0,
    this.confirmed = 0,
    this.denied = 0,
    this.other = 0,
    this.unreadCount = 0,
  });

  factory DriverTabCounts.fromJson(Map<String, dynamic> json) {
    int getInt(dynamic v) => (v as num?)?.toInt() ?? (int.tryParse(v?.toString() ?? '') ?? 0);
    return DriverTabCounts(
      bookingRequests: getInt(json['booking_requests'] ?? json['bookingRequests'] ?? json['new']),
      confirmed: getInt(json['confirmed']),
      denied: getInt(json['denied'] ?? json['cancelled'] ?? json['declined']),
      other: getInt(json['other']),
      unreadCount: getInt(json['unreadCount']),
    );
  }
}

class DriverBookingRequestItem {
  final String id;
  final String bookingId;
  final String rideId;
  final String customerName;
  final String customerAvatar;
  final String customerPhone;
  final String pickup;
  final String destination;
  final String boardingPoint;
  final String routeText;
  final String createdAt;
  final String timestamp;
  final String timeAgo;
  final int seats;
  final double amount;
  final String formattedAmount;
  final String seatPriceText;
  final String status;
  final String statusBadge;
  final String badgeColor;
  final bool isDetour;
  final num detourDistanceKm;
  final num detourExtraFare;
  final num detourShiftMinutes;
  final String detourPickup;
  final String detourDestination;
  final Map<String, dynamic>? actions;
  final Map<String, dynamic>? publishNewRideCta;

  const DriverBookingRequestItem({
    required this.id,
    required this.bookingId,
    this.rideId = '',
    this.customerName = 'Passenger',
    this.customerAvatar = '',
    this.customerPhone = '',
    this.pickup = '',
    this.destination = '',
    this.boardingPoint = '',
    this.routeText = '',
    this.createdAt = '',
    this.timestamp = '',
    this.timeAgo = 'Just now',
    this.seats = 1,
    this.amount = 0.0,
    this.formattedAmount = '',
    this.seatPriceText = '',
    this.status = 'pending',
    this.statusBadge = 'Pending',
    this.badgeColor = 'purple',
    this.isDetour = false,
    this.detourDistanceKm = 0,
    this.detourExtraFare = 0,
    this.detourShiftMinutes = 0,
    this.detourPickup = '',
    this.detourDestination = '',
    this.actions,
    this.publishNewRideCta,
  });

  bool get isPending => status.toLowerCase() == 'pending' || status.toLowerCase() == 'requested' || status.toLowerCase() == 'new';
  bool get isConfirmed => status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'conformed' || status.toLowerCase() == 'accepted';
  bool get isDenied => status.toLowerCase() == 'declined' || status.toLowerCase() == 'denied' || status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'rejected';

  factory DriverBookingRequestItem.fromJson(Map<String, dynamic> json) {
    num getNum(dynamic v) => (v is num) ? v : (num.tryParse(v?.toString() ?? '') ?? 0);

    final bId = json['bookingId']?.toString() ?? json['id']?.toString() ?? json['_id']?.toString() ?? '';
    final seatsVal = getNum(json['seats'] ?? json['seatsBooked'] ?? json['seatsCount']).toInt();
    final amtVal = getNum(json['amount'] ?? json['totalAmount'] ?? json['fare']).toDouble();
    final fromLoc = json['pickup']?.toString() ?? json['from'] ?? json['pickupLocation'] ?? json['origin'] ?? '';
    final toLoc = json['destination']?.toString() ?? json['to'] ?? json['destinationLocation'] ?? '';
    final rtText = json['routeText']?.toString() ?? (fromLoc.isNotEmpty && toLoc.isNotEmpty ? '$fromLoc → $toLoc' : '');

    final detourDist = getNum(json['detourDistanceKm'] ?? json['detourDistance'] ?? json['extraDistanceKm']);
    final detourExtra = getNum(json['detourExtraFare'] ?? json['driverExtraEarning'] ?? json['extraCharge']);
    final isDetourReq = json['isDetour'] == true || json['isDoorstep'] == true || json['detour'] == true || detourDist > 0;

    return DriverBookingRequestItem(
      id: json['id']?.toString() ?? bId,
      bookingId: bId,
      rideId: json['rideId']?.toString() ?? json['ride']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? json['passengerName']?.toString() ?? json['name']?.toString() ?? 'Passenger',
      customerAvatar: json['customerAvatar']?.toString() ?? json['avatar']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? json['phone']?.toString() ?? json['phoneNumber']?.toString() ?? '',
      pickup: fromLoc,
      destination: toLoc,
      boardingPoint: json['boardingPoint']?.toString() ?? fromLoc,
      routeText: rtText,
      createdAt: json['createdAt']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      timeAgo: json['timeAgo']?.toString() ?? json['time']?.toString() ?? 'Just now',
      seats: seatsVal > 0 ? seatsVal : 1,
      amount: amtVal,
      formattedAmount: json['formattedAmount']?.toString() ?? (amtVal > 0 ? '₹ ${amtVal.toInt()}' : ''),
      seatPriceText: json['seatPriceText']?.toString() ?? '${seatsVal > 0 ? seatsVal : 1} Seat · ₹ ${amtVal.toInt()}',
      status: json['status']?.toString() ?? 'pending',
      statusBadge: json['statusBadge']?.toString() ?? (json['status']?.toString().toUpperCase() ?? 'PENDING'),
      badgeColor: json['badgeColor']?.toString() ?? 'purple',
      isDetour: isDetourReq,
      detourDistanceKm: detourDist,
      detourExtraFare: detourExtra,
      detourShiftMinutes: getNum(json['detourShiftMinutes'] ?? json['totalTripShiftMinutes'] ?? json['shiftMinutes']),
      detourPickup: json['detourPickup']?.toString() ?? json['pickupAddress']?.toString() ?? fromLoc,
      detourDestination: json['detourDestination']?.toString() ?? json['destinationAddress']?.toString() ?? toLoc,
      actions: json['actions'] is Map ? Map<String, dynamic>.from(json['actions'] as Map) : null,
      publishNewRideCta: json['publishNewRideCta'] is Map ? Map<String, dynamic>.from(json['publishNewRideCta'] as Map) : null,
    );
  }
}

class DriverOtherNotificationItem {
  final String id;
  final String title;
  final String body;
  final String category;
  final String iconType;
  final bool read;
  final bool unread;
  final String timeAgo;

  const DriverOtherNotificationItem({
    required this.id,
    required this.title,
    this.body = '',
    this.category = 'General',
    this.iconType = 'general',
    this.read = true,
    this.unread = false,
    this.timeAgo = 'Recently',
  });

  factory DriverOtherNotificationItem.fromJson(Map<String, dynamic> json) {
    return DriverOtherNotificationItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['subject']?.toString() ?? json['message']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? json['description']?.toString() ?? json['subtitle']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      iconType: json['iconType']?.toString() ?? json['type']?.toString() ?? 'general',
      read: json['read'] == true,
      unread: json['unread'] == true || json['read'] == false,
      timeAgo: json['timeAgo']?.toString() ?? json['time']?.toString() ?? json['createdAt']?.toString() ?? 'Recently',
    );
  }
}

class DriverNotificationResponse {
  final bool success;
  final String selectedTab;
  final List<DriverTabInfo> tabs;
  final DriverTabCounts counts;
  final int count;
  final List<DriverBookingRequestItem> bookingItems;
  final List<DriverOtherNotificationItem> otherItems;
  final String? emptyStateTitle;
  final String? emptyStateDescription;

  const DriverNotificationResponse({
    this.success = false,
    this.selectedTab = 'booking_requests',
    this.tabs = const [],
    this.counts = const DriverTabCounts(),
    this.count = 0,
    this.bookingItems = const [],
    this.otherItems = const [],
    this.emptyStateTitle,
    this.emptyStateDescription,
  });

  factory DriverNotificationResponse.fromJson(Map<String, dynamic> json) {
    final tabList = (json['tabs'] as List?)
            ?.map((t) => DriverTabInfo.fromJson(t is Map<String, dynamic> ? t : Map<String, dynamic>.from(t as Map)))
            .toList() ??
        const [];

    final countsObj = json['counts'] is Map
        ? DriverTabCounts.fromJson(Map<String, dynamic>.from(json['counts'] as Map))
        : const DriverTabCounts();

    final selected = json['selectedTab']?.toString() ?? 'booking_requests';
    final rawItems = json['items'] as List? ?? json['data'] as List? ?? json['notifications'] as List? ?? [];

    final bookings = <DriverBookingRequestItem>[];
    final notifs = <DriverOtherNotificationItem>[];

    if (selected == 'other') {
      for (final item in rawItems) {
        if (item is Map) {
          notifs.add(DriverOtherNotificationItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else {
      for (final item in rawItems) {
        if (item is Map) {
          bookings.add(DriverBookingRequestItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    String? emptyT;
    String? emptyD;
    if (json['emptyState'] is Map) {
      emptyT = json['emptyState']['title']?.toString();
      emptyD = json['emptyState']['description']?.toString();
    }

    return DriverNotificationResponse(
      success: json['success'] == true,
      selectedTab: selected,
      tabs: tabList,
      counts: countsObj,
      count: (json['count'] as num?)?.toInt() ?? (selected == 'other' ? notifs.length : bookings.length),
      bookingItems: bookings,
      otherItems: notifs,
      emptyStateTitle: emptyT,
      emptyStateDescription: emptyD,
    );
  }
}

class DriverCustomerInfo {
  final String name;
  final String phone;
  final String email;
  final String avatar;

  const DriverCustomerInfo({
    this.name = 'Passenger',
    this.phone = '',
    this.email = '',
    this.avatar = '',
  });

  factory DriverCustomerInfo.fromJson(Map<String, dynamic> json) {
    return DriverCustomerInfo(
      name: json['name']?.toString() ?? 'Passenger',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString() ?? '',
      email: json['email']?.toString() ?? json['emailID']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
    );
  }
}

class DriverRideSummary {
  final String rideId;
  final String from;
  final String to;
  final String departureDate;
  final String departureTime;
  final String vehicle;
  final String vehicleNumberPlate;

  const DriverRideSummary({
    this.rideId = '',
    this.from = '',
    this.to = '',
    this.departureDate = '',
    this.departureTime = '',
    this.vehicle = '',
    this.vehicleNumberPlate = '',
  });

  factory DriverRideSummary.fromJson(Map<String, dynamic> json) {
    return DriverRideSummary(
      rideId: json['rideId']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      departureDate: json['departureDate']?.toString() ?? '',
      departureTime: json['departureTime']?.toString() ?? '',
      vehicle: json['vehicle']?.toString() ?? '',
      vehicleNumberPlate: json['vehicleNumberPlate']?.toString() ?? '',
    );
  }
}

class DriverBoardingInfo {
  final String boardingPoint;
  final String customerPickupAddress;
  final String customerPickupLandmark;
  final String customerPickupPincode;
  final bool doorstepPickupRequested;
  final double extraPickupCharge;

  const DriverBoardingInfo({
    this.boardingPoint = '',
    this.customerPickupAddress = '',
    this.customerPickupLandmark = '',
    this.customerPickupPincode = '',
    this.doorstepPickupRequested = false,
    this.extraPickupCharge = 0.0,
  });

  factory DriverBoardingInfo.fromJson(Map<String, dynamic> json) {
    num getNum(dynamic v) => (v is num) ? v : (num.tryParse(v?.toString() ?? '') ?? 0);
    return DriverBoardingInfo(
      boardingPoint: json['boardingPoint']?.toString() ?? '',
      customerPickupAddress: json['customerPickupAddress']?.toString() ?? '',
      customerPickupLandmark: json['customerPickupLandmark']?.toString() ?? '',
      customerPickupPincode: json['customerPickupPincode']?.toString() ?? '',
      doorstepPickupRequested: json['doorstepPickupRequested'] == true,
      extraPickupCharge: getNum(json['extraPickupCharge']).toDouble(),
    );
  }
}

class DriverPricingInfo {
  final int seats;
  final double pricePerSeat;
  final double totalAmount;
  final String formattedAmount;
  final String paymentStatus;
  final String paymentMethod;

  const DriverPricingInfo({
    this.seats = 1,
    this.pricePerSeat = 0.0,
    this.totalAmount = 0.0,
    this.formattedAmount = '',
    this.paymentStatus = 'unpaid',
    this.paymentMethod = 'UPI',
  });

  factory DriverPricingInfo.fromJson(Map<String, dynamic> json) {
    num getNum(dynamic v) => (v is num) ? v : (num.tryParse(v?.toString() ?? '') ?? 0);
    final tot = getNum(json['totalAmount'] ?? json['amount']).toDouble();
    return DriverPricingInfo(
      seats: getNum(json['seats']).toInt(),
      pricePerSeat: getNum(json['pricePerSeat']).toDouble(),
      totalAmount: tot,
      formattedAmount: json['formattedAmount']?.toString() ?? (tot > 0 ? '₹ ${tot.toInt()}' : ''),
      paymentStatus: json['paymentStatus']?.toString() ?? 'paid',
      paymentMethod: json['paymentMethod']?.toString() ?? 'UPI',
    );
  }
}

class DriverSecurityInfo {
  final String boardingPin;
  final String qrPassToken;
  final bool isBoarded;

  const DriverSecurityInfo({
    this.boardingPin = '',
    this.qrPassToken = '',
    this.isBoarded = false,
  });

  factory DriverSecurityInfo.fromJson(Map<String, dynamic> json) {
    return DriverSecurityInfo(
      boardingPin: json['boardingPin']?.toString() ?? '',
      qrPassToken: json['qrPassToken']?.toString() ?? '',
      isBoarded: json['isBoarded'] == true,
    );
  }
}

class DriverDetailActions {
  final bool canAccept;
  final bool canDecline;
  final String acceptUrl;
  final String declineUrl;

  const DriverDetailActions({
    this.canAccept = false,
    this.canDecline = false,
    this.acceptUrl = '',
    this.declineUrl = '',
  });

  factory DriverDetailActions.fromJson(Map<String, dynamic> json) {
    return DriverDetailActions(
      canAccept: json['canAccept'] == true,
      canDecline: json['canDecline'] == true,
      acceptUrl: json['acceptUrl']?.toString() ?? '',
      declineUrl: json['declineUrl']?.toString() ?? '',
    );
  }
}

class DriverBookingDetail {
  final String id;
  final String bookingId;
  final String status;
  final String statusBadge;
  final DriverCustomerInfo customer;
  final DriverRideSummary ride;
  final DriverBoardingInfo boarding;
  final DriverPricingInfo pricing;
  final DriverSecurityInfo security;
  final DriverDetailActions actions;

  const DriverBookingDetail({
    required this.id,
    required this.bookingId,
    this.status = 'pending',
    this.statusBadge = 'Pending',
    this.customer = const DriverCustomerInfo(),
    this.ride = const DriverRideSummary(),
    this.boarding = const DriverBoardingInfo(),
    this.pricing = const DriverPricingInfo(),
    this.security = const DriverSecurityInfo(),
    this.actions = const DriverDetailActions(),
  });

  factory DriverBookingDetail.fromJson(Map<String, dynamic> json) {
    final b = json['booking'] is Map
        ? json['booking'] as Map<String, dynamic>
        : (json['data'] is Map ? json['data'] as Map<String, dynamic> : json);

    final bId = b['bookingId']?.toString() ?? b['id']?.toString() ?? '';

    return DriverBookingDetail(
      id: b['id']?.toString() ?? bId,
      bookingId: bId,
      status: b['status']?.toString() ?? 'pending',
      statusBadge: b['statusBadge']?.toString() ?? (b['status']?.toString().toUpperCase() ?? 'PENDING'),
      customer: b['customer'] is Map ? DriverCustomerInfo.fromJson(Map<String, dynamic>.from(b['customer'] as Map)) : const DriverCustomerInfo(),
      ride: b['ride'] is Map ? DriverRideSummary.fromJson(Map<String, dynamic>.from(b['ride'] as Map)) : const DriverRideSummary(),
      boarding: b['boarding'] is Map ? DriverBoardingInfo.fromJson(Map<String, dynamic>.from(b['boarding'] as Map)) : const DriverBoardingInfo(),
      pricing: b['pricing'] is Map ? DriverPricingInfo.fromJson(Map<String, dynamic>.from(b['pricing'] as Map)) : const DriverPricingInfo(),
      security: b['security'] is Map ? DriverSecurityInfo.fromJson(Map<String, dynamic>.from(b['security'] as Map)) : const DriverSecurityInfo(),
      actions: b['actions'] is Map ? DriverDetailActions.fromJson(Map<String, dynamic>.from(b['actions'] as Map)) : const DriverDetailActions(),
    );
  }
}
