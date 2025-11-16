import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RouteModel extends Equatable {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final double basePrice;
  final int estimatedDurationMinutes;
  final List<String> stops;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RouteModel({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.basePrice,
    required this.estimatedDurationMinutes,
    required this.stops,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory RouteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RouteModel(
      id: doc.id,
      name: data['name'] as String,
      origin: data['origin'] as String,
      destination: data['destination'] as String,
      basePrice: (data['basePrice'] as num).toDouble(),
      estimatedDurationMinutes: data['estimatedDurationMinutes'] as int,
      stops: List<String>.from(data['stops'] as List? ?? []),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'origin': origin,
      'destination': destination,
      'basePrice': basePrice,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'stops': stops,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        origin,
        destination,
        basePrice,
        estimatedDurationMinutes,
        stops,
        isActive,
        createdAt,
        updatedAt,
      ];
}

