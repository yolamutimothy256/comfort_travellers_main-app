import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/ticket_repository.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

