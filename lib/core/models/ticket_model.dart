import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum TicketStatus {
  pending,
  confirmed,
  used,
  cancelled,
}

class TicketModel extends Equatable {
  final String id;
  final String userId;
  final String tripId;
  final String routeId;
  final String passengerName;
  final String? passengerPhone;
  final String? passengerEmail;
  final int seatNumber;
  final double amount;
  final TicketStatus status;
  final String qrPayload;
  final DateTime issuedAt;
  final String issuedBy; // Agent/Admin UID
  final DateTime? usedAt;
  final String? usedBy; // Conductor UID
  final Map<String, dynamic>? metadata;

  const TicketModel({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.routeId,
    required this.passengerName,
    this.passengerPhone,
    this.passengerEmail,
    required this.seatNumber,
    required this.amount,
    this.status = TicketStatus.confirmed,
    required this.qrPayload,
    required this.issuedAt,
    required this.issuedBy,
    this.usedAt,
    this.usedBy,
    this.metadata,
  });

  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketModel(
      id: doc.id,
      userId: data['userId'] as String,
      tripId: data['tripId'] as String,
      routeId: data['routeId'] as String,
      passengerName: data['passengerName'] as String,
      passengerPhone: data['passengerPhone'] as String?,
      passengerEmail: data['passengerEmail'] as String?,
      seatNumber: data['seatNumber'] as int,
      amount: (data['amount'] as num).toDouble(),
      status: TicketStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TicketStatus.confirmed,
      ),
      qrPayload: data['qrPayload'] as String,
      issuedAt: (data['issuedAt'] as Timestamp).toDate(),
      issuedBy: data['issuedBy'] as String,
      usedAt: data['usedAt'] != null
          ? (data['usedAt'] as Timestamp).toDate()
          : null,
      usedBy: data['usedBy'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'tripId': tripId,
      'routeId': routeId,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'passengerEmail': passengerEmail,
      'seatNumber': seatNumber,
      'amount': amount,
      'status': status.name,
      'qrPayload': qrPayload,
      'issuedAt': Timestamp.fromDate(issuedAt),
      'issuedBy': issuedBy,
      'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
      'usedBy': usedBy,
      'metadata': metadata,
    };
  }

  TicketModel copyWith({
    String? id,
    String? userId,
    String? tripId,
    String? routeId,
    String? passengerName,
    String? passengerPhone,
    String? passengerEmail,
    int? seatNumber,
    double? amount,
    TicketStatus? status,
    String? qrPayload,
    DateTime? issuedAt,
    String? issuedBy,
    DateTime? usedAt,
    String? usedBy,
    Map<String, dynamic>? metadata,
  }) {
    return TicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      routeId: routeId ?? this.routeId,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerEmail: passengerEmail ?? this.passengerEmail,
      seatNumber: seatNumber ?? this.seatNumber,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      qrPayload: qrPayload ?? this.qrPayload,
      issuedAt: issuedAt ?? this.issuedAt,
      issuedBy: issuedBy ?? this.issuedBy,
      usedAt: usedAt ?? this.usedAt,
      usedBy: usedBy ?? this.usedBy,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        tripId,
        routeId,
        passengerName,
        passengerPhone,
        passengerEmail,
        seatNumber,
        amount,
        status,
        qrPayload,
        issuedAt,
        issuedBy,
        usedAt,
        usedBy,
        metadata,
      ];
}

