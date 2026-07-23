# Analysis Report: CGV Cinema Ticket Booking Data Seeding & Hanoi Expansion Analysis

## Executive Summary
This report presents an in-depth, read-only architectural investigation of the `booking_ticket` Flutter application to support Milestone 2 (Data & Seeding Upgrade - R1 & R3). The investigation focused on `lib/core/services/seed_service.dart`, domain models located across `lib/features/*/models/`, food/beverage product seed data, image URLs, and cinema cluster location modeling for the upcoming Hanoi expansion.

---

## 1. Codebase & Data Architecture Overview

The project uses a feature-first directory layout under `lib/features/` with shared utilities and core services in `lib/core/`:

- **Seed Service**: `lib/core/services/seed_service.dart` handles initial Firestore database population via `seedAllSampleData()`.
- **Domain Models**:
  - `Cinema` (`lib/features/cinemas/models/cinema.dart`): Represents a cinema cluster. Already includes `id`, `name`, `address`, `city`, `imageUrl`, `isActive`.
  - `CinemaRoom` & `CinemaSeat` (`lib/features/rooms/models/cinema_room.dart`): Represents a room/hall within a cinema. Includes `id`, `cinemaId`, `cinemaName`, `name`, `roomType` (`standard`, `vip`, `threeD`), seating configuration (`rowCount`, `seatsPerRow`, `vipRowStart`, `coupleSeatCount`), and seat list (`seats`).
  - `Product` (`lib/features/concessions/models/product.dart`): Individual concession item with `id`, `name`, `category` (`popcorn`, `drink`, `snack`), `description`, `imageUrl`, `price`, `isAvailable`.
  - `Combo` (`lib/features/concessions/models/combo.dart`): Product bundle with `id`, `name`, `description`, `imageUrl`, `price`, `items` (`List<ComboItem>`), `isAvailable`.
  - `Movie` (`lib/features/movies/models/movie.dart`): Movie details including TMDB metadata and status (`nowShowing`, `comingSoon`, `stopped`).
  - `Showtime` (`lib/features/showtimes/models/showtime.dart`): Movie screening schedule associated with a `cinemaId`, `cinemaName`, `roomId`, `roomName`, `movieId`, `startTime`, `endTime`, `basePrice`.

---

## 2. Concessions & Food Item Seed Data Analysis (R1)

### Observations:
- In `lib/core/services/seed_service.dart`:
  - `seedDefaultProducts()` seeds **9 concession items** (3 popcorns, 4 drinks, 2 snacks). All 9 items currently have `imageUrl: ''` (empty string).
  - `seedDefaultCombos()` seeds **6 combos** (Combo Solo, Combo Couple, Combo Family, Combo Premium Gold Class, Combo Student, Combo Party). All 6 combos currently have `imageUrl: ''` (empty string).

### Impact:
- When rendering concessions in `UserConcessionScreen` (`lib/features/concessions/presentation/screens/user_concession_screen.dart`) and admin lists (`AdminProductListScreen`, `AdminComboListScreen`), empty image URLs lead to blank boxes or fallback placeholders, missing high-quality visual representation.

### Recommendation / Solution:
Update `seed_service.dart` with high-resolution, reliable Unsplash CDN image URLs for all products and combos:

| Item Name | Category / Type | Proposed High-Res Image URL |
|---|---|---|
| Bắp rang bơ Caramel (L) | Product / Popcorn | `https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=800` |
| Bắp rang bơ Phô mai (L) | Product / Popcorn | `https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?w=800` |
| Bắp rang bơ Truyền thống (M) | Product / Popcorn | `https://images.unsplash.com/photo-1512149177596-f817c7ef5d4c?w=800` |
| Coca Cola (L) | Product / Drink | `https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800` |
| Pepsi Zero (L) | Product / Drink | `https://images.unsplash.com/photo-1554866585-cd94860890b7?w=800` |
| Trà Sữa Đào CGV (L) | Product / Drink | `https://images.unsplash.com/photo-1558857563-b371033873b8?w=800` |
| Nước suối Dasani | Product / Drink | `https://images.unsplash.com/photo-1548839140-29a749e1bc4e?w=800` |
| Nachos Phô Mai Thượng Hạng | Product / Snack | `https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?w=800` |
| Xúc Xích Đức Nướng | Product / Snack | `https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=800` |
| Combo Solo My CGV | Combo | `https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=800` |
| Combo Couple CGV | Combo | `https://images.unsplash.com/photo-1512149177596-f817c7ef5d4c?w=800` |
| Combo Family Ngon Mê | Combo | `https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?w=800` |
| Combo Premium Gold Class | Combo | `https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=800` |
| Combo Học Sinh Sinh Viên | Combo | `https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8?w=800` |
| Combo Party Bạn Bè | Combo | `https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=800` |

---

## 3. Cinema Cluster Location Modeling & Hanoi Expansion (R1 & R3)

### Observations on Cinema Model:
- `Cinema` in `lib/features/cinemas/models/cinema.dart` already contains `final String city;`.
- Firestore converter `fromMap` reads `map['city'] as String? ?? ''`, and `toMap` writes `'city': city`.
- Thus, **NO database model changes or schema migrations are required** for `Cinema`.

### Current Cinema Seed Data:
- `seedDefaultCinemas()` currently defines 4 clusters, all located in `TP.HCM`:
  1. `CGV Vincom Đồng Khởi` (`city: 'TP.HCM'`)
  2. `CGV Hùng Vương Plaza` (`city: 'TP.HCM'`)
  3. `CGV Landmark 81` (`city: 'TP.HCM'`)
  4. `CGV Crescent Mall` (`city: 'TP.HCM'`)

### 4 New Hanoi CGV Clusters Specification:
To satisfy requirement R1, the following 4 Hanoi clusters must be added to `seedDefaultCinemas()`:

1. **CGV Vincom Bà Triệu**:
   - `name`: `'CGV Vincom Bà Triệu'`
   - `address`: `'Tầng 6 Vincom Center, 191 Bà Triệu, Q. Hai Bà Trưng, Hà Nội'`
   - `city`: `'Hà Nội'`
   - `imageUrl`: `'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800'`
   - `isActive`: `true`

2. **CGV Royal City**:
   - `name`: `'CGV Royal City'`
   - `address`: `'Tầng B2 - Vincom Mega Mall Royal City, 72A Nguyễn Trãi, Q. Thanh Xuân, Hà Nội'`
   - `city`: `'Hà Nội'`
   - `imageUrl`: `'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800'`
   - `isActive`: `true`

3. **CGV Lotte Center Hà Nội**:
   - `name`: `'CGV Lotte Center Hà Nội'`
   - `address`: `'Tầng 5 Lotte Center, 54 Liễu Giai, Q. Ba Đình, Hà Nội'`
   - `city`: `'Hà Nội'`
   - `imageUrl`: `'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800'`
   - `isActive`: `true`

4. **CGV Aeon Mall Hà Đông**:
   - `name`: `'CGV Aeon Mall Hà Đông'`
   - `address`: `'Tầng 3 Aeon Mall Hà Đông, Phường Dương Nội, Q. Hà Đông, Hà Nội'`
   - `city`: `'Hà Nội'`
   - `imageUrl`: `'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=800'`
   - `isActive`: `true`

---

## 4. Room & Showtime Seeding Architecture for Hanoi Clusters

### Room Seeding Mechanism (`seedDefaultRooms()`):
1. `seedDefaultRooms()` retrieves all cinema documents from Firestore and maps `cinemaName -> (cinemaId, cinemaName)`.
2. It instantiates `CinemaRoom` objects using `generateSeats(...)` for row/seat maps.
3. Adding Hanoi cinemas requires defining 8 new rooms (2 rooms per Hanoi cinema):
   - `Phòng 11 (IMAX Bà Triệu)` (`RoomType.threeD`) -> CGV Vincom Bà Triệu
   - `Phòng 12 (Gold Class Bà Triệu)` (`RoomType.vip`) -> CGV Vincom Bà Triệu
   - `Phòng 13 (4DX Royal)` (`RoomType.threeD`) -> CGV Royal City
   - `Phòng 14 (Standard Royal)` (`RoomType.standard`) -> CGV Royal City
   - `Phòng 15 (Lotte Lounge)` (`RoomType.vip`) -> CGV Lotte Center Hà Nội
   - `Phòng 16 (Standard Lotte)` (`RoomType.standard`) -> CGV Lotte Center Hà Nội
   - `Phòng 17 (Starium Hà Đông)` (`RoomType.threeD`) -> CGV Aeon Mall Hà Đông
   - `Phòng 18 (CGV Kids Hà Đông)` (`RoomType.standard`) -> CGV Aeon Mall Hà Đông

### Showtime Seeding Mechanism (`seedDefaultShowtimes()`):
- `seedDefaultShowtimes()` fetches all `nowShowing` movies and all rooms in Firestore (`roomsSnap`).
- It iterates across 5 days and all movies, distributing showtimes across available rooms.
- Because `seedDefaultShowtimes()` queries all rooms dynamically from `FirestorePaths.rooms`, adding rooms for Hanoi cinemas will automatically generate showtimes for the new Hanoi cinemas without requiring any structural changes to the showtime loop logic.

---

## 5. UI City Filter Integration Analysis (R3 Support)

- In `UserShowtimesScreen` (`lib/features/showtimes/presentation/screens/user_showtimes_screen.dart`):
  - Currently, `activeCinemasProvider` returns all active cinemas.
  - The cinema chip selector shows `'Tất cả cụm rạp'` followed by all active cinemas.
  - To support city filtering:
    - Add a City Selector (e.g. `ChoiceChip` for `'Tất cả thành phố'`, `'TP.HCM'`, `'Hà Nội'`).
    - Filter the visible cinema list by `cinema.city == _selectedCity`.
    - Automatically reset `_selectedCinemaId` when the selected city changes.

---

## 6. Actionable Implementation Steps for Milestone 2

1. **Update `lib/core/services/seed_service.dart`**:
   - In `seedDefaultCinemas()`: Add 4 Hanoi CGV definitions.
   - In `seedDefaultRooms()`: Add 8 rooms corresponding to the 4 Hanoi cinemas.
   - In `seedDefaultProducts()`: Replace empty `imageUrl: ''` strings with curated Unsplash URLs for all 9 products.
   - In `seedDefaultCombos()`: Replace empty `imageUrl: ''` strings with curated Unsplash URLs for all 6 combos.
2. **Re-seed Data**:
   - Call `SeedService.seedAllSampleData(force: true)` to re-populate Firestore collections with complete images and Hanoi clusters.
