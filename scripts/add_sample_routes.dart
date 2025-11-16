import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/core/config/firebase_options.dart';

/// Script to add sample routes to Firestore
/// Run this with: dart run scripts/add_sample_routes.dart
Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  // Route 1: Kampala to Lira
  final route1 = {
    'name': 'Kampala to Lira',
    'origin': 'Kampala',
    'destination': 'Lira',
    'basePrice': 40000.0,
    'estimatedDurationMinutes': 240, // 4 hours
    'stops': ['Kampala', 'Lira'],
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
  };

  // Route 2: Kampala to Lira to Apac
  final route2 = {
    'name': 'Kampala to Lira to Apac',
    'origin': 'Kampala',
    'destination': 'Apac',
    'basePrice': 50000.0,
    'estimatedDurationMinutes': 300, // 5 hours
    'stops': ['Kampala', 'Lira', 'Apac'],
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
  };

  try {
    // Add Route 1
    final route1Ref = await firestore.collection('routes').add(route1);
    print('✅ Added Route 1: Kampala to Lira (ID: ${route1Ref.id})');

    // Add Route 2
    final route2Ref = await firestore.collection('routes').add(route2);
    print('✅ Added Route 2: Kampala to Lira to Apac (ID: ${route2Ref.id})');

    print('\n✅ Successfully added both routes to Firestore!');
    print('You can now use the booking feature.');
  } catch (e) {
    print('❌ Error adding routes: $e');
  }
}

