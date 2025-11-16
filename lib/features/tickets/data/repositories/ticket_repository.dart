import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../../../core/models/ticket_model.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../core/models/route_model.dart';

class TicketRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  TicketRepository({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  // Generate QR payload with ticket ID and signature
  String _generateQrPayload(String ticketId) {
    // Create a simple signature (in production, use proper encryption)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final signature = sha256
        .convert(utf8.encode('$ticketId:$timestamp:comfort_busses'))
        .toString()
        .substring(0, 16);
    return '$ticketId:$signature';
  }

  Future<TicketModel> createTicket({
    required String userId,
    required String tripId,
    required String routeId,
    required String passengerName,
    String? passengerPhone,
    String? passengerEmail,
    required int seatNumber,
    required double amount,
    required String issuedBy,
  }) async {
    try {
      // Verify seat is available
      final tripDoc = await _firestore.collection('trips').doc(tripId).get();
      if (!tripDoc.exists) {
        throw Exception('Trip not found');
      }

      final trip = TripModel.fromFirestore(tripDoc);
      if (!trip.availableSeats.contains(seatNumber)) {
        throw Exception('Seat $seatNumber is not available');
      }

      // Generate ticket ID
      final ticketId = _uuid.v4();
      final qrPayload = _generateQrPayload(ticketId);

      // Create ticket
      final ticket = TicketModel(
        id: ticketId,
        userId: userId,
        tripId: tripId,
        routeId: routeId,
        passengerName: passengerName,
        passengerPhone: passengerPhone,
        passengerEmail: passengerEmail,
        seatNumber: seatNumber,
        amount: amount,
        status: TicketStatus.confirmed,
        qrPayload: qrPayload,
        issuedAt: DateTime.now(),
        issuedBy: issuedBy,
      );

      // Write ticket to Firestore
      await _firestore
          .collection('tickets')
          .doc(ticketId)
          .set(ticket.toFirestore());

      // Update trip available seats
      final updatedAvailableSeats = List<int>.from(trip.availableSeats)
        ..remove(seatNumber);

      await _firestore.collection('trips').doc(tripId).update({
        'availableSeats': updatedAvailableSeats,
      });

      return ticket;
    } catch (e) {
      throw Exception('Failed to create ticket: ${e.toString()}');
    }
  }

  Stream<List<TicketModel>> getUserTickets(String userId) {
    return _firestore
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('issuedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketModel.fromFirestore(doc))
            .toList());
  }

  Future<TicketModel?> getTicketById(String ticketId) async {
    try {
      final doc = await _firestore.collection('tickets').doc(ticketId).get();
      if (doc.exists) {
        return TicketModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get ticket: ${e.toString()}');
    }
  }

  Future<List<TicketModel>> getTicketsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) async {
    try {
      Query query = _firestore
          .collection('tickets')
          .where('issuedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('issuedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.orderBy('issuedAt', descending: true).get();
      return snapshot.docs
          .map((doc) => TicketModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tickets: ${e.toString()}');
    }
  }

  Future<void> markTicketAsUsed({
    required String ticketId,
    required String usedBy,
  }) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({
        'status': TicketStatus.used.name,
        'usedAt': FieldValue.serverTimestamp(),
        'usedBy': usedBy,
      });
    } catch (e) {
      throw Exception('Failed to mark ticket as used: ${e.toString()}');
    }
  }

  Future<void> cancelTicket(String ticketId) async {
    try {
      final ticketDoc = await _firestore.collection('tickets').doc(ticketId).get();
      if (!ticketDoc.exists) {
        throw Exception('Ticket not found');
      }

      final ticket = TicketModel.fromFirestore(ticketDoc);

      // Update ticket status
      await _firestore.collection('tickets').doc(ticketId).update({
        'status': TicketStatus.cancelled.name,
      });

      // Release seat back to trip
      final tripDoc = await _firestore.collection('trips').doc(ticket.tripId).get();
      if (tripDoc.exists) {
        final trip = TripModel.fromFirestore(tripDoc);
        final updatedAvailableSeats = List<int>.from(trip.availableSeats)
          ..add(ticket.seatNumber)
          ..sort();

        await _firestore.collection('trips').doc(ticket.tripId).update({
          'availableSeats': updatedAvailableSeats,
        });
      }
    } catch (e) {
      throw Exception('Failed to cancel ticket: ${e.toString()}');
    }
  }

  // Get routes
  Future<List<RouteModel>> getRoutes({bool activeOnly = true}) async {
    try {
      Query query = _firestore.collection('routes');
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => RouteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get routes: ${e.toString()}');
    }
  }

  // Get trips for a route
  Future<List<TripModel>> getTripsForRoute({
    required String routeId,
    DateTime? date,
    bool activeOnly = true,
  }) async {
    try {
      Query query = _firestore
          .collection('trips')
          .where('routeId', isEqualTo: routeId);

      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
        query = query
            .where('departureTime',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('departureTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
      }

      final snapshot = await query.orderBy('departureTime').get();
      return snapshot.docs
          .map((doc) => TripModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get trips: ${e.toString()}');
    }
  }
}

