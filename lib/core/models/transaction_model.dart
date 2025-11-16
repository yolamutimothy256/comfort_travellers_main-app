import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum TransactionStatus {
  pending,
  success,
  failed,
}

class TransactionModel extends Equatable {
  final String id;
  final String? ticketId;
  final String userId;
  final double amount;
  final String method; // e.g., 'mtn_momo'
  final TransactionStatus status;
  final String externalId; // client-side reference
  final String? momoReferenceId; // provider reference (if any)
  final String? payerMsisdn;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? raw;

  const TransactionModel({
    required this.id,
    this.ticketId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    required this.externalId,
    this.momoReferenceId,
    this.payerMsisdn,
    required this.createdAt,
    this.updatedAt,
    this.raw,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      ticketId: data['ticketId'] as String?,
      userId: data['userId'] as String,
      amount: (data['amount'] as num).toDouble(),
      method: data['method'] as String,
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TransactionStatus.pending,
      ),
      externalId: data['externalId'] as String,
      momoReferenceId: data['momoReferenceId'] as String?,
      payerMsisdn: data['payerMsisdn'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
          data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      raw: data['raw'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ticketId': ticketId,
      'userId': userId,
      'amount': amount,
      'method': method,
      'status': status.name,
      'externalId': externalId,
      'momoReferenceId': momoReferenceId,
      'payerMsisdn': payerMsisdn,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'raw': raw,
    };
  }

  @override
  List<Object?> get props => [
        id,
        ticketId,
        userId,
        amount,
        method,
        status,
        externalId,
        momoReferenceId,
        payerMsisdn,
        createdAt,
        updatedAt,
        raw,
      ];
}


