import 'package:flutter_test/flutter_test.dart';
import 'package:booking_cinema/features/cinemas/models/cinema.dart';
import 'package:booking_cinema/features/showtimes/models/showtime.dart';

void main() {
  group('UserShowtimesScreen filtering logic tests', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 14, 0);

    final cinemas = <Cinema>[
      const Cinema(
        id: 'c1',
        name: 'CGV Vincom HCM',
        address: 'District 1',
        city: 'TP.HCM',
        imageUrl: '',
        isActive: true,
      ),
      const Cinema(
        id: 'c2',
        name: 'CGV Vincom HN',
        address: 'Ba Dinh',
        city: 'Hà Nội',
        imageUrl: '',
        isActive: true,
      ),
    ];

    final showtimes = <Showtime>[
      Showtime(
        id: 's1',
        movieId: 'm1',
        movieTitle: 'Movie A',
        moviePosterUrl: '',
        cinemaId: 'c1',
        cinemaName: 'CGV Vincom HCM',
        roomId: 'r1',
        roomName: 'Room 1',
        startTime: today,
        endTime: today.add(const Duration(hours: 2)),
        basePrice: 100000,
        bookedSeatCodes: const [],
        heldSeats: const {},
        isActive: true,
      ),
      Showtime(
        id: 's2',
        movieId: 'm1',
        movieTitle: 'Movie A',
        moviePosterUrl: '',
        cinemaId: 'c2',
        cinemaName: 'CGV Vincom HN',
        roomId: 'r2',
        roomName: 'Room 2',
        startTime: today,
        endTime: today.add(const Duration(hours: 2)),
        basePrice: 100000,
        bookedSeatCodes: const [],
        heldSeats: const {},
        isActive: true,
      ),
    ];

    test('Filters cinemas by selected city correctly', () {
      List<Cinema> filterCinemas(List<Cinema> input, String selectedCity) {
        if (selectedCity == 'Tất cả thành phố') return input;
        return input.where((c) => c.city == selectedCity).toList();
      }

      expect(filterCinemas(cinemas, 'Tất cả thành phố').length, 2);
      expect(filterCinemas(cinemas, 'TP.HCM').length, 1);
      expect(filterCinemas(cinemas, 'TP.HCM').first.id, 'c1');
      expect(filterCinemas(cinemas, 'Hà Nội').length, 1);
      expect(filterCinemas(cinemas, 'Hà Nội').first.id, 'c2');
    });

    test('Filters showtimes by selected city and cinema correctly', () {
      List<Showtime> filterShowtimes(
        List<Showtime> items,
        List<Cinema> cinemaList,
        DateTime selectedDay,
        String selectedCity,
        String? selectedCinemaId,
      ) {
        final cinemaMap = {for (final c in cinemaList) c.id: c};
        return items.where((s) {
          final matchesDay = s.startTime.year == selectedDay.year &&
              s.startTime.month == selectedDay.month &&
              s.startTime.day == selectedDay.day;
          final cinema = cinemaMap[s.cinemaId];
          final matchesCity = selectedCity == 'Tất cả thành phố' ||
              cinema?.city == selectedCity;
          final matchesCinema =
              selectedCinemaId == null || s.cinemaId == selectedCinemaId;
          return matchesDay && matchesCity && matchesCinema;
        }).toList();
      }

      // All cities
      expect(filterShowtimes(showtimes, cinemas, today, 'Tất cả thành phố', null).length, 2);
      // TP.HCM
      expect(filterShowtimes(showtimes, cinemas, today, 'TP.HCM', null).length, 1);
      expect(filterShowtimes(showtimes, cinemas, today, 'TP.HCM', null).first.id, 's1');
      // Hà Nội
      expect(filterShowtimes(showtimes, cinemas, today, 'Hà Nội', null).length, 1);
      expect(filterShowtimes(showtimes, cinemas, today, 'Hà Nội', null).first.id, 's2');
      // Specific cinema c1 in TP.HCM
      expect(filterShowtimes(showtimes, cinemas, today, 'TP.HCM', 'c1').length, 1);
      // Specific cinema c2 in TP.HCM (mismatch)
      expect(filterShowtimes(showtimes, cinemas, today, 'TP.HCM', 'c2').length, 0);
    });
  });
}
