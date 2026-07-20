import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/combo_repository.dart';

final comboFormControllerProvider =
    NotifierProvider<ComboFormController, ComboDraft>(ComboFormController.new);

class ComboFormController extends Notifier<ComboDraft> {
  @override
  ComboDraft build() => const ComboDraft(
    name: '',
    description: '',
    imageUrl: '',
    price: 0,
    items: [],
  );
}
