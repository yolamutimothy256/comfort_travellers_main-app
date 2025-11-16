import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../data/services/location_service.dart';
import '../../data/repositories/location_repository.dart';
import '../providers/tracking_providers.dart';
import '../widgets/bus_map_view.dart';
import '../../../../core/models/location_model.dart';
import '../../../../core/models/vehicle_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class DriverTrackingPage extends ConsumerStatefulWidget {
  final String vehicleId;
  final String? tripId;
  final String? routeId;

  const DriverTrackingPage({
    super.key,
    required this.vehicleId,
    this.tripId,
    this.routeId,
  });

  @override
  ConsumerState<DriverTrackingPage> createState() => _DriverTrackingPageState();
}

class _DriverTrackingPageState extends ConsumerState<DriverTrackingPage> {
  bool _isTracking = false;
  bool _isLoading = false;
  LocationModel? _currentLocation;
  Position? _lastPosition;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final locationService = ref.read(locationServiceProvider);
    final hasPermission = await locationService.hasPermission();
    if (!hasPermission) {
      await locationService.requestPermission();
    }
  }

  Future<void> _startTracking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final locationRepository = ref.read(locationRepositoryProvider);
      final currentUser = ref.read(authStateProvider).valueOrNull;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check permissions
      if (!await locationService.hasPermission()) {
        final permission = await locationService.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          throw Exception('Location permission denied');
        }
      }

      // Update vehicle status to active
      await locationRepository.updateVehicleStatus(
        vehicleId: widget.vehicleId,
        isActive: true,
        tripId: widget.tripId,
        routeId: widget.routeId,
      );

      // Assign driver to vehicle
      await locationRepository.assignVehicleCrew(
        vehicleId: widget.vehicleId,
        driverId: currentUser.uid,
      );

      // Get initial position
      final position = await locationService.getCurrentPosition();
      await locationRepository.updateVehicleLocation(
        vehicleId: widget.vehicleId,
        position: position,
        tripId: widget.tripId,
        routeId: widget.routeId,
      );

      setState(() {
        _lastPosition = position;
        _isTracking = true;
        _isLoading = false;
      });

      // Listen to position updates
      locationService.getPositionStream(
        distanceFilter: 10, // Update every 10 meters
      ).listen((position) async {
        await locationRepository.updateVehicleLocation(
          vehicleId: widget.vehicleId,
          position: position,
          tripId: widget.tripId,
          routeId: widget.routeId,
        );

        setState(() {
          _lastPosition = position;
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start tracking: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _stopTracking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locationRepository = ref.read(locationRepositoryProvider);

      // Update vehicle status to inactive
      await locationRepository.updateVehicleStatus(
        vehicleId: widget.vehicleId,
        isActive: false,
      );

      setState(() {
        _isTracking = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tracking stopped'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop tracking: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationRepository = ref.read(locationRepositoryProvider);
    final locationStream = locationRepository.streamVehicleLocation(widget.vehicleId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Tracking'),
      ),
      body: StreamBuilder<LocationModel?>(
        stream: locationStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            _currentLocation = snapshot.data;
          }

          return Column(
            children: [
              // Map View
              Expanded(
                child: _currentLocation != null
                    ? BusMapView(
                        vehicleLocations: [_currentLocation!],
                        center: LatLng(
                          _currentLocation!.latitude,
                          _currentLocation!.longitude,
                        ),
                        zoom: 15.0,
                        showUserLocation: true,
                        userLocation: _lastPosition != null
                            ? LatLng(
                                _lastPosition!.latitude,
                                _lastPosition!.longitude,
                              )
                            : null,
                      )
                    : const Center(
                        child: Text('Waiting for location...'),
                      ),
              ),
              // Control Panel
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status Info
                    if (_currentLocation != null) ...[
                      _buildInfoRow(
                        'Speed',
                        '${(_currentLocation!.speed ?? 0).toStringAsFixed(1)} km/h',
                        Icons.speed,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Accuracy',
                        '${(_currentLocation!.accuracy ?? 0).toStringAsFixed(0)} m',
                        Icons.gps_fixed,
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Control Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : (_isTracking ? _stopTracking : _startTracking),
                        icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                        label: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _isTracking
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
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
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }
}

