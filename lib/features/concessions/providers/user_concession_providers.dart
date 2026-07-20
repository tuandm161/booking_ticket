import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/combo.dart';
import '../models/product.dart';
import 'combo_providers.dart';
import 'product_providers.dart';

final userProductsProvider = StreamProvider<List<Product>>(
  (ref) => ref
      .watch(productRepositoryProvider)
      .watchProducts(includeUnavailable: false),
);
final userCombosProvider = StreamProvider<List<Combo>>(
  (ref) =>
      ref.watch(comboRepositoryProvider).watchCombos(includeUnavailable: false),
);
