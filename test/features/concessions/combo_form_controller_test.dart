import 'package:booking_cinema/features/concessions/data/combo_repository.dart';
import 'package:booking_cinema/features/concessions/models/combo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('combo draft keeps item quantities', () {
    const items = [ComboItem(productId: 'p1', productName: 'Bắp', quantity: 2)];
    const draft = ComboDraft(
      name: 'Combo',
      description: '',
      imageUrl: 'https://example.com/c.jpg',
      price: 100000,
      items: items,
    );
    expect(draft.items.single.quantity, 2);
    expect(draft.price, 100000);
  });
}
