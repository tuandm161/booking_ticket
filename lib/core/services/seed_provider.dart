import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_providers.dart';
import 'seed_service.dart';

final seedServiceProvider = Provider<SeedService>(
  (ref) => SeedService(ref.watch(firestoreProvider)),
);
