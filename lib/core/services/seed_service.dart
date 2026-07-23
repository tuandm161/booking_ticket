import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_paths.dart';
import '../utils/seat_generator.dart';
import '../../features/cinemas/models/cinema.dart';
import '../../features/rooms/models/cinema_room.dart';
import '../../features/movies/models/movie.dart';
import '../../features/showtimes/models/showtime.dart';
import '../../features/concessions/models/product.dart';
import '../../features/concessions/models/combo.dart';
import '../../features/vouchers/models/voucher.dart';

class SeedResult {
  const SeedResult({required this.createdCount, required this.skipped});
  final int createdCount;
  final bool skipped;
}

class SeedService {
  const SeedService(this._firestore);
  final FirebaseFirestore _firestore;

  // ── Master Seed ─────────────────────────────────────────────────────────────
  Future<Map<String, SeedResult>> seedAllSampleData({bool force = false}) async {
    final cinemasRes = await seedDefaultCinemas(force: force);
    final roomsRes = await seedDefaultRooms(force: force);
    final moviesRes = await seedDefaultMovies(force: force);
    final productsRes = await seedDefaultProducts(force: force);
    final combosRes = await seedDefaultCombos(force: force);
    final vouchersRes = await seedDefaultVouchers(force: force);
    final showtimesRes = await seedDefaultShowtimes(force: force);

    return {
      'cinemas': cinemasRes,
      'rooms': roomsRes,
      'movies': moviesRes,
      'products': productsRes,
      'combos': combosRes,
      'vouchers': vouchersRes,
      'showtimes': showtimesRes,
    };
  }

  // ── 1. Cinemas (8 Cụm Rạp: 4 TP.HCM, 4 Hà Nội) ──────────────────────────────
  Future<SeedResult> seedDefaultCinemas({bool force = false}) async {
    final collection = _firestore.collection(FirestorePaths.cinemas);
    if (!force && (await collection.limit(1).get()).docs.isNotEmpty) {
      return const SeedResult(createdCount: 0, skipped: true);
    }

    final definitions = [
      const Cinema(
        name: 'CGV Vincom Đồng Khởi',
        address: '72 Lê Thánh Tôn & 45A Lý Tự Trọng, Q. 1',
        city: 'TP.HCM',
        imageUrl:
            'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
        isActive: true,
      ),
      const Cinema(
        name: 'CGV Hùng Vương Plaza',
        address: '126 Hùng Vương, Q. 5',
        city: 'TP.HCM',
        imageUrl:
            'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800',
        isActive: true,
      ),
      const Cinema(
        name: 'CGV Landmark 81',
        address: '720A Điện Biên Phủ, Q. Bình Thạnh',
        city: 'TP.HCM',
        imageUrl:
            'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800',
        isActive: true,
      ),
      const Cinema(
        name: 'CGV Crescent Mall',
        address: '101 Tôn Dật Tiên, Phú Mỹ Hưng, Q. 7',
        city: 'TP.HCM',
        imageUrl:
            'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=800',
        isActive: true,
      ),
      const Cinema(
        name: 'CGV Vincom Bà Triệu',
        address: '191 Bà Triệu, Q. Hai Bà Trưng, Hà Nội',
        city: 'Hà Nội',
        imageUrl:
            'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800',
        isActive: true,
      ),
      const Cinema(
        name: 'CGV Royal City',
        address: '72A Nguyễn Trãi, Q. Thanh Xuân, Hà Nội',
        city: 'Hà Nội',
        imageUrl:
            'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
        isActive: true,
      ),
      const Cinema(
        name: 'CGV Lotte Center Hà Nội',
        address: '54 Liễu Giai, Q. Ba Đình, Hà Nội',
        city: 'Hà Nội',
        imageUrl:
            'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800',
        isActive: true,
      ),
      const Cinema(
        name: 'CGV Aeon Mall Hà Đông',
        address: 'KĐT Dương Nội, Q. Hà Đông, Hà Nội',
        city: 'Hà Nội',
        imageUrl:
            'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=800',
        isActive: true,
      ),
    ];

    final now = DateTime.now();
    final batch = _firestore.batch();
    for (final c in definitions) {
      final ref = collection.doc();
      batch.set(ref, c.copyWith(createdAt: now, updatedAt: now).toMap());
    }
    await batch.commit();
    return SeedResult(createdCount: definitions.length, skipped: false);
  }

  // ── 2. Rooms (18 Phòng Chiếu: 10 TP.HCM, 8 Hà Nội) ──────────────────────────
  Future<SeedResult> seedDefaultRooms({bool force = false}) async {
    final collection = _firestore.collection(FirestorePaths.rooms);
    if (!force && (await collection.limit(1).get()).docs.isNotEmpty) {
      return const SeedResult(createdCount: 0, skipped: true);
    }

    var cinemasSnap =
        await _firestore.collection(FirestorePaths.cinemas).get();
    if (cinemasSnap.docs.isEmpty) {
      await seedDefaultCinemas();
      cinemasSnap = await _firestore.collection(FirestorePaths.cinemas).get();
    }

    final cinemaMap = {
      for (final doc in cinemasSnap.docs)
        (doc.data()['name'] as String? ?? ''): (doc.id, doc.data()['name'] as String),
    };

    final cVincom = cinemaMap['CGV Vincom Đồng Khởi'] ?? ('', 'CGV Vincom Đồng Khởi');
    final cHungVuong = cinemaMap['CGV Hùng Vương Plaza'] ?? ('', 'CGV Hùng Vương Plaza');
    final cLandmark = cinemaMap['CGV Landmark 81'] ?? ('', 'CGV Landmark 81');
    final cCrescent = cinemaMap['CGV Crescent Mall'] ?? ('', 'CGV Crescent Mall');
    final cBaTrieu = cinemaMap['CGV Vincom Bà Triệu'] ?? ('', 'CGV Vincom Bà Triệu');
    final cRoyal = cinemaMap['CGV Royal City'] ?? ('', 'CGV Royal City');
    final cLotteHN = cinemaMap['CGV Lotte Center Hà Nội'] ?? ('', 'CGV Lotte Center Hà Nội');
    final cAeonHD = cinemaMap['CGV Aeon Mall Hà Đông'] ?? ('', 'CGV Aeon Mall Hà Đông');

    final definitions = [
      ('Phòng 1 (IMAX)', RoomType.threeD, 10, 12, 6, 4, cVincom),
      ('Phòng 2 (Gold Class)', RoomType.vip, 6, 8, 3, 2, cVincom),
      ('Phòng 3 (4DX)', RoomType.threeD, 8, 10, 5, 4, cHungVuong),
      ('Phòng 4 (ScreenX 270°)', RoomType.standard, 8, 10, 5, 4, cHungVuong),
      ('Phòng 5 (L\'Amour Giường Nằm)', RoomType.vip, 5, 6, 3, 2, cLandmark),
      ('Phòng 6 (Starium Laser)', RoomType.threeD, 10, 14, 6, 4, cLandmark),
      ('Phòng 7 (Standard Premium)', RoomType.standard, 8, 10, 5, 4, cCrescent),
      ('Phòng 8 (Standard Compact)', RoomType.standard, 7, 10, 4, 4, cCrescent),
      ('Phòng 9 (CGV Kids)', RoomType.standard, 6, 8, 4, 2, cVincom),
      ('Phòng 10 (CGV VIP Lounge)', RoomType.vip, 6, 8, 4, 2, cHungVuong),
      ('Phòng 11 (IMAX Bà Triệu)', RoomType.threeD, 10, 12, 6, 4, cBaTrieu),
      ('Phòng 12 (Gold Class Bà Triệu)', RoomType.vip, 6, 8, 3, 2, cBaTrieu),
      ('Phòng 13 (4DX Royal)', RoomType.threeD, 8, 10, 5, 4, cRoyal),
      ('Phòng 14 (Standard Royal)', RoomType.standard, 8, 10, 5, 4, cRoyal),
      ('Phòng 15 (Lotte Lounge)', RoomType.vip, 6, 8, 3, 2, cLotteHN),
      ('Phòng 16 (Standard Lotte)', RoomType.standard, 8, 10, 5, 4, cLotteHN),
      ('Phòng 17 (Starium Hà Đông)', RoomType.threeD, 10, 14, 6, 4, cAeonHD),
      ('Phòng 18 (Cinema 2 Hà Đông)', RoomType.standard, 8, 10, 5, 4, cAeonHD),
    ];

    final now = DateTime.now();
    final batch = _firestore.batch();
    for (final item in definitions) {
      final ref = collection.doc();
      final seats = generateSeats(
        rowCount: item.$3,
        seatsPerRow: item.$4,
        vipRowStart: item.$5,
        coupleSeatCount: item.$6,
      );
      final room = CinemaRoom(
        name: item.$1,
        cinemaId: item.$7.$1,
        cinemaName: item.$7.$2,
        roomType: item.$2,
        rowCount: item.$3,
        seatsPerRow: item.$4,
        vipRowStart: item.$5,
        coupleSeatCount: item.$6,
        seats: seats,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      batch.set(ref, room.toMap());
    }
    await batch.commit();
    return SeedResult(createdCount: definitions.length, skipped: false);
  }

  // ── 3. Movies (20 Phim TMDB thực tế) ────────────────────────────────────────
  Future<SeedResult> seedDefaultMovies({bool force = false}) async {
    final collection = _firestore.collection(FirestorePaths.movies);
    if (!force && (await collection.limit(1).get()).docs.isNotEmpty) {
      return const SeedResult(createdCount: 0, skipped: true);
    }

    final now = DateTime.now();
    final movies = [
      // ── Đang chiếu (14 phim) ────────────────────────────────────────────────
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 533535,
        title: 'Deadpool & Wolverine',
        overview:
            'Wolverine đang phục hồi sau chấn thương thì tình cờ gặp Deadpool siêu quậy. Cả hai kết hợp để đánh bại kẻ thù chung.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/8cdWjvZ211M1l92r2BxUsRKVj2p.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/yDHYTfA3R0jFYba16jBB1ef8oIt.jpg',
        durationMinutes: 128,
        genres: ['Hành động', 'Hài', 'Khoa học viễn tưởng'],
        releaseDate: DateTime(2024, 7, 26),
        ageRating: 'T18',
        country: 'Mỹ',
        director: 'Shawn Levy',
        cast: ['Ryan Reynolds', 'Hugh Jackman', 'Emma Corrin'],
        trailerUrl: 'https://www.youtube.com/watch?v=73_1biulkYk',
        status: MovieStatus.nowShowing,
        isFeatured: true,
        isActive: true,
        bookingCount: 1540,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 693134,
        title: 'Dune: Hành Tinh Cát - Phần Hai',
        overview:
            'Paul Atreides tái hợp với Chani và người Fremen trong khi tìm cách trả thù những kẻ đã hủy hoại gia đình anh.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/1pdfLPoLMag8StutMwPoKVjufGZ.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/xOMo8BRK7PfcJv9JCnx7s52SIYs.jpg',
        durationMinutes: 166,
        genres: ['Khoa học viễn tưởng', 'Phiêu lưu', 'Hành động'],
        releaseDate: DateTime(2024, 3, 1),
        ageRating: 'T16',
        country: 'Mỹ',
        director: 'Denis Villeneuve',
        cast: ['Timothée Chalamet', 'Zendaya', 'Rebecca Ferguson'],
        trailerUrl: 'https://www.youtube.com/watch?v=Way9Dexny3w',
        status: MovieStatus.nowShowing,
        isFeatured: true,
        isActive: true,
        bookingCount: 1280,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 1022789,
        title: 'Những Mảnh Ghép Cảm Xúc 2',
        overview:
            'Riley bước vào tuổi dậy thì với những cảm xúc mới xuất hiện như Lo Âu, Ghen Tị, Xấu Hổ.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpPBZohHQ9vOTVv8.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/stKGOm8UyhuLPR92pNKx268StqV.jpg',
        durationMinutes: 96,
        genres: ['Hoạt hình', 'Gia đình', 'Hài'],
        releaseDate: DateTime(2024, 6, 14),
        ageRating: 'P',
        country: 'Mỹ',
        director: 'Kelsey Mann',
        cast: ['Amy Poehler', 'Maya Hawke', 'Kensington Tallman'],
        trailerUrl: 'https://www.youtube.com/watch?v=LEjhY15eCx0',
        status: MovieStatus.nowShowing,
        isFeatured: true,
        isActive: true,
        bookingCount: 2100,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 823464,
        title: 'Godzilla x Kong: Đế Chế Mới',
        overview:
            'Godzilla và Kong phải đối đầu với một mối đe dọa khổng lồ chưa từng được khám phá ẩn sâu trong Trái Đất.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/z1yfcZudx8U2LzK0fL65tT1nU6T.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/4woS07qxmchb1vqGlT39hlw9vo1.jpg',
        durationMinutes: 115,
        genres: ['Hành động', 'Khoa học viễn tưởng'],
        releaseDate: DateTime(2024, 3, 29),
        ageRating: 'T13',
        country: 'Mỹ',
        director: 'Adam Wingard',
        cast: ['Rebecca Hall', 'Brian Tyree Henry', 'Dan Stevens'],
        trailerUrl: 'https://www.youtube.com/watch?v=lV1OOlGwExM',
        status: MovieStatus.nowShowing,
        isFeatured: false,
        isActive: true,
        bookingCount: 980,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 872585,
        title: 'Oppenheimer',
        overview:
            'Câu chuyện về nhà vật lý J. Robert Oppenheimer và vai trò của ông trong việc phát triển bom nguyên tử.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/rLb2cwFcvazhGEA8TjuT3TUtzPh.jpg',
        durationMinutes: 180,
        genres: ['Lịch sử', 'Chính kịch'],
        releaseDate: DateTime(2023, 7, 21),
        ageRating: 'T18',
        country: 'Mỹ',
        director: 'Christopher Nolan',
        cast: ['Cillian Murphy', 'Emily Blunt', 'Matt Damon', 'Robert Downey Jr.'],
        trailerUrl: 'https://www.youtube.com/watch?v=uYPbbksJxIg',
        status: MovieStatus.nowShowing,
        isFeatured: false,
        isActive: true,
        bookingCount: 1750,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 569094,
        title: 'Spider-Man: Du Hành Vũ Trụ Nhện',
        overview:
            'Miles Morales du hành qua đa vũ trụ nhện và xung đột với Người Nhện 2099 về cách bảo vệ đa vũ trụ.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/8Vt6mWEReuy4Of61Lnj5Xj7sFm8.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/4HodYYKEIsGOdinkGi2USt6uBh0.jpg',
        durationMinutes: 140,
        genres: ['Hoạt hình', 'Hành động', 'Khoa học viễn tưởng'],
        releaseDate: DateTime(2023, 6, 2),
        ageRating: 'T13',
        country: 'Mỹ',
        director: 'Joaquim Dos Santos',
        cast: ['Shameik Moore', 'Hailee Steinfeld', 'Oscar Isaac'],
        trailerUrl: 'https://www.youtube.com/watch?v=cqGjhVJWtEg',
        status: MovieStatus.nowShowing,
        isFeatured: false,
        isActive: true,
        bookingCount: 890,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 1011985,
        title: 'Kung Fu Panda 4',
        overview:
            'Po được chọn làm Thủ lĩnh Tinh thần của Thung lũng Bình Yên và phải tìm người nối ngôi Thần Long Đại Hiệp.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/kDp1vUBnMpe82wL3vYy9f5xLODU.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/1XddXPXGiVGESjILpNPrYZPWhvo.jpg',
        durationMinutes: 94,
        genres: ['Hoạt hình', 'Hành động', 'Hài'],
        releaseDate: DateTime(2024, 3, 8),
        ageRating: 'P',
        country: 'Mỹ',
        director: 'Mike Mitchell',
        cast: ['Jack Black', 'Awkwafina', 'Viola Davis'],
        trailerUrl: 'https://www.youtube.com/watch?v=_inKs4eeHiI',
        status: MovieStatus.nowShowing,
        isFeatured: false,
        isActive: true,
        bookingCount: 760,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 519182,
        title: 'Kẻ Trộm Mặt Trăng 4',
        overview:
            'Gru và gia đình đối mặt với kẻ thù mới Maxime Le Mal và bạn gái hắn Valentina.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/w9kR8qbmQ01HSuB1FcZ4p9d3m.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/lgkPzcOSnfeRMsUd9GjCjfsKHfl.jpg',
        durationMinutes: 95,
        genres: ['Hoạt hình', 'Hài', 'Gia đình'],
        releaseDate: DateTime(2024, 7, 3),
        ageRating: 'P',
        country: 'Mỹ',
        director: 'Chris Renaud',
        cast: ['Steve Carell', 'Kristen Wiig', 'Will Ferrell'],
        trailerUrl: 'https://www.youtube.com/watch?v=qQlr9-rF320',
        status: MovieStatus.nowShowing,
        isFeatured: false,
        isActive: true,
        bookingCount: 1120,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 912649,
        title: 'Venom: Kèo Cuối',
        overview:
            'Eddie và Venom đang chạy trốn. Bị săn đuổi bởi cả hai thế giới, chiếc lưới đang khép lại quanh họ.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/vGXd0h22cVJk5uP5y4yGkK12k.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/3V4kSt8aL9DODhZa7RUtvMwo8ut.jpg',
        durationMinutes: 110,
        genres: ['Hành động', 'Khoa học viễn tưởng'],
        releaseDate: DateTime(2024, 10, 25),
        ageRating: 'T16',
        country: 'Mỹ',
        director: 'Kelly Marcel',
        cast: ['Tom Hardy', 'Chiwetel Ejiofor', 'Juno Temple'],
        trailerUrl: 'https://www.youtube.com/watch?v=__2bjWbetsA',
        status: MovieStatus.nowShowing,
        isFeatured: false,
        isActive: true,
        bookingCount: 650,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 945961,
        title: 'Alien: Romulus',
        overview:
            'Một nhóm bạn trẻ trên một hành tinh xa xôi đối mặt với dạng sống đáng sợ nhất vũ trụ.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/b33nnKl1v24jICSDYhG47Y1Y35Z.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/9SSEUrSqhljBMzRe4aBTh17rUdF.jpg',
        durationMinutes: 119,
        genres: ['Kinh dị', 'Khoa học viễn tưởng'],
        releaseDate: DateTime(2024, 8, 16),
        ageRating: 'T18',
        country: 'Mỹ',
        director: 'Fede Álvarez',
        cast: ['Cailee Spaeny', 'David Jonsson', 'Archie Renaux'],
        trailerUrl: 'https://www.youtube.com/watch?v=x0XDEhP4MhE',
        status: MovieStatus.nowShowing,
        isFeatured: false,
        isActive: true,
        bookingCount: 540,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 1241982,
        title: 'Moana 2',
        overview:
            'Moana nhận được cuộc gọi bất ngờ từ những tổ tiên dẫn đường và bắt đầu chuyến hành trình đến đại dương xa xôi.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/aIS2eL4vL43214oM90321M3.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/v9L4vL43214oM90321M3.jpg',
        durationMinutes: 100,
        genres: ['Hoạt hình', 'Phiêu lưu', 'Gia đình'],
        releaseDate: DateTime(2024, 11, 27),
        ageRating: 'P',
        country: 'Mỹ',
        director: 'David Derrick Jr.',
        cast: ['Auliʻi Cravalho', 'Dwayne Johnson'],
        trailerUrl: 'https://www.youtube.com/watch?v=hDZ7y8RP5HE',
        status: MovieStatus.nowShowing,
        isFeatured: false,
        isActive: true,
        bookingCount: 430,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 558449,
        title: 'Võ Sĩ Giác Đấu II',
        overview:
            'Nhiều năm sau cái chết của Maximus, Lucius phải bước vào Đấu trường La Mã để giành lại vinh quang.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/2cxhvwyEwRlysAmRH4iodkvo0Y5.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/Eu1A2B3C4D5E6F7G8H9I0J1K2L.jpg',
        durationMinutes: 148,
        genres: ['Hành động', 'Chính kịch', 'Lịch sử'],
        releaseDate: DateTime(2024, 11, 22),
        ageRating: 'T18',
        country: 'Mỹ',
        director: 'Ridley Scott',
        cast: ['Paul Mescal', 'Pedro Pascal', 'Denzel Washington'],
        trailerUrl: 'https://www.youtube.com/watch?v=4rgIUyaL5F8',
        status: MovieStatus.nowShowing,
        isFeatured: false,
        isActive: true,
        bookingCount: 620,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 653346,
        title: 'Hành Tinh Khỉ: Vương Quốc Mới',
        overview:
            'Nhiều thế hệ sau triều đại của Caesar, một chú khỉ trẻ bắt đầu hành trình quyết định tương lai cho cả loài khỉ và con người.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/gKkl37FiDMaintain123.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/fqv8vL43214oM90321M3.jpg',
        durationMinutes: 145,
        genres: ['Khoa học viễn tưởng', 'Hành động'],
        releaseDate: DateTime(2024, 5, 10),
        ageRating: 'T13',
        country: 'Mỹ',
        director: 'Wes Ball',
        cast: ['Owen Teague', 'Freya Allan', 'Kevin Durand'],
        trailerUrl: 'https://www.youtube.com/watch?v=XtFI7SNtVpY',
        status: MovieStatus.nowShowing,
        isFeatured: false,
        isActive: true,
        bookingCount: 410,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 762441,
        title: 'Vùng Đất Câm Lặng: Ngày Một',
        overview:
            'Trải nghiệm ngày đầu tiên thế giới rơi vào câm lặng khi những sinh vật tàn bạo hạ cánh xuống Trái Đất.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/yrpGj123456789.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/p987654321.jpg',
        durationMinutes: 99,
        genres: ['Kinh dị', 'Khoa học viễn tưởng'],
        releaseDate: DateTime(2024, 6, 28),
        ageRating: 'T16',
        country: 'Mỹ',
        director: 'Michael Sarnoski',
        cast: ['Lupita Nyong\'o', 'Joseph Quinn', 'Djimon Hounsou'],
        trailerUrl: 'https://www.youtube.com/watch?v=YPY7J-flzE8',
        status: MovieStatus.nowShowing,
        isFeatured: false,
        isActive: true,
        bookingCount: 380,
        createdAt: now,
        updatedAt: now,
      ),

      // ── Sắp chiếu (6 phim) ────────────────────────────────────────────────
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 83533,
        title: 'Avatar 3: Lửa Và Tro Tàn',
        overview:
            'Jake Sully và Neytiri khám phá các bộ tộc mới trên hành tinh Pandora bao gồm Tộc Tro Tàn tàn bạo.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/avatar3poster.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/avatar3bg.jpg',
        durationMinutes: 190,
        genres: ['Khoa học viễn tưởng', 'Hành động', 'Phiêu lưu'],
        releaseDate: DateTime(2025, 12, 19),
        ageRating: 'T13',
        country: 'Mỹ',
        director: 'James Cameron',
        cast: ['Sam Worthington', 'Zoe Saldaña', 'Sigourney Weaver'],
        trailerUrl: 'https://www.youtube.com/watch?v=d9MyW72ELq0',
        status: MovieStatus.comingSoon,
        isFeatured: false,
        isActive: true,
        bookingCount: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 1022796,
        title: 'Phi Vụ Hạt Dẻ 2 (Zootopia 2)',
        overview:
            'Judy Hopps và Nick Wilde tiếp tục phá giải những vụ án bí ẩn mới trong thành phố động vật Zootopia.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/zootopia2.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/zootopia2bg.jpg',
        durationMinutes: 105,
        genres: ['Hoạt hình', 'Hài', 'Phiêu lưu'],
        releaseDate: DateTime(2025, 11, 26),
        ageRating: 'P',
        country: 'Mỹ',
        director: 'Byron Howard',
        cast: ['Ginnifer Goodwin', 'Jason Bateman'],
        trailerUrl: '',
        status: MovieStatus.comingSoon,
        isFeatured: false,
        isActive: true,
        bookingCount: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 762509,
        title: 'Mufasa: Vua Sư Tử',
        overview:
            'Hành trình trở thành vị vua huyền thoại của Mufasa qua lời kể của Rafiki cho kiệt tác vương quốc sư tử.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/mufasaposter.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/mufasabg.jpg',
        durationMinutes: 118,
        genres: ['Hoạt hình', 'Chính kịch', 'Gia đình'],
        releaseDate: DateTime(2024, 12, 20),
        ageRating: 'P',
        country: 'Mỹ',
        director: 'Barry Jenkins',
        cast: ['Aaron Pierre', 'Kelvin Harrison Jr.', 'Seth Rogen'],
        trailerUrl: 'https://www.youtube.com/watch?v=o17MF9vnabg',
        status: MovieStatus.comingSoon,
        isFeatured: false,
        isActive: true,
        bookingCount: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 822119,
        title: 'Captain America: Thế Giới Mới Phân Dải',
        overview:
            'Sam Wilson chính thức tiếp quản danh hiệu Captain America và đối mặt với âm mưu toàn cầu mới.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/cap4poster.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/cap4bg.jpg',
        durationMinutes: 130,
        genres: ['Hành động', 'Khoa học viễn tưởng'],
        releaseDate: DateTime(2025, 2, 14),
        ageRating: 'T13',
        country: 'Mỹ',
        director: 'Julius Onah',
        cast: ['Anthony Mackie', 'Harrison Ford', 'Danny Ramirez'],
        trailerUrl: 'https://www.youtube.com/watch?v=1pHDWnXmKMY',
        status: MovieStatus.comingSoon,
        isFeatured: false,
        isActive: true,
        bookingCount: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 402431,
        title: 'Wicked: Phù Thủy Xứ Oz',
        overview:
            'Câu chuyện chưa từng kể về tình bạn phi thường giữa Elphaba và Glinda trước khi trở thành Phù Thủy Phương Tây.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/wickedposter.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/wickedbg.jpg',
        durationMinutes: 160,
        genres: ['Nhạc kịch', 'Kỳ ảo', 'Chính kịch'],
        releaseDate: DateTime(2024, 11, 22),
        ageRating: 'P',
        country: 'Mỹ',
        director: 'Jon M. Chu',
        cast: ['Cynthia Erivo', 'Ariana Grande', 'Jonathan Bailey'],
        trailerUrl: 'https://www.youtube.com/watch?v=6COmYeL942A',
        status: MovieStatus.comingSoon,
        isFeatured: false,
        isActive: true,
        bookingCount: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        source: MovieSource.tmdb,
        tmdbId: 1061474,
        title: 'Superman (2025)',
        overview:
            'Tái khởi động vũ trụ DC với hành trình dung hòa giữa di sản Krypton và sự nuôi dưỡng ở loài người của Clark Kent.',
        posterUrl:
            'https://image.tmdb.org/t/p/w500/superman2025.jpg',
        backdropUrl:
            'https://image.tmdb.org/t/p/w1280/superman2025bg.jpg',
        durationMinutes: 140,
        genres: ['Hành động', 'Khoa học viễn tưởng'],
        releaseDate: DateTime(2025, 7, 11),
        ageRating: 'T13',
        country: 'Mỹ',
        director: 'James Gunn',
        cast: ['David Corenswet', 'Rachel Brosnahan', 'Nicholas Hoult'],
        trailerUrl: '',
        status: MovieStatus.comingSoon,
        isFeatured: false,
        isActive: true,
        bookingCount: 0,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final batch = _firestore.batch();
    for (final m in movies) {
      batch.set(collection.doc(), m.toMap());
    }
    await batch.commit();
    return SeedResult(createdCount: movies.length, skipped: false);
  }

  // ── 4. Products (9 Sản phẩm) ────────────────────────────────────────────────
  Future<SeedResult> seedDefaultProducts({bool force = false}) async {
    final collection = _firestore.collection(FirestorePaths.products);
    if (!force && (await collection.limit(1).get()).docs.isNotEmpty) {
      return const SeedResult(createdCount: 0, skipped: true);
    }

    final now = DateTime.now();
    final definitions = [
      const Product(
        name: 'Bắp rang bơ Caramel (L)',
        category: ProductCategory.popcorn,
        description: 'Bắp rang bơ phủ phô mai & caramel thơm nức size lớn.',
        imageUrl:
            'https://images.unsplash.com/photo-1608188309313-cbef53c98a66?w=800&q=80',
        price: 55000,
        isAvailable: true,
      ),
      const Product(
        name: 'Bắp rang bơ Phô mai (L)',
        category: ProductCategory.popcorn,
        description: 'Bắp rang vị phô mai đậm đà giòn rụm.',
        imageUrl:
            'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?w=800&q=80',
        price: 55000,
        isAvailable: true,
      ),
      const Product(
        name: 'Bắp rang bơ Truyền thống (M)',
        category: ProductCategory.popcorn,
        description: 'Bắp bơ truyền thống thơm ngon ngọt nhẹ.',
        imageUrl:
            'https://images.unsplash.com/photo-1606923829579-0cb981a83e2e?w=800&q=80',
        price: 45000,
        isAvailable: true,
      ),
      const Product(
        name: 'Coca Cola (L)',
        category: ProductCategory.drink,
        description: 'Nước ngọt Coca Cola 32oz ướp lạnh.',
        imageUrl:
            'https://images.unsplash.com/photo-1629203432180-71e9f9a9b875?w=800&q=80',
        price: 35000,
        isAvailable: true,
      ),
      const Product(
        name: 'Pepsi Zero (L)',
        category: ProductCategory.drink,
        description: 'Nước ngọt Pepsi 0 calo tươi mát.',
        imageUrl:
            'https://images.unsplash.com/photo-1679917151037-4b8e3c2c5b29?w=800&q=80',
        price: 35000,
        isAvailable: true,
      ),
      const Product(
        name: 'Trà Sữa Đào CGV (L)',
        category: ProductCategory.drink,
        description: 'Trà sữa đào trân trùng dai giòn đặc trưng CGV.',
        imageUrl:
            'https://images.unsplash.com/photo-1558857563-b371033873b8?w=800&q=80',
        price: 49000,
        isAvailable: true,
      ),
      const Product(
        name: 'Nước suối Dasani',
        category: ProductCategory.drink,
        description: 'Nước tinh khiết 500ml.',
        imageUrl:
            'https://images.unsplash.com/photo-1599560240122-d2d23e4ffad1?w=800&q=80',
        price: 20000,
        isAvailable: true,
      ),
      const Product(
        name: 'Nachos Phô Mai Thượng Hạng',
        category: ProductCategory.snack,
        description: 'Bánh nachos giòn kèm kem phô mai dẻo cay nhẹ.',
        imageUrl:
            'https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?w=800&q=80',
        price: 65000,
        isAvailable: true,
      ),
      const Product(
        name: 'Xúc Xích Đức Nướng',
        category: ProductCategory.snack,
        description: 'Xúc xích Đức nướng xốt mù tạt vàng thơm lừng.',
        imageUrl:
            'https://images.unsplash.com/photo-1619740455993-9e612b1af08a?w=800&q=80',
        price: 45000,
        isAvailable: true,
      ),
    ];

    final batch = _firestore.batch();
    for (final p in definitions) {
      batch.set(collection.doc(), p.copyWith(createdAt: now, updatedAt: now).toMap());
    }
    await batch.commit();
    return SeedResult(createdCount: definitions.length, skipped: false);
  }

  // ── 5. Combos (6 Combos) ────────────────────────────────────────────────────
  Future<SeedResult> seedDefaultCombos({bool force = false}) async {
    final collection = _firestore.collection(FirestorePaths.combos);
    if (!force && (await collection.limit(1).get()).docs.isNotEmpty) {
      return const SeedResult(createdCount: 0, skipped: true);
    }

    var productSnap = await _firestore.collection(FirestorePaths.products).get();
    if (productSnap.docs.isEmpty) {
      await seedDefaultProducts();
      productSnap = await _firestore.collection(FirestorePaths.products).get();
    }

    final byName = {
      for (final doc in productSnap.docs)
        (doc.data()['name'] as String? ?? ''): doc,
    };

    final popcornL = byName['Bắp rang bơ Caramel (L)'];
    final popcornCheese = byName['Bắp rang bơ Phô mai (L)'];
    final popcornM = byName['Bắp rang bơ Truyền thống (M)'];
    final cola = byName['Coca Cola (L)'];
    final milkTea = byName['Trà Sữa Đào CGV (L)'];
    final water = byName['Nước suối Dasani'];
    final nachos = byName['Nachos Phô Mai Thượng Hạng'];
    final sausage = byName['Xúc Xích Đức Nướng'];

    final now = DateTime.now();
    Combo make(
      String name,
      String description,
      int price,
      List<ComboItem> items,
      String imageUrl,
    ) =>
        Combo(
          name: name,
          description: description,
          imageUrl: imageUrl,
          price: price,
          items: items,
          isAvailable: true,
          createdAt: now,
          updatedAt: now,
        );

    final definitions = [
      if (popcornL != null && cola != null)
        make(
          'Combo Solo My CGV',
          '1 Bắp Caramel L + 1 Coca L',
          85000,
          [
            ComboItem(
                productId: popcornL.id,
                productName: popcornL.data()['name'] as String,
                quantity: 1),
            ComboItem(
                productId: cola.id,
                productName: cola.data()['name'] as String,
                quantity: 1),
          ],
          'https://images.unsplash.com/photo-1631897642055-4f44f8e8b56a?w=800&q=80',
        ),
      if (popcornL != null && cola != null)
        make(
          'Combo Couple CGV',
          '1 Bắp Caramel L + 2 Coca L',
          115000,
          [
            ComboItem(
                productId: popcornL.id,
                productName: popcornL.data()['name'] as String,
                quantity: 1),
            ComboItem(
                productId: cola.id,
                productName: cola.data()['name'] as String,
                quantity: 2),
          ],
          'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=800&q=80',
        ),
      if (popcornL != null && cola != null && nachos != null)
        make(
          'Combo Family Ngon Mê',
          '2 Bắp Caramel L + 3 Coca L + 1 Nachos',
          195000,
          [
            ComboItem(
                productId: popcornL.id,
                productName: popcornL.data()['name'] as String,
                quantity: 2),
            ComboItem(
                productId: cola.id,
                productName: cola.data()['name'] as String,
                quantity: 3),
            ComboItem(
                productId: nachos.id,
                productName: nachos.data()['name'] as String,
                quantity: 1),
          ],
          'https://images.unsplash.com/photo-1585846416120-3a7354ed7d39?w=800&q=80',
        ),
      if (popcornCheese != null && milkTea != null && sausage != null)
        make(
          'Combo Premium Gold Class',
          '1 Bắp Phô mai L + 2 Trà Sữa Đào + 1 Xúc xích',
          175000,
          [
            ComboItem(
                productId: popcornCheese.id,
                productName: popcornCheese.data()['name'] as String,
                quantity: 1),
            ComboItem(
                productId: milkTea.id,
                productName: milkTea.data()['name'] as String,
                quantity: 2),
            ComboItem(
                productId: sausage.id,
                productName: sausage.data()['name'] as String,
                quantity: 1),
          ],
          'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=800&q=80',
        ),
      if (popcornM != null && water != null)
        make(
          'Combo Học Sinh Sinh Viên',
          '1 Bắp M + 1 Nước Suối (Ưu đãi HSSV)',
          55000,
          [
            ComboItem(
                productId: popcornM.id,
                productName: popcornM.data()['name'] as String,
                quantity: 1),
            ComboItem(
                productId: water.id,
                productName: water.data()['name'] as String,
                quantity: 1),
          ],
          'https://images.unsplash.com/photo-1571167955512-fddde3d4f99e?w=800&q=80',
        ),
      if (popcornL != null && cola != null && sausage != null)
        make(
          'Combo Party Bạn Bè',
          '2 Bắp Caramel L + 4 Coca L + 2 Xúc xích',
          245000,
          [
            ComboItem(
                productId: popcornL.id,
                productName: popcornL.data()['name'] as String,
                quantity: 2),
            ComboItem(
                productId: cola.id,
                productName: cola.data()['name'] as String,
                quantity: 4),
            ComboItem(
                productId: sausage.id,
                productName: sausage.data()['name'] as String,
                quantity: 2),
          ],
          'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=800&q=80',
        ),
    ];

    final batch = _firestore.batch();
    for (final c in definitions) {
      batch.set(collection.doc(), c.toMap());
    }
    await batch.commit();
    return SeedResult(createdCount: definitions.length, skipped: false);
  }

  // ── 6. Vouchers (5 Vouchers) ────────────────────────────────────────────────
  Future<SeedResult> seedDefaultVouchers({bool force = false}) async {
    final collection = _firestore.collection(FirestorePaths.vouchers);
    if (!force && (await collection.limit(1).get()).docs.isNotEmpty) {
      return const SeedResult(createdCount: 0, skipped: true);
    }

    final now = DateTime.now();
    final end = now.add(const Duration(days: 90));
    final definitions = [
      Voucher(
        code: 'CGVWELCOME50',
        description: 'Giảm 50.000đ cho đơn từ 150.000đ.',
        discountType: DiscountType.fixedAmount,
        discountValue: 50000,
        minOrderValue: 150000,
        maxDiscount: 50000,
        startDate: now,
        endDate: end,
        usageLimit: 500,
        usedCount: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Voucher(
        code: 'CGVMOVIE20',
        description: 'Giảm 20% tối đa 60.000đ cho đơn từ 120.000đ.',
        discountType: DiscountType.percentage,
        discountValue: 20,
        minOrderValue: 120000,
        maxDiscount: 60000,
        startDate: now,
        endDate: end,
        usageLimit: 300,
        usedCount: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Voucher(
        code: 'CGVTUESDAY30',
        description: 'Giảm 30% cho Ngày Hội Điện Ảnh Thứ 3.',
        discountType: DiscountType.percentage,
        discountValue: 30,
        minOrderValue: 100000,
        maxDiscount: 70000,
        startDate: now,
        endDate: end,
        usageLimit: 200,
        usedCount: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Voucher(
        code: 'CGVCOUPLE40',
        description: 'Giảm 40.000đ cho đơn từ 200.000đ.',
        discountType: DiscountType.fixedAmount,
        discountValue: 40000,
        minOrderValue: 200000,
        maxDiscount: 40000,
        startDate: now,
        endDate: end,
        usageLimit: 150,
        usedCount: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Voucher(
        code: 'CGVSTUDENT15',
        description: 'Giảm 15% cho học sinh sinh viên.',
        discountType: DiscountType.percentage,
        discountValue: 15,
        minOrderValue: 80000,
        maxDiscount: 30000,
        startDate: now,
        endDate: end,
        usageLimit: 400,
        usedCount: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final batch = _firestore.batch();
    for (final v in definitions) {
      batch.set(collection.doc(), v.toMap());
    }
    await batch.commit();
    return SeedResult(createdCount: definitions.length, skipped: false);
  }

  // ── 7. Showtimes (7-8 suất chiếu / ngày / phim cho 5 ngày tới) ──────────────
  Future<SeedResult> seedDefaultShowtimes({bool force = false}) async {
    final collection = _firestore.collection(FirestorePaths.showtimes);
    if (!force && (await collection.limit(1).get()).docs.isNotEmpty) {
      return const SeedResult(createdCount: 0, skipped: true);
    }

    final moviesSnap = await _firestore
        .collection(FirestorePaths.movies)
        .where('status', isEqualTo: 'nowShowing')
        .get();
    final roomsSnap = await _firestore.collection(FirestorePaths.rooms).get();

    if (moviesSnap.docs.isEmpty || roomsSnap.docs.isEmpty) {
      return const SeedResult(createdCount: 0, skipped: true);
    }

    final movies = moviesSnap.docs
        .map((d) => Movie.fromMap(d.id, d.data()))
        .toList();
    final rooms = roomsSnap.docs
        .map((d) => CinemaRoom.fromMap(d.id, d.data()))
        .toList();

    // Showtimes slots
    final slots = [
      (8, 30),
      (10, 45),
      (13, 15),
      (15, 45),
      (18, 15),
      (20, 30),
      (22, 45),
    ];

    final today = DateTime.now();
    var createdCount = 0;
    var batch = _firestore.batch();
    var batchOperations = 0;

    for (var dayOffset = 0; dayOffset < 5; dayOffset++) {
      final date = today.add(Duration(days: dayOffset));
      for (var i = 0; i < movies.length; i++) {
        final movie = movies[i];
        // Assign 2 rooms for this movie
        final room1 = rooms[i % rooms.length];
        final room2 = rooms[(i + 1) % rooms.length];

        for (var j = 0; j < slots.length; j++) {
          final slot = slots[j];
          final start = DateTime(
              date.year, date.month, date.day, slot.$1, slot.$2);
          final end = start.add(
              Duration(minutes: movie.durationMinutes + 15));
          final selectedRoom = j % 2 == 0 ? room1 : room2;

          final basePrice = selectedRoom.roomType == RoomType.vip
              ? 110000
              : (selectedRoom.roomType == RoomType.threeD ? 120000 : 90000);

          final showtime = Showtime(
            movieId: movie.id,
            movieTitle: movie.title,
            moviePosterUrl: movie.posterUrl,
            roomId: selectedRoom.id,
            roomName: selectedRoom.name,
            cinemaId: selectedRoom.cinemaId,
            cinemaName: selectedRoom.cinemaName,
            startTime: start,
            endTime: end,
            basePrice: basePrice,
            isActive: true,
            bookedSeatCodes: const [],
            heldSeats: const {},
            createdAt: today,
            updatedAt: today,
          );

          batch.set(collection.doc(), showtime.toMap());
          batchOperations++;
          createdCount++;

          if (batchOperations >= 450) {
            await batch.commit();
            batch = _firestore.batch();
            batchOperations = 0;
          }
        }
      }
    }

    if (batchOperations > 0) {
      await batch.commit();
    }

    return SeedResult(createdCount: createdCount, skipped: false);
  }
}
