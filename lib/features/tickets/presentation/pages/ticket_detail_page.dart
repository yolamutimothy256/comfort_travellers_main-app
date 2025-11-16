import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

import '../providers/ticket_providers.dart';
import '../widgets/ticket_view.dart';
import '../../../../core/models/ticket_model.dart';
import '../../../../core/models/route_model.dart';
import '../../../../core/models/trip_model.dart';

class TicketDetailPage extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketDetailPage({
    super.key,
    required this.ticketId,
  });

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
  TicketModel? _ticket;
  RouteModel? _route;
  TripModel? _trip;
  bool _isLoading = true;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    try {
      final repository = ref.read(ticketRepositoryProvider);
      final ticket = await repository.getTicketById(widget.ticketId);
      
      if (ticket == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ticket not found'),
              backgroundColor: Colors.red,
            ),
          );
          context.pop();
        }
        return;
      }

      setState(() {
        _ticket = ticket;
      });

      // Load route and trip info
      final firestore = FirebaseFirestore.instance;
      
      try {
        final routeDoc = await firestore.collection('routes').doc(ticket.routeId).get();
        if (routeDoc.exists) {
          setState(() {
            _route = RouteModel.fromFirestore(routeDoc);
          });
        } else {
          print('Route not found: ${ticket.routeId}');
        }
      } catch (e) {
        print('Error loading route: $e');
      }

      try {
        final tripDoc = await firestore.collection('trips').doc(ticket.tripId).get();
        if (tripDoc.exists) {
          setState(() {
            _trip = TripModel.fromFirestore(tripDoc);
          });
        } else {
          print('Trip not found: ${ticket.tripId}');
        }
      } catch (e) {
        print('Error loading trip: $e');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load ticket: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelTicket() async {
    if (_ticket == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ticket'),
        content: const Text('Are you sure you want to cancel this ticket? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCancelling = true);

    try {
      final repository = ref.read(ticketRepositoryProvider);
      await repository.cancelTicket(_ticket!.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadTicket(); // Reload to show updated status
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel ticket: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  void _trackBus() {
    if (_ticket == null) return;
    context.push('/track/${_ticket!.tripId}?ticketId=${_ticket!.id}');
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.confirmed:
        return Colors.green;
      case TicketStatus.pending:
        return Colors.orange;
      case TicketStatus.used:
        return Colors.blue;
      case TicketStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ticket Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_ticket == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ticket Details'),
        ),
        body: const Center(child: Text('Ticket not found')),
      );
    }

    final ticket = _ticket!;
    final canTrack = ticket.status == TicketStatus.confirmed && _trip != null;
    final canCancel = ticket.status == TicketStatus.confirmed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon'),
                ),
              );
            },
            tooltip: 'Share Ticket',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ticket View (Physical Ticket Design)
            if (_route != null && _trip != null)
              TicketView(
                ticket: ticket,
                route: _route!,
                trip: _trip!,
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Loading route and trip information...'),
              ),
            const SizedBox(height: 24),
            
            // Status Card
            Card(
              color: _getStatusColor(ticket.status).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      ticket.status == TicketStatus.confirmed
                          ? Icons.check_circle
                          : ticket.status == TicketStatus.used
                              ? Icons.done_all
                              : ticket.status == TicketStatus.cancelled
                                  ? Icons.cancel
                                  : Icons.pending,
                      color: _getStatusColor(ticket.status),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${ticket.status.name.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(ticket.status),
                            ),
                          ),
                          if (ticket.usedAt != null)
                            Text(
                              'Used on: ${DateFormat('MMM dd, yyyy • hh:mm a').format(ticket.usedAt!)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Route Information
            if (_route != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.route, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Route',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Origin', _route!.origin, Icons.location_on),
                      const SizedBox(height: 8),
                      _buildInfoRow('Destination', _route!.destination, Icons.location_on),
                      const SizedBox(height: 8),
                      _buildInfoRow('Price', 'UGX ${_route!.basePrice.toStringAsFixed(0)}', Icons.attach_money),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Trip Information
            if (_trip != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.directions_bus, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Trip Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Departure',
                        DateFormat('MMM dd, yyyy • hh:mm a').format(_trip!.departureTime),
                        Icons.schedule,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Arrival',
                        DateFormat('MMM dd, yyyy • hh:mm a').format(_trip!.arrivalTime),
                        Icons.flag,
                      ),
                      if (_trip!.vehicleNumber != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow('Vehicle', _trip!.vehicleNumber!, Icons.directions_bus),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Passenger Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Passenger Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Name', ticket.passengerName, Icons.person_outline),
                    if (ticket.passengerPhone != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow('Phone', ticket.passengerPhone!, Icons.phone),
                    ],
                    if (ticket.passengerEmail != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow('Email', ticket.passengerEmail!, Icons.email),
                    ],
                    const SizedBox(height: 8),
                    _buildInfoRow('Seat Number', '${ticket.seatNumber}', Icons.event_seat),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ticket Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.confirmation_number, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Ticket Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Ticket ID', ticket.id, Icons.tag),
                    const SizedBox(height: 8),
                    // QR Code
                    if (ticket.qrPayload.isNotEmpty)
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            QrImageView(
                              data: ticket.qrPayload,
                              version: QrVersions.auto,
                              size: 160,
                              backgroundColor: Colors.white,
                              errorCorrectionLevel: QrErrorCorrectLevel.M,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'QR Payload: ${ticket.qrPayload}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: ticket.qrPayload));
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('QR payload copied')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('Copy QR Payload'),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Issued On',
                      DateFormat('MMM dd, yyyy • hh:mm a').format(ticket.issuedAt),
                      Icons.calendar_today,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Amount', 'UGX ${ticket.amount.toStringAsFixed(0)}', Icons.payments),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (canTrack) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _trackBus,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Track Bus'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (canCancel) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isCancelling ? null : _cancelTicket,
                  icon: _isCancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel),
                  label: Text(_isCancelling ? 'Cancelling...' : 'Cancel Ticket'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
