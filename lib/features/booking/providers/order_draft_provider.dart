import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_draft.dart';

final orderDraftProvider = NotifierProvider<OrderDraftController, OrderDraft?>(
  OrderDraftController.new,
);

class OrderDraftController extends Notifier<OrderDraft?> {
  @override
  OrderDraft? build() => null;
  void setDraft(OrderDraft draft) => state = draft;
  void update(OrderDraft Function(OrderDraft current) transform) {
    if (state != null) state = transform(state!);
  }

  void clear() => state = null;
}
