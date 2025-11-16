import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/models/location_model.dart';
import '../../../../core/models/vehicle_model.dart';

class LocationRepository {
  final FirebaseFirestore _firestore;

  LocationRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Update vehicle location in Firestore
  Future<void> updateVehicleLocation({
    required String vehicleId,
    required Position position,
    String? tripId,
    String? routeId,
  }) async {
    try {
      final location = LocationModel(
        vehicleId: vehicleId,
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
        speed: position.speed * 3.6, // Convert m/s to km/h
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
        tripId: tripId,
        routeId: routeId,
      );

      // Update or create location document
      await _firestore
          .collection('vehicleLocations')
          .doc(vehicleId)
          .set(location.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update vehicle location: ${e.toString()}');
    }
  }

  // Get current location of a vehicle
  Future<LocationModel?> getVehicleLocation(String vehicleId) async {
    try {
      final doc =
          await _firestore.collection('vehicleLocations').doc(vehicleId).get();
      if (doc.exists) {
        return LocationModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get vehicle location: ${e.toString()}');
    }
  }

  // Stream of vehicle location updates
  Stream<LocationModel?> streamVehicleLocation(String vehicleId) {
    return _firestore
        .collection('vehicleLocations')
        .doc(vehicleId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return LocationModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Get locations of all active vehicles
  Future<List<LocationModel>> getActiveVehicleLocations() async {
    try {
      final snapshot = await _firestore
          .collection('vehicleLocations')
          .where('timestamp',
              isGreaterThan: Timestamp.fromDate(
                  DateTime.now().subtract(const Duration(minutes: 10))))
          .get();

      return snapshot.docs
          .map((doc) => LocationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception(
          'Failed to get active vehicle locations: ${e.toString()}');
    }
  }

  // Stream of all active vehicle locations
  Stream<List<LocationModel>> streamActiveVehicleLocations() {
    return _firestore
        .collection('vehicleLocations')
        .where('timestamp',
            isGreaterThan: Timestamp.fromDate(
                DateTime.now().subtract(const Duration(minutes: 10))))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LocationModel.fromFirestore(doc))
            .toList());
  }

  // Get location for a specific trip
  Future<LocationModel?> getTripVehicleLocation(String tripId) async {
    try {
      final snapshot = await _firestore
          .collection('vehicleLocations')
          .where('tripId', isEqualTo: tripId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return LocationModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get trip vehicle location: ${e.toString()}');
    }
  }

  // Stream location for a specific trip
  Stream<LocationModel?> streamTripVehicleLocation(String tripId) {
    return _firestore
        .collection('vehicleLocations')
        .where('tripId', isEqualTo: tripId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return LocationModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    });
  }

  // Get vehicles
  Future<List<VehicleModel>> getVehicles({bool activeOnly = false}) async {
    try {
      Query query = _firestore.collection('vehicles');
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => VehicleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get vehicles: ${e.toString()}');
    }
  }

  // Get vehicle by ID
  Future<VehicleModel?> getVehicle(String vehicleId) async {
    try {
      final doc = await _firestore.collection('vehicles').doc(vehicleId).get();
      if (doc.exists) {
        return VehicleModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get vehicle: ${e.toString()}');
    }
  }

  // Update vehicle status
  Future<void> updateVehicleStatus({
    required String vehicleId,
    required bool isActive,
    String? tripId,
    String? routeId,
  }) async {
    try {
      await _firestore.collection('vehicles').doc(vehicleId).update({
        'isActive': isActive,
        'currentTripId': tripId,
        'routeId': routeId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update vehicle status: ${e.toString()}');
    }
  }

  // Assign driver/conductor to vehicle
  Future<void> assignVehicleCrew({
    required String vehicleId,
    String? driverId,
    String? conductorId,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (driverId != null) updates['driverId'] = driverId;
      if (conductorId != null) updates['conductorId'] = conductorId;

      await _firestore.collection('vehicles').doc(vehicleId).update(updates);
    } catch (e) {
      throw Exception('Failed to assign vehicle crew: ${e.toString()}');
    }
  }
}

