import 'package:booking_cinema/features/showtimes/data/showtime_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final base = DateTime(2026, 1, 1, 18);
  test('detects overlap and allows touching intervals', () {
    expect(
      showtimesOverlap(
        base,
        base.add(const Duration(hours: 2)),
        base.add(const Duration(hours: 1)),
        base.add(const Duration(hours: 3)),
      ),
      isTrue,
    );
    expect(
      showtimesOverlap(
        base,
        base.add(const Duration(hours: 2)),
        base.add(const Duration(hours: 2)),
        base.add(const Duration(hours: 4)),
      ),
      isFalse,
    );
    expect(
      showtimesOverlap(
        base,
        base.add(const Duration(hours: 2)),
        base.subtract(const Duration(hours: 1)),
        base,
      ),
      isFalse,
    );
  });
}
