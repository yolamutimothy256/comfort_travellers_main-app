import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/route_model.dart';
import '../../../../core/models/trip_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/ticket_providers.dart';
import '../../data/repositories/transaction_repository.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final String routeId;
  final String tripId;
  final int seatNumber;

  const PaymentPage({
    super.key,
    required this.routeId,
    required this.tripId,
    required this.seatNumber,
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  RouteModel? _route;
  TripModel? _trip;
  bool _loading = true;
  bool _processing = false;
  final _msisdnController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _msisdnController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final routeDoc = await firestore.collection('routes').doc(widget.routeId).get();
      final tripDoc = await firestore.collection('trips').doc(widget.tripId).get();
      if (routeDoc.exists) {
        _route = RouteModel.fromFirestore(routeDoc);
      }
      if (tripDoc.exists) {
        _trip = TripModel.fromFirestore(tripDoc);
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load payment data: ${e.toString()}')),
        );
        context.pop();
      }
    }
  }

  Future<void> _mockPayAndCreateTicket() async {
    if (_route == null || _trip == null) return;
    if (_msisdnController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter payer phone number')),
      );
      return;
    }

    setState(() {
      _processing = true;
    });

    try {
      final currentUser = ref.read(authStateProvider).valueOrNull;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Create pending transaction
      final transactions = TransactionRepository();
      final externalId = 'momo_${DateTime.now().millisecondsSinceEpoch}';
      final pendingTx = await transactions.createPendingTransaction(
        userId: currentUser.uid,
        amount: _route!.basePrice,
        method: 'mtn_momo',
        externalId: externalId,
        payerMsisdn: _msisdnController.text.trim(),
      );

      // Simulate MTN MoMo approval delay
      await Future.delayed(const Duration(seconds: 2));

      // Create ticket upon success
      final ticketRepo = ref.read(ticketRepositoryProvider);

      // Get user model for passenger details
      final authRepository = ref.read(authRepositoryProvider);
      final userModel = await authRepository.getCurrentUserModel();
      if (userModel == null) {
        throw Exception('User model not found');
      }

      final ticket = await ticketRepo.createTicket(
        userId: userModel.uid,
        tripId: _trip!.id,
        routeId: _route!.id,
        passengerName: userModel.displayName ?? userModel.email.split('@')[0],
        passengerPhone: null,
        passengerEmail: userModel.email,
        seatNumber: widget.seatNumber,
        amount: _route!.basePrice,
        issuedBy: currentUser.uid,
      );

      // Mark transaction success and link ticket
      await transactions.markTransactionSuccess(
        transactionId: pendingTx.id,
        ticketId: ticket.id,
        momoReferenceId: 'MOCK-${pendingTx.id.substring(0, 8).toUpperCase()}',
        raw: {'mock': true},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful. Ticket created!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/tickets/${ticket.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_route == null || _trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: const Center(child: Text('Invalid route or trip')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Review & Pay',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Route'),
                          Text('${_route!.origin} → ${_route!.destination}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Seat'),
                          Text('#${widget.seatNumber}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount'),
                          Text('UGX ${_route!.basePrice.toStringAsFixed(0)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payer Phone (MTN MoMo)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _msisdnController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 0772123456',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _processing ? null : _mockPayAndCreateTicket,
                  icon: _processing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.lock),
                  label: Text(_processing ? 'Processing...' : 'Pay UGX ${_route!.basePrice.toStringAsFixed(0)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


