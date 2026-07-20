import 'package:booking_cinema/features/showtimes/data/showtime_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('showtime draft copyWith preserves fields', () {
    final start = DateTime(2026, 1, 1, 18);
    final draft = ShowtimeDraft(
      movieId: 'movie',
      roomId: 'room',
      startTime: start,
      basePrice: 80000,
    );
    final changed = draft.copyWith(basePrice: 90000, isActive: false);
    expect(changed.movieId, 'movie');
    expect(changed.roomId, 'room');
    expect(changed.startTime, start);
    expect(changed.basePrice, 90000);
    expect(changed.isActive, isFalse);
  });
}
