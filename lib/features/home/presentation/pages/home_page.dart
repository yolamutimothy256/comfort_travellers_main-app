import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/models/user_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signOut();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelAsync = ref.watch(currentUserModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comfort Busses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context, ref),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: userModelAsync.when(
        data: (userModel) {
          if (userModel == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Loading user data...'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Refresh the provider
                      ref.invalidate(currentUserModelProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          backgroundImage: userModel.photoUrl != null
                              ? NetworkImage(userModel.photoUrl!)
                              : null,
                          child: userModel.photoUrl == null
                              ? Text(
                                  userModel.displayName?.isNotEmpty == true
                                      ? userModel.displayName![0].toUpperCase()
                                      : userModel.email[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${userModel.displayName ?? userModel.email.split('@')[0]}!',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userModel.email,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(
                                  userModel.role.name.toUpperCase(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Quick actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _ActionCard(
                      icon: Icons.confirmation_number,
                      title: 'My Tickets',
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => context.push('/tickets'),
                    ),
                    if (userModel.role == UserRole.customer)
                      _ActionCard(
                        icon: Icons.add_shopping_cart,
                        title: 'Book Ticket',
                        color: Colors.blue,
                        onTap: () => context.push('/book-ticket'),
                      ),
                    _ActionCard(
                      icon: Icons.qr_code_scanner,
                      title: 'Scan QR',
                      color: Colors.green,
                      onTap: () {
                        // TODO: Navigate to QR scanner
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('QR Scanner coming soon'),
                          ),
                        );
                      },
                    ),
                    if (userModel.role != UserRole.customer)
                      _ActionCard(
                        icon: Icons.add_card,
                        title: 'Issue Ticket',
                        color: Colors.blue,
                        onTap: () => context.push('/agent/issue-ticket'),
                      ),
                    if (userModel.role == UserRole.admin)
                      _ActionCard(
                        icon: Icons.analytics,
                        title: 'Analytics',
                        color: Colors.purple,
                        onTap: () => context.push('/admin/analytics'),
                      ),
                    if (userModel.role == UserRole.admin)
                      _ActionCard(
                        icon: Icons.people,
                        title: 'Users',
                        color: Colors.orange,
                        onTap: () => context.push('/admin/users'),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading user data: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

