import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  final String vehicleId;
  final double latitude;
  final double longitude;
  final double? heading; // Direction in degrees (0-360)
  final double? speed; // km/h
  final double? accuracy; // meters
  final DateTime timestamp;
  final String? tripId;
  final String? routeId;

  const LocationModel({
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    this.accuracy,
    required this.timestamp,
    this.tripId,
    this.routeId,
  });

  factory LocationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LocationModel(
      vehicleId: data['vehicleId'] as String,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      heading: data['heading'] != null ? (data['heading'] as num).toDouble() : null,
      speed: data['speed'] != null ? (data['speed'] as num).toDouble() : null,
      accuracy: data['accuracy'] != null ? (data['accuracy'] as num).toDouble() : null,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      tripId: data['tripId'] as String?,
      routeId: data['routeId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vehicleId': vehicleId,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
      'accuracy': accuracy,
      'timestamp': Timestamp.fromDate(timestamp),
      'tripId': tripId,
      'routeId': routeId,
    };
  }

  LocationModel copyWith({
    String? vehicleId,
    double? latitude,
    double? longitude,
    double? heading,
    double? speed,
    double? accuracy,
    DateTime? timestamp,
    String? tripId,
    String? routeId,
  }) {
    return LocationModel(
      vehicleId: vehicleId ?? this.vehicleId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      tripId: tripId ?? this.tripId,
      routeId: routeId ?? this.routeId,
    );
  }

  @override
  List<Object?> get props => [
        vehicleId,
        latitude,
        longitude,
        heading,
        speed,
        accuracy,
        timestamp,
        tripId,
        routeId,
      ];
}

