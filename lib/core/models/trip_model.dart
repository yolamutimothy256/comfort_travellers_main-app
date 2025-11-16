import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TripModel extends Equatable {
  final String id;
  final String routeId;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String vehicleId;
  final String? vehicleNumber;
  final int totalSeats;
  final List<int> availableSeats;
  final String? driverName;
  final String? conductorName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TripModel({
    required this.id,
    required this.routeId,
    required this.departureTime,
    required this.arrivalTime,
    required this.vehicleId,
    this.vehicleNumber,
    required this.totalSeats,
    required this.availableSeats,
    this.driverName,
    this.conductorName,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TripModel(
      id: doc.id,
      routeId: data['routeId'] as String,
      departureTime: (data['departureTime'] as Timestamp).toDate(),
      arrivalTime: (data['arrivalTime'] as Timestamp).toDate(),
      vehicleId: data['vehicleId'] as String,
      vehicleNumber: data['vehicleNumber'] as String?,
      totalSeats: data['totalSeats'] as int,
      availableSeats: List<int>.from(data['availableSeats'] as List? ?? []),
      driverName: data['driverName'] as String?,
      conductorName: data['conductorName'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'routeId': routeId,
      'departureTime': Timestamp.fromDate(departureTime),
      'arrivalTime': Timestamp.fromDate(arrivalTime),
      'vehicleId': vehicleId,
      'vehicleNumber': vehicleNumber,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'driverName': driverName,
      'conductorName': conductorName,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  List<int> get bookedSeats {
    final allSeats = List.generate(totalSeats, (i) => i + 1);
    return allSeats.where((seat) => !availableSeats.contains(seat)).toList();
  }

  @override
  List<Object?> get props => [
        id,
        routeId,
        departureTime,
        arrivalTime,
        vehicleId,
        vehicleNumber,
        totalSeats,
        availableSeats,
        driverName,
        conductorName,
        isActive,
        createdAt,
        updatedAt,
      ];
}

