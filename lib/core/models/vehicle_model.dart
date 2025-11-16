import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class VehicleModel extends Equatable {
  final String id;
  final String vehicleNumber;
  final String? routeId;
  final String? currentTripId;
  final bool isActive;
  final String? driverId;
  final String? conductorId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const VehicleModel({
    required this.id,
    required this.vehicleNumber,
    this.routeId,
    this.currentTripId,
    this.isActive = false,
    this.driverId,
    this.conductorId,
    required this.createdAt,
    this.updatedAt,
  });

  factory VehicleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleModel(
      id: doc.id,
      vehicleNumber: data['vehicleNumber'] as String,
      routeId: data['routeId'] as String?,
      currentTripId: data['currentTripId'] as String?,
      isActive: data['isActive'] as bool? ?? false,
      driverId: data['driverId'] as String?,
      conductorId: data['conductorId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vehicleNumber': vehicleNumber,
      'routeId': routeId,
      'currentTripId': currentTripId,
      'isActive': isActive,
      'driverId': driverId,
      'conductorId': conductorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  VehicleModel copyWith({
    String? id,
    String? vehicleNumber,
    String? routeId,
    String? currentTripId,
    bool? isActive,
    String? driverId,
    String? conductorId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      routeId: routeId ?? this.routeId,
      currentTripId: currentTripId ?? this.currentTripId,
      isActive: isActive ?? this.isActive,
      driverId: driverId ?? this.driverId,
      conductorId: conductorId ?? this.conductorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        vehicleNumber,
        routeId,
        currentTripId,
        isActive,
        driverId,
        conductorId,
        createdAt,
        updatedAt,
      ];
}

