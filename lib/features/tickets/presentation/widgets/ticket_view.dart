import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/ticket_model.dart';
import '../../../../core/models/route_model.dart';
import '../../../../core/models/trip_model.dart';

class TicketView extends StatelessWidget {
  final TicketModel ticket;
  final RouteModel? route;
  final TripModel? trip;

  const TicketView({
    super.key,
    required this.ticket,
    this.route,
    this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
        children: [
          // Main ticket body
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Company branding (Pink/Red)
              Container(
                width: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFE91E63), // Pink/Red color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Company logo/name
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // AG logo circle
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'AG',
                                style: TextStyle(
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Company name
                          const Text(
                            'AG COMFORT',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                          const Text(
                            'V.VIP CLASS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Contact information
                    _buildContactInfo(context),
                    const SizedBox(height: 12),
                    // V.VIPS TICKET bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC2185B), // Darker pink
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'V. VIPS TICKET',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Serial number
                    Text(
                      'S/No. ${ticket.id.substring(0, 4)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Bus reg number (if available)
                    if (trip?.vehicleNumber != null)
                      Text(
                        'Bus reg. No. ${trip!.vehicleNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right side - Ticket details (Light Pink/White)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F5), // Light pink background
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Date', DateFormat('dd-MM-yy').format(ticket.issuedAt)),
                      const SizedBox(height: 12),
                      _buildDetailRow('Seat No.', '${ticket.seatNumber}'),
                      const SizedBox(height: 12),
                      _buildDetailRow('Name', ticket.passengerName),
                      const SizedBox(height: 12),
                      if (route != null) ...[
                        _buildDetailRow('To', route!.destination),
                        const SizedBox(height: 12),
                        _buildDetailRow('From', route!.origin),
                        const SizedBox(height: 12),
                      ],
                      if (trip != null)
                        _buildDetailRow(
                          'Date of Travel',
                          DateFormat('dd-MM-yy').format(trip!.departureTime),
                        ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Amount paid',
                        '${ticket.amount.toStringAsFixed(0)}.000',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Please Note section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFC2185B), // Darker red
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please Note:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                _buildNoteText(
                  'Ticket once issued is not returnable & Luggage carried at owners\' risk',
                ),
                const SizedBox(height: 4),
                _buildNoteText(
                  'Smoking and taking alcoholic drinks are simply prohibited in the bus',
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContactLine('K\'LA:', '0392 987 320 / 0774 544 319'),
        const SizedBox(height: 4),
        _buildContactLine('LIRA:', '0775 330 070'),
        const SizedBox(height: 4),
        _buildContactLine('APAC:', '0779 878 632'),
        const SizedBox(height: 4),
        _buildContactLine('ADUKU:', '0784 234 007'),
        const SizedBox(height: 4),
        _buildContactLine('Helpline:', '0788 225 336'),
      ],
    );
  }

  Widget _buildContactLine(String label, String number) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          height: 1.3,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: number),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteText(String text) {
    return Text(
      '• $text',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        height: 1.4,
      ),
    );
  }
}

