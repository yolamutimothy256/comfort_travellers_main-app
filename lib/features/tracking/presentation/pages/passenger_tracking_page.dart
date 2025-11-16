import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../../data/repositories/location_repository.dart';
import '../providers/tracking_providers.dart';
import '../widgets/bus_map_view.dart';
import '../../../../core/models/location_model.dart';
import '../../../../core/models/vehicle_model.dart';
import '../../../../core/models/trip_model.dart';

class PassengerTrackingPage extends ConsumerStatefulWidget {
  final String tripId;
  final String? ticketId;

  const PassengerTrackingPage({
    super.key,
    required this.tripId,
    this.ticketId,
  });

  @override
  ConsumerState<PassengerTrackingPage> createState() =>
      _PassengerTrackingPageState();
}

class _PassengerTrackingPageState
    extends ConsumerState<PassengerTrackingPage> {
  TripModel? _trip;
  VehicleModel? _vehicle;

  @override
  void initState() {
    super.initState();
    _loadTripInfo();
  }

  Future<void> _loadTripInfo() async {
    try {
      final locationRepository = ref.read(locationRepositoryProvider);
      
      // Get trip info from Firestore
      final firestore = FirebaseFirestore.instance;
      final tripDoc = await firestore.collection('trips').doc(widget.tripId).get();

      if (tripDoc.exists) {
        setState(() {
          _trip = TripModel.fromFirestore(tripDoc);
        });

        // Load vehicle info if available
        if (_trip?.vehicleId != null) {
          final vehicle = await locationRepository.getVehicle(_trip!.vehicleId);
          setState(() {
            _vehicle = vehicle;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load trip info: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationRepository = ref.read(locationRepositoryProvider);
    final locationStream =
        locationRepository.streamTripVehicleLocation(widget.tripId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Your Bus'),
      ),
      body: StreamBuilder<LocationModel?>(
        stream: locationStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bus location not available',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The bus may not have started tracking yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final location = snapshot.data!;

          return Column(
            children: [
              // Map View
              Expanded(
                child: BusMapView(
                  vehicleLocations: [location],
                  vehicles: _vehicle != null ? [_vehicle!] : null,
                  center: LatLng(location.latitude, location.longitude),
                  zoom: 14.0,
                ),
              ),
              // Info Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_trip != null) ...[
                      Text(
                        'Trip Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Departure',
                        DateFormat('MMM dd, yyyy • hh:mm a')
                            .format(_trip!.departureTime),
                        Icons.schedule,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Arrival',
                        DateFormat('MMM dd, yyyy • hh:mm a')
                            .format(_trip!.arrivalTime),
                        Icons.flag,
                      ),
                      const Divider(),
                    ],
                    Text(
                      'Bus Location',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Speed',
                      '${(location.speed ?? 0).toStringAsFixed(1)} km/h',
                      Icons.speed,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Last Updated',
                      _formatTimeAgo(location.timestamp),
                      Icons.access_time,
                    ),
                    if (_vehicle != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Vehicle',
                        _vehicle!.vehicleNumber,
                        Icons.directions_bus,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
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

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('MMM dd, hh:mm a').format(timestamp);
    }
  }
}

