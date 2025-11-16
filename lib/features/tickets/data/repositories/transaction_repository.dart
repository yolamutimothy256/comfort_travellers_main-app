import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  TransactionRepository({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  Future<TransactionModel> createPendingTransaction({
    required String userId,
    required double amount,
    required String method, // e.g., 'mtn_momo'
    required String externalId,
    String? payerMsisdn,
  }) async {
    final id = _uuid.v4();
    final transaction = TransactionModel(
      id: id,
      ticketId: null,
      userId: userId,
      amount: amount,
      method: method,
      status: TransactionStatus.pending,
      externalId: externalId,
      momoReferenceId: null,
      payerMsisdn: payerMsisdn,
      createdAt: DateTime.now(),
      updatedAt: null,
      raw: null,
    );

    await _firestore.collection('transactions').doc(id).set(transaction.toFirestore());
    return transaction;
  }

  Future<void> markTransactionSuccess({
    required String transactionId,
    required String ticketId,
    String? momoReferenceId,
    Map<String, dynamic>? raw,
  }) async {
    await _firestore.collection('transactions').doc(transactionId).update({
      'status': TransactionStatus.success.name,
      'ticketId': ticketId,
      'momoReferenceId': momoReferenceId,
      'raw': raw,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markTransactionFailed({
    required String transactionId,
    Map<String, dynamic>? raw,
  }) async {
    await _firestore.collection('transactions').doc(transactionId).update({
      'status': TransactionStatus.failed.name,
      'raw': raw,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}


