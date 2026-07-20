import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_providers.dart';
import '../data/combo_repository.dart';
import '../models/combo.dart';

final comboRepositoryProvider = Provider<ComboRepository>(
  (ref) => ComboRepository(ref.watch(firestoreProvider)),
);
final combosProvider = StreamProvider<List<Combo>>(
  (ref) => ref.watch(comboRepositoryProvider).watchCombos(),
);
