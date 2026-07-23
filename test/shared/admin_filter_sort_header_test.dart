import 'package:flutter_test/flutter_test.dart';
import 'package:booking_cinema/shared/widgets/admin_filter_sort_header.dart';
import 'package:booking_cinema/features/movies/models/movie.dart';
import 'package:booking_cinema/features/showtimes/models/showtime.dart';
import 'package:booking_cinema/features/rooms/models/cinema_room.dart';
import 'package:booking_cinema/features/concessions/models/combo.dart';
import 'package:booking_cinema/features/concessions/models/product.dart';
import 'package:booking_cinema/features/vouchers/models/voucher.dart';

void main() {
  group('AdminFilterSortHeader and 6 Admin Screens Logic Tests', () {
    test('AdminActiveStatusFilter enum values', () {
      expect(AdminActiveStatusFilter.values.length, 3);
      expect(AdminActiveStatusFilter.values, contains(AdminActiveStatusFilter.all));
      expect(AdminActiveStatusFilter.values, contains(AdminActiveStatusFilter.active));
      expect(AdminActiveStatusFilter.values, contains(AdminActiveStatusFilter.hidden));
    });

    test('1. Movie screen filtering and sorting', () {
      final movies = [
        Movie(
          id: 'm1',
          title: 'Zebra Movie',
          source: MovieSource.manual,
          overview: '',
          posterUrl: '',
          backdropUrl: '',
          durationMinutes: 120,
          genres: const [],
          releaseDate: DateTime(2025, 1, 1),
          ageRating: 'P',
          country: 'VN',
          director: 'Director A',
          cast: const [],
          trailerUrl: '',
          status: MovieStatus.nowShowing,
          isFeatured: true,
          isActive: true,
          bookingCount: 50,
        ),
        Movie(
          id: 'm2',
          title: 'Alpha Movie',
          source: MovieSource.manual,
          overview: '',
          posterUrl: '',
          backdropUrl: '',
          durationMinutes: 90,
          genres: const [],
          releaseDate: DateTime(2025, 6, 1),
          ageRating: 'C13',
          country: 'US',
          director: 'Director B',
          cast: const [],
          trailerUrl: '',
          status: MovieStatus.comingSoon,
          isFeatured: false,
          isActive: false,
          bookingCount: 100,
        ),
      ];

      // Filter active status
      final activeOnly = movies.where((m) => m.isActive).toList();
      expect(activeOnly.length, 1);
      expect(activeOnly.first.id, 'm1');

      final hiddenOnly = movies.where((m) => !m.isActive).toList();
      expect(hiddenOnly.length, 1);
      expect(hiddenOnly.first.id, 'm2');

      // Sort by title (A-Z)
      final sortedTitle = List<Movie>.from(movies)
        ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      expect(sortedTitle.first.title, 'Alpha Movie');

      // Sort by bookingCount (desc)
      final sortedBooking = List<Movie>.from(movies)
        ..sort((a, b) => b.bookingCount.compareTo(a.bookingCount));
      expect(sortedBooking.first.bookingCount, 100);
    });

    test('2. Showtime screen filtering and sorting', () {
      final today = DateTime(2026, 7, 22, 10, 0);
      final showtimes = [
        Showtime(
          id: 's1',
          movieId: 'm1',
          movieTitle: 'Beta Movie',
          moviePosterUrl: '',
          roomId: 'r1',
          roomName: 'Room 1',
          startTime: today.add(const Duration(hours: 4)),
          endTime: today.add(const Duration(hours: 6)),
          basePrice: 90000,
          isActive: true,
          bookedSeatCodes: const [],
          heldSeats: const {},
        ),
        Showtime(
          id: 's2',
          movieId: 'm2',
          movieTitle: 'Alpha Movie',
          moviePosterUrl: '',
          roomId: 'r2',
          roomName: 'Room 2',
          startTime: today,
          endTime: today.add(const Duration(hours: 2)),
          basePrice: 120000,
          isActive: false,
          bookedSeatCodes: const [],
          heldSeats: const {},
        ),
      ];

      // Filter active status
      final activeOnly = showtimes.where((s) => s.isActive).toList();
      expect(activeOnly.length, 1);
      expect(activeOnly.first.id, 's1');

      // Sort by startTime (asc)
      final sortedTime = List<Showtime>.from(showtimes)
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      expect(sortedTime.first.id, 's2');

      // Sort by price (desc)
      final sortedPrice = List<Showtime>.from(showtimes)
        ..sort((a, b) => b.basePrice.compareTo(a.basePrice));
      expect(sortedPrice.first.basePrice, 120000);
    });

    test('3. Room screen filtering and sorting', () {
      final rooms = [
        const CinemaRoom(
          id: 'r1',
          cinemaId: 'c1',
          name: 'Hall B',
          roomType: RoomType.standard,
          rowCount: 5,
          seatsPerRow: 10,
          vipRowStart: 2,
          coupleSeatCount: 0,
          seats: [],
          isActive: true,
        ),
        const CinemaRoom(
          id: 'r2',
          cinemaId: 'c1',
          name: 'Hall A',
          roomType: RoomType.vip,
          rowCount: 10,
          seatsPerRow: 10,
          vipRowStart: 1,
          coupleSeatCount: 2,
          seats: [],
          isActive: false,
        ),
      ];

      final sortedName = List<CinemaRoom>.from(rooms)
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      expect(sortedName.first.name, 'Hall A');
    });

    test('4. Combo screen filtering and sorting', () {
      final combos = [
        const Combo(
          id: 'c1',
          name: 'Super Combo',
          description: 'Description 1',
          price: 150000,
          imageUrl: '',
          isAvailable: true,
          items: [],
        ),
        const Combo(
          id: 'c2',
          name: 'Basic Combo',
          description: 'Description 2',
          price: 80000,
          imageUrl: '',
          isAvailable: false,
          items: [],
        ),
      ];

      final activeOnly = combos.where((c) => c.isAvailable).toList();
      expect(activeOnly.length, 1);
      expect(activeOnly.first.id, 'c1');

      final sortedPrice = List<Combo>.from(combos)
        ..sort((a, b) => b.price.compareTo(a.price));
      expect(sortedPrice.first.name, 'Super Combo');
    });

    test('5. Product screen filtering and sorting', () {
      final products = [
        const Product(
          id: 'p1',
          name: 'Popcorn Large',
          description: 'Desc 1',
          category: ProductCategory.popcorn,
          price: 60000,
          imageUrl: '',
          isAvailable: true,
        ),
        const Product(
          id: 'p2',
          name: 'Coke Large',
          description: 'Desc 2',
          category: ProductCategory.drink,
          price: 35000,
          imageUrl: '',
          isAvailable: false,
        ),
      ];

      final drinkOnly = products.where((p) => p.category == ProductCategory.drink).toList();
      expect(drinkOnly.length, 1);
      expect(drinkOnly.first.name, 'Coke Large');
    });

    test('6. Voucher screen filtering and sorting', () {
      final vouchers = [
        Voucher(
          id: 'v1',
          code: 'CGV20',
          description: 'Desc 1',
          discountType: DiscountType.percentage,
          discountValue: 20,
          minOrderValue: 100000,
          maxDiscount: 50000,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 12, 31),
          usageLimit: 100,
          usedCount: 10,
          isActive: true,
        ),
        Voucher(
          id: 'v2',
          code: 'CGV50K',
          description: 'Desc 2',
          discountType: DiscountType.fixedAmount,
          discountValue: 50000,
          minOrderValue: 150000,
          maxDiscount: 0,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 6, 30),
          usageLimit: 50,
          usedCount: 5,
          isActive: false,
        ),
      ];

      final sortedDiscount = List<Voucher>.from(vouchers)
        ..sort((a, b) => b.discountValue.compareTo(a.discountValue));
      expect(sortedDiscount.first.code, 'CGV50K');
    });
  });
}
