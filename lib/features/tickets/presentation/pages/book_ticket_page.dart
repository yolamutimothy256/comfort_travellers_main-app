import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/route_model.dart';
import '../../../../core/models/trip_model.dart';
import '../providers/ticket_providers.dart';
import '../../../auth/presentation/widgets/auth_button.dart';

class BookTicketPage extends ConsumerStatefulWidget {
  const BookTicketPage({super.key});

  @override
  ConsumerState<BookTicketPage> createState() => _BookTicketPageState();
}

class _BookTicketPageState extends ConsumerState<BookTicketPage> {
  RouteModel? _selectedRoute;
  TripModel? _selectedTrip;
  int? _selectedSeat;
  bool _isLoading = false;
  bool _loadingRoutes = false;
  bool _loadingTrips = false;
  List<RouteModel> _routes = [];
  List<TripModel> _trips = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() => _loadingRoutes = true);
    try {
      final repository = ref.read(ticketRepositoryProvider);
      final routes = await repository.getRoutes();
      setState(() {
        _routes = routes;
        _loadingRoutes = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load routes: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _loadingRoutes = false);
      }
    }
  }

  Future<void> _loadTrips() async {
    if (_selectedRoute == null) return;

    setState(() => _loadingTrips = true);
    try {
      final repository = ref.read(ticketRepositoryProvider);
      final trips = await repository.getTripsForRoute(
        routeId: _selectedRoute!.id,
        date: _selectedDate,
      );
      setState(() {
        _trips = trips;
        _selectedTrip = null;
        _selectedSeat = null;
        _loadingTrips = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load trips: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _loadingTrips = false);
      }
    }
  }

  // Ticket creation now happens after payment. This method is no longer used.

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTrip = null;
        _selectedSeat = null;
      });
      _loadTrips();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Ticket'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Route Selection
              const Text(
                'Select Route',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _loadingRoutes
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<RouteModel>(
                      value: _selectedRoute,
                      decoration: const InputDecoration(
                        labelText: 'Route',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.route),
                      ),
                      items: _routes.map((route) {
                        return DropdownMenuItem<RouteModel>(
                          value: route,
                          child: Text(
                            '${route.origin} → ${route.destination}',
                          ),
                        );
                      }).toList(),
                      onChanged: (route) {
                        setState(() {
                          _selectedRoute = route;
                          _selectedTrip = null;
                          _selectedSeat = null;
                        });
                        if (route != null) {
                          _loadTrips();
                        }
                      },
                    ),
              const SizedBox(height: 24),

              // Date Selection
              const Text(
                'Select Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),

              // Trip Selection
              if (_selectedRoute != null) ...[
                const Text(
                  'Select Trip',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _loadingTrips
                    ? const Center(child: CircularProgressIndicator())
                    : _trips.isEmpty
                        ? const Text('No trips available for this date')
                        : DropdownButtonFormField<TripModel>(
                            value: _selectedTrip,
                            decoration: const InputDecoration(
                              labelText: 'Trip',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.directions_bus),
                            ),
                            items: _trips.map((trip) {
                              return DropdownMenuItem<TripModel>(
                                value: trip,
                                child: Text(
                                  '${DateFormat('hh:mm a').format(trip.departureTime)} - ${DateFormat('hh:mm a').format(trip.arrivalTime)}',
                                ),
                              );
                            }).toList(),
                            onChanged: (trip) {
                              setState(() {
                                _selectedTrip = trip;
                                _selectedSeat = null;
                              });
                            },
                          ),
                const SizedBox(height: 24),
              ],

              // Seat Selection
              if (_selectedTrip != null) ...[
                const Text(
                  'Select Seat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildSeatSelector(),
                const SizedBox(height: 24),
              ],

              // Price Display
              if (_selectedRoute != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ticket Price:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'UGX ${_selectedRoute!.basePrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Continue to Payment
              AuthButton(
                text: 'Continue to Payment',
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_selectedRoute == null ||
                            _selectedTrip == null ||
                            _selectedSeat == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select route, trip, and seat'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        context.push(
                          '/pay?routeId=${_selectedRoute!.id}&tripId=${_selectedTrip!.id}&seat=${_selectedSeat!}',
                        );
                      },
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeatSelector() {
    if (_selectedTrip == null) return const SizedBox.shrink();

    final totalSeats = _selectedTrip!.totalSeats;
    final availableSeats = _selectedTrip!.availableSeats;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: totalSeats,
      itemBuilder: (context, index) {
        final seatNumber = index + 1;
        final isAvailable = availableSeats.contains(seatNumber);
        final isSelected = _selectedSeat == seatNumber;

        Color backgroundColor;
        if (isSelected) {
          backgroundColor = Theme.of(context).colorScheme.primary;
        } else if (isAvailable) {
          backgroundColor = Colors.green.shade100;
        } else {
          backgroundColor = Colors.grey.shade300;
        }

        return GestureDetector(
          onTap: isAvailable
              ? () {
                  setState(() {
                    _selectedSeat = seatNumber;
                  });
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAvailable ? Icons.event_seat : Icons.event_seat_outlined,
                    color: isAvailable ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$seatNumber',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isAvailable ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

