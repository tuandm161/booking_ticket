# Handoff Report: CGV Cinema Ticket Booking Data & Hanoi Expansion Analysis

## 1. Observation

### Code & Data Files Inspected:
- `lib/core/services/seed_service.dart` (1106 lines)
- `lib/features/cinemas/models/cinema.dart` (92 lines)
- `lib/features/rooms/models/cinema_room.dart` (120 lines)
- `lib/features/concessions/models/product.dart` (77 lines)
- `lib/features/concessions/models/combo.dart` (92 lines)
- `lib/features/movies/models/movie.dart` (117 lines)
- `lib/features/showtimes/models/showtime.dart` (144 lines)
- `lib/features/vouchers/models/voucher.dart` (95 lines)
- `lib/features/showtimes/presentation/screens/user_showtimes_screen.dart` (338 lines)
- `lib/features/cinemas/data/cinema_repository.dart` (57 lines)

### Direct Evidence & Observations:
1. **Products & Combos Image URLs**:
   - `lib/core/services/seed_service.dart:693-764`: All 9 products (`Bắp rang bơ Caramel (L)`, `Bắp rang bơ Phô mai (L)`, `Bắp rang bơ Truyền thống (M)`, `Coca Cola (L)`, `Pepsi Zero (L)`, `Trà Sữa Đào CGV (L)`, `Nước suối Dasani`, `Nachos Phô Mai Thượng Hạng`, `Xúc Xích Đức Nướng`) are initialized with `imageUrl: ''`.
   - `lib/core/services/seed_service.dart:820-903`: All 6 combos (`Combo Solo My CGV`, `Combo Couple CGV`, `Combo Family Ngon Mê`, `Combo Premium Gold Class`, `Combo Học Sinh Sinh Viên`, `Combo Party Bạn Bè`) are initialized with `imageUrl: ''`.

2. **Cinema Data Model & Location Modeling**:
   - `lib/features/cinemas/models/cinema.dart:18`: `final String city;` is already present on `Cinema`.
   - `lib/features/cinemas/models/cinema.dart:28`: `fromMap` parses `city: map['city'] as String? ?? ''`.
   - `lib/features/cinemas/models/cinema.dart:38`: `toMap` serializes `'city': city`.
   - No database schema migration or model property addition is required for `Cinema`.

3. **Current Cinema Seed Data**:
   - `lib/core/services/seed_service.dart:50-83`: `seedDefaultCinemas()` seeds 4 cinemas, all in `city: 'TP.HCM'` (`CGV Vincom Đồng Khởi`, `CGV Hùng Vương Plaza`, `CGV Landmark 81`, `CGV Crescent Mall`).
   - 0 Hanoi cinemas currently exist in seed data.

4. **Rooms & Showtimes Seeding Mechanism**:
   - `lib/core/services/seed_service.dart:96-160`: `seedDefaultRooms()` seeds 10 rooms across the 4 TP.HCM cinemas.
   - `lib/core/services/seed_service.dart:1008-1104`: `seedDefaultShowtimes()` queries all active rooms from `FirestorePaths.rooms` and generates showtimes across 5 days for `nowShowing` movies.

5. **Test Suite Status**:
   - Ran `flutter test` via terminal task.
   - Command result: 32/32 tests passed (100% pass rate).

---

## 2. Logic Chain

1. **Popcorn/Beverage Image Upgrade (R1)**:
   - *Observation*: Products and Combos in `seed_service.dart` have `imageUrl: ''`.
   - *Reasoning*: Adding Unsplash image URLs for all 9 products and 6 combos directly in `seed_service.dart` ensures Firestore is populated with valid URLs when seeding.
   - *Result*: UI screens will display sharp high-res images for all concession items without requiring model or UI widget structure changes.

2. **Hanoi Cinema Expansion (R1)**:
   - *Observation*: `Cinema` model already has `city` field. `seedDefaultCinemas()` only contains 4 TP.HCM cinemas.
   - *Reasoning*: Adding 4 new Hanoi CGV clusters (`CGV Vincom Bà Triệu`, `CGV Royal City`, `CGV Lotte Center Hà Nội`, `CGV Aeon Mall Hà Đông`) with `city: 'Hà Nội'` to `seedDefaultCinemas()` directly expands the cinema dataset.
   - *Result*: Adding 8 new rooms (2 per Hanoi cinema) in `seedDefaultRooms()` causes `seedDefaultShowtimes()` to automatically generate showtimes for Hanoi cinemas as well.

3. **User Showtime City Filter Support (R3)**:
   - *Observation*: `user_showtimes_screen.dart` loads active cinemas via `activeCinemasProvider`.
   - *Reasoning*: Since `Cinema` has `city`, adding a City selector (`ChoiceChip` for `Tất cả thành phố`, `TP.HCM`, `Hà Nội`) filters `activeCinemasProvider` results by `city`.
   - *Result*: Users selecting "Hà Nội" will see only Hanoi cinemas and showtimes.

---

## 3. Caveats

- `seed_service.dart` checks `(await collection.limit(1).get()).docs.isNotEmpty` before seeding each collection unless `force: true` is passed to `seedAllSampleData(force: true)`.
- When updating `seed_service.dart`, existing Firestore databases must be cleared or seeded with `force: true` so the new Hanoi cinemas and product image URLs overwrite old empty data.

---

## 4. Conclusion

- **Model Compatibility**: All existing models (`Cinema`, `CinemaRoom`, `Product`, `Combo`, `Showtime`, `Voucher`) are 100% compatible with Hanoi expansion and food image URL additions.
- **Seeding Plan**:
  1. Update `seed_service.dart`: Add 15 Unsplash URLs for 9 products & 6 combos.
  2. Add 4 Hanoi CGV clusters to `seedDefaultCinemas()`.
  3. Add 8 Hanoi rooms (2 per cinema) to `seedDefaultRooms()`.
  4. `seedDefaultShowtimes()` requires no structural modifications — it will automatically pick up the 8 Hanoi rooms and populate 5-day showtimes.
- **Test Integrity**: Test suite is passing 32/32 tests.

---

## 5. Verification Method

To verify findings independently:

1. **Verify Test Suite**:
   ```bash
   cd d:\prm\Project\booking_ticket
   flutter test
   ```
   *Expected result*: 32/32 tests pass.

2. **Inspect Model Code**:
   ```bash
   view_file lib/features/cinemas/models/cinema.dart
   ```
   *Verify*: Line 18 contains `final String city;`.

3. **Inspect Seed Code**:
   ```bash
   view_file lib/core/services/seed_service.dart
   ```
   *Verify*: Lines 693-764 and 820-903 contain `imageUrl: ''`.
