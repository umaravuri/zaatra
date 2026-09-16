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
