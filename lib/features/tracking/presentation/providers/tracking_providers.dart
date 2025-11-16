import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/location_service.dart';
import '../../data/repositories/location_repository.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

