import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CustomerBookingItem {
  final String id;
  final String bookingId;
  final String category; // 'Stay' | 'Ride' | 'Heritage Sites' | 'Banquet Halls'
  final String type; // 'HOTEL STAY', 'RIDE BOOKING', 'HERITAGE TOUR', 'BANQUET VENUE'
  final String title;
  final String subtitle;
  final String price;
  final String status;
  final IconData icon;
  final Color statusColor;
  final DateTime? date;
  final Map<String, dynamic> rawJson;

  CustomerBookingItem({
    required this.id,
    required this.bookingId,
    required this.category,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.status,
    required this.icon,
    required this.statusColor,
    this.date,
    this.rawJson = const {},
  });

  factory CustomerBookingItem.fromJson(Map<String, dynamic> json, {String? defaultCategory}) {
    final id = json['id']?.toString() ?? json['_id']?.toString() ?? json['bookingId']?.toString() ?? '';
    final bookingId = json['bookingId']?.toString() ?? json['bookingCode']?.toString() ?? id;

    // Detect category if not provided
    String detectedCategory = defaultCategory ?? 'Ride';
    final rawCategory = json['category']?.toString().toLowerCase() ??
        json['type']?.toString().toLowerCase() ??
        json['bookingType']?.toString().toLowerCase() ??
        '';

    if (rawCategory.contains('stay') || rawCategory.contains('hotel') || rawCategory.contains('room')) {
      detectedCategory = 'Stay';
    } else if (rawCategory.contains('ride') || rawCategory.contains('cab') || rawCategory.contains('car')) {
      detectedCategory = 'Ride';
    } else if (rawCategory.contains('heritage') || rawCategory.contains('tour') || rawCategory.contains('monument')) {
      detectedCategory = 'Heritage Sites';
    } else if (rawCategory.contains('banquet') || rawCategory.contains('hall') || rawCategory.contains('event')) {
      detectedCategory = 'Banquet Halls';
    }

    // Determine type label and icon
    String typeLabel = 'BOOKING';
    IconData iconData = Icons.event_note_rounded;

    switch (detectedCategory) {
      case 'Stay':
        typeLabel = json['stayType']?.toString() ?? 'HOTEL STAY';
        iconData = Icons.apartment_rounded;
        break;
      case 'Ride':
        typeLabel = 'RIDE BOOKING';
        iconData = Icons.directions_car_rounded;
        break;
      case 'Heritage Sites':
        typeLabel = 'HERITAGE TOUR';
        iconData = Icons.account_balance_rounded;
        break;
      case 'Banquet Halls':
        typeLabel = 'BANQUET VENUE';
        iconData = Icons.celebration_rounded;
        break;
    }

    // Title & Subtitle
    String title = json['title']?.toString() ?? '';
    if (title.isEmpty) {
      if (detectedCategory == 'Ride') {
        final pickup = json['pickup'] ?? json['pickupLocation'] ?? json['from'] ?? 'Madhapur';
        final drop = json['destination'] ?? json['dropoffLocation'] ?? json['to'] ?? 'Secundrabad';
        title = '$pickup ➔ $drop';
      } else if (detectedCategory == 'Stay') {
        title = json['hotelName'] ?? json['propertyName'] ?? 'Zaatra Grand Stay';
      } else if (detectedCategory == 'Heritage Sites') {
        title = json['placeName'] ?? json['monumentName'] ?? 'Heritage Guided Tour';
      } else {
        title = json['hallName'] ?? json['venueName'] ?? 'Zaatra Royal Banquet Hall';
      }
    }

    String subtitle = json['subtitle']?.toString() ?? '';
    if (subtitle.isEmpty) {
      if (detectedCategory == 'Ride') {
        final dateStr = json['date'] ?? json['scheduleDate'] ?? 'Today';
        final driverName = json['driverName'] ?? (json['driver'] is Map ? json['driver']['name'] : null);
        subtitle = driverName != null ? '$dateStr • Driver: $driverName' : '$dateStr • Confirmed Ride';
      } else if (detectedCategory == 'Stay') {
        final checkIn = json['checkIn'] ?? json['checkInDate'] ?? '25 Aug';
        final checkOut = json['checkOut'] ?? json['checkOutDate'] ?? '28 Aug';
        subtitle = '$checkIn - $checkOut • Confirmed Stay';
      } else if (detectedCategory == 'Heritage Sites') {
        final timeStr = json['time'] ?? '10:00 AM';
        subtitle = 'Tour Timing: $timeStr • Entry Pass';
      } else {
        final guests = json['guests'] ?? json['capacity'] ?? '250+ Guests';
        subtitle = 'Event Reservation • $guests';
      }
    }

    // Price
    String priceStr = json['price']?.toString() ?? json['fare']?.toString() ?? json['totalAmount']?.toString() ?? '';
    if (priceStr.isNotEmpty && !priceStr.startsWith('₹') && !priceStr.startsWith('\$')) {
      final pNum = double.tryParse(priceStr);
      if (pNum != null) {
        priceStr = '₹${pNum.toStringAsFixed(0)}';
      } else {
        priceStr = '₹$priceStr';
      }
    }
    if (priceStr.isEmpty) {
      priceStr = detectedCategory == 'Banquet Halls'
          ? '₹75,000'
          : detectedCategory == 'Stay'
              ? '₹4,500'
              : detectedCategory == 'Ride'
                  ? '₹650'
                  : '₹350';
    }

    // Status & Color
    final rawStatus = json['status']?.toString() ?? 'Confirmed';
    Color statusColor = AppColors.success;
    String displayStatus = rawStatus;

    if (rawStatus.toLowerCase().contains('confirm') || rawStatus.toLowerCase().contains('booked')) {
      displayStatus = 'Confirmed ✅';
      statusColor = AppColors.success;
    } else if (rawStatus.toLowerCase().contains('schedule') || rawStatus.toLowerCase().contains('pending')) {
      displayStatus = 'Scheduled ⏳';
      statusColor = AppColors.primary;
    } else if (rawStatus.toLowerCase().contains('complete')) {
      displayStatus = 'Completed';
      statusColor = const Color(0xFF64748B);
    } else if (rawStatus.toLowerCase().contains('cancel')) {
      displayStatus = 'Cancelled ❌';
      statusColor = Colors.red;
    }

    return CustomerBookingItem(
      id: id,
      bookingId: bookingId,
      category: detectedCategory,
      type: typeLabel,
      title: title,
      subtitle: subtitle,
      price: priceStr,
      status: displayStatus,
      icon: iconData,
      statusColor: statusColor,
      rawJson: json,
    );
  }
}
