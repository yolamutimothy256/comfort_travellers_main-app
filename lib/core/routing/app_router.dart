import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/profile_setup_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/tickets/presentation/pages/tickets_list_page.dart';
import '../../features/tickets/presentation/pages/ticket_detail_page.dart';
import '../../features/tickets/presentation/pages/issue_ticket_page.dart';
import '../../features/tickets/presentation/pages/payment_page.dart';
import '../../features/tickets/presentation/pages/book_ticket_page.dart';
import '../../features/tracking/presentation/pages/driver_tracking_page.dart';
import '../../features/tracking/presentation/pages/passenger_tracking_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../core/models/user_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userModelAsync = ref.watch(currentUserModelProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final userModel = userModelAsync.valueOrNull;
      final userRole = userModel?.role;

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // If authenticated and on login/signup page
      if (isAuthenticated && isLoggingIn) {
        // Check if user needs to complete profile
        if (userModel != null && 
            (userModel.displayName == null || userModel.displayName!.isEmpty)) {
          return '/profile-setup';
        }
        return '/home';
      }

      // Redirect new users to profile setup if display name is missing
      if (isAuthenticated && 
          userModel != null && 
          state.matchedLocation != '/profile-setup' &&
          (userModel.displayName == null || userModel.displayName!.isEmpty)) {
        return '/profile-setup';
      }

      // Role-based route guards
      if (isAuthenticated && userModel != null) {
        final location = state.matchedLocation;
        
        // Admin-only routes
        if (location.startsWith('/admin') && userRole != UserRole.admin) {
          return '/home'; // Redirect non-admins away from admin routes
        }
        
        // Agent/Admin-only routes (staff routes)
        if (location.startsWith('/agent') && 
            userRole != UserRole.agent && 
            userRole != UserRole.admin) {
          return '/home'; // Redirect customers away from agent routes
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/tickets',
        name: 'tickets',
        builder: (context, state) => const TicketsListPage(),
      ),
      GoRoute(
        path: '/tickets/:id',
        name: 'ticket-detail',
        builder: (context, state) {
          final ticketId = state.pathParameters['id']!;
          return TicketDetailPage(ticketId: ticketId);
        },
      ),
      // Payment route
      GoRoute(
        path: '/pay',
        name: 'payment',
        builder: (context, state) {
          final routeId = state.uri.queryParameters['routeId']!;
          final tripId = state.uri.queryParameters['tripId']!;
          final seat = int.parse(state.uri.queryParameters['seat']!);
          return PaymentPage(
            routeId: routeId,
            tripId: tripId,
            seatNumber: seat,
          );
        },
      ),
      // Customer booking route
      GoRoute(
        path: '/book-ticket',
        name: 'book-ticket',
        builder: (context, state) => const BookTicketPage(),
      ),
      // Agent/Admin routes for ticket issuance
      GoRoute(
        path: '/agent/issue-ticket',
        name: 'issue-ticket',
        builder: (context, state) {
          return const IssueTicketPage();
        },
      ),
      // Driver tracking route
      GoRoute(
        path: '/driver/tracking/:vehicleId',
        name: 'driver-tracking',
        builder: (context, state) {
          final vehicleId = state.pathParameters['vehicleId']!;
          final tripId = state.uri.queryParameters['tripId'];
          final routeId = state.uri.queryParameters['routeId'];
          return DriverTrackingPage(
            vehicleId: vehicleId,
            tripId: tripId,
            routeId: routeId,
          );
        },
      ),
      // Passenger tracking route
      GoRoute(
        path: '/track/:tripId',
        name: 'track-bus',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          final ticketId = state.uri.queryParameters['ticketId'];
          return PassengerTrackingPage(
            tripId: tripId,
            ticketId: ticketId,
          );
        },
      ),
      // Admin-only routes
      GoRoute(
        path: '/admin/analytics',
        name: 'analytics',
        builder: (context, state) {
          // TODO: Create AnalyticsPage
          return Scaffold(
            appBar: AppBar(title: const Text('Analytics')),
            body: const Center(child: Text('Analytics dashboard coming soon')),
          );
        },
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin-users',
        builder: (context, state) {
          // TODO: Create UsersManagementPage
          return Scaffold(
            appBar: AppBar(title: const Text('User Management')),
            body: const Center(child: Text('User management coming soon')),
          );
        },
      ),
    ],
  );
});

