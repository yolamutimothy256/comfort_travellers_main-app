import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/models/location_model.dart';
import '../../../../core/models/vehicle_model.dart';

class BusMapView extends StatelessWidget {
  final List<LocationModel> vehicleLocations;
  final List<VehicleModel>? vehicles;
  final LatLng? center;
  final double? zoom;
  final Function(LocationModel)? onVehicleTap;
  final bool showUserLocation;
  final LatLng? userLocation;

  const BusMapView({
    super.key,
    required this.vehicleLocations,
    this.vehicles,
    this.center,
    this.zoom,
    this.onVehicleTap,
    this.showUserLocation = false,
    this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    final mapController = MapController();

    // Find center if not provided
    LatLng mapCenter = center ??
        (vehicleLocations.isNotEmpty
            ? LatLng(
                vehicleLocations.first.latitude,
                vehicleLocations.first.longitude,
              )
            : const LatLng(6.5244, 3.3792)); // Default to Lagos, Nigeria

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: mapCenter,
        initialZoom: zoom ?? 13.0,
        minZoom: 5.0,
        maxZoom: 18.0,
        onTap: (tapPosition, point) {
          // Handle map tap if needed
        },
      ),
      children: [
        // OpenStreetMap tile layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.comfortbusses.ticketing',
          maxZoom: 19,
        ),
        // Vehicle markers
        MarkerLayer(
          markers: _buildVehicleMarkers(context),
        ),
        // User location marker (if enabled)
        if (showUserLocation && userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: userLocation!,
                width: 30,
                height: 30,
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ],
          ),
      ],
    );
  }

  List<Marker> _buildVehicleMarkers(BuildContext context) {
    return vehicleLocations.map((location) {
      // Find corresponding vehicle info
      final vehicle = vehicles?.firstWhere(
        (v) => v.id == location.vehicleId,
        orElse: () => VehicleModel(
          id: location.vehicleId,
          vehicleNumber: location.vehicleId,
          createdAt: DateTime.now(),
        ),
      );

      return Marker(
        point: LatLng(location.latitude, location.longitude),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => onVehicleTap?.call(location),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Bus icon with rotation based on heading
              Transform.rotate(
                angle: (location.heading ?? 0) * (3.14159 / 180), // Convert to radians
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              // Vehicle number badge
              if (vehicle != null)
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vehicle.vehicleNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

