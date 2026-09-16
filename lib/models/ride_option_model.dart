import 'package:flutter/material.dart';

class RideOptionModel {
  final String id;
  final String name;
  final String description;
  final double estimatedFare;
  final int etaMinutes;
  final int capacity;
  final IconData icon;
  final bool isPopular;

  RideOptionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.estimatedFare,
    required this.etaMinutes,
    required this.capacity,
    required this.icon,
    this.isPopular = false,
  });

  static List<RideOptionModel> get sampleOptions {
    return [
      RideOptionModel(
        id: 'zaatra_go',
        name: 'Zaatra Go',
        description: 'Affordable, everyday rides',
        estimatedFare: 14.50,
        etaMinutes: 3,
        capacity: 4,
        icon: Icons.directions_car_rounded,
        isPopular: true,
      ),
      RideOptionModel(
        id: 'zaatra_comfort',
        name: 'Zaatra Comfort',
        description: 'Newer cars with extra legroom',
        estimatedFare: 22.00,
        etaMinutes: 5,
        capacity: 4,
        icon: Icons.local_taxi_rounded,
      ),
      RideOptionModel(
        id: 'zaatra_executive',
        name: 'Zaatra Executive',
        description: 'Premium luxury rides & top drivers',
        estimatedFare: 38.00,
        etaMinutes: 7,
        capacity: 6,
        icon: Icons.airport_shuttle_rounded,
      ),
    ];
  }
}
